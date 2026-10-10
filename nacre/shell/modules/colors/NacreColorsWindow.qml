import QtQuick
import QtQuick.Window
import Quickshell
import qs.widgets
import qs.services
import qs.modules.settings

FloatingWindow {
    id: root
    title: "Nacre Colors"
    visible: NacreColorsApp.visible
    minimumSize: Qt.size(760, 560)
    implicitWidth: Math.min(1260, Math.max(760, (screen?.width || 1920) * .78))
    implicitHeight: Math.min(900, Math.max(560, (screen?.height || 1200) * .82))
    color: NacreTokens.body
    updatesEnabled: NacreColorsApp.active
    function activate() {
        minimized = false;
        contentItem.Window.window?.requestActivate();
        view.forceActiveFocus();
    }
    Component.onCompleted: {
        NacreColorsApp.window = root;
        const focused = Quickshell.screens.find(s => s.name === NacreHyprland.focusedMonitor?.name);
        if (focused)
            screen = focused;
    }
    Component.onDestruction: if (NacreColorsApp.window === root)
        NacreColorsApp.window = null
    onWindowConnected: activate()
    onClosed: NacreColorsApp.close()
    Item {
        id: header
        width: parent.width
        height: 64
        MouseArea {
            width: parent.width - 136
            height: 64
            onPressed: root.contentItem.Window.window.startSystemMove()
            onDoubleClicked: root.maximized = !root.maximized
        }
        BrandLogo {
            x: 20
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            colorsApp: true
        }
        NacreText {
            x: 64
            anchors.verticalCenter: parent.verticalCenter
            text: "Nacre Colors"
            font.pointSize: 15
        }
        Row {
            x: parent.width - width - 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            NacreWindowButton {
                icon: "remove"
                label: "Minimize"
                onClicked: NacreColorsApp.minimize()
            }
            NacreWindowButton {
                icon: root.maximized ? "filter_none" : "crop_square"
                label: "Maximize or restore"
                onClicked: root.maximized = !root.maximized
            }
            NacreWindowButton {
                icon: "close"
                label: "Close Colors"
                onClicked: NacreColorsApp.close()
            }
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: NacreTokens.outline
            opacity: .4
        }
    }
    NacreColorsView {
        id: view
        x: 16
        y: 80
        width: parent.width - 32
        height: parent.height - 96
    }
    Shortcut {
        sequence: "Ctrl+W"
        context: Qt.WindowShortcut
        onActivated: NacreColorsApp.close()
    }
    Shortcut {
        sequence: "Ctrl+Return"
        context: Qt.WindowShortcut
        onActivated: NacreColorsApp.action("apply")
    }
    Shortcut {
        sequence: "Ctrl+F"
        context: Qt.WindowShortcut
        onActivated: view.search()
    }
}
