#include "chevalsqlmodel.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

ChevalSqlModel::ChevalSqlModel(QObject *parent) : QSqlQueryModel(parent) {}

void ChevalSqlModel::refresh()
{
    this->setQuery(
        "SELECT c.cheval_ID, c.rfid, c.nom, c.taille, c.peut_manger, "
        "GROUP_CONCAT(CONCAT(r.quantite_repas, ' kg ', r.nourriture_nom) SEPARATOR '\n') AS regime_complet "
        "FROM cheval c "
        "LEFT JOIN regime r ON c.cheval_ID = r.cheval_ID "
        "GROUP BY c.cheval_ID"
    );
}

QHash<int, QByteArray> ChevalSqlModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[RfidRole] = "rfid";
    roles[NomRole] = "nom";
    roles[TailleRole] = "taille";
    roles[PeutMangerRole] = "peut_manger";
    roles[RegimeCompletRole] = "regime_complet";
    return roles;
}

QVariant ChevalSqlModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();
    if (role == IdRole) return QSqlQueryModel::data(this->index(index.row(), 0));
    if (role == RfidRole) return QSqlQueryModel::data(this->index(index.row(), 1));
    if (role == NomRole) return QSqlQueryModel::data(this->index(index.row(), 2));
    if (role == TailleRole) return QSqlQueryModel::data(this->index(index.row(), 3));
    if (role == PeutMangerRole) return QSqlQueryModel::data(this->index(index.row(), 4)).toBool();
    if (role == RegimeCompletRole) return QSqlQueryModel::data(this->index(index.row(), 5)).toString();

    return QSqlQueryModel::data(index, role);
}

void ChevalSqlModel::addCheval(const QString &rfid, const QString &nom, int taille)
{
    QSqlQuery q;
    q.prepare("INSERT INTO cheval (rfid, nom, taille, peut_manger) "
              "VALUES (:rfid, :nom, :taille, true)");
    q.bindValue(":rfid", rfid);
    q.bindValue(":nom", nom);
    q.bindValue(":taille", taille);

    if (q.exec()) {
        refresh();
    }
}

void ChevalSqlModel::updateCheval(int id, const QString &rfid, const QString &nom, int taille)
{
    QSqlQuery q;
    q.prepare("UPDATE cheval SET rfid = :rfid, nom = :nom, taille = :taille "
              "WHERE cheval_ID = :id");
    q.bindValue(":rfid", rfid);
    q.bindValue(":nom", nom);
    q.bindValue(":taille", taille);
    q.bindValue(":id", id);

    if (q.exec()) {
        refresh();
    }
}

void ChevalSqlModel::toggleAccess(int id, bool status)
{
    QSqlQuery q;
    q.prepare("UPDATE cheval SET peut_manger = :status WHERE cheval_ID = :id");
    q.bindValue(":status", status);
    q.bindValue(":id", id);
    if (q.exec()) refresh();
}

void ChevalSqlModel::deleteCheval(int id)
{
    QSqlQuery q;
    q.prepare("DELETE FROM cheval WHERE cheval_ID = :id");
    q.bindValue(":id", id);
    if (q.exec()) refresh();
}

QStringList ChevalSqlModel::getNourritures()
{
    QStringList liste;
    QSqlQuery q("SELECT nom FROM nourriture_stock");
    while (q.next()) {
        liste.append(q.value(0).toString());
    }

    if (liste.isEmpty()) {
        liste.append("Aucun stock");
    }
    return liste;
}

int ChevalSqlModel::getStock(const QString &nom)
{
    QSqlQuery q;
    q.prepare("SELECT quantite FROM nourriture_stock WHERE nom = :nom");
    q.bindValue(":nom", nom);

    if (q.exec() && q.next()) {
        return q.value(0).toInt();
    }
    return 0;
}

void ChevalSqlModel::commanderNourriture(const QString &nom, int quantiteAjoutee)
{
    QSqlQuery q;
    q.prepare("UPDATE nourriture_stock SET quantite = quantite + :ajout WHERE nom = :nom");
    q.bindValue(":ajout", quantiteAjoutee);
    q.bindValue(":nom", nom);

    if (q.exec()) {
        emit stockUpdated();
    }
}
