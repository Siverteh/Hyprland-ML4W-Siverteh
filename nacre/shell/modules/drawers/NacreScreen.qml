import QtQuick
import "registry.js" as Registry
import Quickshell
import Quickshell.Wayland
import qs.widgets
import qs.services

NacreWindow {
    id: root
    name: "drawers"
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    WlrLayershell.layer: inputController.modal ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: inputController.modal ? WlrKeyboardFocus.Exclusive : (flags.left || flags.osd || flags.dashboard) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    property string registeredName: ""
    PersistentProperties {
        id: flags
        reloadableId: "nacre-view-" + root.screen.name
        property bool previewOnly: false
        property bool osd: false
        property bool session: false
        property bool launcher: false
        property bool left: false
        property bool leftPinned: false
        property bool dashboard: false
        property bool dashboardPinned: false
        property int dashboardTab: 0
        property string launcherQuery: ""
        property string launcherMode: "apps"
        property int launcherRequest: 0
        property string edgeMenu: ""
        property string controlSection: "home"
    }
    Component.onCompleted: {
        registeredName = screen.name;
        Registry.register(NacrePanelState, registeredName, flags, panelHost);
    }
    Component.onDestruction: Registry.release(NacrePanelState, registeredName, flags, panelHost)
    mask: NacrePanelMask {
        controller: inputController
    }
    NacreReservedEdges {
        screen: root.screen
    }
    FocusScope {
        id: scene
        anchors.fill: parent
        opacity: NacrePanelState.reveal
        focus: true
        Keys.priority: Keys.AfterItem
        Keys.onEscapePressed: event => {
            inputController.dismiss();
            event.accepted = true;
        }
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: flags.session ? 0.45 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: NacreTokens.motionEnabled ? 200 : 0
                }
            }
        }
        NacreChrome {
            anchors.fill: parent
            host: panelHost
        }
        NacrePanelInput {
            id: inputController
            anchors.fill: parent
            screen: root.screen
            panels: panelHost
            lips: lips
            visibilities: flags
        }
        NacrePanelHost {
            id: panelHost
            anchors.fill: parent
            screen: root.screen
            visibilities: flags
            input: inputController
            z: 1
        }
        NacreFrameLips {
            id: lips
            anchors.fill: parent
            screen: root.screen
            visibilities: flags
            controller: inputController
            z: 3
        }
    }
}
