import qs.widgets
import qs.services
import qs.config
import Quickshell.Io
import QtQuick
import QtQuick.Controls
Column {
    width:300;spacing:12
    StyledText {text:"Sound";font.weight:500}
    StyledText {width:300;elide:Text.ElideRight;text:Audio.sink?.description??"No output device";color:Colours.palette.m3onSurfaceVariant}
    Slider {width:300;from:0;to:1;value:Audio.volume;onMoved:Audio.setVolume(value)}
    Row {spacing:10
        StyledRect {implicitWidth:90;implicitHeight:36;radius:18;color:Colours.palette.m3surfaceContainer
            StyledText {anchors.centerIn:parent;text:Audio.muted?"Unmute":"Mute"}
            Process {id:mute;command:["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","toggle"]}
            StateLayer {function onClicked(){mute.startDetached()}}
        }
        StyledRect {implicitWidth:190;implicitHeight:36;radius:18;color:Colours.palette.m3surfaceContainer
            StyledText {anchors.centerIn:parent;text:"Sound settings"}
            Process {id:settings;command:["pavucontrol"]}
            StateLayer {function onClicked(){AppLaunch.run(settings.command)}}
        }
    }
}
