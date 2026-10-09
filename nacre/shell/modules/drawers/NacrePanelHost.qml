import QtQuick
import Quickshell
import qs.config
import qs.modules.bar.popouts as Popouts
import qs.modules.dashboard as Dashboard
import qs.modules.extras as Extras
import qs.modules.launcher as Launcher
import qs.modules.notifications as Notifications
import qs.modules.osd as Osd
import qs.modules.session as Session

Item {
    id: root
    required property var screen
    required property var visibilities
    required property var input
    readonly property alias leftDrawer: left
    readonly property alias dashboard: dashboard
    readonly property alias launcher: launcher
    readonly property alias notifications: notifications
    readonly property alias session: session
    readonly property alias osd: osd
    readonly property alias popouts: popouts
    readonly property bool hovered: input.hovered
    readonly property bool popoutHovered: input.popoutHovered
    readonly property bool dashboardHovered: input.dashboardHovered
    anchors.leftMargin: NacreFrame.left
    anchors.rightMargin: NacreFrame.right
    anchors.topMargin: NacreFrame.headerHeight
    anchors.bottomMargin: NacreFrame.bottom
    Extras.LeftDrawer {
        id: left
        screen: root.screen
        visibilities: root.visibilities
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        clip: true
    }
    Osd.Wrapper {
        id: osd
        screen: root.screen
        visibility: root.visibilities.osd && !root.visibilities.session
        anchors.right: parent.right
        anchors.rightMargin: session.width
        anchors.verticalCenter: parent.verticalCenter
        clip: true
    }
    Session.Wrapper {
        id: session
        visibilities: root.visibilities
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        clip: true
    }
    Dashboard.Wrapper {
        id: dashboard
        visibilities: root.visibilities
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true
    }
    Popouts.Wrapper {
        id: popouts
        screen: root.screen
        readonly property bool joinsRight: currentCenter - root.x + targetWidth / 2 > root.width - NacreFrame.rounding * 2
        anchors.top: parent.top
        x: joinsRight ? parent.width - width : Math.max(NacreFrame.rounding * 2, currentCenter - root.x - width / 2)
        clip: true
    }
    Notifications.Wrapper {
        id: notifications
        suppressed: popouts.height > 0.1 || session.width > 0.1 || dashboard.height > 0.1
        anchors.right: parent.right
        anchors.top: parent.top
    }
    Launcher.Wrapper {
        id: launcher
        visibilities: root.visibilities
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        clip: true
        z: 10
    }
}
