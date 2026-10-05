import "widgets"
import "services"
import Quickshell
import Quickshell.Io
import QtQuick
ShellRoot {
 FloatingWindow {
  id:window;title:"Siverteh lock screen preview";width:1280;height:800;color:Colours.palette.m3surface
  property var data:({})
  Image {anchors.fill:parent;source:"file://"+Wallpapers.current;fillMode:Image.PreserveAspectCrop;sourceSize.width:1280;sourceSize.height:800;asynchronous:true}
  Rectangle {anchors.fill:parent;color:"#99000000"}
  Item {anchors.fill:parent;focus:true;Keys.onEscapePressed:Qt.quit()
   StyledText {x:24;y:20;text:"Lock screen preview · Esc to close";color:"white";font.pointSize:11}
   Column {anchors.centerIn:parent;spacing:14
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:Time.format("HH:mm");font.pointSize:70;color:"white"}
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:Time.format("dddd, dd MMMM");font.pointSize:15;color:Colours.palette.m3primary}
    StyledRect {width:280;height:50;radius:25;color:Colours.palette.m3surfaceContainer;border.width:2;border.color:Colours.palette.m3primary
     StyledText {anchors.centerIn:parent;text:"Password";color:Colours.palette.m3onSurfaceVariant}
    }
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:"Siverteh OS";font.pointSize:20;color:Colours.palette.m3primary}
   }
   Column {x:30;width:300;anchors.verticalCenter:parent.verticalCenter;spacing:18
    PreviewCard {visible:window.data.preferences?.lockWeather!==false;heading:"Weather";body:(window.data.weather?.location??"")+"\n"+(window.data.weather?.temperature??"")+"\n"+(window.data.weather?.description??"Weather unavailable")}
    PreviewCard {visible:window.data.preferences?.lockMedia!==false;heading:"Media";body:window.data.media?(window.data.media.title??"")+"\n"+(window.data.media.artist??"")+"\n"+(window.data.media.playing?"Playing":"Paused"):"Nothing playing"}
   }
   PreviewCard {visible:window.data.preferences?.lockNotifications!==false;x:parent.width-width-30;width:300;anchors.verticalCenter:parent.verticalCenter;heading:"Notifications · "+(window.data.count??0);body:(window.data.notifications??[]).slice(0,4).map(n=>n.app+(n.summary?"\n"+n.summary:"")).join("\n\n")||"You are all caught up"}
  }
  Process {id:reader;running:true;command:[Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/bin/qs","-c","siverteh_shell","ipc","call","lockWidgets","state"];stdout:SplitParser {splitMarker:"";onRead:line=>{try{window.data=JSON.parse(line);}catch(e){}}}}
  Timer {interval:3000;repeat:true;running:window.visible;onTriggered:if(!reader.running)reader.running=true}
 }
 component PreviewCard:StyledRect {
  property string heading;property string body
  width:parent.width;implicitHeight:copy.implicitHeight+40;radius:22;color:Colours.palette.m3surfaceContainer
  Column {id:copy;x:20;y:20;width:parent.width-40;spacing:12
   StyledText {text:parent.parent.heading;color:Colours.palette.m3primary;font.pointSize:14}
   StyledText {width:parent.width;text:parent.parent.body;wrapMode:Text.Wrap;font.pointSize:12}
  }
 }
}
