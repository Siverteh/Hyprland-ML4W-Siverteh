import qs.widgets
import qs.services
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
SettingsPage {
 id:root
 readonly property var nodes:Pipewire.nodes.values.filter(n=>n.audio!==null)
 readonly property var outputs:nodes.filter(n=>!n.isStream&&n.isSink)
 readonly property var inputs:nodes.filter(n=>!n.isStream&&!n.isSink)
 readonly property var streams:nodes.filter(n=>n.isStream)
 PwObjectTracker {objects:root.nodes}
 SettingsSection {title:"Speakers and headphones";description:"Choose the default output for new playback."
  Repeater {model:root.outputs
   AudioRow {required property var modelData;node:modelData;selectable:true;selected:Pipewire.defaultAudioSink===node;onSelect:Pipewire.preferredDefaultAudioSink=node}
  }
  StyledText {visible:root.outputs.length===0;text:"No output devices available";color:Colours.palette.m3onSurfaceVariant}
 }
 SettingsSection {title:"Microphones";description:"Choose the default input. Selecting a device keeps its mute state."
  Repeater {model:root.inputs
   AudioRow {required property var modelData;node:modelData;selectable:true;selected:Pipewire.defaultAudioSource===node;onSelect:Pipewire.preferredDefaultAudioSource=node}
  }
  StyledText {visible:root.inputs.length===0;text:"No microphone devices available";color:Colours.palette.m3onSurfaceVariant}
 }
 SettingsSection {title:"Application volumes";description:"Apps appear here while they have an audio stream."
  Repeater {model:root.streams
   AudioRow {required property var modelData;node:modelData}
  }
  StyledText {visible:root.streams.length===0;text:"No active application audio";color:Colours.palette.m3onSurfaceVariant}
  ActionButton {text:"Routing and advanced sound";icon:"tune";onClicked:AppLaunch.run(["pavucontrol"])}
 }
 component AudioRow:Column {
  id:row;property var node;property bool selectable:false;property bool selected:false;signal select()
  width:parent.width;spacing:4
  StyledText {width:parent.width;text:row.node?.description||row.node?.name||"Audio device";elide:Text.ElideRight;font.pointSize:11}
  Row {width:parent.width;spacing:8
   ActionButton {width:Math.max(100,parent.width-110);text:row.selectable?(row.selected?"Default device":"Use device"):(row.node?.properties?.["application.name"]??"Application");selected:row.selected;enabled:row.selectable;onClicked:row.select()}
   ActionButton {text:"";icon:row.node?.audio?.muted?"volume_off":"volume_up";selected:row.node?.audio?.muted??false;enabled:row.node?.ready??false;onClicked:row.node.audio.muted=!row.node.audio.muted}
   StyledText {anchors.verticalCenter:parent.verticalCenter;text:Math.round((row.node?.audio?.volume??0)*100)+"%";font.pointSize:10}
  }
  Slider {width:parent.width;from:0;to:1;value:row.node?.audio?.volume??0;enabled:row.node?.ready??false;onMoved:row.node.audio.volume=value}
 }
}
