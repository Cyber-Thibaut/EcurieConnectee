import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root
    background: Rectangle { color: "#f2f2f2" }

    // État du système (Local)
    property bool systemActive: true

    Connections {
        target: mqtt
        function onMessageReceived(topic, message) {
            var timeString = new Date().toLocaleTimeString(Qt.locale("fr_FR"), "HH:mm:ss")
            terminalLog.text += "\n[" + timeString + "] " + topic + "\n➔ " + message + "\n"
            scrollViewLog.ScrollBar.vertical.position = 1.0
        }
    }

    // --- TERMINAL DE DÉBOGAGE (DRAWER) ---
    Drawer {
        id: consoleDrawer
        edge: Qt.BottomEdge
        width: parent.width
        height: 250
        background: Rectangle {
            color: "#1e1e2e"
            border.color: "#4b6bfb"
            border.width: 2
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Terminal de Débogage LoRa/MQTT"
                    color: "#a6accd"
                    font.bold: true
                    Layout.fillWidth: true
                }

                // --- NOUVEAU BOUTON : RESET NOURRITURE ---
                Button {
                    text: "🔄 Reset Nourriture"
                    background: Rectangle { color: "#4b6bfb"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; padding: 8 }
                    onClicked: {
                        dbManager.resetAllFoodAccess()
                        terminalLog.text += "\n[SYSTÈME] Réinitialisation de tous les accès nourriture effectuée.\n"
                    }
                }

                Button {
                    text: "Vider"
                    background: Rectangle { color: "transparent"; border.color: "#f87272"; radius: 4; border.width: 1 }
                    contentItem: Text { text: parent.text; color: "#f87272"; font.bold: true }
                    onClicked: terminalLog.text = "> IP de la machine détectée :" << localIpAddress;
                }

                Button {
                    text: "Fermer"
                    background: Rectangle { color: "transparent"; border.color: "#a6accd"; radius: 4; border.width: 1 }
                    contentItem: Text { text: parent.text; color: "#a6accd"; font.bold: true }
                    onClicked: consoleDrawer.close()
                }
            }
            ScrollView {
                id: scrollViewLog
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                TextArea {
                    id: terminalLog
                    text: "Console de maintenance active..."
                    color: "#c3e88d"; font.family: "Courier"; font.pixelSize: 13; readOnly: true; background: null
                }
            }
        }
    }

    // --- CONTENU PRINCIPAL ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 0

        // --- TITRE ---
        Label {
            text: "Tableau de Bord - Domaine Yakari"
            font.pixelSize: 32; font.bold: true; color: "#181a2a"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10; Layout.bottomMargin: 20
        }

        // --- GRILLE DES BOUTONS ---
        GridLayout {
            columns: 2
            rowSpacing: 24; columnSpacing: 24
            Layout.alignment: Qt.AlignHCenter
            enabled: systemActive // Désactive les boutons si le système est arrêté
            opacity: systemActive ? 1.0 : 0.5

            Button {
                id: btnChevaux
                Layout.preferredWidth: 300; Layout.preferredHeight: 100
                onClicked: stackView.push("qrc:/ChevauxForm.qml")
                background: Rectangle {
                    color: btnChevaux.down ? "#e5e6e6" : "#ffffff"
                    radius: 8; border.color: "#4b6bfb"; border.width: btnChevaux.hovered ? 2 : 1
                    Rectangle { width: 6; height: parent.height; radius: 8; color: "#4b6bfb"; anchors.left: parent.left }
                }
                contentItem: Label { text: "Gestion des Chevaux"; font.pixelSize: 20; color: "#181a2a"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }

            Button {
                id: btnStocks
                Layout.preferredWidth: 300; Layout.preferredHeight: 100
                onClicked: stackView.push("qrc:/StocksForm.qml")
                background: Rectangle {
                    color: btnStocks.down ? "#e5e6e6" : "#ffffff"
                    radius: 8; border.color: "#67cba0"; border.width: 1
                    Rectangle { width: 6; height: parent.height; radius: 8; color: "#67cba0"; anchors.left: parent.left }
                }
                contentItem: Label { text: "État des Stocks"; font.pixelSize: 20; color: "#181a2a"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }

            Button {
                id: btnAcces
                Layout.preferredWidth: 300; Layout.preferredHeight: 100
                onClicked: stackView.push("qrc:/AccesForm.qml")
                background: Rectangle {
                    color: btnAcces.down ? "#e5e6e6" : "#ffffff"
                    radius: 8; border.color: "#7b92b2"; border.width: 1
                    Rectangle { width: 6; height: parent.height; radius: 8; color: "#7b92b2"; anchors.left: parent.left }
                }
                contentItem: Label { text: "Contrôle des Accès"; font.pixelSize: 20; color: "#181a2a"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }

            Button {
                id: btnAlimentation
                Layout.preferredWidth: 300; Layout.preferredHeight: 100
                onClicked: stackView.push("qrc:/NourritureForm.qml")
                background: Rectangle {
                    color: btnAlimentation.down ? "#e5e6e6" : "#ffffff"
                    radius: 8; border.color: "#181a2a"; border.width: 1
                    Rectangle { width: 6; height: parent.height; radius: 8; color: "#181a2a"; anchors.left: parent.left }
                }
                contentItem: Label { text: "Suivi Alimentation"; font.pixelSize: 20; color: "#181a2a"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        Item { Layout.fillHeight: true }

        // --- PIED DE PAGE (Footer) ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    spacing: 15 // Espace entre la ligne des boutons et l'horloge

                    // Ligne 1 : Les boutons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        // Bouton Test à gauche
                        Button {
                            text: "🛠️ Test Matériel"
                            background: Rectangle { color: "transparent"; border.color: "#7b92b2"; radius: 6; border.width: 1 }
                            contentItem: Text { text: parent.text; color: "#7b92b2"; font.bold: true; padding: 5 }
                            onClicked: consoleDrawer.open()
                        }

                        Item { Layout.fillWidth: true } // Ressort pour centrer les boutons power

                        // Bouton ARRÊT SYSTÈME
                        Button {
                            id: btnStop
                            text: "🔌 Éteindre le Pi"
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 160
                            onClicked: stopConfirmDialog.open() // On ouvre une confirmation pour éviter les erreurs

                            background: Rectangle {
                                color: btnStop.down ? "#d76565" : "#f87272"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text; color: "white"; font.bold: true
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Bouton REDÉMARRAGE SYSTÈME
                        Button {
                            id: btnRestart
                            text: "🔄 Redémarrer"
                            Layout.preferredHeight: 45
                            Layout.preferredWidth: 160
                            onClicked: restartConfirmDialog.open()

                            background: Rectangle {
                                color: btnRestart.down ? "#2db885" : "#36d399"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text; color: "white"; font.bold: true
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Item { Layout.fillWidth: true } // Ressort pour équilibrer

                        // On laisse un Item vide à droite de la même taille que le bouton Test
                        // pour que les boutons centraux soient parfaitement au milieu
                        Item { Layout.preferredWidth: 100 }
                    }

                    // Ligne 2 : L'Horloge (Maintenant en dessous et centrée)
                    Label {
                        id: clockLabel
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: 22
                        font.bold: true
                        color: "#7b92b2"
                        text: "Chargement heure..."
                    }
                }
    } // FIN DU COLUMNLAYOUT

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var d = new Date()
            clockLabel.text = d.toLocaleDateString(Qt.locale("fr_FR")) + "  |  " + d.toLocaleTimeString(Qt.locale("fr_FR"), "HH:mm")
        }
    }
    Dialog {
        id: stopConfirmDialog
        title: "Confirmer l'arrêt ?"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        Text { text: "Voulez-vous vraiment éteindre le Raspberry Pi ?" }
        onAccepted: dbManager.systemShutdown() // MODIFIÉ ICI
    }

    // Dialogue de confirmation pour le redémarrage
    Dialog {
        id: restartConfirmDialog
        title: "Confirmer le redémarrage ?"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        Text { text: "Le système va redémarrer immédiatement." }
        onAccepted: dbManager.systemReboot() // MODIFIÉ ICI
    }
}
