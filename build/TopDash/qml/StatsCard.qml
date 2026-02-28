import QtQuick

// StatsCard.qml
// Each Text is bound individually so SystemInfo property-change signals
// propagate correctly. A JS object array model breaks live QML bindings.

Rectangle {
    id: root

    property color  cFg:       "white"
    property string cFont:     "sans"
    property int    cFontSize: 16

    color: "transparent"

    Column {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "CPU: " + SystemInfo.cpuUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
        }
        Text {
            text: "GPU: " + SystemInfo.gpuUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
        }
        Text {
            text: "RAM: " + SystemInfo.ramUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
        }
        Text {
            text: "DISK: " + SystemInfo.diskUsage + "%"
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
        }
    }
}
