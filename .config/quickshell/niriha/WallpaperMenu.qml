import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: menu

    anchors.top:   true
    anchors.left:  false
    anchors.right: false

    implicitWidth:  740
    implicitHeight: 150
    color: "transparent"
    visible: false

    WlrLayershell.namespace:     "niri-wallpaper-menu"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.margins.top:   30

    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Wallpapers"
    readonly property string cacheDir:     Quickshell.env("HOME") + "/.cache/qs-wallpapers"
    property var    wallpapers:  []
    property var    _buf:        []
    property string currentWall: ""

    onVisibleChanged: {
        if (!visible) return
        menu._buf = []
        menu.wallpapers = []
        mkCache.running = false
        mkCache.running = true
    }

    Process {
        id: mkCache
        command: ["sh", "-c", "mkdir -p \"" + menu.cacheDir + "\""]
        running: false
        onRunningChanged: if (!running) { wallScan.running = false; wallScan.running = true }
    }

    Process {
        id: wallScan
        command: ["sh", "-c",
            "find \"" + menu.wallpaperDir + "\" -maxdepth 2 -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' " +
            "-o -iname '*.webp' -o -iname '*.bmp' \\) | sort | while read f; do " +
            "  base=$(basename \"$f\"); " +
            "  thumb=\"" + menu.cacheDir + "/${base%.*}.png\"; " +
            "  [ -f \"$thumb\" ] || magick \"$f\" -resize 320x200^ -gravity center -extent 320x200 \"$thumb\" 2>/dev/null; " +
            "  [ -f \"$thumb\" ] && echo \"$f|$thumb\"; " +
            "done"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (!line) return
                var parts = line.split("|")
                if (parts.length < 2) return
                var b = menu._buf.slice()
                b.push({ orig: parts[0], thumb: parts[1] })
                menu._buf = b
                menu.wallpapers = b
            }
        }
        onRunningChanged: if (!running) { swwwQuery.running = false; swwwQuery.running = true }
    }

    Process {
        id: swwwQuery
        command: ["swww", "query"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var m = data.match(/currently displaying:\s*(.+)/)
                if (m) menu.currentWall = m[1].trim()
            }
        }
    }

    function setWallpaper(path) {
        menu.currentWall = path
        swwwSet.running = false
        swwwSet.running = true
    }

    Process {
        id: swwwSet
        property string path: menu.currentWall
        command: ["swww", "img", "--transition-type", "fade", "--transition-duration", "0.8", menu.currentWall]
        running: false
    }

    Item {
        anchors.fill: parent
        opacity: 0.92
        Rectangle {
            anchors.fill: parent
            color: "#282828"
            radius: 10
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left; anchors.right: parent.right
                height: 10; color: "#282828"
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill:    parent
        anchors.margins: 12
        contentWidth:    wallRow.implicitWidth
        contentHeight:   height
        clip:            true
        flickableDirection: Flickable.HorizontalFlick

        WheelHandler {
            orientation:     Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            rotationScale:   -5
            target:          flick
            property:        "contentX"
        }
        WheelHandler {
            orientation:     Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            rotationScale:   -5
            target:          flick
            property:        "contentX"
        }

        Row {
            id: wallRow
            spacing: 10
            height:  parent.height

            Repeater {
                model: menu.wallpapers

                Item {
                    id: card
                    required property var modelData
                    readonly property bool active: menu.currentWall === modelData.orig

                    width: 164; height: 120

                    Rectangle {
                        anchors.fill: parent
                        radius: 7; clip: true; color: "#3c3836"
                        Image {
                            anchors.fill: parent
                            source:       "file://" + card.modelData.thumb
                            fillMode:     Image.PreserveAspectCrop
                            smooth:       true
                            asynchronous: true
                        }
                    }

                    Rectangle {
                        anchors.fill:  parent
                        radius:        0
                        color:         "transparent"
                        border.width:  card.active ? 3 : (ma.containsMouse ? 2 : 0)
                        border.color:  card.active ? "#83a598" : "#ebdbb2"
                    }

                    Rectangle {
                        visible:         card.active
                        width: 10; height: 10; radius: 5
                        color:           "#83a598"
                        anchors.bottom:  parent.bottom
                        anchors.right:   parent.right
                        anchors.margins: 7
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    menu.setWallpaper(card.modelData.orig)
                    }
                }
            }

            Text {
                visible:                menu.wallpapers.length === 0
                anchors.verticalCenter: parent.verticalCenter
                text:  "Generating thumbnails…"
                color: "#a89984"
                font.family: "Google Sans"; font.pixelSize: 13
            }
        }
    }
}
