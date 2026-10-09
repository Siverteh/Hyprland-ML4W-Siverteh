import qs.widgets
import qs.services
import qs.config
import QtQuick

Column {
    id: root
    required property Brightness.Monitor monitor
    padding: NacreAppearance.padding.large
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    spacing: 12
    Grid {
        columns: 2
        columnSpacing: 14
        rowSpacing: 12
        Control {
            label: "Display"
            visible: root.monitor?.available ?? false
            NacreSlider {
                icon: "brightness_6"
                value: root.monitor?.brightness ?? 0
                onMoved: root.monitor?.setBrightness(value)
                implicitWidth: NacreOsd.sizes.sliderWidth
                implicitHeight: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Control {
            label: "Keys"
            visible: KeyboardLight.available
            NacreSlider {
                icon: "keyboard"
                stepSize: KeyboardLight.maximum ? 1 / KeyboardLight.maximum : 1
                value: KeyboardLight.brightness
                onMoved: KeyboardLight.setBrightness(value)
                implicitWidth: NacreOsd.sizes.sliderWidth
                implicitHeight: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Control {
            label: "Speaker"
            hasMute: true
            ActionButton {
                text: ""
                icon: NacreAudio.muted ? "volume_off" : "volume_up"
                selected: NacreAudio.muted
                y: 156
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: NacreAudio.toggleMute()
            }
            NacreSlider {
                icon: NacreAudio.muted ? "no_sound" : "volume_up"
                value: NacreAudio.volume
                onMoved: NacreAudio.setVolume(value)
                implicitWidth: NacreOsd.sizes.sliderWidth
                implicitHeight: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Control {
            label: "Mic"
            hasMute: true
            visible: NacreAudio.micAvailable
            ActionButton {
                text: ""
                icon: NacreAudio.micMuted ? "mic_off" : "mic"
                selected: NacreAudio.micMuted
                y: 156
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: NacreAudio.toggleMic()
            }
            NacreSlider {
                icon: NacreAudio.micMuted ? "mic_off" : "mic"
                value: NacreAudio.micVolume
                onMoved: NacreAudio.setMicVolume(value)
                implicitWidth: NacreOsd.sizes.sliderWidth
                implicitHeight: 120
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    component Control: Item {
        required property string label
        property bool hasMute: false
        implicitWidth: 60
        implicitHeight: hasMute ? 190 : 144
        NacreText {
            anchors.top: parent.top
            anchors.topMargin: 128
            anchors.horizontalCenter: parent.horizontalCenter
            text: parent.label
            font.pointSize: 9
            color: Colours.palette.m3onSurfaceVariant
        }
    }
}
