pragma Singleton
import Quickshell

Singleton {
    readonly property bool visibleDashboard: NacreSystemUsage.visibleDashboard
    readonly property string kernel: NacreSystemUsage.kernel
    readonly property string loadAverage: NacreSystemUsage.loadAverage
    readonly property real cpuPerc: NacreSystemUsage.cpuPerc
    readonly property real cpuTemp: NacreSystemUsage.cpuTemp
    readonly property bool gpuUsageAvailable: NacreSystemUsage.gpuUsageAvailable
    readonly property real gpuPerc: NacreSystemUsage.gpuPerc
    readonly property real gpuTemp: NacreSystemUsage.gpuTemp
    readonly property real memUsed: NacreSystemUsage.memUsed
    readonly property real memTotal: NacreSystemUsage.memTotal
    readonly property real memPerc: NacreSystemUsage.memPerc
    readonly property real storageUsed: NacreSystemUsage.storageUsed
    readonly property real storageTotal: NacreSystemUsage.storageTotal
    readonly property real storagePerc: NacreSystemUsage.storagePerc
    function formatKib(value) {
        return NacreSystemUsage.formatKib(value);
    }
}
