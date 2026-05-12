import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

Page {
    id: pageAcces
    background: Rectangle { color: "#f2f2f2" } // Fond Base-200

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
            width: 100
            height: 50
            contentItem: Text {
                text: "◀ Retour"
                color: "#4b6bfb" // Primary
                font.bold: true
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { color: "transparent" }
            onClicked: stackView.pop()
        }

        Label {
            anchors.centerIn: parent
            text: "Gestion des Accès"
            font.pixelSize: 22
            color: "#181a2a" // Neutral
            font.bold: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#fef08a" // Warning léger
            radius: 8
            border.color: "#fbbd23" // Warning fort
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Label {
                    text: "⚠️"
                    font.pixelSize: 20
                }
                Label {
                    text: "Mode Simulation : En raison d'un manque de capteurs physiques (portes de tri), les accès et routages ci-dessous sont purement fictifs."
                    color: "#b45309"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 15; Layout.rightMargin: 15
            spacing: 15

            Label { text: "IDENTITÉ"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.preferredWidth: 220 }
            Label { text: "ZONE REPAS"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.preferredWidth: 140 }
            Label { text: "PÂTURAGE"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.preferredWidth: 140 }
            Label { text: "PLAGES HORAIRES"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.fillWidth: true }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: chevalModel

            delegate: Rectangle {
                width: ListView.view.width
                height: 80
                color: "#ffffff"
                radius: 8
                border.color: "#e5e7eb"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15; anchors.rightMargin: 15
                    spacing: 15

                    ColumnLayout {
                        Layout.preferredWidth: 220
                        spacing: 2
                        Label { text: model.nom; font.bold: true; font.pixelSize: 16; color: "#181a2a"; elide: Text.ElideRight; Layout.fillWidth: true }
                        Label { text: "Tag: " + model.rfid; color: "#7b92b2"; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.preferredWidth: 140
                        spacing: 5
                        Switch {
                            id: swRepas
                            checked: true
                        }
                        Label {
                            text: swRepas.checked ? "Autorisé" : "Bloqué"
                            color: swRepas.checked ? "#10b981" : "#f87272"
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }
                    RowLayout {
                        Layout.preferredWidth: 140
                        spacing: 5
                        Switch {
                            id: swPaturage
                            checked: false
                        }
                        Label {
                            text: swPaturage.checked ? "Ouvert" : "Fermé"
                            color: swPaturage.checked ? "#10b981" : "#f87272"
                            font.bold: true
                            font.pixelSize: 13
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Label { text: "De"; color: "#7b92b2"; font.pixelSize: 14 }

                        TextField {
                            text: "08:00"
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 36
                            horizontalAlignment: Text.AlignHCenter
                            color: "#181a2a"
                            background: Rectangle { color: "#f8f9fa"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                        }

                        Label { text: "à"; color: "#7b92b2"; font.pixelSize: 14 }

                        TextField {
                            text: "18:00"
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 36
                            horizontalAlignment: Text.AlignHCenter
                            color: "#181a2a"
                            background: Rectangle { color: "#f8f9fa"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                        }
                    }
                }
            }
        }
    }
}
