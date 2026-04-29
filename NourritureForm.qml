import QtQuick 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.15

Page {
    id: pageNourriture
    background: Rectangle { color: "#f2f2f2" }

    header: Rectangle {
        width: parent.width
        height: 60
        color: "#ffffff"
        border.color: "#e5e7eb"
        border.width: 1

        ToolButton {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            contentItem: Text {
                text: "◀ Retour"
                color: "#4b6bfb"
                font.bold: true
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { color: "transparent" }
            onClicked: stackView.pop()
        }

        Label {
            anchors.centerIn: parent
            text: "Monitoring Alimentation"
            font.pixelSize: 22
            color: "#181a2a"
            font.bold: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            spacing: 15

            Label {
                text: "CHEVAL"
                font.bold: true
                color: "#7b92b2"
                font.pixelSize: 12
                Layout.preferredWidth: 200
            }
            Label {
                text: "RÉGIME PLANIFIÉ"
                font.bold: true
                color: "#7b92b2"
                font.pixelSize: 12
                Layout.fillWidth: true
            }
            Label {
                text: "ÉTAT / DISTRIBUÉ"
                font.bold: true
                color: "#7b92b2"
                font.pixelSize: 12
                Layout.fillWidth: true
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: chevalModel

            delegate: Rectangle {
                width: ListView.view.width
                height: 75
                color: "#ffffff"
                radius: 8
                border.color: "#e5e7eb"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Label {
                        text: model.nom ? model.nom : "Cheval inconnu"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#181a2a"
                        elide: Text.ElideRight
                        Layout.preferredWidth: 200
                        Layout.alignment: Qt.AlignTop
                    }

                    Label {
                        text: model.regime_complet ? model.regime_complet : "Aucun régime défini"
                        font.pixelSize: 14
                        color: "#7b92b2"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                    }

                    Label {
                        text: model.peut_manger ? "⏳ En attente de passage..." : "✅ " + (model.regime ? model.regime : "Ration consommée")
                        font.pixelSize: 14
                        font.bold: true
                        color: model.peut_manger ? "#f59e0b" : "#10b981"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                    }
                }
            }
        }
    }
}
