pragma Singleton
import QtQuick

QtObject {
    readonly property var expire: NacreNotifications.expire
    readonly property var defaultExpireTimeout: NacreNotifications.defaultExpireTimeout
    readonly property var clearThreshold: NacreNotifications.clearThreshold
    readonly property var expandThreshold: NacreNotifications.expandThreshold
    readonly property var actionOnClick: NacreNotifications.actionOnClick
    readonly property var sizes: NacreNotifications.sizes
}
