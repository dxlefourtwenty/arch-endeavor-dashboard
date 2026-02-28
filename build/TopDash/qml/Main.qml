import QtQuick
import QtCore
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
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

    property string profileImagePath:
        "file:///home/dxle/bin/images/profile-picture.png"

    Loader {
        id: themeLoader
        source: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation
                ) + "/.config/themes/current/dashboard.qml"
    }

    property var theme: themeLoader.item

    property color cBg: (theme && theme.bg) ? theme.bg : "#111111"
    property real cOpacity: (theme && theme.opacity !== undefined) ? theme.opacity : 1.0
    property int cRadius: (theme && theme.radius !== undefined) ? theme.radius : 0
    property int cBorderWidth: (theme && theme.borderWidth !== undefined) ? theme.borderWidth : 2
    property color cBorder: (theme && theme.border) ? theme.border : "#444444"
    property color cFg: (theme && theme.fg) ? theme.fg : "white"
    property color cMuted: (theme && theme.muted) ? theme.muted : "#888888"
    property string cFont: (theme && theme.font) ? theme.font : "sans"
    property int cFontSize: (theme && theme.fontSize !== undefined) ? theme.fontSize : 16

    // Force a fixed layer-surface height so it doesn't become fullscreen
    property int panelH: 560

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

    // ---- date selection ----
    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()        // 0-11
    property int selectedDay: today.getDate()

    function daysInMonth(y, m0) { // m0 = 0-11
        return new Date(y, m0 + 1, 0).getDate()
    }
    function firstWeekday(y, m0) { // 0=Sun..6=Sat
        return new Date(y, m0, 1).getDay()
    }
    function pad2(n) { return (n < 10 ? "0" : "") + n }
    function selectedKey() {
        return viewYear + "-" + pad2(viewMonth + 1) + "-" + pad2(selectedDay)
    }

    // tasks model
    ListModel { id: tasksModel }

    function loadTasks() {
        tasksModel.clear()

        const p = StandardPaths.writableLocation(StandardPaths.HomeLocation)
                + "/.local/share/topdash/tasks/" + selectedKey() + ".txt"

        // read file with XHR (file path)
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + p)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status !== 200) return // no file -> empty list
            const lines = xhr.responseText.split("\n")
            for (let i = 0; i < lines.length; i++) {
                const t = lines[i].trim()
                if (t.length) tasksModel.append({ text: t })
            }
        }
        xhr.send()
    }

    onViewYearChanged: loadTasks()
    onViewMonthChanged: loadTasks()
    onSelectedDayChanged: loadTasks()
    Component.onCompleted: loadTasks()


    // Animate the panel INSIDE the window (Wayland-safe)
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
            width: stage.width > 10 ? Math.min(stage.width * 0.75, 900) : 900
            height: 520
            anchors.horizontalCenter: parent.horizontalCenter

            y: win.open ? 0 : (-height - 12)
            Behavior on y { NumberAnimation { duration: win.animMs; easing.type: Easing.OutCubic } }

            radius: cRadius
            color: Qt.rgba(cBg.r, cBg.g, cBg.b, cOpacity)
            border.width: 0 // no top border look; we draw custom sides/bottom below

            // sides + bottom borders (integrates with waybar)
            Rectangle { width: theme ? cBorderWidth : 2; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; color: theme ? cBorder : "#444" }
            Rectangle { width: theme ? cBorderWidth : 2; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; color: theme ? cBorder : "#444" }
            Rectangle { height: theme ? cBorderWidth : 2; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; color: theme ? cBorder : "#444" }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 18

                // ---- Left column: Profile + Stats ----
                ColumnLayout {
                    Layout.preferredWidth: 280
                    spacing: 18

                    // Profile card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        radius: 0
                        color: "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 10

                            // circle avatar
                            Item {
                                width: 96
                                height: 96
                                clip: true

                                Rectangle {
                                    width: 96
                                    height: 96
                                    radius: width / 2

                                    border.width: theme ? cBorderWidth : 2
                                    border.color: theme ? cBorder : "#444"

                                    Image {
                                        anchors.fill: parent
                                        source: (AppConfig.profileImage.startsWith("file:") ? AppConfig.profileImage
                                                    : "file://" + AppConfig.profileImage)
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }

                                // border as overlay so it renders on top, still clipped to circle
                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.width: cBorderWidth
                                    border.color: cBorder
                                }

                                // fallback if no image
                                Text {
                                    anchors.centerIn: parent
                                    text: "?"
                                    color: theme ? cFg : "white"
                                    font.family: theme ? cFont : "sans"
                                    font.pixelSize: 28
                                    visible: AppConfig.profileImage.toString().length === 0
                                }
                            }

                            Text {
                                text: "welcome\n" + AppConfig.username
                                color: theme ? cFg : "white"
                                font.family: theme ? cFont : "sans"
                                font.pixelSize: theme ? cFontSize : 16
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // Stats card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        color: "transparent"

                        Column {
                            anchors.fill: parent
                            spacing: 10

                            function line(label, value) { return label + ": " + value + "%" }

                            Text {
                                text: "CPU: " + SystemInfo.cpuUsage + "%"
                                color: theme ? cFg : "white"
                                font.family: cFont
                                font.pixelSize: cFontSize
                            }

                            Text {
                                text: "GPU: " + SystemInfo.gpuUsage + "%"
                                color: theme ? cFg : "white"
                                font.family: cFont
                                font.pixelSize: cFontSize
                            }

                            Text {
                                text: "RAM: " + SystemInfo.ramUsage + "%"
                                color: theme ? cFg : "white"
                                font.family: cFont
                                font.pixelSize: cFontSize
                            }

                            Text {
                                text: "DISK: " + SystemInfo.diskUsage + "%"
                                color: theme ? cFg : "white"
                                font.family: cFont
                                font.pixelSize: cFontSize
                            }
                        }
                    }
                }

                // ---- Right side: Calendar + Tasks ----
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Month header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Button {
                            text: "<"
                            onClicked: {
                                if (viewMonth === 0) { viewMonth = 11; viewYear -= 1 }
                                else viewMonth -= 1
                                selectedDay = 1
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Qt.formatDate(new Date(viewYear, viewMonth, 1), "MMMM yyyy")
                            color: theme ? cFg : "white"
                            font.family: theme ? cFont : "sans"
                            font.pixelSize: (theme ? cFontSize : 16) + 2
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Button {
                            text: ">"
                            onClicked: {
                                if (viewMonth === 11) { viewMonth = 0; viewYear += 1 }
                                else viewMonth += 1
                                selectedDay = 1
                            }
                        }
                    }

                    // weekday labels
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Repeater {
                            model: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                            delegate: Text {
                                Layout.fillWidth: true
                                text: modelData
                                color: theme ? cMuted : "#999"
                                font.family: theme ? cFont : "sans"
                                font.pixelSize: theme ? cFontSize : 16
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // calendar grid
                    GridLayout {
                        id: calGrid
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 8
                        columnSpacing: 8

                        property int lead: firstWeekday(viewYear, viewMonth)
                        property int dim: daysInMonth(viewYear, viewMonth)
                        property int cells: 42

                        Repeater {
                            model: calGrid.cells
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36

                                property int idx: index
                                property int dayNum: idx - calGrid.lead + 1
                                property bool inMonth: dayNum >= 1 && dayNum <= calGrid.dim
                                property bool selected: inMonth && dayNum === selectedDay

                                radius: 0
                                color: selected ? (theme ? cBg : "#222") : "transparent"
                                border.width: selected ? (theme ? cBorderWidth : 2) : 0
                                border.color: theme ? cBorder : "#444"

                                Text {
                                    anchors.centerIn: parent
                                    text: inMonth ? dayNum : ""
                                    color: theme ? cFg : "white"
                                    font.family: theme ? cFont : "sans"
                                    font.pixelSize: theme ? cFontSize : 16
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: inMonth
                                    onClicked: {
                                        selectedDay = dayNum
                                    }
                                }
                            }
                        }
                    }

                    // selected date + tasks
                    Text {
                        Layout.topMargin: 6
                        text: "Selected: " + selectedKey()
                        color: theme ? cFg : "white"
                        font.family: theme ? cFont : "sans"
                        font.pixelSize: theme ? cFontSize : 16
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: tasksModel
                        spacing: 8
                        clip: true

                        delegate: Text {
                            text: "• " + model.text
                            color: theme ? cFg : "white"
                            font.family: theme ? cFont : "sans"
                            font.pixelSize: theme ? cFontSize : 16
                            wrapMode: Text.Wrap
                        }

                        // empty state
                        footer: Text {
                            visible: tasksModel.count === 0
                            text: "No tasks."
                            color: theme ? cMuted : "#999"
                            font.family: theme ? cFont : "sans"
                            font.pixelSize: theme ? cFontSize : 16
                        }
                    }
                }
            }
        }
    }
}
