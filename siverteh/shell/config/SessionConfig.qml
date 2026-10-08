pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property int dragThreshold: 30
    readonly property Sizes sizes: Sizes {}

    component Sizes: QtObject {
        readonly property int button: 80
    }
}
