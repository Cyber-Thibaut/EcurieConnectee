#ifndef MQTTMANAGER_H
#define MQTTMANAGER_H

#include <QObject>
#include <QMqttClient>

class MqttManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connectedToTTN READ isConnectedToTTN NOTIFY connectedToTTNChanged)
public:
    explicit MqttManager(QObject *parent = nullptr);
    bool isConnectedToTTN() const { return m_connectedToTTN; }

    Q_INVOKABLE void connectToServer(const QString &host, quint16 port, const QString &username, const QString &password);
    Q_INVOKABLE void publishMessage(const QString &topic, const QString &message);
    Q_INVOKABLE void subscribeToTopic(const QString &topic);

signals:
    void messageReceived(const QString &topic, const QString &message);
    void connected();
    void connectedToTTNChanged(bool connected);

public slots:
    void setConnectionState(bool state) {
        if (m_connectedToTTN != state) {
            m_connectedToTTN = state;
            emit connectedToTTNChanged(m_connectedToTTN);
        }
    }
private:
    QMqttClient *m_client;
    bool m_connectedToTTN = false;
};

#endif // MQTTMANAGER_H
