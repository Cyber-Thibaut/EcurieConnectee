#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool connectToDatabase(const QString &host, const QString &dbName, const QString &user, const QString &password);

    Q_INVOKABLE void testMorganSimul(const QString &rfidMorgan);

    Q_INVOKABLE void resetAllFoodAccess();
    Q_INVOKABLE void systemReboot();
    Q_INVOKABLE void systemShutdown();

public slots:
    void handleMqttMessage(const QString &topic, const QString &message);

signals:
    void newTagScanned(const QString &rfid);
    void openDoorRequested();
    void sendMqttMessage(const QString &topic, const QString &message);
    void sendLocalMqttMessage(const QString &topic, const QString &message);
    void dbUpdated();
    void stockUpdated();

private:
    QSqlDatabase m_db;
    QString m_lastScannedTag;
    qint64 m_lastScanTime;
    QString m_lastSource;
    QString m_lastAction;
    QNetworkAccessManager *m_networkManager;
};

#endif // DATABASEMANAGER_H
