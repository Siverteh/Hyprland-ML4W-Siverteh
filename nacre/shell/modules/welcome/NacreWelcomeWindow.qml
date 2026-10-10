import QtQuick
import QtQuick.Window
import Quickshell
import qs.widgets
import qs.services

FloatingWindow {
    id: root
    title: "Nacre Welcome"
    visible: NacreWelcomeApp.visible
    minimumSize: Qt.size(720, 540)
    implicitWidth: Math.min(1040, Math.max(720, (screen?.width || 1920) * .72))
    implicitHeight: Math.min(760, Math.max(540, (screen?.height || 1200) * .76))
    color: NacreTokens.body
    updatesEnabled: NacreWelcomeApp.active
    readonly property alias view: view
    function activate() {
        minimized = false;
        contentItem.Window.window?.requestActivate();
        view.forceActiveFocus();
    }
    Component.onCompleted: {
        NacreWelcomeApp.window = root;
        const focused = Quickshell.screens.find(s => s.name === NacreHyprland.focusedMonitor?.name);
        if (focused)
            screen = focused;
    }
    Component.onDestruction: if (NacreWelcomeApp.window === root)
        NacreWelcomeApp.window = null
    onWindowConnected: activate()
    onClosed: NacreWelcomeApp.close()
    Item {
        id: header
        width: parent.width
        height: 64
        MouseArea {
            anchors.fill: parent
            onPressed: root.contentItem.Window.window.startSystemMove()
            onDoubleClicked: root.maximized = !root.maximized
        }
        BrandLogo {
            x: 20
            width: 32
            height: 32
            anchors.verticalCenter: parent.verticalCenter
            motionEnabled: NacreTokens.motionEnabled
        }
        NacreText {
            x: 64
            text: "Nacre Welcome"
            font.pointSize: 15
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: NacreTokens.outline
            opacity: .35
        }
    }
    NacreWelcomeView {
        id: view
        x: 24
        y: 80
        width: parent.width - 48
        height: parent.height - 96
    }
    Shortcut {
        sequence: "Ctrl+W"
        context: Qt.WindowShortcut
        onActivated: NacreWelcomeApp.close()
    }
}
