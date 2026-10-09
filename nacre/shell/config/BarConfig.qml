pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property list<string> workspaceNames: ["Browse", "Work", "Chat", "Music", "Mail", "Brain", "Other"]
    readonly property list<string> workspaceIcons: ["language", "terminal", "forum", "music_note", "mail", "neurology", "apps"]
    readonly property Sizes sizes: Sizes {}

    component Sizes: QtObject {
        property int innerHeight: 30
        property int batteryWidth: 200
    }
}
