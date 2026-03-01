import QtQuick
import QtQuick.Layouts

Item {
    id: root
    clip: true

    property color  cFg:       "white"
    property color  cMuted:    "#888888"
    property string cFont:     "sans"
    property int    cFontSize: 16
    property string selectedDateKey: ""
    property int    taskIndent: 8
    property int    taskCharCutoff: 240

    function load(dateKey) {
        selectedDateKey = dateKey
        reloadCurrent()
    }

    function reloadCurrent() {
        tasksModel.clear()
        if (!selectedDateKey.length) return

        const tasks = AppConfig.tasksForDate(selectedDateKey)
        for (let i = 0; i < tasks.length; i++) {
            const raw = tasks[i].toString().trim()
            if (!raw.length) continue
            const cutoff = taskCharCutoff > 0 ? taskCharCutoff : 240
            const text = raw.length > cutoff ? raw.slice(0, cutoff) + "..." : raw
            tasksModel.append({ text: text })
        }
    }

    ListModel { id: tasksModel }

    ListView {
        anchors.fill: parent
        model: tasksModel
        spacing: 8
        clip: true

        delegate: Item {
            width: ListView.view.width
            height: Math.max(bullet.implicitHeight, line.implicitHeight)

            Text {
                id: bullet
                text: "•"
                color: root.cFg
                font.family: root.cFont
                font.pixelSize: root.cFontSize
                anchors.left: parent.left
                anchors.leftMargin: root.taskIndent
            }

            Text {
                id: line
                text: model.text
                textFormat: Text.PlainText
                color: root.cFg
                font.family: root.cFont
                font.pixelSize: root.cFontSize
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.leftMargin: root.taskIndent + 22
                anchors.right: parent.right
                anchors.rightMargin: root.taskIndent
            }
        }

        footer: Text {
            visible: tasksModel.count === 0
            text: "No tasks."
            color: root.cMuted
            font.family: root.cFont
            font.pixelSize: root.cFontSize
            x: root.taskIndent
        }
    }
}
