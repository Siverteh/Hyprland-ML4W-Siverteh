import qs.widgets
import qs.services
import qs.config
import QtQuick

Column {
    id: root
    required property NacreBacklight monitor
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
            visible: NacreKeyboardLight.available
            NacreSlider {
                icon: "keyboard"
                stepSize: NacreKeyboardLight.maximum ? 1 / NacreKeyboardLight.maximum : 1
                value: NacreKeyboardLight.brightness
                onMoved: NacreKeyboardLight.setBrightness(value)
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
    NacreText {
        width: parent.width
        text: root.monitor?.error || NacreKeyboardLight.error
        visible: text.length > 0
        color: NacreColours.palette.m3error
        wrapMode: Text.Wrap
        font.pointSize: 9
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
            color: NacreColours.palette.m3onSurfaceVariant
        }
    }
}
