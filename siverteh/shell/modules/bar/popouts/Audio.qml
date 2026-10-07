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
        StyledText {
            text: "Sound"
            font.pointSize: 14
            color: Colours.palette.m3primary
        }
        Row {
            width: parent.width
            StyledText {
                width: parent.width - 65
                text: Audio.sink?.description ?? "No output device"
                elide: Text.ElideRight
                font.pointSize: 11
            }
            StyledText {
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
        StyledText {
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
        StyledText {
            text: "Output device"
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
        QuickList {
            maximumHeight: 132
            Repeater {
                model: root.outputs
                StyledRect {
                    id: device
                    required property var modelData
                    property bool chosen: Pipewire.defaultAudioSink === modelData
                    width: parent.width
                    height: 40
                    radius: 10
                    color: chosen ? Colours.palette.m3primaryContainer : Colours.palette.m3surfaceContainerHigh
                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44
                        text: device.modelData.description || device.modelData.name
                        elide: Text.ElideRight
                        font.pointSize: 10
                    }
                    MaterialIcon {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: device.chosen ? "check" : "speaker"
                        font.pointSize: 13
                    }
                    StateLayer {
                        function onClicked() {
                            Pipewire.preferredDefaultAudioSink = device.modelData;
                        }
                    }
                }
            }
        }
        ActionButton {
            objectName: "quickSettingsLink"
            text: "Sound settings"
            icon: "settings"
            onClicked: Visibilities.openSettings("sound")
        }
    }
}
