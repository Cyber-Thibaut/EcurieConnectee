#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include <QDebug>
#include <QMqttClient>
#include <QTimer>
#include <QNetworkInterface>

#include "mqttmanager.h"
#include "databasemanager.h"
#include "chevalsqlmodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString localIpAddress = "127.0.0.1";
    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();

    for (const QNetworkInterface &interface : interfaces) {
        if (interface.flags().testFlag(QNetworkInterface::IsUp) &&
            !interface.flags().testFlag(QNetworkInterface::IsLoopBack)) {

            for (const QNetworkAddressEntry &entry : interface.addressEntries()) {
                if (entry.ip().protocol() == QAbstractSocket::IPv4Protocol) {
                    if (interface.name().startsWith("e")) {
                        localIpAddress = entry.ip().toString();
                        goto ipFound;
                    } else if (localIpAddress == "127.0.0.1") {
                        localIpAddress = entry.ip().toString();
                    }
                }
            }
        }
    }
ipFound:
    qDebug() << "[RÉSEAU] IP de la machine détectée :" << localIpAddress;
                                                              engine.rootContext()->setContextProperty("localIpAddress", localIpAddress);


                    MqttManager mqttManager;
    DatabaseManager dbManager;

    dbManager.connectToDatabase("localhost", "ecurie", "pi", "raspberry");
    ChevalSqlModel chevalModel;
    chevalModel.refresh();

    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("chevalModel", &chevalModel);
    engine.rootContext()->setContextProperty("mqtt", &mqttManager);

    engine.rootContext()->setContextProperty("brokerIpAddress", localIpAddress);

    // ===================================================================
    // 1. CLIENT MQTT N°1 : THE THINGS NETWORK (CLOUD LoRa) via MqttManager
    // ===================================================================
    QObject::connect(&mqttManager, &MqttManager::messageReceived,
                     &dbManager, &DatabaseManager::handleMqttMessage);

    QObject::connect(&dbManager, &DatabaseManager::sendMqttMessage,
                     &mqttManager, &MqttManager::publishMessage);

    // ===================================================================
    // 2. CLIENT MQTT N°2 : BROKER LOCAL (RASPBERRY PI / ESP32)
    // ===================================================================
    QMqttClient *clientLocal = new QMqttClient(&app);

    clientLocal->setHostname(localIpAddress);
    clientLocal->setPort(1883);

    QObject::connect(clientLocal, &QMqttClient::connected, [localIpAddress, clientLocal]() {
        qDebug() << "[MQTT LOCAL] Connecté au broker sur" << localIpAddress;
                                                                 clientLocal->subscribe(QMqttTopicFilter("#"));
    });

    QObject::connect(clientLocal, &QMqttClient::disconnected, [clientLocal]() {
        qDebug() << "[MQTT LOCAL] Déconnecté. Nouvelle tentative dans 5 secondes...";
        QTimer::singleShot(5000, clientLocal, [clientLocal]() {
            clientLocal->connectToHost();
        });
    });

    QObject::connect(clientLocal, &QMqttClient::messageReceived,
                     [&dbManager](const QByteArray &message, const QMqttTopicName &topic) {
                         dbManager.handleMqttMessage(topic.name(), QString::fromUtf8(message));
                     });

    QObject::connect(&dbManager, &DatabaseManager::sendLocalMqttMessage,
                     [clientLocal](const QString &topic, const QString &payload) {
                         if (clientLocal->state() == QMqttClient::Connected) {
                             clientLocal->publish(QMqttTopicName(topic), payload.toUtf8());
                         }
                     });

    clientLocal->connectToHost();

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    QObject::connect(&dbManager, &DatabaseManager::dbUpdated,
                     &chevalModel, &ChevalSqlModel::refresh);

    engine.load(url);

    return app.exec();
}
