import QtQuick
import Quickshell
import qs.services
import qs.modules
import qs.modules.drawers
import qs.modules.background
import qs.modules.topbar
import qs.modules.extras

ShellRoot {
    property var controlTools: NacreControlTools
    property var batteryAlerts: NacreBatteryAlerts
    property var lockWidgets: LockWidgets
    property var displayRecovery: DisplayRecovery
    NacreBackground {}
    NacreDesktop {}
    NacreTopBar {}
    NacreShellShortcuts {}
    NacreShellIpc {}
    Component.onCompleted: ChatWindowTitle.scan()
}
