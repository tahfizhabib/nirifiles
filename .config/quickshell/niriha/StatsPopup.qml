import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: sp
    anchors.top: true
    anchors.right: true
    implicitWidth:  300
    implicitHeight: mainCol.implicitHeight + 20
    color: "transparent"
    visible: false

    WlrLayershell.namespace:     "niriha-stats"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.margins.top:   30
    WlrLayershell.margins.right: 60

    // ── State ─────────────────────────────────────────────────────────
    property real loadAvg1:  0
    property real loadAvg5:  0
    property real loadAvg15: 0
    property int  procTotal: 0
    property int  procRun:   0
    property string uptimeStr: ""
    property string hostname:  ""
    property string osName:    ""
    property string kernelVer: ""
    property real rxKb: 0
    property real txKb: 0
    property real _prevRx: 0
    property real _prevTx: 0
    property real _prevTs: 0

    // ECG histories
    property var cpuHist:  [20,35,28,45,60,42,55,38,62,48,70,52,44,66,58,72,50,63,57,65]
    property var tempHist: [45,47,46,48,50,49,51,50,52,51,53,52,54,53,55,54,56,55,57,58]
    property var ramHist:  [40,42,41,43,44,42,45,43,46,44,47,45,48,46,47,45,49,47,48,50]
    function pushH(arr, val) { var a=arr.slice(1); a.push(val); return a }

    Connections {
        target: SystemStats
        function onCpuPctChanged()  { sp.cpuHist  = sp.pushH(sp.cpuHist,  SystemStats.cpuPct) }
        function onCpuTempChanged() { sp.tempHist = sp.pushH(sp.tempHist, SystemStats.cpuTemp) }
        function onRamPctChanged()  { sp.ramHist  = sp.pushH(sp.ramHist,  SystemStats.ramPct) }
    }
    Timer { interval:200; running:sp.visible; repeat:true
        onTriggered: {
            sp.cpuHist  = sp.pushH(sp.cpuHist,  Math.max(2,Math.min(98,sp.cpuHist[sp.cpuHist.length-1]+(Math.random()-.48)*12)))
            sp.tempHist = sp.pushH(sp.tempHist, Math.max(2,Math.min(98,sp.tempHist[sp.tempHist.length-1]+(Math.random()-.48)*5)))
            sp.ramHist  = sp.pushH(sp.ramHist,  Math.max(2,Math.min(98,sp.ramHist[sp.ramHist.length-1]+(Math.random()-.48)*6)))
        }
    }

    // ── /proc/loadavg ─────────────────────────────────────────────────
    FileView { id:loadFv; path:"/proc/loadavg"; watchChanges:true
        onFileChanged: reload()
        onTextChanged: {
            var t=text(); if(!t||!t.trim()) return
            var p=t.trim().split(/\s+/)
            sp.loadAvg1  = parseFloat(p[0])||0
            sp.loadAvg5  = parseFloat(p[1])||0
            sp.loadAvg15 = parseFloat(p[2])||0
            var tasks=(p[3]||"0/0").split("/")
            sp.procRun   = parseInt(tasks[0])||0
            sp.procTotal = parseInt(tasks[1])||0
        }
    }
    Timer { interval:3000; running:sp.visible; repeat:true; triggeredOnStart:true
        onTriggered: loadFv.reload() }

    // ── /proc/uptime ──────────────────────────────────────────────────
    FileView { id:uptimeFv; path:"/proc/uptime"; watchChanges:false
        onTextChanged: {
            var t=text(); if(!t) return
            var secs=Math.floor(parseFloat(t.trim().split(/\s+/)[0])||0)
            var d=Math.floor(secs/86400); secs%=86400
            var h=Math.floor(secs/3600);  secs%=3600
            var m=Math.floor(secs/60)
            sp.uptimeStr = d>0?(d+"d "+h+"h "+m+"m"):h>0?(h+"h "+m+"m"):(m+"m")
        }
    }
    Timer { interval:30000; running:sp.visible; repeat:true; triggeredOnStart:true
        onTriggered: uptimeFv.reload() }

    // ── /proc/net/dev ─────────────────────────────────────────────────
    FileView { id:netFv; path:"/proc/net/dev"; watchChanges:true
        onFileChanged: reload()
        onTextChanged: {
            var t=text(); if(!t) return
            var now=Date.now()
            var elapsed=sp._prevTs>0?Math.max(0.1,(now-sp._prevTs)/1000.0):1.0
            sp._prevTs=now
            var lines=t.split("\n"); var rx=0,tx=0
            for(var i=0;i<lines.length;i++){
                var l=lines[i].trim(); if(!l) continue
                var ci=l.lastIndexOf(":"); if(ci<0) continue
                if(l.substring(0,ci).trim()==="lo") continue
                var nums=l.substring(ci+1).trim().split(/\s+/)
                if(nums.length<9) continue
                rx+=parseFloat(nums[0])||0; tx+=parseFloat(nums[8])||0
            }
            if(sp._prevRx>0&&rx>0&&elapsed>0){
                sp.rxKb=Math.max(0,(rx-sp._prevRx)/1024.0/elapsed)
                sp.txKb=Math.max(0,(tx-sp._prevTx)/1024.0/elapsed)
            }
            if(rx>0){sp._prevRx=rx; sp._prevTx=tx}
        }
    }
    Timer { interval:600; running:sp.visible; repeat:true; triggeredOnStart:true
        onTriggered: netFv.reload() }

    // ── df -h / ───────────────────────────────────────────────────────
    // Read real block device mounts only
    property var diskList: []
    Process { id:diskProc
        command:["sh","-c","df -h 2>/dev/null | awk 'NR>1 && ($1~/^\/dev\//) {print $6,$2,$3,$4,$5}'"]
        stdout: SplitParser {
            property var _tmp: []
            onRead: function(d) {
                var p=d.trim().split(/\s+/)
                if(p.length<5) return
                _tmp.push({mount:p[0],total:p[1],used:p[2],free:p[3],pct:parseInt(p[4].replace("%",""))||0})
            }
            Component.onCompleted: _tmp=[]
        }
        onRunningChanged: {
            if(!running) {
                // If no /dev/ partitions found, fallback to showing /
                if(diskProc.stdout._tmp.length===0) {
                    diskProc2.running=false; diskProc2.running=true
                } else {
                    sp.diskList=diskProc.stdout._tmp.slice()
                    diskProc.stdout._tmp=[]
                }
            } else {
                diskProc.stdout._tmp=[]
            }
        }
        Component.onCompleted: running=true
    }
    // Fallback: show / if no /dev/ partitions
    Process { id:diskProc2; command:["df","-h","/"]
        property bool _hdr: true
        stdout: SplitParser {
            onRead: function(d) {
                if(diskProc2._hdr){diskProc2._hdr=false;return}
                var p=d.trim().split(/\s+/)
                if(p.length<6) return
                sp.diskList=[{mount:p[5]||"/",total:p[1],used:p[2],free:p[3],pct:parseInt(p[4].replace("%",""))||0}]
            }
        }
        onRunningChanged: if(!running) _hdr=true
    }
    Timer { interval:15000; running:sp.visible; repeat:true; triggeredOnStart:true
        onTriggered:{ diskProc.running=false; diskProc.running=true } }

    // Legacy single-disk props for compat
    property string diskTotal: diskList.length>0?diskList[0].total:"?"
    property string diskUsed:  diskList.length>0?diskList[0].used:"?"
    property string diskFree:  diskList.length>0?diskList[0].free:"?"
    property int    diskPct:   diskList.length>0?diskList[0].pct:0

    // ── hostname ──────────────────────────────────────────────────────
    Process { id:hostProc; command:["hostname"]
        stdout: SplitParser { onRead: function(d){ sp.hostname=d.trim() } }
        Component.onCompleted: running=true }

    // ── uname -r ──────────────────────────────────────────────────────
    Process { id:kernelProc; command:["uname","-r"]
        stdout: SplitParser { onRead: function(d){ sp.kernelVer=d.trim().split("-")[0] } }
        Component.onCompleted: running=true }

    // ── OS name ───────────────────────────────────────────────────────
    Process { id:osProc; command:["sh","-c","grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//;s/\"//g;s/—//g;s/ - //g'"]
        stdout: SplitParser { onRead: function(d){ sp.osName=d.trim().replace(/[\u2014\u2013\u2012]/g,"").trim() } }
        Component.onCompleted: running=true }

    // ── Helpers ───────────────────────────────────────────────────────
    function fmtNet(kb) {
        if(kb>=1024) return (kb/1024).toFixed(1)+" MB/s"
        if(kb>=1)    return Math.round(kb)+" KB/s"
        return "0 B/s"
    }
    function ico(paths,color,sz) {
        return "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='"+(sz||16)+"' height='"+(sz||16)+"' viewBox='0 0 24 24' fill='none' stroke='"+color+"' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"+paths+"</svg>"
    }

    readonly property string i_cpu:   "<rect x='4' y='4' width='16' height='16' rx='2'/><rect x='8' y='8' width='8' height='8' rx='1'/><path d='M12 2v2'/><path d='M12 20v2'/><path d='M2 12h2'/><path d='M20 12h2'/>"
    readonly property string i_therm: "<path d='M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z'/>"
    readonly property string i_ram:   "<rect x='6' y='2' width='12' height='20' rx='2'/><path d='M10 7h4'/><path d='M10 12h4'/><path d='M10 17h4'/><path d='M4 7h2'/><path d='M4 12h2'/><path d='M4 17h2'/><path d='M18 7h2'/><path d='M18 12h2'/><path d='M18 17h2'/>"
    readonly property string i_down:  "<path d='M12 5v14'/><path d='m19 12-7 7-7-7'/>"
    readonly property string i_up:    "<path d='M12 19V5'/><path d='m5 12 7-7 7 7'/>"
    readonly property string i_disk:  "<ellipse cx='12' cy='5' rx='9' ry='3'/><path d='M3 5v14a9 3 0 0 0 18 0V5'/><path d='M3 12a9 3 0 0 0 18 0'/>"

    // ── Background ────────────────────────────────────────────────────
    Item { anchors.fill:parent; opacity:0.96
        Rectangle { anchors.fill:parent; color:"#282828"; radius:10
            Rectangle { anchors.top:parent.top; anchors.left:parent.left; anchors.right:parent.right; height:10; color:"#282828" }
        }
    }

    ColumnLayout {
        id: mainCol
        anchors.left:     parent.left
        anchors.right:    parent.right
        anchors.top:      parent.top
        anchors.margins:  10
        anchors.topMargin: 10
        spacing: 6

        // ── ECG ───────────────────────────────────────────────────────
        Rectangle { Layout.fillWidth:true; height:168; radius:10; color:"#3c3836"
            Repeater { model:2; Rectangle { x:10; y:56+index*54; width:parent.width-20; height:1; color:"#504945"; opacity:0.25 } }
            Column {
                anchors.left:      parent.left
                anchors.right:     parent.right
                anchors.top:       parent.top
                anchors.topMargin: 4
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing:0

                Item { width:parent.width; height:54
                    Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:"#504945"
                        Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:sp.ico(sp.i_cpu,"%23ebdbb2",16)}}
                    Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:Math.round(SystemStats.cpuPct)+"%";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                    Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:sp.cpuHist;onHistChanged:requestPaint()
                        onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle="#83a598";c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle="#83a598";c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                }
                Item { width:parent.width; height:54
                    Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:"#504945"
                        Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:sp.ico(sp.i_therm,"%23ebdbb2",16)}}
                    Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:SystemStats.cpuTemp>0?Math.round(SystemStats.cpuTemp)+"°":"--°";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                    Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:sp.tempHist;onHistChanged:requestPaint()
                        onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle="#fabd2f";c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle="#fabd2f";c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                }
                Item { width:parent.width; height:54
                    Rectangle{x:0;anchors.verticalCenter:parent.verticalCenter;width:30;height:30;radius:6;color:"#504945"
                        Image{anchors.centerIn:parent;width:16;height:16;smooth:true;source:sp.ico(sp.i_ram,"%23ebdbb2",16)}}
                    Text{x:40;anchors.verticalCenter:parent.verticalCenter;text:SystemStats.ramGb.toFixed(1)+"G";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:15;font.weight:Font.Medium;width:46}
                    Canvas{x:88;y:7;width:parent.width-88;height:40;property var hist:sp.ramHist;onHistChanged:requestPaint()
                        onPaint:{var c=getContext("2d");c.clearRect(0,0,width,height);c.strokeStyle="#d3869b";c.lineWidth=1.8;c.lineJoin="round";c.beginPath();for(var i=0;i<hist.length;i++){var px=i/(hist.length-1)*width,py=height-(hist[i]/100)*height*.85;i?c.lineTo(px,py):c.moveTo(px,py)}c.stroke();c.fillStyle="#d3869b";c.beginPath();c.arc(width,height-(hist[hist.length-1]/100)*height*.85,3,0,Math.PI*2);c.fill()}}
                }
            }
        }

        // ── Network ───────────────────────────────────────────────────
        Rectangle { Layout.fillWidth:true; height:64; radius:10; color:"#3c3836"
            Item {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14

                // Download — left half
                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Row { spacing:6
                        Image{width:14;height:14;smooth:true;anchors.verticalCenter:parent.verticalCenter;source:sp.ico(sp.i_down,"%238ec07c",14)}
                        Text{text:sp.fmtNet(sp.rxKb);color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16;font.weight:Font.Medium;anchors.verticalCenter:parent.verticalCenter}
                    }
                    Text{text:"Download";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:10}
                }

                // Separator
                Rectangle { width:1; height:40; color:"#504945"; opacity:0.4; anchors.centerIn:parent }

                // Upload — right half
                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Row { spacing:6; layoutDirection:Qt.RightToLeft
                        Image{width:14;height:14;smooth:true;anchors.verticalCenter:parent.verticalCenter;source:sp.ico(sp.i_up,"%23fe8019",14)}
                        Text{text:sp.fmtNet(sp.txKb);color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16;font.weight:Font.Medium;anchors.verticalCenter:parent.verticalCenter}
                    }
                    Text{text:"Upload";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:11;anchors.right:parent.right}
                }
            }
        }

        // ── Disk — one card per partition ─────────────────────────────
        Repeater {
            model: sp.diskList.length > 0 ? sp.diskList : [{mount:"/",total:"",used:"",free:"",pct:0}]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true; height: 62; radius: 10; color: "#3c3836"
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    anchors.topMargin: 10; anchors.bottomMargin: 10

                    Row {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 6
                        Image { width:13; height:13; smooth:true; anchors.verticalCenter:parent.verticalCenter
                            source: sp.ico(sp.i_disk, "%23a89984", 13) }
                        Text { text: modelData.mount; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:13; font.weight:Font.Medium; anchors.verticalCenter:parent.verticalCenter }
                        Item { width:1; height:1; Layout.fillWidth:true }
                        Text { text: modelData.used+" / "+modelData.total; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:12; anchors.verticalCenter:parent.verticalCenter }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 6; radius: 3; color: "#504945"
                        Rectangle {
                            width: parent.width * Math.min(modelData.pct, 100) / 100
                            height: parent.height; radius: 3; color: "#a89984"
                            Behavior on width { NumberAnimation { duration: 600 } }
                        }
                        Text { anchors.right:parent.right; anchors.rightMargin:4; anchors.verticalCenter:parent.verticalCenter
                            text: modelData.pct+"%"; color:"#ebdbb2"; font.family:"Google Sans"; font.pixelSize:10; font.weight:Font.Bold }
                    }
                }
            }
        }

        // ── Load avg ──────────────────────────────────────────────────
        Rectangle { Layout.fillWidth:true; height:58; radius:10; color:"#3c3836"
            Item {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Text{text:"Load Average";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:10}
                    Row { spacing:14
                        Column { spacing:1
                            Text{text:sp.loadAvg1.toFixed(2);color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16;font.weight:Font.Medium}
                            Text{text:"1 min";color:"#a89984";font.family:"Google Sans";font.pixelSize:10}
                        }
                        Column { spacing:1
                            Text{text:sp.loadAvg5.toFixed(2);color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16}
                            Text{text:"5 min";color:"#a89984";font.family:"Google Sans";font.pixelSize:10}
                        }
                        Column { spacing:1
                            Text{text:sp.loadAvg15.toFixed(2);color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16}
                            Text{text:"15 min";color:"#a89984";font.family:"Google Sans";font.pixelSize:10}
                        }
                    }
                }

                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Text{text:"Uptime";color:"#665c54";font.family:"Google Sans";font.pixelSize:11;anchors.right:parent.right}
                    Text{text:sp.uptimeStr||"";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16;font.weight:Font.Medium}
                }
            }
        }

        // ── Host ──────────────────────────────────────────────────────
        Rectangle { Layout.fillWidth:true; height:62; radius:10; color:"#3c3836"
            Item {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text{text:sp.hostname||"";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:16;font.weight:Font.Medium}
                    Text{text:sp.osName||"Linux";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:13}
                }

                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text{text:"Kernel";color:"#665c54";font.family:"Google Sans";font.pixelSize:11;anchors.right:parent.right}
                    Text{text:sp.kernelVer||"";color:"#ebdbb2";font.family:"Google Sans";font.pixelSize:15;font.weight:Font.Medium}
                }
            }
        }
    }
}
