import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    required property var monitor
    implicitWidth: 260
    implicitHeight: 220
    Row {
        x: 10
        y: 14
        spacing: 4
        Level {
            label: "Volume"
            icon: NacreAudio.muted ? "volume_off" : "volume_up"
            level: NacreAudio.volume
            usable: NacreAudio.available
            canMute: true
            onAdjusted: value => NacreAudio.setVolume(value)
            onMute: NacreAudio.toggleMute()
        }
        Level {
            label: "Microphone"
            icon: NacreAudio.micMuted ? "mic_off" : "mic"
            level: NacreAudio.micVolume
            usable: NacreAudio.micAvailable
            canMute: true
            onAdjusted: value => NacreAudio.setMicVolume(value)
            onMute: NacreAudio.toggleMic()
        }
        Level {
            label: "Screen"
            icon: "brightness_6"
            level: root.monitor?.brightness || 0
            usable: root.monitor?.available === true
            onAdjusted: value => root.monitor?.setBrightness(value)
        }
        Level {
            label: "Keyboard"
            icon: "keyboard"
            level: NacreKeyboardLight.brightness
            usable: NacreKeyboardLight.available
            onAdjusted: value => NacreKeyboardLight.setBrightness(value)
        }
    }
    NacreText {
        x: 12
        y: 198
        width: root.width - 24
        text: root.monitor?.error || NacreKeyboardLight.error || ""
        visible: text !== ""
        maximumLineCount: 1
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        font.pointSize: 10
        color: NacreColours.palette.m3error
    }
    component Level: Item {
        required property string label
        required property string icon
        required property real level
        required property bool usable
        property bool canMute: false
        signal adjusted(real value)
        signal mute
        width: 56
        height: 172
        NacreText {
            width: parent.width
            height: 26
            text: parent.label
            font.pointSize: 9
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        NacreSlider {
            objectName: "osd" + parent.label
            y: 28
            height: 120
            width: 30
            anchors.horizontalCenter: parent.horizontalCenter
            icon: parent.canMute ? "" : parent.icon
            accessibleName: parent.label
            value: parent.level
            enabled: parent.usable
            onMoved: if (enabled)
                parent.adjusted(value)
        }
        NacreSurface {
            y: 152
            width: 30
            height: 30
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 15
            color: "transparent"
            enabled: parent.usable && parent.canMute
            visible: parent.canMute
            NacreIcon {
                anchors.centerIn: parent
                text: parent.parent.icon
            }
            NacreInteraction {
                accessibleName: "Toggle " + parent.parent.label + " mute"
                function onClicked() {
                    parent.parent.mute();
                }
            }
        }
    }
}
