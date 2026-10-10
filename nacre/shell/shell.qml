import QtQuick
import Quickshell
import qs.services
import qs.modules
import qs.modules.drawers
import qs.modules.background
import qs.modules.extras

ShellRoot {
    property var controlTools: NacreControlTools
    property var batteryAlerts: NacreBatteryAlerts
    property var lockWidgets: LockWidgets
    property var displayRecovery: DisplayRecovery
    NacreBackground {}
    NacreDesktop {}
    NacreShellShortcuts {}
    NacreShellIpc {}
    Component.onCompleted: ChatWindowTitle.scan()
}
