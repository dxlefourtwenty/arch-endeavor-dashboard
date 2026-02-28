import QtQuick

// ProfileCard.qml

Rectangle {
    id: root

    property color  cFg:          "white"
    property string cFont:        "sans"
    property int    cFontSize:    16
    property color  cBorder:      "#444444"
    property int    cBorderWidth: 2

    color: "transparent"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Item {
            width: 96
            height: 96
            anchors.horizontalCenter: parent.horizontalCenter

            // clip: true here only clips to the Item rectangle, not the circle.
            // The clip must be on the Rectangle that has the radius.
            Rectangle {
                id: avatarCircle
                width: 96
                height: 96
                radius: width / 2
                clip: true                      // <-- this clips Image to the circle
                border.width: root.cBorderWidth
                border.color: root.cBorder

                Image {
                    anchors.fill: parent
                    source: AppConfig.profileImage.startsWith("file:")
                            ? AppConfig.profileImage
                            : "file://" + AppConfig.profileImage
                    fillMode: Image.PreserveAspectCrop
                }
            }

            // Border overlay on top so it isn't obscured by the image
            Rectangle {
                anchors.fill: avatarCircle
                radius: width / 2
                color: "transparent"
                border.width: root.cBorderWidth
                border.color: root.cBorder
            }

            Text {
                anchors.centerIn: avatarCircle
                text: "?"
                color: root.cFg
                font.family: root.cFont
                font.pixelSize: 28
                visible: AppConfig.profileImage.toString().length === 0
            }
        }

        Text {
            width: root.width
            text: "welcome\n" + AppConfig.username
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideRight
        }
    }
}
