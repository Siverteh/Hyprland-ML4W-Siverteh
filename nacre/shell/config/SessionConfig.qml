pragma Singleton
import QtQuick

QtObject {
    readonly property var dragThreshold: NacreSession.dragThreshold
    readonly property var sizes: NacreSession.sizes
}
