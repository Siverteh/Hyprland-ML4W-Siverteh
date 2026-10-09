pragma Singleton
import QtQuick

QtObject {
    readonly property string home: NacrePaths.home
    readonly property string pictures: NacrePaths.pictures
    readonly property string config: NacrePaths.config
    readonly property string state: NacrePaths.state
    readonly property string cache: NacrePaths.cache
}
