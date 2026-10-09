pragma Singleton
import Quickshell

Singleton {
    readonly property var list: NacreNotifs.list
    readonly property var retained: NacreNotifs.retained
    readonly property var popups: NacreNotifs.popups
    function dismiss(entry) {
        NacreNotifs.dismiss(entry);
    }
    function clearHistory() {
        NacreNotifs.clearHistory();
    }
    function hidePopups() {
        NacreNotifs.hidePopups();
    }
}
