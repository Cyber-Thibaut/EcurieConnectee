import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    color: "#f2f2f2"
    title: "Écurie Active - IHM Embarquée"

    Component.onCompleted: {
        var ttnHost = "eu1.cloud.thethings.network"
        var ttnPort = 8883
        var ttnUsername = "ecurie-active@ttn"
        var ttnApiKey = "NNSXS.TNHBFJISC6MI4ZFSYYH5XBKQLTBRTZG2VIJFV3I.O5RQVBYE6RLCQ3KX2UXIMSZXKD6STXCJPNGQODRPBWQXBXXDIDJQ"

        mqtt.connectToServer(ttnHost, ttnPort, ttnUsername, ttnApiKey)
    }

    Connections {
        target: mqtt
        function onConnected() {
            var ttnUplinkTopic = "v3/ecurie-active@ttn/devices/+/up"

            mqtt.subscribeToTopic(ttnUplinkTopic)
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "qrc:/HomeForm.qml"
    }

    Rectangle {
            id: alertBanner
            width: parent.width
            height: 50
            color: "#ef4444"
            z: 999

            y: mqtt.connectedToTTN ? -height : 0
            Behavior on y {
                NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Label {
                    text: "⚠️"
                    font.pixelSize: 22
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: "Connexion au réseau LoRa perdue. La lecture des badges est interrompue. Veuillez contacter l'assistance."
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 3
                anchors.bottom: parent.bottom
                color: "#000000"
                opacity: 0.15
            }
        }
}
