import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.utils
import qs.widgets

Row {
    id: root

    padding: NacreAppearance.padding.large
    spacing: NacreAppearance.spacing.large

    NacreClip {
        implicitWidth: info.implicitHeight
        implicitHeight: info.implicitHeight
        radius: NacreAppearance.rounding.full
        color: Colours.palette.m3surfaceContainerHigh

        BrandLogo {
            anchors.centerIn: parent
            scale: parent.width / 48
        }
    }

    Column {
        id: info

        spacing: NacreAppearance.spacing.normal

        InfoLine {
            icon: "badge"
            text: Quickshell.env("USER") || "Siverteh"
            colour: Colours.palette.m3primary
        }

        InfoLine {
            icon: "computer"
            text: NacreIcons.osName
            colour: Colours.palette.m3primary
        }

        InfoLine {
            icon: "select_window_2"
            text: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP")
            colour: Colours.palette.m3secondary
        }

        InfoLine {
            icon: "timer"
            text: uptimeProc.uptime
            colour: Colours.palette.m3tertiary

            Timer {
                running: true
                repeat: true
                interval: 15000
                onTriggered: uptimeProc.running = true
            }

            Process {
                id: uptimeProc

                property string uptime

                running: true
                command: ["uptime", "-p"]

                stdout: SplitParser {
                    onRead: data => {
                        return uptimeProc.uptime = data;
                    }
                }
            }
        }
    }

    component InfoLine: Item {
        id: line

        required property string icon
        required property string text
        required property color colour

        implicitWidth: icon.implicitWidth + text.width + text.anchors.leftMargin
        implicitHeight: Math.max(icon.implicitHeight, text.implicitHeight)

        NacreIcon {
            id: icon

            anchors.left: parent.left
            anchors.leftMargin: (NacreDashboard.sizes.infoIconSize - implicitWidth) / 2
            text: line.icon
            color: line.colour
            font.pointSize: NacreAppearance.font.size.normal
            font.variableAxes: ({
                    "FILL": 1
                })
        }

        NacreText {
            id: text

            anchors.verticalCenter: icon.verticalCenter
            anchors.left: icon.right
            anchors.leftMargin: icon.anchors.leftMargin
            text: `:  ${line.text}`
            font.pointSize: NacreAppearance.font.size.normal
            width: NacreDashboard.sizes.infoWidth
            elide: Text.ElideRight
        }
    }
}
