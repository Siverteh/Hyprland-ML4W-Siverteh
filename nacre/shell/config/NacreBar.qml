pragma Singleton
import QtQuick

QtObject {
    property var workspaceNames: ["Browse", "Work", "Chat", "Music", "Mail", "Brain", "Other"]
    property var workspaceIcons: ["language", "terminal", "forum", "music_note", "mail", "neurology", "apps"]
    property QtObject sizes: QtObject {
        property int innerHeight: 30
        property int batteryWidth: 200
    }
}
