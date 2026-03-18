pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

QtObject {
    id: svc

    property var popups: []

    property NotificationServer _server: NotificationServer {
        keepOnReload:        true
        actionsSupported:    true
        bodySupported:       true
        imageSupported:      true
        bodyMarkupSupported: false

        onNotification: notif => {
            var arr = svc.popups.slice()
            arr.push(notif)
            svc.popups = arr

            var ms = notif.urgency === Notification.Critical ? 6000 : 3000
            var t = Qt.createQmlObject(
                'import QtQuick; Timer { interval: ' + ms + '; running: true; repeat: false }',
                svc._server, "xt")
            t.triggered.connect(function() {
                svc._remove(notif)
                t.destroy()
            })
        }
    }

    function _remove(notif) {
        var arr = svc.popups.slice()
        var idx = arr.indexOf(notif)
        if (idx !== -1) arr.splice(idx, 1)
        svc.popups = arr
    }

    function dismiss(notif) {
        notif.dismiss()
        _remove(notif)
    }
}
