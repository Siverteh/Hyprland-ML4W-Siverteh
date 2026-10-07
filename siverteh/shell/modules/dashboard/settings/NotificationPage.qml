import qs.widgets
import qs.services
import QtQuick

SettingsPage {
    SettingsSection {
        title: "Notification behavior"
        SettingToggle {
            label: "Do not disturb"
            setting: "dnd"
        }
        SettingToggle {
            label: "Show notification summaries on the lock screen"
            setting: "lockNotifications"
        }
        SettingToggle {
            label: "Show message previews while locked"
            setting: "lockNotificationContents"
        }
        StyledText {
            width: parent.width
            wrapMode: Text.Wrap
            text: "Do not disturb silences popups while keeping history. Notifications stay here until you dismiss them."
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
    }
    SettingsSection {
        title: "Notification history"
        description: Notifs.retained.length + " retained notifications"
        ActionButton {
            text: "Clear history"
            icon: "clear_all"
            enabled: Notifs.retained.length > 0
            onClicked: confirm.visible = !confirm.visible
        }
        Row {
            id: confirm
            visible: false
            spacing: 8
            ActionButton {
                text: "Clear all"
                selected: true
                onClicked: {
                    Notifs.clearHistory();
                    confirm.visible = false;
                }
            }
            ActionButton {
                text: "Cancel"
                onClicked: confirm.visible = false
            }
        }
        Repeater {
            model: [...Notifs.retained].reverse()
            Column {
                required property var modelData
                width: parent.width
                spacing: 4
                Row {
                    width: parent.width
                    StyledText {
                        width: parent.width - 55
                        text: parent.parent.modelData.appName + " · " + parent.parent.modelData.timeStr
                        color: Colours.palette.m3primary
                        font.pointSize: 10
                    }
                    ActionButton {
                        text: ""
                        icon: "close"
                        onClicked: Notifs.dismiss(parent.parent.modelData)
                    }
                }
                StyledText {
                    width: parent.width
                    text: parent.modelData.summary
                    wrapMode: Text.Wrap
                    font.pointSize: 12
                }
                StyledText {
                    width: parent.width
                    text: parent.modelData.body
                    wrapMode: Text.Wrap
                    font.pointSize: 10
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }
}
