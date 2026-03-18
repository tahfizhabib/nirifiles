import QtQuick
import QtQuick.Layouts

Rectangle {
    id: tog
    property bool   active:   false
    property bool   dimmed:   false
    property string label:    ""
    property string iconSvg:  ""
    signal toggled()

    implicitHeight: 56
    radius: 8
    color: active ? "#3c3836" : "#1d2021"

    Behavior on color { ColorAnimation { duration: 100 } }

    Column {
        anchors.centerIn: parent
        spacing: 5

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 18; height: 18; smooth: true
            source: {
                var stroke = tog.active ? "%2383a598"
                           : tog.dimmed ? "%23504945"
                           : "%2357514e"
                return tog.iconSvg.replace("currentColor", stroke)
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: tog.label
            color: tog.active ? "#ebdbb2" : "#57514e"
            font.family: "Google Sans"; font.pixelSize: 10
            elide: Text.ElideRight; width: tog.width - 8
            horizontalAlignment: Text.AlignHCenter
            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }

    MouseArea {
        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
        onClicked: tog.toggled()
    }
}
