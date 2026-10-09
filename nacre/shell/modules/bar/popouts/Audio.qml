import qs.widgets
import qs.services
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 340
    width: implicitWidth
    implicitHeight: body.implicitHeight
    readonly property var outputs: Pipewire.nodes.values.filter(n => !n.isStream && n.isSink)
    PwObjectTracker {
        objects: root.outputs
    }
    Column {
        id: body
        width: root.width
        spacing: 12
        NacreText {
            text: "Sound"
            font.pointSize: 14
            color: Colours.palette.m3primary
        }
        Row {
            width: parent.width
            NacreText {
                width: parent.width - 65
                text: Audio.sink?.description ?? "No output device"
                elide: Text.ElideRight
                font.pointSize: 11
            }
            NacreText {
                text: Math.round(Audio.volume * 100) + "%"
                font.pointSize: 11
            }
        }
        QuickSlider {
            objectName: "quickOutputVolume"
            width: parent.width
            from: 0
            to: 1
            enabled: !!Audio.sink?.ready
            value: Audio.volume
            onMoved: Audio.setVolume(value)
        }
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                objectName: "quickOutputMute"
                text: Audio.muted ? "Unmute output" : "Mute output"
                selected: Audio.muted
                enabled: !!Audio.sink?.ready
                onClicked: Audio.toggleMute()
            }
            ActionButton {
                objectName: "quickMicMute"
                text: Audio.micMuted ? "Unmute mic" : "Mute mic"
                selected: Audio.micMuted
                enabled: Audio.micAvailable
                onClicked: Audio.toggleMic()
            }
        }
        NacreText {
            text: "Microphone"
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
        QuickSlider {
            objectName: "quickMicVolume"
            width: parent.width
            from: 0
            to: 1
            enabled: Audio.micAvailable
            value: Audio.micVolume
            onMoved: Audio.setMicVolume(value)
        }
        NacreText {
            text: "Output device"
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
        QuickList {
            maximumHeight: 132
            Repeater {
                model: root.outputs
                NacreSurface {
                    id: device
                    required property var modelData
                    property bool chosen: Pipewire.defaultAudioSink === modelData
                    width: parent.width
                    height: 40
                    radius: 10
                    color: chosen ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHigh
                    NacreText {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44
                        text: device.modelData.description || device.modelData.name
                        elide: Text.ElideRight
                        font.pointSize: 10
                    }
                    NacreIcon {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: device.chosen ? "check" : "speaker"
                        font.pointSize: 13
                    }
                    NacreInteraction {
                        function onClicked() {
                            Pipewire.preferredDefaultAudioSink = device.modelData;
                        }
                    }
                }
            }
        }
    }
}
