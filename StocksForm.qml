import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtCharts 2.11

Page {
    id: pageStocks
    background: Rectangle { color: "#f2f2f2" }

    Connections {
        target: chevalModel
        function onStockUpdated() {
            setFoin.values = [chevalModel.getStock("Foin")]
            setGranules.values = [chevalModel.getStock("Granulés")]
            setPaille.values = [chevalModel.getStock("Paille")]
        }
    }

    Popup {
        id: easterEggPopup
        anchors.centerIn: parent
        width: 400
        height: 400
        modal: true
        background: Rectangle {
            color: "#ffffff"
            radius: 12
            border.color: "#e5e7eb"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20

            Label {
                text: "Erreur Système 404"
                font.pixelSize: 22
                font.bold: true
                color: "#f87272"
                Layout.alignment: Qt.AlignHCenter
            }

            Image {
                source: "qrc:/contribution_gallery.jpg"
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                Layout.alignment: Qt.AlignHCenter
                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Impossible de joindre l'imprimante."
                font.pixelSize: 16
                color: "#181a2a" // Neutral
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Fermer"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                background: Rectangle { color: "#f3f4f6"; radius: 8; border.color: "#e5e7eb" }
                contentItem: Text { text: parent.text; color: "#4b5563"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: easterEggPopup.close()
            }
        }
    }

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
            text: "État des Stocks"
            font.pixelSize: 22
            color: "#181a2a"
            font.bold: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: stockTabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            background: Rectangle {
                color: "#ffffff"
                Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.bottom: parent.bottom }
            }

            TabButton {
                id: btnInventaire
                text: "Inventaire Global"
                contentItem: Text { text: parent.text; color: parent.checked ? "#4b6bfb" : "#7b92b2"; font.bold: parent.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: "transparent"; Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: btnInventaire.checked } }
            }
            TabButton {
                id: btnCommandes
                text: "Réception"
                contentItem: Text { text: parent.text; color: parent.checked ? "#4b6bfb" : "#7b92b2"; font.bold: parent.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: "transparent"; Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: btnCommandes.checked } }
            }
            TabButton {
                id: btnFactures
                text: "Facturation"
                contentItem: Text { text: parent.text; color: parent.checked ? "#4b6bfb" : "#7b92b2"; font.bold: parent.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: "transparent"; Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: btnFactures.checked } }
            }
        }

        StackLayout {
            currentIndex: stockTabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 20
                    color: "#ffffff"
                    radius: 12
                    border.color: "#e5e7eb"

                    ChartView {
                        title: "Niveau réel des stocks en écurie (kg)"
                        titleColor: "#181a2a"
                        titleFont.pixelSize: 18
                        titleFont.bold: true
                        anchors.fill: parent
                        anchors.margins: 10
                        antialiasing: true
                        legend.alignment: Qt.AlignBottom
                        legend.labelColor: "#4b5563"
                        backgroundColor: "transparent"

                        BarSeries {
                            id: barSeries
                            axisX: BarCategoryAxis { categories: ["Quantité Actuelle"]; labelsColor: "#7b92b2" }
                            axisY: ValueAxis { min: 0; max: 1000; labelFormat: "%d kg"; labelsColor: "#7b92b2" }

                            BarSet { id: setFoin; label: "Foin"; color: "#4b6bfb"; values: [chevalModel.getStock("Foin")] }
                            BarSet { id: setGranules; label: "Granulés"; color: "#67cba0"; values: [chevalModel.getStock("Granulés")] }
                            BarSet { id: setPaille; label: "Paille"; color: "#fbbd23"; values: [chevalModel.getStock("Paille")] }
                        }
                    }
                }
            }

            Rectangle {
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 500
                    height: 250
                    color: "#ffffff"
                    radius: 12
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 30

                        Label {
                            text: "Réception Commande Fournisseur"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#181a2a"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 15
                            Layout.alignment: Qt.AlignHCenter

                            ComboBox {
                                id: comboAchat
                                model: chevalModel.getNourritures()
                                Layout.preferredWidth: 160
                                Layout.preferredHeight: 40
                                background: Rectangle { color: "#ffffff"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                            }

                            TextField {
                                id: champQuantite
                                placeholderText: "Quantité (kg)"
                                validator: IntValidator { bottom: 1; top: 5000 }
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                background: Rectangle { color: "#ffffff"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                            }
                        }

                        Button {
                            text: "Valider l'achat"
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 45
                            Layout.alignment: Qt.AlignHCenter
                            enabled: champQuantite.text !== ""
                            background: Rectangle { color: parent.enabled ? "#67cba0" : "#d1d5db"; radius: 8 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                chevalModel.commanderNourriture(comboAchat.currentText, parseInt(champQuantite.text))
                                champQuantite.text = ""
                                stockTabBar.currentIndex = 0
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 500
                    height: 250
                    color: "#ffffff"
                    radius: 12
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 30

                        Label {
                            text: "Édition Facture Mensuelle"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#181a2a"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 20
                            Layout.alignment: Qt.AlignHCenter

                            ComboBox {
                                model: ["Thibaut", "Gaspard"]
                                Layout.preferredWidth: 200
                                Layout.preferredHeight: 40
                                background: Rectangle { color: "#ffffff"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                            }

                            Button {
                                text: "Générer PDF"
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 40
                                background: Rectangle { color: "#4b6bfb"; radius: 8 }
                                contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                onClicked: easterEggPopup.open()
                            }
                        }
                    }
                }
            }
        }
    }
}
