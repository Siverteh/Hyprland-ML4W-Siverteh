pragma ComponentBehavior: Bound

import qs.widgets
import qs.config
import qs.services
import Quickshell
import QtQuick

Scope {
    id: root

    required property ShellScreen screen
    required property Item bar

    ExclusionZone {
        anchors.left: true
        exclusiveZone: Visibilities.hidden ? 0 : root.bar.implicitWidth
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: Visibilities.hidden ? 0 : BorderConfig.headerHeight
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: Visibilities.hidden ? 0 : BorderConfig.right
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: Visibilities.hidden ? 0 : BorderConfig.bottom
    }

    component ExclusionZone: StyledWindow {
        screen: root.screen
        name: "border-exclusion"
        exclusiveZone: Visibilities.hidden ? 0 : BorderConfig.thickness
    }
}
