import QtQuick
import qs.widgets
import qs.services
import "media" as Controls
import "media/media.js" as Model

Item {
    id: root
    required property bool shouldUpdate
    readonly property bool compact: width < 700
    // The current collector uses zero when no GPU sensor/usage data exists.
    readonly property real gpuTemperature: !NacreSystemUsage.gpuUsageAvailable && NacreSystemUsage.gpuTemp === 0 ? NaN : NacreSystemUsage.gpuTemp
    readonly property var metrics: [
        {
            value: Model.temperature(root.gpuTemperature),
            label: "GPU temperature",
            first: NacreSystemUsage.gpuUsageAvailable ? NacreSystemUsage.gpuPerc : NaN,
            second: Number.isFinite(root.gpuTemperature) ? root.gpuTemperature / 100 : NaN,
            detail: NacreSystemUsage.gpuUsageAvailable ? Model.percent(NacreSystemUsage.gpuPerc) : "Unavailable",
            detailLabel: "GPU usage"
        },
        {
            value: Model.temperature(NacreSystemUsage.cpuTemp),
            label: "CPU temperature",
            first: NacreSystemUsage.cpuPerc,
            second: Number.isFinite(NacreSystemUsage.cpuTemp) ? NacreSystemUsage.cpuTemp / 100 : NaN,
            detail: Model.percent(NacreSystemUsage.cpuPerc),
            detailLabel: "CPU usage"
        },
        {
            value: Model.size(NacreSystemUsage.memUsed),
            label: "Memory used",
            first: NacreSystemUsage.memPerc,
            second: NacreSystemUsage.storagePerc,
            detail: Model.size(NacreSystemUsage.storageUsed),
            detailLabel: "Root storage used"
        }
    ]
    implicitWidth: 835
    implicitHeight: compact ? 914 : 342
    Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: root.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        FastScroll {
            view: scroll
        }
        Repeater {
            model: root.metrics
            delegate: Controls.NacreMetricRing {
                required property var modelData
                required property int index
                objectName: "performanceMetric" + index
                x: root.compact ? 0 : index * root.width / 3
                y: root.compact ? index * 268 : 0
                width: root.compact ? root.width : root.width / 3
                height: 268
                valueText: modelData.value
                label: modelData.label
                firstValue: modelData.first
                secondValue: modelData.second
                detail: modelData.detail
                detailLabel: modelData.detailLabel
            }
        }
        Column {
            x: 12
            y: root.compact ? 814 : 278
            width: parent.width - 24
            spacing: 8
            NacreText {
                objectName: "performanceSummary"
                width: parent.width
                text: "Load (1/5/15m) " + (NacreSystemUsage.loadAverage || "—") + " · RAM " + Model.size(NacreSystemUsage.memTotal) + " · root free " + Model.size(Math.max(0, NacreSystemUsage.storageTotal - NacreSystemUsage.storageUsed))
                font.pointSize: 10
                color: NacreTokens.mutedInk
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            NacreText {
                width: parent.width
                text: "Kernel " + (NacreSystemUsage.kernel || "—")
                font.pointSize: 10
                color: NacreTokens.mutedInk
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
