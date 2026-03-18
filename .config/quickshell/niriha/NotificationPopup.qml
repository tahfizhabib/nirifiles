import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: win

    anchors.top:   true
    anchors.left:  false
    anchors.right: false

    implicitWidth:  380
    implicitHeight: col.implicitHeight + 16
    color: "transparent"
    visible: NotificationService.popups.length > 0

    WlrLayershell.namespace:     "niriha-notif"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.margins.top:   32

    Column {
        id: col
        anchors.top:              parent.top
        anchors.topMargin:        6
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 16
        spacing: 6

        Repeater {
            model: NotificationService.popups

            Rectangle {
                id: card
                required property var modelData

                width:  col.width
                height: row.implicitHeight + 12
                radius: 10
                color:  "#282828"
                opacity: 0.92

                RowLayout {
                    id: row
                    anchors {
                        left: parent.left; leftMargin: 12
                        right: parent.right; rightMargin: 10
                        top: parent.top; topMargin: 7
                    }
                    spacing: 10

                    // icon
                    Item {
                        Layout.alignment: Qt.AlignTop
                        width: 32; height: 32

                        IconImage {
                            id: ico; anchors.fill: parent; smooth: true
                            source: card.modelData.image !== ""
                                ? card.modelData.image
                                : Quickshell.iconPath(card.modelData.appIcon, true)
                        }
                        Rectangle {
                            anchors.fill: parent; radius: 6; color: "#3c3836"
                            visible: ico.status !== Image.Ready
                            Text {
                                anchors.centerIn: parent
                                text: (card.modelData.appName || "?").charAt(0).toUpperCase()
                                color: "#ebdbb2"; font.pixelSize: 14; font.weight: Font.Bold
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: card.modelData.appName || ""
                                color: "#a89984"; font.family: "Google Sans"; font.pixelSize: 12
                                Layout.fillWidth: true; elide: Text.ElideRight
                            }
                            Text {
                                text: "✕"; color: "#57514e"; font.pixelSize: 13
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: NotificationService.dismiss(card.modelData)
                                }
                            }
                        }

                        Text {
                            visible: (card.modelData.summary || "") !== ""
                            text: card.modelData.summary || ""
                            color: "#ebdbb2"; font.family: "Google Sans"
                            font.pixelSize: 15; font.weight: Font.Medium
                            Layout.fillWidth: true; wrapMode: Text.WordWrap
                            maximumLineCount: 2; elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                        Text {
                            visible: (card.modelData.body || "") !== ""
                            text: card.modelData.body || ""
                            color: "#a89984"; font.family: "Google Sans"; font.pixelSize: 13
                            Layout.fillWidth: true; wrapMode: Text.WordWrap
                            maximumLineCount: 2; elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent; z: -1; cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.dismiss(card.modelData)
                }
            }
        }
    }
}
