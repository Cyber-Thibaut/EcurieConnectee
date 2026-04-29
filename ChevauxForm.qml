import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15

Page {
    id: pageChevaux
    property bool isListeningEcriture: false
    property int currentEditId: -1

    background: Rectangle { color: "#f2f2f2" }

    Connections {
        target: dbManager
        function onNewTagScanned(rfid) {
            if (tabBar.currentIndex === 1) { champRFID.text = rfid }
            if (tabBar.currentIndex === 2) { editRFID.text = rfid }
            isListeningEcriture = false
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
            text: "Administration des Chevaux"
            font.pixelSize: 22
            color: "#181a2a"
            font.bold: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            background: Rectangle {
                color: "#ffffff"
                Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.bottom: parent.bottom }
            }

            TabButton {
                id: tab1
                text: "Registre"
                contentItem: Text {
                    text: tab1.text; color: tab1.checked ? "#4b6bfb" : "#7b92b2"
                    font.bold: tab1.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                    Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: tab1.checked }
                }
            }
            TabButton {
                id: tab2
                text: "Nouveau Profil"
                contentItem: Text {
                    text: tab2.text; color: tab2.checked ? "#4b6bfb" : "#7b92b2"
                    font.bold: tab2.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                    Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: tab2.checked }
                }
            }
            TabButton {
                id: tab3
                text: "Modifier"
                enabled: currentEditId !== -1
                contentItem: Text {
                    text: tab3.text; color: tab3.enabled ? (tab3.checked ? "#4b6bfb" : "#7b92b2") : "#d1d5db"
                    font.bold: tab3.checked; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "transparent"
                    Rectangle { width: parent.width; height: 3; color: "#4b6bfb"; anchors.bottom: parent.bottom; visible: tab3.checked }
                }
            }
        }

        StackLayout {
            currentIndex: tabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15; Layout.rightMargin: 15; spacing: 15
                        Label { text: "IDENTITÉ"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.fillWidth: true }
                        Label { text: "ACTIONS"; font.bold: true; color: "#7b92b2"; font.pixelSize: 12; Layout.preferredWidth: 160 }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: chevalModel
                        delegate: Rectangle {
                            width: ListView.view.width; height: 65
                            color: "#ffffff"; radius: 8; border.color: "#e5e7eb"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15; anchors.rightMargin: 15; spacing: 15

                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Label { text: model.nom ? model.nom : "Non renseigné"; font.bold: true; font.pixelSize: 16; color: "#181a2a"; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Label { text: "Tag: " + (model.rfid ? model.rfid : "Aucun"); color: "#7b92b2"; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                                }

                                RowLayout {
                                    Layout.preferredWidth: 160; spacing: 10
                                    Button {
                                        text: "Éditer"
                                        Layout.preferredWidth: 70; Layout.preferredHeight: 32
                                        background: Rectangle { radius: 6; color: parent.down ? "#f3f4f6" : "transparent"; border.color: "#4b6bfb"; border.width: 1 }
                                        contentItem: Text { text: parent.text; color: "#4b6bfb"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: {
                                            currentEditId = model.id
                                            editRFID.text = model.rfid ? model.rfid : ""
                                            editNom.text = model.nom ? model.nom : ""
                                            editTaille.text = model.taille ? model.taille : ""
                                            tabBar.currentIndex = 2
                                        }
                                    }
                                    Button {
                                        text: "Suppr."
                                        Layout.preferredWidth: 70; Layout.preferredHeight: 32
                                        background: Rectangle { radius: 6; color: parent.down ? "#fee2e2" : "transparent"; border.color: "#f87272"; border.width: 1 }
                                        contentItem: Text { text: parent.text; color: "#f87272"; font.bold: true; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: chevalModel.deleteCheval(model.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 550
                    height: 350
                    color: "#ffffff"
                    radius: 12
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Button {
                            text: pageChevaux.isListeningEcriture ? "Lecture RFID en cours..." : "Scanner le badge RFID"
                            Layout.fillWidth: true; Layout.preferredHeight: 40
                            enabled: !pageChevaux.isListeningEcriture
                            background: Rectangle { color: pageChevaux.isListeningEcriture ? "#f3f4f6" : "#7b92b2"; radius: 8 }
                            contentItem: Text { text: parent.text; color: pageChevaux.isListeningEcriture ? "#9ca3af" : "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                pageChevaux.isListeningEcriture = true

                                var ttnTopic = "v3/ecurie-active@ttn/devices/ard-num-2/down/push"
                                var ttnPayload = '{ "downlinks": [{ "f_port": 1, "frm_payload": "TkVX", "priority": "NORMAL" }] }'

                                mqtt.publishMessage(ttnTopic, ttnPayload)
                            }
                        }

                        GridLayout {
                            columns: 2; rowSpacing: 8; columnSpacing: 20; Layout.fillWidth: true

                            Label { text: "ID (RFID) :"; color: "#181a2a"; font.bold: true }
                            TextField {
                                id: champRFID; readOnly: true; placeholderText: "En attente du scan..."
                                Layout.fillWidth: true; Layout.preferredHeight: 36
                                background: Rectangle { color: "#f3f4f6"; radius: 6; border.color: "#e5e7eb" }
                            }

                            Label { text: "Nom du cheval :"; color: "#181a2a"; font.bold: true }
                            TextField {
                                id: champNom; placeholderText: "Ex: Tornado"
                                Layout.fillWidth: true; Layout.preferredHeight: 36
                                background: Rectangle { color: "white"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                            }

                            Label { text: "Taille (cm) :"; color: "#181a2a"; font.bold: true }
                            TextField {
                                id: champTaille; placeholderText: "Ex: 165"
                                validator: IntValidator { bottom: 50; top: 250 }
                                Layout.fillWidth: true; Layout.preferredHeight: 36
                                background: Rectangle { color: "white"; radius: 6; border.color: "#e5e7eb"; border.width: 1 }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        Button {
                            text: "Sauvegarder l'enregistrement"
                            Layout.fillWidth: true; Layout.preferredHeight: 40
                            enabled: champRFID.text !== "" && champNom.text !== ""
                            background: Rectangle { color: parent.enabled ? "#67cba0" : "#d1d5db"; radius: 8 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                chevalModel.addCheval(champRFID.text, champNom.text, parseInt(champTaille.text) || 0)
                                champRFID.text = ""; champNom.text = ""; champTaille.text = ""
                                tabBar.currentIndex = 0
                            }
                        }
                    }
                }
            }

            Rectangle {
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 550
                    height: 350
                    color: "white"
                    radius: 12
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Button {
                            text: pageChevaux.isListeningEcriture ? "Lecture RFID en cours..." : "Remplacer le badge RFID"
                            Layout.fillWidth: true; Layout.preferredHeight: 40
                            enabled: !pageChevaux.isListeningEcriture
                            background: Rectangle { color: pageChevaux.isListeningEcriture ? "#f3f4f6" : "#7b92b2"; radius: 8 }
                            contentItem: Text { text: parent.text; color: pageChevaux.isListeningEcriture ? "#9ca3af" : "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                pageChevaux.isListeningEcriture = true

                                var ttnTopic = "v3/ecurie-active@ttn/devices/ard-num-2/down/push"

                                var ttnPayload = '{ "downlinks": [{ "f_port": 1, "frm_payload": "TkVX", "priority": "NORMAL" }] }'

                                mqtt.publishMessage(ttnTopic, ttnPayload)
                            }
                        }

                        GridLayout {
                            columns: 2; rowSpacing: 8; columnSpacing: 20; Layout.fillWidth: true

                            Label { text: "ID (RFID) :"; color: "#181a2a"; font.bold: true }
                            TextField { id: editRFID; readOnly: true; Layout.fillWidth: true; Layout.preferredHeight: 36; background: Rectangle { color: "#f3f4f6"; radius: 6; border.color: "#e5e7eb" } }

                            Label { text: "Nom du cheval :"; color: "#181a2a"; font.bold: true }
                            TextField { id: editNom; Layout.fillWidth: true; Layout.preferredHeight: 36; background: Rectangle { color: "white"; radius: 6; border.color: "#e5e7eb"; border.width: 1 } }

                            Label { text: "Taille (cm) :"; color: "#181a2a"; font.bold: true }
                            TextField { id: editTaille; validator: IntValidator {bottom: 50; top: 250} Layout.fillWidth: true; Layout.preferredHeight: 36; background: Rectangle { color: "white"; radius: 6; border.color: "#e5e7eb"; border.width: 1 } }
                        }

                        Item { Layout.fillHeight: true }

                        Button {
                            text: "Appliquer les modifications"
                            Layout.fillWidth: true; Layout.preferredHeight: 40
                            background: Rectangle { color: "#4b6bfb"; radius: 8 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                chevalModel.updateCheval(currentEditId, editRFID.text, editNom.text || "Inconnu", parseInt(editTaille.text) || 0)
                                currentEditId = -1
                                tabBar.currentIndex = 0
                            }
                        }
                    }
                }
            }
        }
    }
}
