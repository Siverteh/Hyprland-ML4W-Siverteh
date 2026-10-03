import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    implicitWidth: 650
    implicitHeight: 240
    spacing: Tokens.spacing.large
    StyledText { text: "Your workspaces"; font: Tokens.font.title.large }
    GridLayout {
        columns: 4
        rowSpacing: Tokens.spacing.medium
        columnSpacing: Tokens.spacing.medium
        Repeater {
            model: ["Browse", "Work", "Chat", "Music", "Mail", "Brain", "Spare"]
            delegate: IconTextButton {
                required property string modelData
                required property int index
                Layout.preferredWidth: 150
                Layout.preferredHeight: 58
                text: (index+1) + "  " + modelData
                icon: ["language","code","forum","music_note","mail","neurology","more_horiz"][index]
                onClicked: { Hypr.focusWorkspace(index+1); ShellState.forActive().dashboard=false; }
            }
        }
    }
}
