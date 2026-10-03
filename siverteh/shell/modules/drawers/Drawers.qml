pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        StyledWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            contentItem.opacity: Visibilities.reveal
            contentItem.focus: true
            contentItem.Keys.onEscapePressed: {visibilities.dashboard=false;visibilities.osd=false;visibilities.launcher=false;visibilities.session=false;panels.popouts.hasCurrent=false;}
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: !Visibilities.hidden && (visibilities.launcher || visibilities.session) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: Region {
                x: Visibilities.hidden ? 0 : bar.implicitWidth
                y: 0
                width: Visibilities.hidden ? win.width : win.width - bar.implicitWidth - BorderConfig.thickness
                height: Visibilities.hidden ? win.height : win.height - BorderConfig.thickness
                intersection: Intersection.Xor

                regions: regions.instances
            }

            margins.top: BorderConfig.headerHeight
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: regions

                model: Visibilities.hidden ? [] : panels.children

                Region {
                    required property Item modelData

                    x: modelData.x + bar.implicitWidth
                    y: modelData.y
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

            HyprlandFocusGrab {
                active: !Visibilities.hidden && (visibilities.launcher || visibilities.session)
                windows: [win]
                onCleared: {
                    visibilities.launcher = false;
                    visibilities.session = false;
                }
            }

            StyledRect {
                anchors.fill: parent
                opacity: visibilities.session ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.standard
                    }
                }
            }

            Item {
                id: background

                anchors.fill: parent
                visible: false

                FrameSurface { panels: panels; bar: bar }
            }

            Item {
                anchors.fill: parent
                clip: true
                MultiEffect {
                    anchors.fill: parent
                    source: background
                    shadowEnabled: true
                    blurMax: 15
                    shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
                }
            }

            PersistentProperties {
                id: visibilities

                property bool osd
                property bool session
                property bool launcher
                property bool dashboard
                property int dashboardTab: 0
                property string launcherQuery: ""
                property string launcherMode: "apps"
                property int launcherRequest: 0

                Component.onCompleted: Visibilities.screens[scope.modelData.name] = this
            }

            Interactions {
                screen: scope.modelData
                popouts: panels.popouts
                visibilities: visibilities
                panels: panels
                bar: bar

                Panels {
                    id: panels

                    screen: scope.modelData
                    visibilities: visibilities
                    bar: bar
                }
            }

            Item {
                id: bar
                implicitWidth: BorderConfig.thickness
                function checkPopout(y) { panels.popouts.hasCurrent=false; }
            }
        }
    }
}
