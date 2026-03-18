import QtQuick

Item {
    id: sl
    property real  value:       50
    property real  maxValue:    100
    property color accentColor: "#83a598"
    signal moved(real v)

    implicitHeight: 22

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 5; radius: 2.5
        color: "#2d3133"

        Rectangle {
            id: fill
            width: Math.max(fill.height, track.width * sl.value / sl.maxValue)
            height: parent.height; radius: 2.5
            color: sl.accentColor
            Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        }
    }

    // Thumb
    Rectangle {
        id: thumb
        width: dragMa.pressed ? 18 : (dragMa.containsMouse ? 16 : 14)
        height: width; radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(track.width - width/2, track.width * sl.value / sl.maxValue - width / 2))
        color: sl.accentColor
        Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
        Behavior on x    { NumberAnimation { duration: 80;  easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.4; height: width; radius: width / 2
            color: "#1a1c1e"
            opacity: dragMa.pressed ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 80 } }
        }
    }

    MouseArea {
        id: dragMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed:         updateVal(mouseX)
        onPositionChanged: if (pressed) updateVal(mouseX)
    }

    function updateVal(mx) {
        var v = Math.round(Math.max(0, Math.min(maxValue, mx / width * maxValue)))
        moved(v)
    }
}
