import "widgets"
import "services"
import Quickshell
import Quickshell.Io
import QtQuick
ShellRoot {
 FloatingWindow {
  id:window;objectName:"lockPreviewWindow";visible:true;title:"Siverteh lock screen preview";implicitWidth:1280;implicitHeight:800;color:Colours.palette.m3surface
  property var widgetData:({})
  Image {anchors.fill:parent;source:Wallpapers.current?"file://"+Wallpapers.current:"";fillMode:Image.PreserveAspectCrop;sourceSize.width:1280;sourceSize.height:800;asynchronous:true}
  Rectangle {anchors.fill:parent;color:"#99000000"}
  Item {objectName:"lockPreviewContent";anchors.fill:parent;focus:true;Keys.onEscapePressed:Qt.quit()
   StyledText {x:24;y:20;text:"Lock screen preview · Esc to close";color:"white";font.pointSize:11}
   Column {anchors.centerIn:parent;spacing:14
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:Time.format("HH:mm");font.pointSize:70;color:"white"}
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:Time.format("dddd, dd MMMM");font.pointSize:15;color:Colours.palette.m3primary}
    StyledRect {width:280;height:50;radius:25;color:Colours.palette.m3surfaceContainer;border.width:2;border.color:Colours.palette.m3primary
     StyledText {anchors.centerIn:parent;text:"Password";color:Colours.palette.m3onSurfaceVariant}
    }
    StyledText {anchors.horizontalCenter:parent.horizontalCenter;text:"Siverteh OS";font.pointSize:20;color:Colours.palette.m3primary}
   }
   Column {x:30;width:Math.max(160,Math.min(300,(window.width-360)/2-30));anchors.verticalCenter:parent.verticalCenter;spacing:18
    PreviewCard {visible:window.widgetData.preferences?.lockWeather!==false;heading:"Weather";body:(window.widgetData.weather?.location??"")+"\n"+(window.widgetData.weather?.temperature??"")+"\n"+(window.widgetData.weather?.description??"Weather unavailable")}
    PreviewCard {visible:window.widgetData.preferences?.lockMedia!==false;heading:"Media";art:window.widgetData.media?.art??"";mediaControls:!!window.widgetData.media;body:window.widgetData.media?(window.widgetData.media.title??"")+"\n"+(window.widgetData.media.artist??"")+"\n"+(window.widgetData.media.playing?"Playing":"Paused"):"Nothing playing"}
   }
   PreviewCard {visible:window.widgetData.preferences?.lockNotifications!==false;x:parent.width-width-30;width:Math.max(160,Math.min(300,(window.width-360)/2-30));anchors.verticalCenter:parent.verticalCenter;heading:"Notifications · "+(window.widgetData.count??0);body:(window.widgetData.notifications??[]).slice(0,4).map(n=>n.app+(n.summary?"\n"+n.summary:"")).join("\n\n")||"You are all caught up"}
  }
  Process {id:reader;running:true;command:[Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/bin/qs","-c","siverteh_shell","ipc","call","lockWidgets","state"];stdout:SplitParser {splitMarker:"";onRead:line=>{try{window.widgetData=JSON.parse(line);}catch(e){}}}}
  Timer {interval:3000;repeat:true;running:window.visible;onTriggered:if(!reader.running)reader.running=true}
 }
 component PreviewCard:StyledRect {
  property string heading;property string body;property string art:"";property bool mediaControls:false
  width:parent.width;implicitHeight:copy.implicitHeight+40;radius:22;color:Colours.palette.m3surfaceContainer
  Column {id:copy;x:20;y:20;width:parent.width-40;spacing:12
   StyledText {text:parent.parent.heading;color:Colours.palette.m3primary;font.pointSize:14}
   Image {visible:parent.parent.art.length>0;width:90;height:visible?90:0;source:parent.parent.art;fillMode:Image.PreserveAspectCrop;asynchronous:true;sourceSize.width:180;sourceSize.height:180}
   StyledText {width:parent.width;text:parent.parent.body;wrapMode:Text.Wrap;font.pointSize:12}
   Row {visible:parent.parent.mediaControls;spacing:8
    Repeater {model:[{icon:"skip_previous",action:"previous"},{icon:"play_pause",action:"toggle"},{icon:"skip_next",action:"next"}]
     ActionButton {required property var modelData;text:"";icon:modelData.icon;onClicked:AppLaunch.run(["python3",Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/lock-info.py",modelData.action])}
    }
   }
  }
 }
}
