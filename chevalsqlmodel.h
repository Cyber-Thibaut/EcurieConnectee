#ifndef CHEVALSQLMODEL_H
#define CHEVALSQLMODEL_H

#include <QSqlQueryModel>
#include <QObject>

class ChevalSqlModel : public QSqlQueryModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        RfidRole,
        NomRole,
        TailleRole,
        PeutMangerRole,
        RegimeCompletRole
    };

    explicit ChevalSqlModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QStringList getNourritures();
    Q_INVOKABLE void addCheval(const QString &rfid, const QString &nom, int taille);
    Q_INVOKABLE void updateCheval(int id, const QString &rfid, const QString &nom, int taille);
    Q_INVOKABLE void toggleAccess(int id, bool status);
    Q_INVOKABLE void deleteCheval(int id);

    Q_INVOKABLE int getStock(const QString &nom);
    Q_INVOKABLE void commanderNourriture(const QString &nom, int quantiteAjoutee);

signals:
    void stockUpdated();
};

#endif // CHEVALSQLMODEL_H
