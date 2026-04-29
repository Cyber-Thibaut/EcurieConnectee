import QtQuick 2.11
import QtQuick.Controls 2.11

Page {
    background: Rectangle { color: "#ECF0F1" }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Réglages des accès - Tornado"
            font.pixelSize: 24
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Label { text: "Accès Granulés"; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
            Switch { checked: true }
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Label { text: "Accès Fourrage"; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
            Switch { checked: true }
        }

        Button {
            text: "Sauvegarder dans la base locale"
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter
            width: 300
            height: 50
        }
    }
}
