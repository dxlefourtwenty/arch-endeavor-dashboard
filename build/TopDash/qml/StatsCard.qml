import QtQuick

// StatsCard.qml
// Each Text is bound individually so SystemInfo property-change signals
// propagate correctly. A JS object array model breaks live QML bindings.

Rectangle {
    id: root

    property color  cFg:       "white"
    property string cFont:     "sans"
    property int    cFontSize: 16
    property int    titleInset: 30
    property real   usageFontSize: cFontSize * 1.012

    color: "transparent"

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.titleInset
        spacing: 10

        Text {
            width: parent.width
            text: "Usage"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.usageFontSize
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            width: parent.width
            text: "CPU: " + SystemInfo.cpuUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.usageFontSize
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            width: parent.width
            text: "GPU: " + SystemInfo.gpuUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.usageFontSize
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            width: parent.width
            text: "RAM: " + SystemInfo.ramUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.usageFontSize
            horizontalAlignment: Text.AlignLeft
        }
        Text {
            width: parent.width
            text: "DISK: " + SystemInfo.diskUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.usageFontSize
            horizontalAlignment: Text.AlignLeft
        }
    }
}
