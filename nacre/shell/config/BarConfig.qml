pragma Singleton
import QtQuick

QtObject {
    readonly property var workspaceNames: NacreBar.workspaceNames
    readonly property var workspaceIcons: NacreBar.workspaceIcons
    readonly property var sizes: NacreBar.sizes
}
