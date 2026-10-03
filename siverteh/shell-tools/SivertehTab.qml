import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    implicitWidth: 650
    implicitHeight: 260
    spacing: Tokens.spacing.large
    StyledText { text: "Siverteh AI"; font: Tokens.font.headline.medium }
    StyledText { text: "Start a conversation. Follow a thought into your brain."; font: Tokens.font.body.medium }
    GridLayout {
        columns: 3
        rowSpacing: Tokens.spacing.medium
        columnSpacing: Tokens.spacing.medium
        Repeater {
            model: [
                {text:"New chat",icon:"chat_bubble",action:"new"},
                {text:"Resume chat",icon:"history",action:"resume"},
                {text:"AI workspace",icon:"tune",action:"tasks"},
                {text:"Open brain",icon:"neurology",action:"brain"},
                {text:"Capture",icon:"edit_note",action:"capture"},
                {text:"Updates",icon:"package_2",action:"updates"}
            ]
            delegate: IconTextButton {
                required property var modelData
                Layout.preferredWidth: 200
                Layout.preferredHeight: 58
                text: modelData.text
                icon: modelData.icon
                onClicked: { ShellState.forActive().dashboard=false; Quickshell.execDetached(["siverteh-observatory",modelData.action]); }
            }
        }
    }
}
