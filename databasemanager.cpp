#include "databasemanager.h"

// --- Bibliothèques pour la Base de données ---
#include <QSqlQuery>
#include <QSqlError>

// --- Bibliothèques pour le temps et le debug ---
#include <QDateTime>
#include <QDebug>
#include <QTimer>

// --- Bibliothèques pour l'image, HTTP et le JSON (MQTT) ---
#include <QJsonDocument>
#include <QJsonObject>
#include <QImage>
#include <QDir>
#include <QByteArray>
#include <QNetworkRequest>
#include <QUrl>
#include <QProcess>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent), m_lastScanTime(0)
{
    m_networkManager = new QNetworkAccessManager(this);
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::connectToDatabase(const QString &host, const QString &dbName, const QString &user, const QString &password)
{
    m_db = QSqlDatabase::addDatabase("QMARIADB");
    m_db.setHostName(host);
    m_db.setDatabaseName(dbName);
    m_db.setUserName(user);
    m_db.setPassword(password);

    if (m_db.open()) {
        return true;
    } else {
        return false;
    }
}

void DatabaseManager::handleMqttMessage(const QString &topic, const QString &message)
{
    if (!m_db.isOpen()) {
        return;
    }

    // =========================================================
    // CAS 1 & 2 : LECTURE À LA PORTE VIA TTN (Uplink)
    // =========================================================
    if (topic.endsWith("/up")) {

        QString vraiRfid = "";
        QString deviceId = "";
        QString sourceScan = "Inconnue";

        QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8());
        if (doc.isObject()) {
            QJsonObject json = doc.object();

            if (json.contains("end_device_ids")) {
                QJsonObject endDeviceObj = json["end_device_ids"].toObject();
                if (endDeviceObj.contains("device_id")) {
                    deviceId = endDeviceObj["device_id"].toString();

                    sourceScan = deviceId;
                }
            }

            if (json.contains("uplink_message")) {
                QJsonObject uplinkObj = json["uplink_message"].toObject();
                if (uplinkObj.contains("decoded_payload")) {
                    QJsonObject decodedObj = uplinkObj["decoded_payload"].toObject();
                    if (decodedObj.contains("nom_cheval")) {
                        vraiRfid = decodedObj["nom_cheval"].toString();
                    }
                }
            }
        }

        if (sourceScan == "ard-num-2") {
            if (vraiRfid == "PING") {
                return;
            } else {
                emit newTagScanned(vraiRfid);
                return;
            }
        }

        if (vraiRfid.isEmpty()) {
            return;
        }

        qint64 currentTime = QDateTime::currentMSecsSinceEpoch();
        if (vraiRfid == m_lastScannedTag && (currentTime - m_lastScanTime) < 5000) {
            return;
        }

        m_lastScannedTag = vraiRfid;
        m_lastScanTime = currentTime;
        m_lastSource = sourceScan;

        emit sendLocalMqttMessage("esp32cam/cmd", "CAPTURE");


        emit newTagScanned(vraiRfid);

        QSqlQuery query;
        query.prepare("SELECT cheval_ID, nom, peut_manger FROM cheval WHERE rfid = :rfid");
        query.bindValue(":rfid", vraiRfid);

        if (query.exec()) {
            if (query.next()) {
                int chevalID = query.value("cheval_ID").toInt();
                QString nom = query.value("nom").toString();
                bool accesAutorise = query.value("peut_manger").toBool();

                if (accesAutorise) {
                    m_lastAction = QString("Accès AUTORISÉ (%1)").arg(sourceScan);

                    if (!deviceId.isEmpty()) {
                        QString downlinkTopic = QString("v3/ecurie-active@ttn/devices/%1/down/push").arg(deviceId);
                        QString payloadTTN = R"({
                            "downlinks": [{
                                "f_port": 1,
                                "frm_payload": "T0s=",
                                "priority": "NORMAL"
                            }]
                        })";
                        emit sendMqttMessage(downlinkTopic, payloadTTN);
                    }
                    QSqlQuery updateQuery;
                    updateQuery.prepare("UPDATE cheval SET peut_manger = false WHERE rfid = :rfid");
                    updateQuery.bindValue(":rfid", vraiRfid);

                    if(updateQuery.exec()) {

                        // =========================================================
                        // 2. RÉCUPÉRATION DU RÉGIME VIA JOINTURE
                        // =========================================================
                        QSqlQuery regimeQuery;
                        regimeQuery.prepare(R"(
                            SELECT r.nourriture_nom, r.quantite_repas
                            FROM regime r
                            JOIN cheval c ON r.cheval_ID = c.cheval_ID
                            WHERE c.rfid = :rfid
                        )");
                        regimeQuery.bindValue(":rfid", vraiRfid);

                        if (regimeQuery.exec()) {
                            while (regimeQuery.next()) {
                                QString nourritureNom = regimeQuery.value("nourriture_nom").toString();

                                int quantiteGrammes = regimeQuery.value("quantite_repas").toInt();

                                double quantiteKilos = quantiteGrammes / 1000.0;

                                QSqlQuery stockQuery;
                                stockQuery.prepare("UPDATE nourriture_stock SET quantite = quantite - :qte WHERE nom = :nomNourriture");
                                stockQuery.bindValue(":qte", quantiteKilos);
                                stockQuery.bindValue(":nomNourriture", nourritureNom);
                            }

                            emit stockUpdated();

                        }
                    }
                } else {
                    m_lastAction = QString("Accès REFUSÉ (%1)").arg(sourceScan);
                }

                QSqlQuery histQuery;
                histQuery.prepare("INSERT INTO historique (cheval_ID, action, date) VALUES (:cid, :action, NOW())");
                histQuery.bindValue(":cid", chevalID);
                histQuery.bindValue(":action", m_lastAction);
                if (histQuery.exec()) {
                    emit dbUpdated();
                }

            } else {
                m_lastAction = QString("Badge Inconnu (%1)").arg(sourceScan);

                QSqlQuery histQuery;
                histQuery.prepare("INSERT INTO historique (cheval_ID, action, date) VALUES (NULL, :action, NOW())");
                histQuery.bindValue(":action", m_lastAction);
                if (histQuery.exec()) emit dbUpdated();
            }
        }
    }

    // =========================================================
    // CAS 3 : RÉCEPTION DE L'ADRESSE DE L'IMAGE VIA MQTT (Caméra ESP32)
    // =========================================================
    else if (topic == "esp32cam/image") {
        QString imageUrl = message.trimmed();

        if (imageUrl.endsWith("capture0")) {
            return;
        }

        if (!imageUrl.startsWith("http")) {
            return;
        }

        QString rfid = m_lastScannedTag;

        emit sendLocalMqttMessage("esp32cam/image", "");

        QNetworkRequest request((QUrl(imageUrl)));
        QNetworkReply *reply = m_networkManager->get(request);

        connect(reply, &QNetworkReply::finished, this, [this, reply, rfid]() {
            if (reply->error() == QNetworkReply::NoError) {
                QByteArray imageData = reply->readAll();
                QImage image;

                if (image.loadFromData(imageData)) {
                    QDir dir("/home/pi/photos_chevaux");
                    if (!dir.exists()) dir.mkpath(".");

                    QString timestamp = QString::number(QDateTime::currentSecsSinceEpoch());
                    QString filePath = QString("%1/%2_%3.jpg").arg(dir.absolutePath(), rfid, timestamp);

                    if (image.save(filePath, "JPEG")) {

                        QSqlQuery queryCheval;
                        queryCheval.prepare("SELECT cheval_ID FROM cheval WHERE rfid = :rfid");
                        queryCheval.bindValue(":rfid", rfid);

                        if (queryCheval.exec() && queryCheval.next()) {
                            int chevalID = queryCheval.value(0).toInt();

                            QSqlQuery queryUpdate;
                            queryUpdate.prepare("UPDATE historique SET photo_path = :path WHERE cheval_ID = :cid ORDER BY hist_id DESC LIMIT 1");
                            queryUpdate.bindValue(":path", filePath);
                            queryUpdate.bindValue(":cid", chevalID);

                            if (queryUpdate.exec()) {
                                emit dbUpdated();
                            }
                        } else {
                            QSqlQuery queryUpdate;
                            queryUpdate.prepare("UPDATE historique SET photo_path = :path WHERE cheval_ID IS NULL ORDER BY hist_id DESC LIMIT 1");
                            queryUpdate.bindValue(":path", filePath);
                            if(queryUpdate.exec()) emit dbUpdated();
                        }
                    }
                }
            }

            reply->deleteLater();
        });
    }
}
void DatabaseManager::testMorganSimul(const QString &rfidMorgan)
{

    QString ttnTopic = "v3/ecurie-active@ttn/devices/simul_m5stack/up";
    QString ttnMessage = R"({
        "uplink_message": {
            "decoded_payload": {
                "nom_cheval": "%1"
            }
        }
    })";
    ttnMessage = ttnMessage.arg(rfidMorgan);
    this->handleMqttMessage(ttnTopic, ttnMessage);

    QTimer::singleShot(1000, this, [this]() {
        emit sendLocalMqttMessage("esp32cam/cmd", "CAPTURE");
    });
}

void DatabaseManager::resetAllFoodAccess()
{
    if (!m_db.isOpen()) return;

    QSqlQuery query;
    if (query.exec("UPDATE cheval SET peut_manger = 1")) {
        qDebug() << "Accès nourriture réinitialisé pour tous les chevaux.";
        emit dbUpdated();

        QSqlQuery hist;
        hist.exec("INSERT INTO historique (action, date) VALUES ('RÉINITIALISATION GLOBALE ACCÈS', NOW())");
    } else {
        qDebug() << "Erreur lors de la réinitialisation :" << query.lastError().text();
    }
}

void DatabaseManager::systemReboot() {
    qDebug() << "Le système va redémarrer...";
    QProcess::startDetached("sudo reboot");
}

void DatabaseManager::systemShutdown() {
    qDebug() << "Le système va s'éteindre...";
    QProcess::startDetached("sudo poweroff");
}
