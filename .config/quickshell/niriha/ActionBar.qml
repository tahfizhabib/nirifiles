import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: win

    property int  cpuPct:  0
    property real ramGb:   0
    property int  volPct:  0
    property bool volMute: false
    property var  wsData:  []
    property bool trayExpanded: false
    property bool calVisible:    false
    property bool statsVisible:  false

    anchors.top: true; anchors.left: true; anchors.right: true
    implicitHeight: 30
    color: "transparent"
    WlrLayershell.namespace: "niriha"

    // Bar background — narrowed with bottom-rounded corners, top flat
    Item {
        anchors.left:  parent.left;  anchors.leftMargin:  50
        anchors.right: parent.right; anchors.rightMargin: 50
        anchors.top:   parent.top
        height: parent.height
        opacity: 0.92
        clip: false

        Rectangle {
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.top:   parent.top
            anchors.topMargin: -10
            height: parent.height + 10
            color: "#282828"
            radius: 10
        }
    }

    // Right-click anywhere on bar to open control center
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                Qt.createQmlObject('import Quickshell.Io; Process{command:["qs","ipc","-c","niriha","call","controlcenter","toggle"];running:true}', parent, "cc")
        }
    }

    // ── LEFT capsule ──────────────────────────────────────────────────
    Rectangle {
        id: leftCap
        anchors.left: parent.left; anchors.leftMargin: 54
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - 8
        width: clockRow.implicitWidth + 14
        radius: 8
        color: "#3c3836"

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: win.calVisible = !win.calVisible
        }

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 5

            property string t: "00:00:00"
            property string d: "Mon, Jan 01"

            Timer {
                interval: 1000; running: true; repeat: true; triggeredOnStart: true
                onTriggered: {
                    var n = new Date()
                    clockRow.t = n.getHours().toString().padStart(2,'0') + ":" +
                                 n.getMinutes().toString().padStart(2,'0') + ":" +
                                 n.getSeconds().toString().padStart(2,'0')
                    var D = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                    var M = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                    clockRow.d = D[n.getDay()] + ", " + M[n.getMonth()] + " " +
                                 n.getDate().toString().padStart(2,'0')
                }
            }
            Text { text: clockRow.t; color: "#ebdbb2"; font.family: "Google Sans"; font.pixelSize: 14; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "|"; color: "#57514e"; font.family: "Google Sans"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
            Text { text: clockRow.d; color: "#ebdbb2"; font.family: "Google Sans"; font.pixelSize: 14; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // ── CENTER capsule ────────────────────────────────────────────────
    Rectangle {
        id: centerCap
        anchors.centerIn: parent
        height: parent.height - 8
        width: wsInner.implicitWidth + 14
        radius: 8
        color: "#3c3836"

        RowLayout {
            id: wsInner; anchors.centerIn: parent; spacing: 4

            Repeater {
                model: win.wsData
                Rectangle {
                    required property var modelData
                    readonly property bool foc: modelData.focused
                    readonly property bool occ: modelData.occupied
                    readonly property int  wid: modelData.idx

                    width: foc ? 26 : 17; height: 17; radius: 8
                    color: foc ? "#83a598" : (occ ? "#57514e" : "#504945")
                    border.width: 0
                    Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation  { duration: 100 } }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.createQmlObject(
                            'import Quickshell.Io; Process{command:["niri","msg","action","focus-workspace","' + wid + '"];running:true}',
                            win, "fw")
                    }
                }
            }
        }
    }

    // ── RIGHT capsule ─────────────────────────────────────────────────
    Rectangle {
        id: rightCap
        anchors.right: parent.right; anchors.rightMargin: 54
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - 8
        width: trayInner.implicitWidth + 8
        radius: 8
        color: "#3c3836"

        Row {
            id: trayInner
            anchors.left: parent.left; anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Item {
                id: trayToggle; width: 17; height: 17
                anchors.verticalCenter: parent.verticalCenter
                property bool _hov: false
                Image {
                    anchors.fill: parent; smooth: true
                    source: trayToggle._hov
                        ? "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ebdbb2' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='m10 16 4-4-4-4'/><path d='M3 12h11'/><path d='M3 8V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-3'/></svg>"
                        : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23ebdbb2' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M10 12h11'/><path d='m17 16 4-4-4-4'/><path d='M21 6.344V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-1.344'/></svg>"
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onEntered: trayToggle._hov = true
                    onExited:  trayToggle._hov = false
                    onClicked: win.trayExpanded = !win.trayExpanded
                }
            }

            Repeater {
                model: win.trayExpanded ? SystemTray.items : []
                delegate: Item {
                    required property var modelData
                    width: 17; height: 17; anchors.verticalCenter: parent.verticalCenter
                    Image { anchors.fill: parent; source: modelData.icon; smooth: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton && modelData.hasMenu)
                                modelData.display(win, mapToItem(win,0,0).x, mapToItem(win,0,0).y)
                            else modelData.activate()
                        }
                    }
                }
            }

            TrayPill { valueText: win.cpuPct+"%"; accentColor: "#83a598"
                onClicked: win.statsVisible = !win.statsVisible
                iconSvg: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20v2"/><path d="M12 2v2"/><path d="M17 20v2"/><path d="M17 2v2"/><path d="M2 12h2"/><path d="M2 17h2"/><path d="M2 7h2"/><path d="M20 12h2"/><path d="M20 17h2"/><path d="M20 7h2"/><path d="M7 20v2"/><path d="M7 2v2"/><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="8" y="8" width="8" height="8" rx="1"/></svg>' }
            TrayPill { valueText: win.ramGb.toFixed(1)+"G"; accentColor: "#8ec07c"
                onClicked: win.statsVisible = !win.statsVisible
                iconSvg: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 12h4"/><path d="M10 17h4"/><path d="M10 7h4"/><path d="M18 12h2"/><path d="M18 18h2"/><path d="M18 6h2"/><path d="M4 12h2"/><path d="M4 18h2"/><path d="M4 6h2"/><rect x="6" y="2" width="12" height="20" rx="2"/></svg>' }
            TrayPill {
                onClicked: win.statsVisible = !win.statsVisible
                valueText: win.volMute ? "mute" : (win.volPct+"%")
                accentColor: win.volMute ? "#fb4934" : "#d3869b"
                iconSvg: {
                    if (win.volMute) return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 9a5 5 0 0 1 .95 2.293"/><path d="M19.364 5.636a9 9 0 0 1 1.889 9.96"/><path d="m2 2 20 20"/><path d="m7 7-.587.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298V11"/><path d="M9.828 4.172A.686.686 0 0 1 11 4.657v.686"/></svg>'
                    if (win.volPct === 0) return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"/><line x1="22" x2="16" y1="9" y2="15"/><line x1="16" x2="22" y1="9" y2="15"/></svg>'
                    if (win.volPct <= 30) return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"/></svg>'
                    if (win.volPct <= 60) return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"/><path d="M16 9a5 5 0 0 1 0 6"/></svg>'
                    return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z"/><path d="M16 9a5 5 0 0 1 0 6"/><path d="M19.364 18.364a9 9 0 0 0 0-12.728"/></svg>'
                }
            }
        }

    }
}
