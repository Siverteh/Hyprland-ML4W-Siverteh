import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.widgets

Column {
    id: root

    required property PersistentProperties visibilities

    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    padding: Appearance.padding.large
    spacing: Appearance.spacing.small

    Repeater {
        id: actions

        model: [
            {
                "label": "Lock",
                "icon": "lock",
                "command": ["hyprlock"]
            },
            {
                "label": "Log out",
                "icon": "logout",
                "command": ["hyprctl", "eval", "hl.dispatch(hl.dsp.exit())"]
            },
            {
                "label": "Restart",
                "icon": "restart_alt",
                "command": ["systemctl", "reboot"]
            },
            {
                "label": "Power off",
                "icon": "power_settings_new",
                "command": ["systemctl", "poweroff"]
            }
        ]

        StyledRect {
            id: button

            required property var modelData
            required property int index

            implicitWidth: 120
            implicitHeight: 80
            radius: Appearance.rounding.normal
            color: activeFocus ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainer
            Keys.onReturnPressed: proc.startDetached()
            Keys.onEnterPressed: proc.startDetached()
            Keys.onEscapePressed: root.visibilities.session = false
            Keys.onDownPressed: {
                if (index < 3) {
                    actions.itemAt(index + 1).forceActiveFocus();
                }
            }
            Keys.onUpPressed: {
                if (index > 0) {
                    actions.itemAt(index - 1).forceActiveFocus();
                }
            }

            Process {
                id: proc

                command: button.modelData.command
            }

            Connections {
                function onSessionChanged() {
                    if (root.visibilities.session && button.index === 0)
                        button.forceActiveFocus();
                }

                target: root.visibilities
            }

            Column {
                anchors.centerIn: parent
                spacing: 5

                MaterialIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: button.modelData.icon
                    font.pointSize: 24
                    color: button.index === 3 ? Colours.palette.m3error : Colours.palette.m3onSurface
                }

                StyledText {
                    text: button.modelData.label
                    font.pointSize: 11
                }
            }

            StateLayer {
                function onClicked() {
                    proc.startDetached();
                }

                radius: button.radius
            }
        }
    }
}
