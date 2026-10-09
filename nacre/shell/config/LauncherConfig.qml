pragma Singleton
import QtQuick

QtObject {
    readonly property var maxShown: NacreLauncher.maxShown
    readonly property var maxWallpapers: NacreLauncher.maxWallpapers
    readonly property var actionPrefix: NacreLauncher.actionPrefix
    readonly property var sizes: NacreLauncher.sizes
}
