pragma Singleton
import Quickshell

Singleton {
    readonly property var pending: NacrePresentation.pending
    readonly property var active: NacrePresentation.active
    readonly property bool available: NacrePresentation.available
    function accept(data) {
        return NacrePresentation.accept(data);
    }
    function activate(poster) {
        return NacrePresentation.activate(poster);
    }
}
