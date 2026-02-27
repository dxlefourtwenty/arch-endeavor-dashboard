pragma Singleton
import QtQuick

QtObject {

    /* ---- colors (mirror rofi) ---- */

    property color bg:        "#0f111a"
    property color bg2:       "#161a27"
    property color fg:        "#cdd6f4"
    property color muted:     "#7b829a"
    property color accent:    "#c792ea"
    property color border:    "#3a3f55"

    /* ---- styling ---- */

    property real opacity: 0.9
    property int borderWidth: 2
    property int radius: 0

    property string font: "JetBrainsMono Nerd Font"
    property int fontSize: 16
}
