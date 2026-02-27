import QtQuick
import QtCore
import QtQuick.Window
import org.kde.layershell 1.0 as LS

Window {
    id: win

    property bool open: false // start hidden
    property int animMs: 180
    property int barHeight: 30

    function toggle() {
        if (open) {
            // close: animate up, then hide surface so it stops blocking clicks
            open = false
            hideTimer.restart()
        } else {
            // open: show surface first, then animate down
            visible = true
            hideTimer.stop()
            open = true
            stage.forceActiveFocus()
        }
    }

    onActiveChanged: {
        if (!active && open)
            toggle()
    }

    Loader {
        id: themeLoader
        source: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation
                ) + "/.config/dashboard/theme.qml"
    }

    property var theme: themeLoader.item

    // Force a fixed layer-surface height so it doesn't become fullscreen
    property int panelH: 300

    height: panelH
    minimumHeight: panelH
    maximumHeight: panelH

    // width will be controlled by anchors left+right anyway
    width: 900

    visible: false
    color: "transparent"

    // allow clicks to pass through when closed
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Layer-shell attached properties
    LS.Window.margins.top: barHeight
    LS.Window.layer: LS.Window.LayerOverlay
    LS.Window.anchors: LS.Window.AnchorTop | LS.Window.AnchorLeft | LS.Window.AnchorRight
    LS.Window.exclusionZone: -1
    LS.Window.keyboardInteractivity: open ? LS.Window.KeyboardInteractivityOnDemand
                                         : LS.Window.KeyboardInteractivityNone

    Timer {
        id: hideTimer
        interval: win.animMs
        repeat: false
        onTriggered: {
            if (!win.open) win.visible = false
        }
    }

    function reloadTheme() {
        themeLoader.active = false
        themeLoader.active = true
    }

    // Animate the panel INSIDE the window (Wayland-safe)
    Item {
        id: stage
        anchors.fill: parent
        focus: true
        clip: true

        Keys.onPressed: (e) => {
          if (e.key === Qt.Key_Escape) {
              win.toggle();
              e.accepted = true;
          }

          if (e.key === Qt.Key_Space) { 
              win.open = !win.open;
          }
        }

        // ---- Rofi-like panel ----
        Rectangle {
            id: panel

            // size (keep whatever you had)
            width: Math.min(stage.width * 0.60, 700)
            height: win.panelH
            anchors.horizontalCenter: parent.horizontalCenter

            // rofi look
            radius: theme.radius
            color: theme
              ? Qt.rgba(
                  theme.bg.r,
                  theme.bg.g,
                  theme.bg.b,
                  theme.opacity
                )
              : "#111111"
            border.width: 0

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                // left
                Rectangle {
                    width: theme ? theme.borderWidth : 2
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: theme ? theme.border : "#444"
                }

                // right
                Rectangle {
                    width: theme ? theme.borderWidth : 2
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: theme ? theme.border : "#444"
                }

                // bottom
                Rectangle {
                    height: theme ? theme.borderWidth : 2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: theme ? theme.border : "#444"
                }
            }

            // slide
            y: win.open ? 0 : (-height - 12)
            Behavior on y {
                    NumberAnimation { duration: win.animMs; easing.type: Easing.OutCubic }
                }
            // padding container
            Item {
                anchors.fill: parent
                anchors.margins: 20                   

                // Title like your launcher
                Text {
                    text: "Dashboard"
                    color: theme ? theme.fg : "white"                  
                    font.family: theme ? theme.font : "sans"
                    font.pixelSize: theme ? theme.fontSize : 14
                }

                // Example list area spacing like rofi listview
                Column {
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    spacing: 8

                    Repeater {
                        model: 6
                        delegate: Item {
                            width: parent.width
                            height: 34

                            Row {
                                anchors.fill: parent
                                spacing: 12

                                // icon placeholder (24px)
                                Rectangle {
                                    width: 24; height: 24
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "transparent"
                                    border.width: 0
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Item " + (index + 1)
                                    color: theme ? theme.fg : "white"
                                    font.family: theme ? theme.font : "sans"
                                    font.pixelSize: theme ? theme.fontSize : 14
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
