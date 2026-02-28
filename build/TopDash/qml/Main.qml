import QtQuick
import QtCore
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.layershell 1.0 as LS

Window {
    id: win

    property bool open: false
    property int animMs: 180
    property int barHeight: 30

    function toggle() {
        if (open) {
            open = false
            hideTimer.restart()
        } else {
            visible = true
            hideTimer.stop()
            open = true
            stage.forceActiveFocus()
        }
    }

    onActiveChanged: {
        if (!active && open) toggle()
    }

    Loader {
        id: themeLoader
        source: StandardPaths.writableLocation(StandardPaths.HomeLocation)
              + "/.config/themes/current/dashboard.qml"
    }

    property var theme: themeLoader.item

    property color  cBg:          (theme && theme.bg)                        ? theme.bg          : "#111111"
    property real   cOpacity:     (theme && theme.opacity !== undefined)      ? theme.opacity     : 1.0
    property int    cRadius:      (theme && theme.radius !== undefined)       ? theme.radius      : 0
    property int    cBorderWidth: (theme && theme.borderWidth !== undefined)  ? theme.borderWidth : 2
    property color  cBorder:      (theme && theme.border)                    ? theme.border      : "#444444"
    property color  cFg:          (theme && theme.fg)                        ? theme.fg          : "white"
    property color  cMuted:       (theme && theme.muted)                     ? theme.muted       : "#888888"
    property string cFont:        (theme && theme.font)                      ? theme.font        : "sans"
    property int    cFontSize:    (theme && theme.fontSize !== undefined)     ? theme.fontSize    : 16

    function reloadTheme() {
        themeLoader.active = false
        themeLoader.active = true
    }

    property int panelH: 560
    height: panelH
    minimumHeight: panelH
    maximumHeight: panelH
    width: 900

    visible: false
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    LS.Window.margins.top: barHeight
    LS.Window.layer: LS.Window.LayerOverlay
    LS.Window.anchors: LS.Window.AnchorTop | LS.Window.AnchorLeft | LS.Window.AnchorRight
    LS.Window.exclusionZone: -1
    LS.Window.keyboardInteractivity: open
        ? LS.Window.KeyboardInteractivityOnDemand
        : LS.Window.KeyboardInteractivityNone

    Timer {
        id: hideTimer
        interval: win.animMs
        repeat: false
        onTriggered: { if (!win.open) win.visible = false }
    }

    Item {
        id: stage
        anchors.fill: parent
        focus: true
        clip: true

        Keys.onPressed: (e) => {
            if (e.key === Qt.Key_Escape) { win.toggle(); e.accepted = true }
        }

        Rectangle {
            id: panel
            width: stage.width > 10 ? Math.min(stage.width * 0.75, 700) : 700
            height: 520
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true

            y: win.open ? 0 : (-height - 12)
            Behavior on y { 
                NumberAnimation { 
                  duration: win.animMs; 
                  easing.type: Easing.OutCubic 
                } 
            }

            radius: win.cRadius
            color: Qt.rgba(win.cBg.r, win.cBg.g, win.cBg.b, win.cOpacity)
            border.width: 0

            // sides + bottom borders
            Rectangle { 
                width: win.cBorderWidth; 
                color: win.cBorder; 
                anchors { 
                    left: parent.left;  
                    top: parent.top; 
                    bottom: parent.bottom 
                }
            }
            Rectangle { 
              width: win.cBorderWidth; 
              color: win.cBorder; 
              anchors { right: parent.right; 
                  top: parent.top; 
                  bottom: parent.bottom 
              }
            }
            Rectangle { 
                height: win.cBorderWidth; 
                color: win.cBorder; 
                anchors { 
                    left: parent.left; 
                    right: parent.right; 
                    bottom: parent.bottom 
                } 
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18

                // ---- Left column ----
                ColumnLayout {
                    id: leftCol
                    Layout.minimumWidth: 220
                    Layout.preferredWidth: 220
                    Layout.maximumWidth: 220
                    Layout.fillHeight: true
                    spacing: 16

                    ProfileCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        cFg: win.cFg
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                        cBorder: win.cBorder
                        cBorderWidth: win.cBorderWidth
                    }

                    StatsCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        cFg: win.cFg
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                    }

                    // push cards to top
                    Item { 
                        Layout.fillHeight: true 
                    }
                }

                // ---- Right column ----
                ColumnLayout {
                    id: rightCol
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 0
                    Layout.preferredWidth: 0
                    spacing: 10

                    CalendarView {
                        id: calView
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        // Fixed height so the grid doesn't overflow the panel.
                        // 6 rows * ~34px + header rows + labels ≈ 340px
                        Layout.preferredHeight: 340
                        Layout.maximumHeight: 340

                        cFg: win.cFg
                        cMuted: win.cMuted
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                        cBg: win.cBg
                        cBorder: win.cBorder
                        cBorderWidth: win.cBorderWidth
                        cRadius: win.cRadius

                        // property signal carries no argument -- read from the id
                        onSelectedKeyChanged: taskView.load(calView.selectedKey)
                    }

                    TasksView {
                        id: taskView
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true
                        cFg: win.cFg
                        cMuted: win.cMuted
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                    }
                }
            }
        }
    }
}
