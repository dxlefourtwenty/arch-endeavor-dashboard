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

    function toggle() {
        if (open) {
            open = false
            hideTimer.restart()
        } else {
            visible = true
            hideTimer.stop()
            open = true
            calendar.refreshToToday()
            stage.forceActiveFocus()
        }
    }

    onActiveChanged: {
        if (!active && open) toggle()
    }

    Loader {
        id: themeLoader
        source: StandardPaths.writableLocation(StandardPaths.HomeLocation)
              + "/.config/dashboard/theme.qml"
    }

    Loader {
        id: styleLoader
        source: StandardPaths.writableLocation(StandardPaths.HomeLocation)
              + "/.config/dashboard/style.qml"
    }

    property var theme: themeLoader.item
    property var style: styleLoader.item

    property color  cBg:          (theme && theme.bg)                        ? theme.bg          : "#111111"
    property real   cOpacity:     (theme && theme.opacity !== undefined)      ? theme.opacity     : 1.0
    property int    cRadius:      (style && style.radius !== undefined)       ? style.radius
                                : (theme && theme.radius !== undefined)       ? theme.radius      : 0
    property int    cBorderWidth: (style && style.borderWidth !== undefined)  ? style.borderWidth
                                : (theme && theme.borderWidth !== undefined)  ? theme.borderWidth : 2
    property color  cBorder:      (theme && theme.border)                    ? theme.border      : "#444444"
    property color  cFg:          (theme && theme.fg)                        ? theme.fg          : "white"
    property color  cMuted:       (theme && theme.muted)                     ? theme.muted       : "#888888"
    property string cFont:        (style && style.font)                      ? style.font
                                : (theme && theme.font)                      ? theme.font        : "sans"
    property int    cFontSize:    (style && style.fontSize !== undefined)     ? style.fontSize
                                : (theme && theme.fontSize !== undefined)     ? theme.fontSize    : 16
    property int    barHeight:    (style && style.barHeight !== undefined)    ? style.barHeight   : 30
    property int    taskCharCutoff: (style && style.taskCharCutoff !== undefined) ? style.taskCharCutoff : 240

    // Inner card layout tuning (edit these to control per-component padding and sizing)
    property int panelOuterMargin: 16
    property int panelColumnSpacing: 14
    property int panelRowSpacing: 14

    property int profilePaddingTop: 32
    property int profilePaddingLeft: 12
    property int profilePaddingRight: 18
    property int profilePaddingBottom: 12

    property int calendarPaddingTop: 18
    property int calendarPaddingLeft: 18
    property int calendarPaddingRight: 18
    property int calendarPaddingBottom: 18

    property int statsPaddingTop: 18
    property int statsPaddingLeft: 18
    property int statsPaddingRight: 18
    property int statsPaddingBottom: 18

    property int tasksPaddingTop: 18
    property int tasksPaddingLeft: 18
    property int tasksPaddingRight: 18
    property int tasksPaddingBottom: 18

    property real profileCardWidthWeight: 0.95
    property real profileCardHeightWeight: 1.0
    property real calendarCardWidthWeight: 1.55
    property real calendarCardHeightWeight: 1.70
    property real statsCardWidthWeight: 0.95
    property real statsCardHeightWeight: 1.0
    property real tasksCardWidthWeight: 1.55
    property real tasksCardHeightWeight: 1.0

    // Minimum content sizes used to keep cards from clipping when padding/margins increase.
    property int profileMinContentWidth: 180
    property int profileMinContentHeight: 170
    property int calendarMinContentWidth: 300
    property int calendarMinContentHeight: 230
    property int statsMinContentWidth: 180
    property int statsMinContentHeight: 130
    property int tasksMinContentWidth: 300
    property int tasksMinContentHeight: 130

    property int profileMinWidth: profileMinContentWidth + profilePaddingLeft + profilePaddingRight
    property int profileMinHeight: profileMinContentHeight + profilePaddingTop + profilePaddingBottom
    property int calendarMinWidth: calendarMinContentWidth + calendarPaddingLeft + calendarPaddingRight
    property int calendarMinHeight: calendarMinContentHeight + calendarPaddingTop + calendarPaddingBottom
    property int statsMinWidth: statsMinContentWidth + statsPaddingLeft + statsPaddingRight
    property int statsMinHeight: statsMinContentHeight + statsPaddingTop + statsPaddingBottom
    property int tasksMinWidth: tasksMinContentWidth + tasksPaddingLeft + tasksPaddingRight
    property int tasksMinHeight: tasksMinContentHeight + tasksPaddingTop + tasksPaddingBottom

    property int panelBaseWidth: 640
    property int panelBaseHeight: 440
    property int panelMinWidthFromLayout: panelOuterMargin * 2
                                        + panelColumnSpacing
                                        + Math.max(profileMinWidth, statsMinWidth)
                                        + Math.max(calendarMinWidth, tasksMinWidth)
    property int panelMinHeightFromLayout: panelOuterMargin * 2
                                         + panelRowSpacing
                                         + Math.max(profileMinHeight, calendarMinHeight)
                                         + Math.max(statsMinHeight, tasksMinHeight)
    property int panelW: Math.max(panelBaseWidth, panelMinWidthFromLayout)
    property int panelH: Math.max(panelBaseHeight, panelMinHeightFromLayout)

    function reloadTheme() {
        themeLoader.active = false
        themeLoader.active = true
        styleLoader.active = false
        styleLoader.active = true
    }

    function reloadTasks() {
        taskView.reloadCurrent()
    }

    height: panelH
    minimumHeight: panelH
    maximumHeight: panelH
    width: panelW
    minimumWidth: panelW
    maximumWidth: panelW

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
            width: win.panelW
            height: win.panelH
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

            GridLayout {
                anchors.fill: parent
                anchors.margins: win.panelOuterMargin
                columns: 2
                columnSpacing: win.panelColumnSpacing
                rowSpacing: win.panelRowSpacing

                Rectangle {
                    Layout.row: 0
                    Layout.column: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: win.profileCardWidthWeight
                    Layout.preferredHeight: win.profileCardHeightWeight
                    Layout.minimumWidth: win.profileMinWidth
                    Layout.minimumHeight: win.profileMinHeight
                    radius: 8
                    clip: true
                    color: "transparent"
                    border.width: win.cBorderWidth
                    border.color: win.cMuted

                    ProfileCard {
                        anchors.fill: parent
                        anchors.topMargin: win.profilePaddingTop
                        anchors.leftMargin: win.profilePaddingLeft
                        anchors.rightMargin: win.profilePaddingRight
                        anchors.bottomMargin: win.profilePaddingBottom
                        cFg: win.cFg
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                        cBorder: win.cBorder
                        cBorderWidth: win.cBorderWidth
                    }
                }

                Rectangle {
                    id: calView
                    Layout.row: 0
                    Layout.column: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: win.calendarCardWidthWeight
                    Layout.preferredHeight: win.calendarCardHeightWeight
                    Layout.minimumWidth: win.calendarMinWidth
                    Layout.minimumHeight: win.calendarMinHeight
                    radius: 8
                    clip: true
                    color: "transparent"
                    border.width: win.cBorderWidth
                    border.color: win.cMuted

                    CalendarView {
                        id: calendar
                        anchors.fill: parent
                        anchors.topMargin: win.calendarPaddingTop
                        anchors.leftMargin: win.calendarPaddingLeft
                        anchors.rightMargin: win.calendarPaddingRight
                        anchors.bottomMargin: win.calendarPaddingBottom

                        cFg: win.cFg
                        cMuted: win.cMuted
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                        cBg: win.cBg
                        cBorder: win.cBorder
                        cBorderWidth: win.cBorderWidth
                        cRadius: win.cRadius

                        // property signal carries no argument -- read from the id
                        onSelectedKeyChanged: taskView.load(calendar.selectedKey)
                    }
                }

                Rectangle {
                    Layout.row: 1
                    Layout.column: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: win.statsCardWidthWeight
                    Layout.preferredHeight: win.statsCardHeightWeight
                    Layout.minimumWidth: win.statsMinWidth
                    Layout.minimumHeight: win.statsMinHeight
                    radius: 8
                    clip: true
                    color: "transparent"
                    border.width: win.cBorderWidth
                    border.color: win.cMuted

                    StatsCard {
                        anchors.fill: parent
                        anchors.topMargin: win.statsPaddingTop
                        anchors.leftMargin: win.statsPaddingLeft
                        anchors.rightMargin: win.statsPaddingRight
                        anchors.bottomMargin: win.statsPaddingBottom
                        cFg: win.cFg
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                    }
                }

                Rectangle {
                    Layout.row: 1
                    Layout.column: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: win.tasksCardWidthWeight
                    Layout.preferredHeight: win.tasksCardHeightWeight
                    Layout.minimumWidth: win.tasksMinWidth
                    Layout.minimumHeight: win.tasksMinHeight
                    radius: 8
                    clip: true
                    color: "transparent"
                    border.width: win.cBorderWidth
                    border.color: win.cMuted

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.topMargin: win.tasksPaddingTop
                        anchors.leftMargin: win.tasksPaddingLeft
                        anchors.rightMargin: win.tasksPaddingRight
                        anchors.bottomMargin: win.tasksPaddingBottom

                        Text {
                            Layout.fillWidth: true
                            text: calendar.selectedDisplayDate
                            color: win.cFg
                            font.family: win.cFont
                            font.pixelSize: win.cFontSize * 1.012
                            elide: Text.ElideRight
                        }

                    TasksView {
                        id: taskView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        cFg: win.cFg
                        cMuted: win.cMuted
                        cFont: win.cFont
                        cFontSize: win.cFontSize
                        taskCharCutoff: win.taskCharCutoff
                    }
                }
            }
        }
        }
    }

    Component.onCompleted: taskView.load(calendar.selectedKey)
}
