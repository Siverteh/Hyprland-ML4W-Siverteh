import "root:/widgets"
import "root:/services"
import QtQuick
import QtQuick.Controls
import ".."
SettingsPage {
 id:root
 readonly property var tileGeometry:wallGrid.children.filter(c=>c.objectName==="wallpaperTile").map(c=>({x:c.x,y:c.y,width:c.width,height:c.height}))
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
  Grid {id:wallGrid;columns:Math.max(1,Math.floor(width/158));width:parent.width;spacing:10
   Repeater {model:Wallpapers.list
    Item {objectName:"wallpaperTile";required property var modelData;width:148;height:105
     Image {anchors.fill:parent;source:"file://"+modelData.path;fillMode:Image.PreserveAspectCrop;asynchronous:true;sourceSize.width:296;sourceSize.height:210}
     Rectangle {anchors.fill:parent;color:"transparent";border.width:Wallpapers.current===modelData.path?3:0;border.color:Colours.palette.m3primary}
     MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:Wallpapers.setWallpaper(parent.modelData.path)}
    }
   }
  }
 }
 DesktopControls {width:parent.width;height:implicitHeight;page:"appearance"}
}
