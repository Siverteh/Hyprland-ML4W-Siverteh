import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    required property var monitor
    implicitWidth: 196
    implicitHeight: 392
    Grid {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 12
        columns: 2
        columnSpacing: 20
        rowSpacing: 16
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
    }
    NacreText {
        x: 12
        y: 374
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
        width: 76
        height: 172
        NacreText {
            width: parent.width
            height: 24
            text: parent.label
            font.pointSize: 10
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        NacreSlider {
            objectName: "osd" + parent.label
            y: 28
            height: 108
            width: 32
            anchors.horizontalCenter: parent.horizontalCenter
            icon: parent.canMute ? "" : parent.icon
            accessibleName: parent.label
            value: parent.level
            enabled: parent.usable
            onMoved: if (enabled)
                parent.adjusted(value)
        }
        NacreSurface {
            y: 140
            width: 32
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 16
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
