import QtQuick
import QtCore
import QtQuick.Layouts

// TasksView.qml
//
// Call load(dateKey) with a "YYYY-MM-DD" string whenever the selected date changes.

Item {
    id: root
    clip: true

    property color  cFg:       "white"
    property color  cMuted:    "#888888"
    property string cFont:     "sans"
    property int    cFontSize: 16

    function load(dateKey) {
        tasksModel.clear()

        const path = StandardPaths.writableLocation(StandardPaths.HomeLocation)
                   + "/.local/share/topdash/tasks/" + dateKey + ".txt"

        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + path)
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status !== 200) return
            const lines = xhr.responseText.split("\n")
            for (let i = 0; i < lines.length; i++) {
                const t = lines[i].trim()
                if (t.length) tasksModel.append({ text: t })
            }
        }
        xhr.send()
    }

    ListModel { id: tasksModel }

    ListView {
        anchors.fill: parent
        model: tasksModel
        spacing: 8
        clip: true

        delegate: Text {
            text: "• " + model.text
            color: root.cFg
            font.family: root.cFont
            font.pixelSize: root.cFontSize
            wrapMode: Text.WrapAnywhere
            width: ListView.view.width
        }

        footer: Text {
            visible: tasksModel.count === 0
            text: "No tasks."
            color: root.cMuted
            font.family: root.cFont
            font.pixelSize: root.cFontSize
        }
    }
}
