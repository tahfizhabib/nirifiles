import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: cal

    anchors.top:   true
    anchors.left:  true
    anchors.right: false

    implicitWidth:  340
    implicitHeight: 460
    color: "transparent"
    visible: false

    WlrLayershell.namespace:     "niriha-cal"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.margins.top:   30
    WlrLayershell.margins.left:  60

    // ── State ─────────────────────────────────────────────────────────
    property int  viewYear:  0
    property int  viewMonth: 0  // 1-12

    readonly property var days:    ["Mo","Tu","We","Th","Fr","Sa","Su"]
    readonly property var months:  ["January","February","March","April","May","June",
                                    "July","August","September","October","November","December"]
    readonly property var dayNames:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

    // live clock
    property string clockH:  "00"
    property string clockM:  "00"
    property string clockS:  "00"
    property string dayName: ""
    property string dateStr: ""

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var h24 = now.getHours()
            var h12 = h24 % 12; if (h12 === 0) h12 = 12
            cal.clockH  = h12.toString()
            cal.clockM  = ("0" + now.getMinutes()).slice(-2)
            cal.clockS  = ("0" + now.getSeconds()).slice(-2)
            cal.dayName = cal.dayNames[now.getDay()]
            var mo = cal.months[now.getMonth()]
            cal.dateStr = mo + " " + now.getDate()
            if (cal.viewYear === 0) {
                cal.viewYear  = now.getFullYear()
                cal.viewMonth = now.getMonth() + 1
            }
        }
    }

    // days in month
    function daysInMonth(y, m) {
        return new Date(y, m, 0).getDate()
    }
    // weekday of first (Mon=0 .. Sun=6)
    function firstWeekday(y, m) {
        var d = new Date(y, m-1, 1).getDay()
        return (d + 6) % 7
    }

    function prevMonth() {
        if (cal.viewMonth === 1) { cal.viewMonth = 12; cal.viewYear-- }
        else cal.viewMonth--
    }
    function nextMonth() {
        if (cal.viewMonth === 12) { cal.viewMonth = 1; cal.viewYear++ }
        else cal.viewMonth++
    }

    onVisibleChanged: {
        if (visible) {
            var now = new Date()
            viewYear  = now.getFullYear()
            viewMonth = now.getMonth() + 1
        }
    }

    // ── Background — top straight, bottom rounded like WallpaperMenu ────
    Item {
        anchors.fill: parent
        opacity: 0.96
        Rectangle {
            anchors.fill: parent
            color: "#282828"; radius: 10
            Rectangle {
                anchors.top:   parent.top
                anchors.left:  parent.left
                anchors.right: parent.right
                height: 10; color: "#282828"
            }
        }
    }

    ColumnLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 8

        // ── Time + day/date header ────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 80; radius: 8; color: "#3c3836"

            // big time left
            Text {
                anchors.left:           parent.left
                anchors.leftMargin:     14
                anchors.verticalCenter: parent.verticalCenter
                text: cal.clockH + ":" + cal.clockM
                color: "#ebdbb2"; font.family: "Google Sans"
                font.pixelSize: 54; font.weight: Font.Medium
            }

            // day name top-right
            Text {
                anchors.right:        parent.right
                anchors.rightMargin:  14
                anchors.top:          parent.top
                anchors.topMargin:    14
                text: cal.dayName
                color: "#ebdbb2"; font.family: "Google Sans"
                font.pixelSize: 18; font.weight: Font.Medium
            }

            // date bottom-right
            Text {
                anchors.right:         parent.right
                anchors.rightMargin:   14
                anchors.bottom:        parent.bottom
                anchors.bottomMargin:  14
                text: cal.dateStr
                color: "#83a598"; font.family: "Google Sans"
                font.pixelSize: 17
            }
        }

        // ── Calendar card ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            id: calCard
            height: 348; radius: 8; color: "#3c3836"

            ColumnLayout {
                anchors { fill: parent; margins: 12 }
                spacing: 6

                // month nav
                RowLayout {
                    Layout.fillWidth: true

                    Item { width: 28; height: 28
                        Text { anchors.centerIn: parent; text: "‹"
                            color: arL.containsMouse ? "#ebdbb2" : "#665c54"
                            font.pixelSize: 20; font.weight: Font.Medium
                            Behavior on color { ColorAnimation { duration: 80 } } }
                        MouseArea { id: arL; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor; onClicked: cal.prevMonth() }
                    }

                    Text {
                        Layout.fillWidth: true; text: cal.months[cal.viewMonth-1] + " " + cal.viewYear
                        color: "#ebdbb2"; font.family: "Google Sans"
                        font.pixelSize: 18; font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { width: 28; height: 28
                        Text { anchors.centerIn: parent; text: "›"
                            color: arR.containsMouse ? "#ebdbb2" : "#665c54"
                            font.pixelSize: 20; font.weight: Font.Medium
                            Behavior on color { ColorAnimation { duration: 80 } } }
                        MouseArea { id: arR; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor; onClicked: cal.nextMonth() }
                    }
                }

                // day headers
                Row {
                    Layout.fillWidth: true
                    spacing: 0
                    Repeater {
                        model: cal.days
                        Text {
                            required property var modelData
                            width: Math.floor((calCard.width - 24) / 7)
                            text: modelData
                            color: "#a89984"; font.family: "Google Sans"
                            font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#504945"; opacity: 0.3 }

                // calendar grid
                Grid {
                    Layout.fillWidth: true
                    columns: 7
                    spacing: 0
                    horizontalItemAlignment: Grid.AlignHCenter

                    property int totalDays:  cal.daysInMonth(cal.viewYear, cal.viewMonth)
                    property int startOff:   cal.firstWeekday(cal.viewYear, cal.viewMonth)
                    property int todayDay:   new Date().getDate()
                    property int todayMonth: new Date().getMonth() + 1
                    property int todayYear:  new Date().getFullYear()
                    property int cellW:      Math.floor((calCard.width - 24) / 7)

                    Repeater {
                        model: 42
                        delegate: Item {
                            required property int index
                            width:  parent.cellW
                            height: 42

                            property int dayNum: index - parent.startOff + 1
                            property bool valid: dayNum >= 1 && dayNum <= parent.totalDays
                            property bool isToday: valid &&
                                dayNum === parent.todayDay &&
                                cal.viewMonth === parent.todayMonth &&
                                cal.viewYear  === parent.todayYear

                            Rectangle {
                                anchors.centerIn: parent
                                width: 32; height: 32; radius: 16
                                color: isToday ? "#2a6050" : (dMa.containsMouse && valid ? "#504945" : "transparent")
                                Behavior on color { ColorAnimation { duration: 80 } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: valid ? dayNum.toString() : ""
                                color: isToday ? "#ebdbb2" : "#ebdbb2"
                                font.family: "Google Sans"; font.pixelSize: 16
                                font.weight: isToday ? Font.Medium : Font.Normal
                            }

                            MouseArea {
                                id: dMa; anchors.fill: parent
                                hoverEnabled: true; cursorShape: valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                    }
                }
            }
        }

        Item { height: 2 }
    }
}
