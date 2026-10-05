import "root:/widgets"
import "root:/services"
import QtQuick
import QtQuick.Controls
import ".."
SettingsPage {
 id:root
 SettingsSection {title:"Wallpaper and colors";description:"Your wallpaper supplies the palette across the desktop, login and lock screen."
  Row {width:parent.width;spacing:16
   Image {width:Math.min(340,parent.width*.48);height:180;source:"file://"+Wallpapers.current;fillMode:Image.PreserveAspectCrop;asynchronous:true;sourceSize.width:680;sourceSize.height:360}
   Column {width:parent.width-previousSiblingWidth-16;property real previousSiblingWidth:Math.min(340,parent.width*.48);spacing:12
    StyledText {width:parent.width;text:Wallpapers.current.split("/").pop();elide:Text.ElideMiddle;font.pointSize:11}
    Row {spacing:8
     ActionButton {text:"Dark";selected:!Colours.light;onClicked:Colours.setMode("dark")}
     ActionButton {text:"Light";selected:Colours.light;onClicked:Colours.setMode("light")}
    }
    Row {spacing:6
     Repeater {model:[Colours.palette.m3primary,Colours.palette.m3secondary,Colours.palette.m3tertiary,Colours.palette.m3surface,Colours.palette.m3onSurface]
      Rectangle {required property color modelData;width:26;height:26;radius:13;color:modelData;border.width:1;border.color:Colours.palette.m3outlineVariant}
     }
    }
    ActionButton {text:"Wallpaper picker";icon:"wallpaper";onClicked:AppLaunch.run(["siverteh-os-shell","wallpaper"])}
   }
  }
  GridView {id:wallGrid;objectName:"settingsWallpaperGrid";width:parent.width;cellWidth:158;cellHeight:115;height:Math.ceil(count/Math.max(1,Math.floor(width/cellWidth)))*cellHeight;interactive:false;model:Wallpapers.list
   delegate:Item {objectName:"wallpaperTile";required property var modelData;width:wallGrid.cellWidth;height:wallGrid.cellHeight
    StyledRect {x:0;y:0;width:148;height:105;radius:8;visible:thumb.status!==Image.Ready;color:Colours.palette.m3surfaceContainerHigh;MaterialIcon {anchors.centerIn:parent;text:"landscape";color:Colours.palette.m3onSurfaceVariant}}
    Image {id:thumb;x:0;y:0;width:148;height:105;source:"file://"+parent.modelData.path;fillMode:Image.PreserveAspectCrop;asynchronous:true;sourceSize.width:296;sourceSize.height:210}
    Rectangle {x:0;y:0;width:148;height:105;color:"transparent";border.width:Wallpapers.current===parent.modelData.path?3:0;border.color:Colours.palette.m3primary}
    MouseArea {x:0;y:0;width:148;height:105;cursorShape:Qt.PointingHandCursor;onClicked:Wallpapers.setWallpaper(parent.modelData.path)}
   }
  }
 }
 SettingsSection {title:"Panels and frame";description:"Desktop edges, previews and panel behavior";collapsible:true
  DesktopControls {width:parent.width;height:implicitHeight;page:"appearance"}
 }
}
