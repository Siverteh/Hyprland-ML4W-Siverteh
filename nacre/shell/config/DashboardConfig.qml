pragma Singleton
import QtQuick

QtObject {
    readonly property var mediaUpdateInterval: NacreDashboard.mediaUpdateInterval
    readonly property var visualiserBars: NacreDashboard.visualiserBars
    readonly property var sizes: NacreDashboard.sizes
}
