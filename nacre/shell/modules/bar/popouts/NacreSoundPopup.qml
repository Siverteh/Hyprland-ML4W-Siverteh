import QtQuick
import Quickshell.Services.Pipewire
import qs.widgets
import qs.services

Item {
    id: root
    readonly property var candidates: Pipewire.nodes.values.filter(node => !node.isStream && node.isSink)
    readonly property var outputs: candidates.filter(node => !!node.audio)
    implicitWidth: 320
    implicitHeight: body.implicitHeight
    function chooseOutput(node) {
        if (!node || !outputs.includes(node) || !node.ready || !node.audio)
            return false;
        Pipewire.preferredDefaultAudioSink = node;
        return true;
    }
    PwObjectTracker {
        objects: root.candidates
    }
    Column {
        id: body
        width: root.width
        spacing: 10
        NacreText {
            text: "Sound"
            font.pointSize: 14
        }
        Row {
            width: parent.width
            spacing: 10
            NacreText {
                width: parent.width - 104
                anchors.verticalCenter: parent.verticalCenter
                text: NacreAudio.sink?.description || "Output unavailable"
                elide: Text.ElideRight
            }
            ActionButton {
                text: NacreAudio.muted ? "Unmute" : "Mute"
                enabled: NacreAudio.available
                compact: true
                onClicked: if (enabled)
                    NacreAudio.toggleMute()
            }
        }
        NacreQuickSlider {
            objectName: "quickOutputVolume"
            width: parent.width
            label: "Output volume"
            value: NacreAudio.volume
            enabled: NacreAudio.available
            onMoved: if (enabled)
                NacreAudio.setVolume(value)
        }
        Row {
            width: parent.width
            spacing: 10
            NacreText {
                width: parent.width - 104
                anchors.verticalCenter: parent.verticalCenter
                text: NacreAudio.micAvailable ? "Microphone" : "Microphone unavailable"
                elide: Text.ElideRight
            }
            ActionButton {
                objectName: "quickMicMute"
                text: NacreAudio.micMuted ? "Unmute" : "Mute"
                enabled: NacreAudio.micAvailable
                compact: true
                onClicked: if (enabled)
                    NacreAudio.toggleMic()
            }
        }
        NacreQuickSlider {
            objectName: "quickMicVolume"
            width: parent.width
            label: "Microphone volume"
            value: NacreAudio.micVolume
            enabled: NacreAudio.micAvailable
            onMoved: if (enabled)
                NacreAudio.setMicVolume(value)
        }
        NacreQuickList {
            width: parent.width
            Column {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.outputs
                    delegate: ActionButton {
                        required property var modelData
                        width: parent.width - 10
                        text: modelData.description || modelData.name || "Audio output"
                        selected: Pipewire.defaultAudioSink === modelData
                        enabled: modelData.ready
                        compact: true
                        onClicked: root.chooseOutput(modelData)
                    }
                }
            }
        }
    }
}
