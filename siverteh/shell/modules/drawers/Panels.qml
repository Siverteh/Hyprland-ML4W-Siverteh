import QtQuick
import Quickshell
import qs.config
import qs.modules.bar.popouts as BarPopouts
import qs.modules.dashboard as Dashboard
import qs.modules.extras as Extras
import qs.modules.launcher as Launcher
import qs.modules.notifications as Notifications
import qs.modules.osd as Osd
import qs.modules.session as Session
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property Item bar
    readonly property Osd.Wrapper osd: osd
    readonly property Notifications.Wrapper notifications: notifications
    readonly property Session.Wrapper session: session
    readonly property Launcher.Wrapper launcher: launcher
    readonly property Dashboard.Wrapper dashboard: dashboard
    readonly property Extras.LeftDrawer leftDrawer: brainDrawer
    readonly property BarPopouts.Wrapper popouts: popouts

    anchors.fill: parent
    anchors.rightMargin: BorderConfig.right
    anchors.bottomMargin: BorderConfig.bottom
    anchors.leftMargin: bar.implicitWidth
    anchors.topMargin: BorderConfig.headerHeight
    Component.onCompleted: {
        const mapping = Object.assign({}, Visibilities.panels);
        mapping[screen.name] = this;
        Visibilities.panels = mapping;
    }

    Extras.LeftDrawer {
        id: brainDrawer

        screen: root.screen
        visibilities: root.visibilities
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    Osd.Wrapper {
        id: osd

        clip: root.visibilities.session
        screen: root.screen
        visibility: root.visibilities.osd && !root.visibilities.session
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: session.width
    }

    Notifications.Wrapper {
        id: notifications

        suppressed: popouts.height > 0.1 || session.width > 0.1 || dashboard.height > 0.1
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Session.Wrapper {
        id: session

        visibilities: root.visibilities
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
    }

    Launcher.Wrapper {
        id: launcher

        z: 100
        visibilities: root.visibilities
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    Dashboard.Wrapper {
        id: dashboard

        visibilities: root.visibilities
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    BarPopouts.Wrapper {
        id: popouts

        readonly property bool joinsRight: currentCenter - root.bar.implicitWidth + targetWidth / 2 > parent.width - BorderConfig.rounding * 2

        screen: root.screen
        anchors.top: parent.top
        x: joinsRight ? parent.width - width : Math.max(BorderConfig.rounding * 2, currentCenter - root.bar.implicitWidth - width / 2)
    }
}
