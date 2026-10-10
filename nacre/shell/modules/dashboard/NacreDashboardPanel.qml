pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.widgets

NacreSurface {
    id: root
    required property PersistentProperties visibilities
    readonly property real viewportWidth: parent?.width ?? 1200
    readonly property real viewportHeight: parent?.height ?? 1000
    readonly property int currentIndex: [0, 1, 2, 3].includes(visibilities.dashboardTab) ? visibilities.dashboardTab : 0
    readonly property bool updating: visibilities.dashboard && visible
    readonly property real contentWidth: Math.min(viewportWidth - 48, Math.max(320, (page.item?.implicitWidth || 820) + 44))
    readonly property real contentHeight: Math.min(viewportHeight - 64, navigation.height + (page.item?.implicitHeight || 420) + 44)
    property real presentedHeight: visibilities.dashboard ? contentHeight : 0
    implicitWidth: Math.max(0, contentWidth)
    implicitHeight: Math.max(0, presentedHeight)
    visible: height > 0
    color: NacreTokens.body
    clip: true
    radius: 18
    function select(index) {
        visibilities.dashboardTab = index;
        visibilities.dashboardPinned = false;
    }
    NacreDashboardNavigation {
        id: navigation
        objectName: "dashboardNavigation"
        x: 22
        y: 12
        width: Math.max(0, root.width - 44)
        currentIndex: root.currentIndex
        onSelected: index => root.select(index)
    }
    Loader {
        id: page
        objectName: "dashboardPage"
        active: root.visibilities.dashboard || root.presentedHeight > 0
        x: 22
        y: navigation.y + navigation.height + 14
        width: Math.max(0, root.width - 44)
        height: Math.max(0, root.contentHeight - y - 18)
        focus: true
        sourceComponent: [overview, media, performance, workspaces][root.currentIndex]
    }
    Component {
        id: overview
        NacreOverview {
            shouldUpdate: root.updating
        }
    }
    Component {
        id: media
        NacreMediaPage {
            shouldUpdate: root.updating
            visibilities: root.visibilities
        }
    }
    Component {
        id: performance
        NacrePerformancePage {
            shouldUpdate: root.updating
        }
    }
    Component {
        id: workspaces
        NacreWorkspacePage {
            visibilities: root.visibilities
        }
    }
    Behavior on presentedHeight {
        NumberAnimation {
            duration: NacreTokens.motionEnabled ? 360 : 0
            easing.type: Easing.InOutCubic
        }
    }
    Keys.onEscapePressed: {
        visibilities.dashboard = false;
        visibilities.dashboardPinned = false;
    }
}
