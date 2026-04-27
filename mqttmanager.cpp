#include "mqttmanager.h"
#include <QDebug>
#include <QTimer>

MqttManager::MqttManager(QObject *parent) : QObject(parent)
{
    m_client = new QMqttClient(this);

    m_client->setHostname("eu1.cloud.thethings.network");
    m_client->setPort(8883);
    m_client->setUsername("ecurie-active@ttn");
    m_client->setPassword("NNSXS.TNHBFJISC6MI4ZFSYYH5XBKQLTBRTZG2VIJFV3I.O5RQVBYE6RLCQ3KX2UXIMSZXKD6STXCJPNGQODRPBWQXBXXDIDJQ");

    connect(m_client, &QMqttClient::connected, this, [this]() {
        setConnectionState(true);
        qDebug() << "[TTN] Connecté avec succès au broker !";
        m_client->subscribe(QMqttTopicFilter("v3/ecurie-active@ttn/devices/+/up"));
    });

    connect(m_client, &QMqttClient::disconnected, this, [this]() {
        setConnectionState(false);
        qDebug() << "[TTN] Déconnecté. Tentative de reconnexion dans 5s...";

        QTimer::singleShot(5000, m_client, [this]() {
            if (m_client->port() == 8883) {
                m_client->connectToHostEncrypted();
            } else {
                m_client->connectToHost();
            }
        });
    });

    connect(m_client, &QMqttClient::messageReceived, this, [this](const QByteArray &message, const QMqttTopicName &topic) {
        emit messageReceived(topic.name(), QString::fromUtf8(message));
    });

    m_client->connectToHostEncrypted();
}

void MqttManager::connectToServer(const QString &host, quint16 port, const QString &username, const QString &password)
{
    m_client->setHostname(host);
    m_client->setPort(port);
    m_client->setUsername(username);
    m_client->setPassword(password);

    qDebug() << "Tentative de connexion à TTN (" << host << ":" << port << ")...";

        if (port == 8883) {
        m_client->connectToHostEncrypted();
    } else {
        m_client->connectToHost();
    }
}

void MqttManager::publishMessage(const QString &topic, const QString &message)
{
    if (m_client->state() == QMqttClient::Connected) {
        m_client->publish(QMqttTopicName(topic), message.toUtf8());
    }
}

void MqttManager::subscribeToTopic(const QString &topic)
{
    if (m_client->state() == QMqttClient::Connected) {
        m_client->subscribe(QMqttTopicFilter(topic));
    }
}
