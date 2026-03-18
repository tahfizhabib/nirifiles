import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: cc

    anchors.top:   true
    anchors.left:  false
    anchors.right: false

    implicitWidth:  360
    implicitHeight: mainCol.implicitHeight + 24
    color: "transparent"
    visible: false

    WlrLayershell.namespace:     "niriha-cc"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.margins.top:   30

    // ── State ────────────────────────────────────────────────────────
    property real   volPct:       50
    property bool   volMute:      false
    property real   briPct:       80
    property bool   wifiOn:       false
    property string wifiName:     ""
    property var    wifiNetworks: []
    property bool   wifiOpen:     false
    property bool   btOn:         false
    property string btDevice:     ""
    property var    btDevices:    []
    property bool   btOpen:       false
    property string powerProfile: "balanced"
    property string hostname:     ""
    property string uptime:       ""
    property string displayName:  ""
    property bool   editingName:  false
    property string avatarEmoji:  "😊"
    property bool   editingAvatar:false

    // system stats

    readonly property var player: { var v = Mpris.players.values; for(var i=0;i<v.length;i++){if(v[i].trackTitle&&v[i].trackTitle!=="")return v[i]}; return v.length>0?v[0]:null }
    property real mediaPos: 0
    property real mediaLen: 0
    FrameAnimation {
        running: cc.player !== null
        onTriggered: {
            if (cc.player) {
                cc.player.positionChanged()
                cc.mediaPos = cc.player.position
                cc.mediaLen = cc.player.length
            }
        }
    }
    readonly property bool hasMedia: player !== null

    // Lucide SVG paths
    readonly property string p_wifi:   "<path d='M5 12.55a11 11 0 0 1 14.08 0'/><path d='M1.42 9a16 16 0 0 1 21.16 0'/><path d='M8.53 16.11a6 6 0 0 1 6.95 0'/><circle cx='12' cy='20' r='1'/>"
    readonly property string p_bt:     "<polyline points='6.5 6.5 17.5 17.5 12 23 12 1 17.5 6.5 6.5 17.5'/>"
    readonly property string p_zap:    "<path d='M13 2 3 14h9l-1 8 10-12h-9l1-8z'/>"
    readonly property string p_power:  "<path d='M12 2v10'/><path d='M18.4 6.6a9 9 0 1 1-12.77.04'/>"
    readonly property string p_x:      "<path d='M18 6 6 18'/><path d='m6 6 12 12'/>"
    readonly property string p_more:   "<circle cx='12' cy='12' r='1'/><circle cx='19' cy='12' r='1'/><circle cx='5' cy='12' r='1'/>"
    readonly property string p_pencil: "<path d='M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z'/><path d='m15 5 4 4'/>"
    readonly property string p_chevR:  "<path d='m9 18 6-6-6-6'/>"
    readonly property string p_vol3:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><path d='M16 9a5 5 0 0 1 0 6'/><path d='M19.364 18.364a9 9 0 0 0 0-12.728'/>"
    readonly property string p_vol2:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><path d='M16 9a5 5 0 0 1 0 6'/>"
    readonly property string p_vol1:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/>"
    readonly property string p_volX:   "<path d='M11 4.702a.705.705 0 0 0-1.203-.498L6.413 7.587A1.4 1.4 0 0 1 5.416 8H3a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2.416a1.4 1.4 0 0 1 .997.413l3.383 3.384A.705.705 0 0 0 11 19.298z'/><line x1='22' x2='16' y1='9' y2='15'/><line x1='16' x2='22' y1='9' y2='15'/>"
    readonly property string p_bri:    "<path d='M12 13v1'/><path d='M17 2a1 1 0 0 1 1 1v4a3 3 0 0 1-.6 1.8l-.6.8A4 4 0 0 0 16 12v8a2 2 0 0 1-2 2H10a2 2 0 0 1-2-2v-8a4 4 0 0 0-.8-2.4l-.6-.8A3 3 0 0 1 6 7V3a1 1 0 0 1 1-1z'/><path d='M6 6h12'/>"
    readonly property string p_briOff: "<path d='M11.652 6H18'/><path d='M12 13v1'/><path d='M16 16v4a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2v-8a4 4 0 0 0-.8-2.4l-.6-.8A3 3 0 0 1 6 7V6'/><path d='m2 2 20 20'/><path d='M7.649 2H17a1 1 0 0 1 1 1v4a3 3 0 0 1-.6 1.8l-.6.8a4 4 0 0 0-.55 1.007'/>"
    readonly property string p_play:   "<polygon points='6 3 20 12 6 21 6 3'/>"
    readonly property string p_pause:  "<rect x='14' y='4' width='4' height='16' rx='1'/><rect x='6' y='4' width='4' height='16' rx='1'/>"
    readonly property string p_skipB:  "<polygon points='19 20 9 12 19 4 19 20'/><line x1='5' x2='5' y1='19' y2='5'/>"
    readonly property string p_skipF:  "<polygon points='5 4 15 12 5 20 5 4'/><line x1='19' x2='19' y1='5' y2='19'/>"
    readonly property string p_repeat: "<path d='m2 9 3-3 3 3'/><path d='M13 18H7a2 2 0 0 1-2-2V6'/><path d='m22 15-3 3-3-3'/><path d='M11 6h6a2 2 0 0 1 2 2v10'/>"
    readonly property string p_shuf:   "<path d='M2 18h1.4c1.3 0 2.5-.6 3.3-1.7l6.1-8.6c.7-1.1 2-1.7 3.3-1.7H22'/><path d='m18 2 4 4-4 4'/><path d='M2 6h1.9c1.5 0 2.9.9 3.6 2.2'/><path d='M22 18h-5.9c-1.3 0-2.6-.7-3.3-1.8l-.5-.8'/><path d='m18 14 4 4-4 4'/>"
    readonly property string p_music:  "<path d='M9 18V5l12-2v13'/><circle cx='6' cy='18' r='3'/><circle cx='18' cy='16' r='3'/>"
    readonly property string p_check:  "<path d='M20 6 9 17l-5-5'/>"
    readonly property string p_cpu:   "<rect x='4' y='4' width='16' height='16' rx='2'/><rect x='8' y='8' width='8' height='8' rx='1'/><path d='M12 2v2'/><path d='M12 20v2'/><path d='M2 12h2'/><path d='M20 12h2'/>"
    readonly property string p_therm: "<path d='M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z'/>"
    readonly property string p_ram:   "<rect x='6' y='2' width='12' height='20' rx='2'/><path d='M10 7h4'/><path d='M10 12h4'/><path d='M10 17h4'/><path d='M4 7h2'/><path d='M4 12h2'/><path d='M4 17h2'/><path d='M18 7h2'/><path d='M18 12h2'/><path d='M18 17h2'/>"
    readonly property string p_net:   "<path d='M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z'/><line x1='3' y1='6' x2='21' y2='6'/><path d='M16 10a4 4 0 0 1-8 0'/>"
    readonly property string p_cal: "<path d='M8 2v4'/><path d='M16 2v4'/><rect width='18' height='18' x='3' y='4' rx='2'/><path d='M3 10h18'/><path d='M8 14h.01'/><path d='M12 14h.01'/><path d='M16 14h.01'/><path d='M8 18h.01'/><path d='M12 18h.01'/><path d='M16 18h.01'/>"
    readonly property string p_user:   "<path d='M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2'/><circle cx='12' cy='7' r='4'/>"

    function formatTime(sec) {
        var s = Math.floor(sec || 0)
        return Math.floor(s/60) + ":" + ("0" + (s%60)).slice(-2)
    }

    function ico(paths, color, size) {
        return "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='" + (size||20) + "' height='" + (size||20) + "' viewBox='0 0 24 24' fill='none' stroke='" + color + "' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>" + paths + "</svg>"
    }

    function pushHistory(arr, val) {
        var a = arr.slice(1)
        a.push(val)
        return a
    }

    function ecgPath(history, maxVal, x0, y0, w, h) {
        var path = ""
        var n = history.length
        for (var i = 0; i < n; i++) {
            var v = Math.min(history[i], maxVal) / maxVal
            var x = x0 + (i / (n-1)) * w
            var y = y0 + h - v * h * 0.85
            if (i === 0) path += "M" + x + "," + y
            else path += " L" + x + "," + y
        }
        return path
    }

    onVisibleChanged: { if (visible) { wifiOpen=false; btOpen=false; refreshAll() } }

    function refreshAll() {
        volProc.running=false;  volProc.running=true
        briProc.running=false;  briProc.running=true
        wifiProc.running=false; wifiProc.running=true
        btProc.running=false;   btProc.running=true
        ppProc.running=false;   ppProc.running=true
        sysProc.running=false;  sysProc.running=true
    }

    // ── ECG history ──────────────────────────────────────────────────
    property var cpuHistory:  [20,35,28,45,60,42,55,38,62,48,70,52,44,66,58,72,50,63,57,65]
    property var tempHistory: [45,47,46,48,50,49,51,50,52,51,53,52,54,53,55,54,56,55,57,58]
    property var ramHistory:  [40,42,41,43,44,42,45,43,46,44,47,45,48,46,47,45,49,47,48,50]
    property var netHistory:  [5,12,8,20,35,15,42,28,18,45,30,22,55,38,25,60,40,30,20,10]

    // Feed history from SystemStats singleton
    Connections {
        target: SystemStats
        function onCpuPctChanged()  { cc.cpuHistory  = cc.pushHistory(cc.cpuHistory,  SystemStats.cpuPct) }
        function onCpuTempChanged() { cc.tempHistory = cc.pushHistory(cc.tempHistory, SystemStats.cpuTemp) }
        function onRamPctChanged()  { cc.ramHistory  = cc.pushHistory(cc.ramHistory,  SystemStats.ramPct) }
    }

    // ECG scroll — adds noise so waveform always moves up/down
    Timer { interval: 200; running: true; repeat: true
        onTriggered: {
            var cn = cc.cpuHistory[cc.cpuHistory.length-1]
            var tn = cc.tempHistory[cc.tempHistory.length-1]
            var rn = cc.ramHistory[cc.ramHistory.length-1]
            cc.cpuHistory  = cc.pushHistory(cc.cpuHistory,  Math.max(2, Math.min(98, cn  + (Math.random()-0.48)*12)))
            cc.tempHistory = cc.pushHistory(cc.tempHistory, Math.max(2, Math.min(98, tn  + (Math.random()-0.48)*5)))
            cc.ramHistory  = cc.pushHistory(cc.ramHistory,  Math.max(2, Math.min(98, rn  + (Math.random()-0.48)*6)))
        }
    }

        Process { id: sysProc; command: ["sh","-c","hostname && uptime -p | sed 's/up //'"]
        stdout: SplitParser { property int _l:0
            onRead: function(d){ if(_l===0){cc.hostname=d.trim(); if(!cc.displayName)cc.displayName=d.trim(); _l=1}else{cc.uptime=d.trim();_l=0} }
            Component.onCompleted: _l=0 } }

    Process { id: volProc; command: ["sh","-c","wpctl get-volume @DEFAULT_SINK@"]
        stdout: SplitParser { onRead: function(d){
            cc.volMute=d.indexOf("MUTED")!==-1
            var m=d.match(/([\d.]+)/); if(m)cc.volPct=Math.round(parseFloat(m[1])*100) } } }
    function setVol(v){ cc.volPct=Math.max(0,Math.min(150,v)); Qt.createQmlObject('import Quickshell.Io; Process{command:["wpctl","set-volume","@DEFAULT_SINK@","'+(cc.volPct/100).toFixed(2)+'"]; running:true}',cc,"sv") }
    function toggleMute(){ cc.volMute=!cc.volMute; Qt.createQmlObject('import Quickshell.Io; Process{command:["wpctl","set-mute","@DEFAULT_SINK@","toggle"]; running:true}',cc,"tm") }

    property int _bc:0; property int _bm:255
    Process { id: briProc; command: ["sh","-c","echo $(brightnessctl get) && echo $(brightnessctl max)"]
        stdout: SplitParser { property int _l:0
            onRead: function(d){ if(_l===0){cc._bc=parseInt(d.trim())||0;_l=1}else{cc._bm=parseInt(d.trim())||255;cc.briPct=Math.round(cc._bc/cc._bm*100);_l=0} }
            Component.onCompleted: _l=0 } }
    function setBri(v){ cc.briPct=Math.max(1,Math.min(100,v)); Qt.createQmlObject('import Quickshell.Io; Process{command:["brightnessctl","set","'+cc.briPct+'%"]; running:true}',cc,"sb") }

    Process { id: wifiProc; command: ["sh","-c","nmcli radio wifi; nmcli -t -f SSID,SIGNAL,ACTIVE dev wifi list 2>/dev/null | head -8"]
        stdout: SplitParser { property int _l:0; property var _n:[]
            onRead: function(d){
                var t=d.trim(); if(_l===0){cc.wifiOn=(t==="enabled");_l=1;_n=[];return}
                var p=t.split(":"); if(p.length<2)return
                var ssid=p[0],sig=parseInt(p[1])||0,act=p[2]==="yes"
                if(ssid&&ssid!=="--"){_n.push({ssid:ssid,signal:sig,active:act}); if(act)cc.wifiName=ssid}
            }
            Component.onCompleted: _l=0 }
        onRunningChanged: if(!running) cc.wifiNetworks=wifiProc.stdout._n?wifiProc.stdout._n.slice():[] }
    function toggleWifi(){ cc.wifiOn=!cc.wifiOn; Qt.createQmlObject('import Quickshell.Io; Process{command:["nmcli","radio","wifi","'+(cc.wifiOn?"on":"off")+'"]; running:true}',cc,"tw"); if(!cc.wifiOn){cc.wifiName="";cc.wifiNetworks=[]} }
    function connectWifi(ssid){ Qt.createQmlObject('import Quickshell.Io; Process{command:["sh","-c","nmcli con up \\"'+ssid+'\\" 2>/dev/null || nmcli dev wifi connect \\"'+ssid+'\\""]; running:true}',cc,"cw"); cc.wifiName=ssid; cc.wifiOpen=false }

    Process { id: btProc; command: ["sh","-c","bluetoothctl show | grep Powered | awk '{print $2}'; bluetoothctl devices Connected 2>/dev/null"]
        stdout: SplitParser { property int _l:0; property var _d:[]
            onRead: function(d){
                var t=d.trim(); if(_l===0){cc.btOn=(t==="yes");_l=1;_d=[];return}
                var m=t.match(/Device ([0-9A-F:]+) (.+)/); if(m)_d.push({mac:m[1],name:m[2]})
            }
            Component.onCompleted: _l=0 }
        onRunningChanged: if(!running){ cc.btDevices=btProc.stdout._d?btProc.stdout._d.slice():[]; if(cc.btDevices.length>0)cc.btDevice=cc.btDevices[0].name } }
    function toggleBt(){ cc.btOn=!cc.btOn; Qt.createQmlObject('import Quickshell.Io; Process{command:["sh","-c","bluetoothctl power '+(cc.btOn?"on":"off")+'"]; running:true}',cc,"tb"); if(!cc.btOn){cc.btDevice="";cc.btDevices=[]} }
    function disconnectBt(mac){ Qt.createQmlObject('import Quickshell.Io; Process{command:["bluetoothctl","disconnect","'+mac+'"]; running:true}',cc,"db"); cc.btDevice=""; cc.btOpen=false; btProc.running=false; btProc.running=true }

    Process { id: ppProc; command:["powerprofilesctl","get"]
        stdout: SplitParser { onRead: function(d){ cc.powerProfile=d.trim() } } }
    function cyclePP(){ var p=["power-saver","balanced","performance"]; var n=p[(p.indexOf(cc.powerProfile)+1)%3]; cc.powerProfile=n; Qt.createQmlObject('import Quickshell.Io; Process{command:["powerprofilesctl","set","'+n+'"]; running:true}',cc,"pp") }

    // ── Background ────────────────────────────────────────────────────
    Rectangle { anchors.fill:parent; color:"#282828"; opacity:0.96; radius:8
        Rectangle { anchors.top:parent.top; anchors.left:parent.left; anchors.right:parent.right; height:8; color:"#282828" } }

    ColumnLayout {
        id: mainCol
        anchors { left:parent.left; right:parent.right; top:parent.top; margins:10; topMargin:10 }
        spacing: 6

        // ── Header ───────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width:42; height:42; radius:8; color:"#3c3836"; clip:true

                // Default lucide user icon
                Image {
                    anchors.centerIn:parent; width:24; height:24; smooth:true
                    visible: cc.avatarEmoji === "😊" || cc.editingAvatar
                    source: cc.ico(cc.p_user, "%23a89984", 24)
                }
                // Custom emoji
                Text {
                    anchors.centerIn:parent; text:cc.avatarEmoji; font.pixelSize:22
                    visible: cc.avatarEmoji !== "😊" && !cc.editingAvatar
                }
                // Pencil badge on hover
                Rectangle {
                    anchors.bottom:parent.bottom; anchors.right:parent.right
                    width:14; height:14; radius:3; color:"#504945"
                    visible:avatMa.containsMouse
                    Image { anchors.centerIn:parent; width:9; height:9; smooth:true; source:cc.ico(cc.p_pencil,"%23ebdbb2",9) }
                }
                MouseArea { id:avatMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                    onDoubleClicked: cc.editingAvatar=!cc.editingAvatar }
                // Emoji picker
                Rectangle {
                    visible:cc.editingAvatar
                    anchors.top:parent.bottom; anchors.topMargin:4; anchors.left:parent.left
                    width:220; height:44; radius:8; color:"#3c3836"; z:10
                    border.width:1; border.color:"#504945"
                    Row { anchors.centerIn:parent; spacing:8
                        Repeater { model:["😊","😎","🦊","🐧","🌙","⭐","🎮","🔥"]
                            Text { required property var modelData; text:modelData; font.pixelSize:20
                                MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                    onClicked:{cc.avatarEmoji=parent.text; cc.editingAvatar=false} } } } }
                }
            }

            ColumnLayout { spacing:2; visible:!cc.editingName
                Text { text:cc.displayName||cc.hostname||"niriha"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:15; font.weight:Font.Medium
                    MouseArea{anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onDoubleClicked:{cc.editingName=true; nameEdit.text=cc.displayName||cc.hostname; nameEdit.forceActiveFocus()}} }
                Text { text:"uptime "+(cc.uptime||""); color:"#a89984"; font.family:"Google Sans"; font.pixelSize:11; visible:cc.uptime!=="" }
            }
            Rectangle { visible:cc.editingName; height:28; width:120; radius:6; color:"#504945"
                TextInput { id:nameEdit; anchors{fill:parent; leftMargin:8; rightMargin:8; verticalCenter:parent.verticalCenter}
                    color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; verticalAlignment:TextInput.AlignVCenter
                    Keys.onReturnPressed:{cc.displayName=text; cc.editingName=false}
                    Keys.onEscapePressed: cc.editingName=false } }

            Item { Layout.fillWidth:true }

            // Header icon capsule — calendar > power > close
            Rectangle {
                height: 38; radius: 8; color: "#3c3836"
                implicitWidth: hBtns.implicitWidth + 12

                Row {
                    id: hBtns
                    anchors.centerIn: parent
                    spacing: 3

                    Item { width: 36; height: 36
                        Rectangle { anchors.fill: parent; radius: 8; color: calMa.containsMouse ? "#504945" : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } } }
                        Image { anchors.centerIn: parent; width: 16; height: 16; smooth: true
                            source: cc.ico(cc.p_cal, "%23ebdbb2", 16) }
                        MouseArea { id: calMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.createQmlObject('import Quickshell.Io; Process{command:["qs","ipc","-c","niriha","call","calendar","toggle"]; running:true}', cc, "cal") } }

                    Rectangle { width: 1; height: 20; anchors.verticalCenter: parent.verticalCenter; color: "#504945"; opacity: 0.5 }

                    Item { width: 36; height: 36
                        Rectangle { anchors.fill: parent; radius: 8; color: poMa.containsMouse ? "#3c2020" : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } } }
                        Image { anchors.centerIn: parent; width: 16; height: 16; smooth: true
                            source: cc.ico(cc.p_power, poMa.containsMouse ? "%23fb4934" : "%23ebdbb2", 16) }
                        MouseArea { id: poMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.createQmlObject('import Quickshell.Io; Process{command:["systemctl","poweroff"]; running:true}', cc, "po") } }

                    Rectangle { width: 1; height: 20; anchors.verticalCenter: parent.verticalCenter; color: "#504945"; opacity: 0.5 }

                    Item { width: 36; height: 36
                        Rectangle { anchors.fill: parent; radius: 8; color: clMa.containsMouse ? "#504945" : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } } }
                        Image { anchors.centerIn: parent; width: 16; height: 16; smooth: true
                            source: cc.ico(cc.p_x, clMa.containsMouse ? "%23fb4934" : "%23ebdbb2", 16) }
                        MouseArea { id: clMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: cc.visible = false } }
                }
            }
        }

        // ── WiFi + BT left | Sliders right ───────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // WiFi
                Rectangle {
                    Layout.fillWidth:true; height:52; radius:8
                    color: "#3c3836"
                    Behavior on color { ColorAnimation{duration:150} }

                    RowLayout { anchors{fill:parent; margins:8}
                        spacing:10
                        Rectangle { width:36; height:36; radius:7; color:"#504945"; Behavior on color{ColorAnimation{duration:150}}
                            Image{anchors.centerIn:parent; width:22; height:22; smooth:true; source:cc.ico(cc.p_wifi, "%23a89984", 22)} }
                        ColumnLayout { Layout.fillWidth:true; spacing:2; Layout.alignment:Qt.AlignVCenter
                            Text{text:"WiFi"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:14; font.weight:Font.Medium; horizontalAlignment:Text.AlignHCenter; Layout.fillWidth:true}
                            Text{visible:cc.wifiOn&&cc.wifiName!==""; text:cc.wifiName; color:"#a89984"; font.family:"Google Sans"; font.pixelSize:12; elide:Text.ElideRight; Layout.fillWidth:true; horizontalAlignment:Text.AlignHCenter} }
    
                    }
                    MouseArea{anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                        onClicked: cc.wifiOn?(cc.wifiOpen=!cc.wifiOpen):cc.toggleWifi()}
                }

                // BT
                Rectangle {
                    Layout.fillWidth:true; height:52; radius:8
                    color: "#3c3836"
                    Behavior on color { ColorAnimation{duration:150} }

                    RowLayout { anchors{fill:parent; margins:8}
                        spacing:10
                        Rectangle { width:36; height:36; radius:7; color:"#504945"; Behavior on color{ColorAnimation{duration:150}}
                            Image{anchors.centerIn:parent; width:22; height:22; smooth:true; source:cc.ico(cc.p_bt, "%23a89984", 22)} }
                        ColumnLayout { Layout.fillWidth:true; spacing:2; Layout.alignment:Qt.AlignVCenter
                            Text{text:"Bluetooth"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:14; font.weight:Font.Medium; horizontalAlignment:Text.AlignHCenter; Layout.fillWidth:true}
                            Text{visible:cc.btOn&&cc.btDevice!==""; text:cc.btDevice; color:"#a89984"; font.family:"Google Sans"; font.pixelSize:12; elide:Text.ElideRight; Layout.fillWidth:true; horizontalAlignment:Text.AlignHCenter} }
    
                    }
                    MouseArea{anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                        onClicked: cc.btOn?(cc.btOpen=!cc.btOpen):cc.toggleBt()}
                }
            }

            // Vol slider
            Item {
                width:52; height:116
                Rectangle {
                    id:volTrack; anchors.horizontalCenter:parent.horizontalCenter
                    width:44; height:parent.height; radius:10; color:"#3c3836"; clip:true
                    Rectangle {
                        id:volFill; anchors.bottom:parent.bottom; anchors.left:parent.left; anchors.right:parent.right
                        height:Math.max(20, parent.height*Math.min(cc.volPct,100)/100)
                        radius:10; color:cc.volMute?"#504945":"#504945"
                        Behavior on height{NumberAnimation{duration:120; easing.type:Easing.OutCubic}}
                        Behavior on color{ColorAnimation{duration:120}}
                    }
                    Text{anchors.horizontalCenter:parent.horizontalCenter; anchors.top:parent.top; anchors.topMargin:8
                        text:"VOL"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:9; font.weight:Font.Bold; font.letterSpacing:1.5}
                    Text{anchors.horizontalCenter:parent.horizontalCenter; anchors.top:parent.top; anchors.topMargin:22
                        text:cc.volMute?"M":cc.volPct+"%"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; font.weight:Font.Medium}
                    Image{anchors.horizontalCenter:parent.horizontalCenter; anchors.bottom:volFill.bottom; anchors.bottomMargin:8
                        width:18; height:18; smooth:true
                        source:cc.ico(cc.volMute?cc.p_volX:cc.volPct<=30?cc.p_vol1:cc.volPct<=60?cc.p_vol2:cc.p_vol3, "%23a89984", 18)}
                }
                MouseArea{anchors.fill:volTrack; cursorShape:Qt.PointingHandCursor; hoverEnabled:true
                    onWheel:function(w){cc.setVol(cc.volPct+(w.angleDelta.y>0?5:-5))}
                    onPressed:function(m){var p=Math.round((1-m.y/volTrack.height)*100); cc.setVol(Math.max(0,Math.min(100,p)))}
                    onPositionChanged:function(m){if(!pressed)return; var p=Math.round((1-m.y/volTrack.height)*100); cc.setVol(Math.max(0,Math.min(100,p)))}
                    onClicked:function(m){if(m.y<volTrack.height*0.25)cc.toggleMute()}}
            }

            // Bri slider
            Item {
                width:52; height:116
                Rectangle {
                    id:briTrack; anchors.horizontalCenter:parent.horizontalCenter
                    width:44; height:parent.height; radius:10; color:"#3c3836"; clip:true
                    Rectangle {
                        anchors.bottom:parent.bottom; anchors.left:parent.left; anchors.right:parent.right
                        height:Math.max(20, parent.height*cc.briPct/100)
                        radius:10; color:"#504945"
                        Behavior on height{NumberAnimation{duration:120; easing.type:Easing.OutCubic}}
                    }
                    Text{anchors.horizontalCenter:parent.horizontalCenter; anchors.top:parent.top; anchors.topMargin:8
                        text:"BRI"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:9; font.weight:Font.Bold; font.letterSpacing:1.5}
                    Text{anchors.horizontalCenter:parent.horizontalCenter; anchors.top:parent.top; anchors.topMargin:22
                        text:cc.briPct+"%"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; font.weight:Font.Medium}
                    Image{anchors.horizontalCenter:parent.horizontalCenter; anchors.bottom:parent.bottom; anchors.bottomMargin:10
                        width:18; height:18; smooth:true
                        source:cc.ico(cc.briPct===0?cc.p_briOff:cc.p_bri, "%23a89984", 18)}
                }
                MouseArea{anchors.fill:briTrack; cursorShape:Qt.PointingHandCursor; hoverEnabled:true
                    onWheel:function(w){cc.setBri(cc.briPct+(w.angleDelta.y>0?5:-5))}
                    onPressed:function(m){var p=Math.round((1-m.y/briTrack.height)*100); cc.setBri(Math.max(1,Math.min(100,p)))}
                    onPositionChanged:function(m){if(!pressed)return; var p=Math.round((1-m.y/briTrack.height)*100); cc.setBri(Math.max(1,Math.min(100,p)))}}
            }
        }

        // WiFi list
        Column { Layout.fillWidth:true; visible:cc.wifiOpen&&cc.wifiNetworks.length>0; spacing:1
            Repeater { model:cc.wifiNetworks
                Rectangle { required property var modelData; width:mainCol.width; height:34; radius:6
                    color:wMa.containsMouse?"#3c3836":"transparent"; Behavior on color{ColorAnimation{duration:60}}
                    RowLayout{anchors{fill:parent; leftMargin:10; rightMargin:10}
                        spacing:8
                        Row{spacing:2; Layout.alignment:Qt.AlignVCenter
                            Repeater{model:4; Rectangle{width:3; radius:1; height:4+index*3; anchors.bottom:parent.bottom
                                color:modelData.signal>=(index+1)*25?"#83a598":"#504945"}}}
                        Text{text:modelData.ssid; Layout.fillWidth:true; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; elide:Text.ElideRight}
                        Image{visible:modelData.active; width:13; height:13; smooth:true; source:cc.ico(cc.p_check,"%2383a598",13)}}
                    MouseArea{id:wMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                        onClicked:if(!modelData.active)cc.connectWifi(modelData.ssid)}}}}

        // BT list
        Column { Layout.fillWidth:true; visible:cc.btOpen; spacing:1
            Text{visible:cc.btDevices.length===0; text:"No devices connected"; color:"#a89984"; font.family:"Google Sans"; font.pixelSize:13; leftPadding:10}
            Repeater{model:cc.btDevices
                Rectangle{required property var modelData; width:mainCol.width; height:34; radius:6; color:"transparent"
                    RowLayout{anchors{fill:parent; leftMargin:10; rightMargin:10}
                        spacing:8
                        Image{width:15; height:15; smooth:true; source:cc.ico(cc.p_bt,"%2383a598",15)}
                        Text{text:modelData.name; Layout.fillWidth:true; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; elide:Text.ElideRight}
                        Text{text:"disconnect"; color:"#a89984"; font.family:"Google Sans"; font.pixelSize:12
                            MouseArea{anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:cc.disconnectBt(modelData.mac)}}}}} }

        // Power profile full width
        Rectangle {
            Layout.fillWidth:true; height:48; radius:8; color:"#3c3836"
            RowLayout { anchors{fill:parent; leftMargin:14; rightMargin:14}
                        spacing:12
                Image{width:26; height:26; smooth:true
                    source:cc.ico(cc.p_zap,
                        cc.powerProfile==="performance"?"%23fe8019":
                        cc.powerProfile==="power-saver"?"%2383a598":"%23a89984", 26)}
                Text{text:cc.powerProfile==="performance"?"Performance":cc.powerProfile==="power-saver"?"Power Saver":"Balanced"
                    color:cc.powerProfile==="performance"?"#fe8019":cc.powerProfile==="power-saver"?"#83a598":"#ebdbb2"
                    font.family:"Google Sans"; font.pixelSize:15; font.weight:Font.Medium; Layout.fillWidth:true}
                Image{width:14; height:14; smooth:true; source:cc.ico(cc.p_chevR,"%23a89984",14)}
            }
            MouseArea{anchors.fill:parent; cursorShape:Qt.PointingHandCursor; onClicked:cc.cyclePP()}
        }

        // ── ECG System Monitor ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth:true; height:168; radius:10; color:"#3c3836"

            // subtle grid lines between rows
            Repeater { model:2
                Rectangle { x:10; y:56+index*54; width:parent.width-20; height:1; color:"#504945"; opacity:0.25 } }

            Column {
                anchors { left:parent.left; right:parent.right; top:parent.top; topMargin:4; leftMargin:10; rightMargin:10 }
                spacing: 0

                // CPU
                Item { width:parent.width; height:54
                    Rectangle { x:0; anchors.verticalCenter:parent.verticalCenter; width:36; height:36; radius:7; color:"#504945";
                        Image { anchors.centerIn:parent; width:20; height:20; smooth:true; source:cc.ico(cc.p_cpu,"%23ebdbb2",20) }
                    }
                    Text { x:46; anchors.verticalCenter:parent.verticalCenter
                        text:Math.round(SystemStats.cpuPct)+"%"
                        color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:15; font.weight:Font.Medium; width:46 }
                    Canvas {
                        x:96; y:7; width:parent.width-96; height:40
                        property var hist: cc.cpuHistory
                        onHistChanged: requestPaint()
                        onPaint: {
                            var ctx=getContext("2d"); ctx.clearRect(0,0,width,height)
                            ctx.strokeStyle="#83a598"; ctx.lineWidth=2; ctx.lineJoin="round"; ctx.beginPath()
                            for(var i=0;i<hist.length;i++){
                                var px=i/(hist.length-1)*width
                                var py=height-(hist[i]/100)*height*0.85
                                i===0?ctx.moveTo(px,py):ctx.lineTo(px,py)
                            }
                            ctx.stroke()
                            ctx.fillStyle="#83a598"; ctx.beginPath()
                            ctx.arc(width, height-(hist[hist.length-1]/100)*height*0.85, 3.5,0,Math.PI*2); ctx.fill()
                        }
                    }
                }

                // TEMP
                Item { width:parent.width; height:54
                    Rectangle { x:0; anchors.verticalCenter:parent.verticalCenter; width:36; height:36; radius:7; color:"#504945";
                        Image { anchors.centerIn:parent; width:20; height:20; smooth:true; source:cc.ico(cc.p_therm,"%23ebdbb2",20) }
                    }
                    Text { x:46; anchors.verticalCenter:parent.verticalCenter
                        text:SystemStats.cpuTemp>0?Math.round(SystemStats.cpuTemp)+"°":"--°"
                        color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:15; font.weight:Font.Medium; width:46 }
                    Canvas {
                        x:96; y:7; width:parent.width-96; height:40
                        property var hist: cc.tempHistory
                        onHistChanged: requestPaint()
                        onPaint: {
                            var ctx=getContext("2d"); ctx.clearRect(0,0,width,height)
                            ctx.strokeStyle="#fabd2f"; ctx.lineWidth=2; ctx.lineJoin="round"; ctx.beginPath()
                            for(var i=0;i<hist.length;i++){
                                var px=i/(hist.length-1)*width
                                var py=height-(hist[i]/100)*height*0.85
                                i===0?ctx.moveTo(px,py):ctx.lineTo(px,py)
                            }
                            ctx.stroke()
                            ctx.fillStyle="#fabd2f"; ctx.beginPath()
                            ctx.arc(width, height-(hist[hist.length-1]/100)*height*0.85, 3.5,0,Math.PI*2); ctx.fill()
                        }
                    }
                }

                // RAM
                Item { width:parent.width; height:54
                    Rectangle { x:0; anchors.verticalCenter:parent.verticalCenter; width:36; height:36; radius:7; color:"#504945";
                        Image { anchors.centerIn:parent; width:20; height:20; smooth:true; source:cc.ico(cc.p_ram,"%23ebdbb2",20) }
                    }
                    Text { x:46; anchors.verticalCenter:parent.verticalCenter
                        text:SystemStats.ramGb.toFixed(1)+"G"
                        color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:15; font.weight:Font.Medium; width:46 }
                    Canvas {
                        x:96; y:7; width:parent.width-96; height:40
                        property var hist: cc.ramHistory
                        onHistChanged: requestPaint()
                        onPaint: {
                            var ctx=getContext("2d"); ctx.clearRect(0,0,width,height)
                            ctx.strokeStyle="#d3869b"; ctx.lineWidth=2; ctx.lineJoin="round"; ctx.beginPath()
                            for(var i=0;i<hist.length;i++){
                                var px=i/(hist.length-1)*width
                                var py=height-(hist[i]/100)*height*0.85
                                i===0?ctx.moveTo(px,py):ctx.lineTo(px,py)
                            }
                            ctx.stroke()
                            ctx.fillStyle="#d3869b"; ctx.beginPath()
                            ctx.arc(width, height-(hist[hist.length-1]/100)*height*0.85, 3.5,0,Math.PI*2); ctx.fill()
                        }
                    }
                }
            }
        }

        // ── Media ────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth:true; visible:cc.hasMedia
            height: visible ? 192 : 0
            radius:10; color:"#3c3836"

            RowLayout {
                anchors { left:parent.left; right:parent.right; top:parent.top; margins:12 }
                spacing: 14

                // Big album art
                Rectangle { width:92; height:92; radius:8; color:"#504945"; clip:true
                    Image {
                        anchors.fill:parent
                        source: cc.player ? (cc.player.trackArtUrl || "") : ""
                        fillMode:Image.PreserveAspectCrop; smooth:true; asynchronous:true
                        visible: status === Image.Ready
                    }
                    Image { anchors.centerIn:parent; width:28; height:28; smooth:true
                        visible: !cc.player || (cc.player.trackArtUrl || "") === ""
                        source: cc.ico(cc.p_music,"%23665c54",28) }
                }

                // Controls column (right of art)
                ColumnLayout {
                    Layout.fillWidth:true
                    spacing: 0

                    // play/skip row
                    RowLayout {
                        Layout.fillWidth:true
                        spacing: 0

                        Item { Layout.fillWidth:true }

                        // skip back
                        Item { width:40; height:40
                            Rectangle { anchors.fill:parent; radius:20; color:sbMa.containsMouse?"#504945":"transparent"
                                Behavior on color { ColorAnimation { duration:80 } } }
                            Image { anchors.centerIn:parent; width:18; height:18; smooth:true
                                source:cc.ico(cc.p_skipB,"%23a89984",18) }
                            MouseArea { id:sbMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                                onClicked: if(cc.player) cc.player.previous() } }

                        // play/pause big
                        Item { width:52; height:52
                            Rectangle { anchors.fill:parent; radius:26; color:"#504945"
                                Behavior on color { ColorAnimation { duration:80 } } }
                            Image { anchors.centerIn:parent; width:22; height:22; smooth:true
                                source: cc.ico(cc.player&&cc.player.isPlaying?cc.p_pause:cc.p_play,"%23ebdbb2",22) }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor
                                onClicked: if(cc.player) cc.player.togglePlaying() } }

                        // skip fwd
                        Item { width:40; height:40
                            Rectangle { anchors.fill:parent; radius:20; color:sfMa.containsMouse?"#504945":"transparent"
                                Behavior on color { ColorAnimation { duration:80 } } }
                            Image { anchors.centerIn:parent; width:18; height:18; smooth:true
                                source:cc.ico(cc.p_skipF,"%23a89984",18) }
                            MouseArea { id:sfMa; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor
                                onClicked: if(cc.player) cc.player.next() } }

                        Item { Layout.fillWidth:true }
                    }

                    // shuffle + repeat row
                    RowLayout {
                        Layout.fillWidth:true
                        spacing: 0
                        Item { Layout.fillWidth:true }
                        Item { width:32; height:32
                            Image { anchors.centerIn:parent; width:16; height:16; smooth:true
                                source:cc.ico(cc.p_shuf,"%23665c54",16) }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor } }
                        Item { width:32; height:32
                            Image { anchors.centerIn:parent; width:16; height:16; smooth:true
                                source:cc.ico(cc.p_repeat,"%23665c54",16) }
                            MouseArea { anchors.fill:parent; cursorShape:Qt.PointingHandCursor } }
                        Item { Layout.fillWidth:true }
                    }
                }
            }

            // Track info + progress below the art+controls row
            ColumnLayout {
                anchors { left:parent.left; right:parent.right; bottom:parent.bottom; margins:12 }
                spacing: 6

                Text {
                    text: cc.player ? (cc.player.trackTitle || "Unknown") : ""
                    color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:16; font.weight:Font.Medium
                    Layout.fillWidth:true; elide:Text.ElideRight
                }
                Text {
                    text: cc.player ? ((cc.player.trackArtist||"") + (cc.player.trackAlbum ? " · " + cc.player.trackAlbum : "")) : ""
                    color:"#a89984"; font.family:"Google Sans"; font.pixelSize:13
                    Layout.fillWidth:true; elide:Text.ElideRight; visible:text!==""
                }

                // Progress bar with timestamps
                Item { Layout.fillWidth:true; height:20
                    Text { anchors.left:parent.left; anchors.verticalCenter:parent.verticalCenter
                        text: cc.mediaLen>0 ? formatTime(cc.mediaPos) : "0:00"
                        color:"#665c54"; font.family:"Google Sans"; font.pixelSize:11 }
                    Text { anchors.right:parent.right; anchors.verticalCenter:parent.verticalCenter
                        text: cc.mediaLen>0 ? formatTime(cc.mediaLen) : "0:00"
                        color:"#665c54"; font.family:"Google Sans"; font.pixelSize:11 }
                    Rectangle { anchors.centerIn:parent; width:parent.width-56; height:6; radius:3; color:"#504945"
                        Rectangle {
                            width: cc.mediaLen>0 ? parent.width*(cc.mediaPos/cc.mediaLen) : 0
                            height:parent.height; radius:3; color:"#83a598"
                            Behavior on width { NumberAnimation { duration:400 } }
                        }
                    }
                }
            }
        }

    }
}
