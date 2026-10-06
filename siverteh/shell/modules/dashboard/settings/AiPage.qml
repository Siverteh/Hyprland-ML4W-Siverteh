import qs.widgets
import qs.services
import QtQuick

SettingsPage {
    SettingsSection {
        title: "Default assistant"
        description: "Used for new chats. Existing conversations keep their assistant and account."
        Row {
            spacing: 8
            ActionButton {
                text: "Codex"
                selected: SidebarChat.defaultProvider === "codex"
                onClicked: SidebarChat.setProvider("codex")
            }
            ActionButton {
                text: "Claude Code"
                selected: SidebarChat.defaultProvider === "claude"
                onClicked: SidebarChat.setProvider("claude")
            }
        }
        SettingToggle {
            label: "Show the left-edge AI drawer"
            setting: "leftDrawer"
        }
        ActionButton {
            text: "Accounts, usage and projects"
            icon: "manage_accounts"
            onClicked: DesktopActions.execute("tasks")
        }
    }
    SettingsSection {
        title: "Brain and conversations"
        description: "Your private notes, accounts and chat history stay outside the OS repository."
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                text: "Open Brain"
                icon: "neurology"
                onClicked: DesktopActions.execute("brain")
            }
            ActionButton {
                text: "Open AI sidebar"
                icon: "forum"
                onClicked: AppLaunch.run(["siverteh-os-shell", "left"])
            }
        }
    }
    Component.onCompleted: SidebarChat.start()
}
