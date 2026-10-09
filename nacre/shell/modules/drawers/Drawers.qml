pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import qs.modules.launcher as Launcher
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Variants {
    model: DisplayRecovery.surfaceScreens

    Scope {
        id: scope

        required property ShellScreen modelData
        property string stableName: ""
        Component.onCompleted: stableName = modelData.name
        Component.onDestruction: {
            if (stableName && !Quickshell.screens.some(s => s.name === stableName))
                DisplayRecovery.remember(stableName);
        }

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        NacreWindow {
            id: win

            screen: scope.modelData
            name: "drawers"
            contentItem.opacity: Visibilities.reveal
            contentItem.focus: true
            function dismissOverlays() {
                HoverIntent.dismiss(win.screen);
                visibilities.edgeMenu = "";
                visibilities.dashboard = false;
                visibilities.osd = false;
                visibilities.launcher = false;
                visibilities.session = false;
                visibilities.left = false;
                visibilities.leftPinned = false;
                visibilities.previewOnly = false;
                panels.popouts.hasCurrent = false;
                panels.popouts.pinned = false;
            }
            contentItem.Keys.onEscapePressed: dismissOverlays()
            Shortcut {
                sequence: "Escape"
                context: Qt.WindowShortcut
                enabled: !Visibilities.hidden && (visibilities.launcher || visibilities.session || visibilities.left || visibilities.dashboard || visibilities.osd || panels.popouts.hasCurrent)
                onActivated: win.dismissOverlays()
            }
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            // Exclusive mode gives modal controls keyboard focus before a mouse click.
            WlrLayershell.keyboardFocus: Visibilities.hidden || visibilities.previewOnly ? WlrKeyboardFocus.None : visibilities.launcher || visibilities.session || (visibilities.dashboard && visibilities.dashboardPinned) || panels.popouts.pinned || visibilities.edgeMenu !== "" ? WlrKeyboardFocus.Exclusive : visibilities.left ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: !Visibilities.hidden && !visibilities.previewOnly && (visibilities.launcher || visibilities.edgeMenu !== "" || (visibilities.dashboard && visibilities.dashboardPinned)) ? null : frameMask
            function panelAcceptsInput(item) {
                if (item === panels.dashboard)
                    return visibilities.dashboard;
                if (item === panels.popouts)
                    return panels.popouts.hasCurrent;
                if (item === panels.launcher)
                    return visibilities.launcher;
                if (item === panels.osd)
                    return visibilities.osd;
                if (item === panels.session)
                    return visibilities.session;
                if (item === panels.leftDrawer)
                    return visibilities.left;
                if (item === panels.notifications)
                    return !panels.notifications.suppressed && Notifs.popups.length > 0;
                return item.visible;
            }
            readonly property Region frameMask: Region {
                x: Visibilities.hidden || visibilities.previewOnly ? 0 : bar.implicitWidth
                y: Visibilities.hidden || visibilities.previewOnly ? 0 : NacreFrame.headerHeight
                width: Visibilities.hidden || visibilities.previewOnly ? win.width : win.width - bar.implicitWidth - NacreFrame.right
                height: Visibilities.hidden || visibilities.previewOnly ? win.height : win.height - NacreFrame.headerHeight - NacreFrame.bottom
                intersection: Intersection.Xor

                regions: regions.instances
            }

            // Keep the render surface fixed; move its interior instead of resizing it.
            margins.top: 0
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: regions

                model: Visibilities.hidden || visibilities.previewOnly ? [] : panels.children

                Region {
                    required property Item modelData

                    x: modelData.x + bar.implicitWidth
                    y: modelData.y + panels.y
                    // Closing visuals must never keep intercepting browser clicks.
                    readonly property bool acceptingInput: win.panelAcceptsInput(modelData)
                    width: acceptingInput ? modelData.width : 0
                    height: acceptingInput ? modelData.height : 0
                    intersection: Intersection.Subtract
                }
            }

            // Changing keyboard interactivity remaps the layer surface. Arm click-away
            // capture only after that remap, so its cleared signal cannot close a new popup.
            readonly property bool wantsPopupGrab: !Visibilities.hidden && !visibilities.previewOnly && (visibilities.launcher || visibilities.session || visibilities.edgeMenu !== "" || panels.popouts.pinned)
            property bool popupGrabReady: false
            onWantsPopupGrabChanged: {
                popupGrabReady = false;
                if (wantsPopupGrab)
                    popupGrabDelay.restart();
                else
                    popupGrabDelay.stop();
            }
            Timer {
                id: popupGrabDelay
                interval: 150
                onTriggered: win.popupGrabReady = win.wantsPopupGrab
            }
            HyprlandFocusGrab {
                active: win.popupGrabReady && !Visibilities.hidden && !visibilities.previewOnly && (visibilities.launcher || visibilities.session || visibilities.edgeMenu !== "" || panels.popouts.pinned)
                windows: [win]
                onCleared: {
                    if (win.popupGrabReady && win.wantsPopupGrab)
                        win.dismissOverlays();
                }
            }

            NacreSurface {
                anchors.fill: parent
                opacity: visibilities.session ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    NumberAnimation {
                        duration: NacreAppearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: NacreAppearance.anim.curves.standard
                    }
                }
            }

            Item {
                id: background

                anchors.fill: parent
                visible: false

                FrameSurface {
                    panels: panels
                    bar: bar
                }
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

            Item {
                anchors.fill: parent
                visible: visibilities.launcher && panels.launcher.fullScreenGallery
                Launcher.WallpaperBackdrop {
                    anchors.fill: parent
                    path: Wallpapers.displayPreview
                }
                Rectangle {
                    anchors.fill: parent
                    color: Qt.alpha(Colours.palette.m3scrim, 0.64)
                }
            }

            PersistentProperties {
                id: visibilities

                property bool previewOnly
                property bool osd
                property bool session
                property bool launcher
                property bool left
                onLeftPinnedChanged: if (left && DesktopSettings.data.clickEdgeMenus === true)
                    edgeMenu = leftPinned ? "" : "left"
                property bool leftPinned
                property bool dashboard
                property string edgeMenu: ""
                onLeftChanged: if (!left && edgeMenu === "left")
                    edgeMenu = ""
                onOsdChanged: if (!osd && edgeMenu === "osd")
                    edgeMenu = ""
                property bool dashboardPinned: false
                onDashboardChanged: if (!dashboard) {
                    dashboardPinned = false;
                    if (edgeMenu === "dashboard")
                        edgeMenu = "";
                }
                property int dashboardTab: 0
                property string launcherQuery: ""
                property string launcherMode: "apps"
                property int launcherRequest: 0

                Component.onDestruction: {
                    if (Visibilities.screens[scope.stableName] === this) {
                        const mapping = Object.assign({}, Visibilities.screens);
                        delete mapping[scope.stableName];
                        Visibilities.screens = mapping;
                    }
                }
                Component.onCompleted: {
                    const mapping = Object.assign({}, Visibilities.screens);
                    mapping[scope.modelData.name] = this;
                    Visibilities.screens = mapping;
                }
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
                implicitWidth: NacreFrame.left
                function checkPopout(y) {
                    panels.popouts.hasCurrent = false;
                }
            }
        }
    }
}
