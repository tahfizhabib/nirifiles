import QtQuick

Item {
    id: pill
    property string iconSvg:     ""
    property string valueText:   ""
    property color  accentColor: "#83a598"
    property bool   _open:       false
    signal clicked()

    height: 19
    width: _open ? (16 + lbl.implicitWidth + 8) : 20
    Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Image {
        id: ico
        width: 17; height: 17
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        smooth: true
        source: pill.iconSvg !== ""
            ? "data:image/svg+xml;utf8," + pill.iconSvg.replace(/currentColor/g,
                pill._open ? pill.encodeColor(pill.accentColor) : "%23ebdbb2")
            : ""
    }

    Text {
        id: lbl
        text: pill.valueText
        color: pill.accentColor
        opacity: pill._open ? 1 : 0
        anchors.left: ico.right; anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Google Sans"; font.pixelSize: 14; font.weight: Font.Medium
        Behavior on opacity { NumberAnimation { duration: 110 } }
    }

    MouseArea {
        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        onEntered: pill._open = true
        onExited:  pill._open = false
        onClicked: pill.clicked()
    }

    function encodeColor(c) {
        var r = Math.round(c.r * 255).toString(16).padStart(2, '0')
        var g = Math.round(c.g * 255).toString(16).padStart(2, '0')
        var b = Math.round(c.b * 255).toString(16).padStart(2, '0')
        return "%23" + r + g + b
    }
}
