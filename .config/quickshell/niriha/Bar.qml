import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    property int  cpuPct:  0
    property real ramGb:   0
    property int  volPct:  0
    property bool volMute:    false
    property bool calVisible:   false
    property bool statsVisible: false
    property var  wsData:  []

    property int _lastIdle:  0
    property int _lastTotal: 0

    // Click-catcher — fullscreen transparent overlay BEHIND wallpaper menu
    PanelWindow {
        id: clickCatch
        anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
        color: "transparent"
        visible: wallMenu.visible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "niri-wallpaper-dismiss"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: wallMenu.visible = false
            }
        }
    }

    // Single overlay with mask punched out over the calendar area.
    // Clicks INSIDE the mask hole pass through to the calendar window below.
    // Clicks OUTSIDE the hole hit this overlay and dismiss the calendar.
    PanelWindow {
        id: calDismiss
        anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
        color: "transparent"
        visible: root.calVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "niriha-cal-dismiss"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Subtract the calendar area so clicks there pass through to calPopup
        mask: Region {
            item: calDismiss
            Region {
                x:      calPopup.WlrLayershell.margins.left
                y:      calPopup.WlrLayershell.margins.top
                width:  calPopup.implicitWidth
                height: calPopup.implicitHeight
                intersection: Intersection.Subtract
            }
        }

        Rectangle {
            anchors.fill: parent; color: "transparent"
            MouseArea { anchors.fill: parent; onClicked: root.calVisible = false }
        }
    }

    // Calendar sits on the SAME Overlay layer, declared AFTER dismiss so it
    // renders on top and receives clicks through the mask hole above.
    CalendarPopup {
        id: calPopup
        visible: root.calVisible
    }

    // Stats dismiss — full screen overlay with hole punched over the stats popup
    PanelWindow {
        id: statsDismiss
        anchors.top:true; anchors.left:true; anchors.right:true; anchors.bottom:true
        color:"transparent"; visible:root.statsVisible
        WlrLayershell.layer:WlrLayer.Overlay; WlrLayershell.exclusionMode:ExclusionMode.Ignore
        WlrLayershell.namespace:"niriha-stats-dismiss"; WlrLayershell.keyboardFocus:WlrKeyboardFocus.None
        // Subtract the popup area — clicks inside hole pass through to statsPopup
        mask: Region {
            item: statsDismiss
            Region {
                // popup is right-anchored: x = screen width - rightMargin - popupWidth
                x:      statsDismiss.width - statsPopup.WlrLayershell.margins.right - statsPopup.implicitWidth
                y:      statsPopup.WlrLayershell.margins.top
                width:  statsPopup.implicitWidth
                height: statsPopup.implicitHeight
                intersection: Intersection.Subtract
            }
        }
        Rectangle { anchors.fill:parent; color:"transparent"
            MouseArea { anchors.fill:parent; onClicked:root.statsVisible=false } }
    }

    // StatsPopup declared after dismiss so it's on top and receives clicks in the hole
    StatsPopup { id:statsPopup; visible:root.statsVisible }

    AppLauncher { id: appLauncher; screen: Quickshell.screens[0] }

    // Click-catcher for launcher
    PanelWindow {
        id: launcherDismiss
        anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
        color: "transparent"
        visible: appLauncher.visible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "niri-launcher-dismiss"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        Rectangle {
            anchors.fill: parent; color: "transparent"
            MouseArea { anchors.fill: parent; onClicked: appLauncher.visible = false }
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { appLauncher.visible = !appLauncher.visible }
        function open(): void   { appLauncher.visible = true  }
        function close(): void  { appLauncher.visible = false }
    }

    WallpaperMenu { id: wallMenu }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { wallMenu.visible = !wallMenu.visible }
        function open(): void   { wallMenu.visible = true  }
        function close(): void  { wallMenu.visible = false }
    }

    // ── CPU ──────────────────────────────────────────────────────────
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                var idle  = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                if (root._lastTotal > 0 && total > root._lastTotal)
                    root.cpuPct = Math.round(100 * (1 - (idle - root._lastIdle) / (total - root._lastTotal)))
                root._lastIdle  = idle; root._lastTotal = total
            }
        }
        Component.onCompleted: running = true
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: cpuProc.running = true }

    // ── RAM ──────────────────────────────────────────────────────────
    Process {
        id: ramProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                root.ramGb = (parseInt(p[2]) || 0) / 1048576.0
            }
        }
        Component.onCompleted: running = true
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: ramProc.running = true }

    // ── Volume ───────────────────────────────────────────────────────
    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                root.volMute = data.indexOf("MUTED") !== -1
                var m = data.match(/([\d.]+)/)
                if (m) root.volPct = Math.round(parseFloat(m[1]) * 100)
            }
        }
        Component.onCompleted: running = true
    }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: volProc.running = true }

    // ── Workspaces ───────────────────────────────────────────────────
    Process {
        id: wsStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var e = JSON.parse(data)
                    if (e.WorkspacesChanged)       root.parseWs(e.WorkspacesChanged.workspaces)
                    else if (e.WorkspaceActivated) wsQuery.running = true
                } catch(_) {}
            }
        }
        onRunningChanged: if (!running) wsRestart.start()
    }
    Timer { id: wsRestart; interval: 1500; onTriggered: wsStream.running = true }

    Process {
        id: wsQuery
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data)
                    var list = (p.Ok && p.Ok.Workspaces) ? p.Ok.Workspaces
                             : Array.isArray(p) ? p
                             : (p.Ok && Array.isArray(p.Ok)) ? p.Ok : null
                    if (list) root.parseWs(list)
                } catch(_) {}
            }
        }
        Component.onCompleted: running = true
    }

    function parseWs(list) {
        if (!Array.isArray(list)) return
        var a = []
        for (var i = 0; i < list.length; i++) {
            var w = list[i]
            a.push({ idx: w.idx !== undefined ? w.idx : i+1,
                     focused: !!w.is_focused,
                     occupied: w.active_window_id != null })
        }
        a.sort(function(x, y) { return x.idx - y.idx })
        root.wsData = a
    }

    Variants {
        model: Quickshell.screens
        NotificationPopup {
            required property var modelData
            screen: modelData
        }
    }

    ControlCenter { id: ctrlCenter }

    PanelWindow {
        id: ccDismiss
        anchors.top: true; anchors.left: true; anchors.right: true; anchors.bottom: true
        color: "transparent"; visible: ctrlCenter.visible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "niriha-cc-dismiss"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        Rectangle { anchors.fill: parent; color: "transparent"
            MouseArea { anchors.fill: parent; onClicked: ctrlCenter.visible = false } }
    }

    IpcHandler {
        target: "controlcenter"
        function toggle(): void { ctrlCenter.visible = !ctrlCenter.visible }
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void { root.calVisible = !root.calVisible }
    }

    IpcHandler {
        target: "stats"
        function toggle(): void { root.statsVisible = !root.statsVisible }
    }

    Variants {
        model: Quickshell.screens
        ActionBar {
            required property var modelData
            screen:     modelData
            cpuPct:     root.cpuPct
            ramGb:      root.ramGb
            volPct:     root.volPct
            volMute:    root.volMute
            wsData:     root.wsData
            calVisible:   root.calVisible
            onCalVisibleChanged:   root.calVisible   = calVisible
            statsVisible: root.statsVisible
            onStatsVisibleChanged: root.statsVisible = statsVisible
        }
    }
}
