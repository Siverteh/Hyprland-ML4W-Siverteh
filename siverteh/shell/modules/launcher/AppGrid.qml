pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import "launcher.js" as Browser
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
Item {
 id:root
 required property PersistentProperties visibilities
 implicitWidth:Math.min(980,Quickshell.screens[0].width-90)
 implicitHeight:Math.min(category==="favorites"&&!search.text.trim()?Math.min(450,Math.max(300,156+Math.ceil(entries.length/5)*119)):570,Quickshell.screens[0].height-170)
 property string category:"favorites"
 property bool userSelected:false
 property var contextEntry:null
 readonly property string query:search.text
 readonly property bool commands:search.text.trim().startsWith(">")
 readonly property var categories:Browser.visible(Apps.list)
 readonly property var entries:{
  const q=search.text.trim();
  if(commands){const words=q.slice(1).toLowerCase().trim().split(/\s+/).filter(Boolean);return DesktopActions.list.filter(e=>e.action!=="power"&&words.every(w=>(e.name+" "+e.description).toLowerCase().includes(w)));}
  if(q)return Apps.fuzzyQuery(q);
  if(category==="hidden")return Apps.all.filter(a=>LauncherPreferences.hidden.includes(a.id));
  if(category==="all")return Array.from(Apps.list);
  return Browser.browse(Apps.list,category,LauncherPreferences.favorites);
 }
 function start(){userSelected=false;category="favorites";search.text="";nav.currentIndex=Math.max(0,categories.findIndex(c=>c.id===category));search.forceActiveFocus();}
 function select(id){userSelected=true;category=id;nav.currentIndex=Math.max(0,categories.findIndex(c=>c.id===id));search.text="";grid.currentIndex=entries.length?0:-1;search.forceActiveFocus();}
 function choose(){const entry=entries[grid.currentIndex];if(!entry)return;if(commands)DesktopActions.execute(entry.action,entry.value);else {Apps.launch(entry);visibilities.launcher=false;}}
 function move(delta){if(commands)grid.currentIndex=Math.max(0,Math.min(entries.length-1,grid.currentIndex+delta));else if(delta>0)grid.moveCurrentIndexDown();else grid.moveCurrentIndexUp();grid.positionViewAtIndex(grid.currentIndex,GridView.Contain);}
 function menuFor(entry,tile){contextEntry=entry;const point=tile.mapToItem(root,0,0);appMenu.x=Math.max(12,Math.min(root.width-appMenu.width-12,point.x));appMenu.y=Math.max(12,Math.min(search.y-appMenu.height-8,point.y+tile.height));appMenu.open();}
 Component.onCompleted:if(visibilities.launcher)start()
 Connections {target:LauncherPreferences;function onReadyChanged(){if(LauncherPreferences.ready&&!root.userSelected&&root.visibilities.launcher&&!search.text.trim())root.start();}}
 Connections {target:root.visibilities;function onLauncherChanged(){if(root.visibilities.launcher)root.start();}}
 StyledRect {id:rail;x:16;y:16;width:190;height:Math.max(0,parent.height-92);radius:17;color:Colours.palette.m3surfaceContainer
  ListView {id:nav;objectName:"appCategories";anchors.fill:parent;anchors.margins:8;clip:true;spacing:3;model:root.categories;currentIndex:0
   FastScroll {view:nav}
   ScrollBar.vertical:ScrollBar {}
   delegate:StyledRect {required property var modelData;required property int index;width:nav.width;height:39;radius:20;color:!root.commands&&root.category===modelData.id?Colours.palette.m3secondaryContainer:"transparent";border.width:nav.activeFocus&&nav.currentIndex===index?1:0;border.color:Colours.palette.m3primary
    Row {x:11;anchors.verticalCenter:parent.verticalCenter;spacing:10
     MaterialIcon {text:modelData.icon;font.pointSize:16;color:Colours.palette.m3primary}
     StyledText {text:modelData.label;font.pointSize:11}
    }
    MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{nav.currentIndex=parent.index;root.select(parent.modelData.id);}}
   }
   Keys.onDownPressed:incrementCurrentIndex()
   Keys.onUpPressed:decrementCurrentIndex()
   Keys.onRightPressed:{root.select(currentItem.modelData.id);grid.forceActiveFocus();}
   Keys.onReturnPressed:root.select(currentItem.modelData.id)
   Keys.onEscapePressed:root.visibilities.launcher=false
   Keys.onTabPressed:search.forceActiveFocus()
  }
 }
 Row {id:heading;anchors.left:rail.right;anchors.leftMargin:22;anchors.right:parent.right;anchors.rightMargin:20;y:18;spacing:8
  Column {width:parent.width-96;spacing:4
   StyledText {text:root.commands?"Commands":search.text.trim()?"Search results":root.category==="hidden"?"Hidden apps":root.categories.find(c=>c.id===root.category)?.label??"All apps";font.pointSize:18;color:Colours.palette.m3primary}
   StyledText {text:root.entries.length+(root.commands?" actions":" apps")+(search.text&&!root.commands?" · All categories":"");font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
  }
  ActionButton {text:"";icon:"visibility_off";visible:LauncherPreferences.hidden.length>0;selected:root.category==="hidden";onClicked:root.select("hidden");ToolTip.visible:hover.hovered;ToolTip.text:"Manage hidden apps";HoverHandler {id:hover}}
  ActionButton {text:"";icon:"settings";onClicked:DesktopActions.execute("settings")}
 }
 GridView {id:grid;objectName:"launcherApps";anchors.left:rail.right;anchors.leftMargin:22;anchors.right:parent.right;anchors.rightMargin:16;anchors.top:heading.bottom;anchors.topMargin:14;anchors.bottom:search.top;anchors.bottomMargin:14;clip:true
  cellWidth:root.commands?width:Math.floor(width/Math.max(1,Math.floor(width/142)));cellHeight:root.commands?74:119
  model:ScriptModel {values:root.entries;onValuesChanged:Qt.callLater(()=>{grid.currentIndex=root.entries.length?0:-1;grid.positionViewAtBeginning();})}
  currentIndex:0
  FastScroll {view:grid}
  ScrollBar.vertical:ScrollBar {}
  Keys.onReturnPressed:root.choose()
  Keys.onEnterPressed:root.choose()
  Keys.onEscapePressed:root.visibilities.launcher=false
  Keys.onTabPressed:search.forceActiveFocus()
  Keys.onLeftPressed:event=>{if(root.commands||grid.currentIndex%Math.max(1,Math.floor(grid.width/grid.cellWidth))===0){nav.forceActiveFocus();event.accepted=true;}else event.accepted=false;}
  Keys.onPressed:event=>{if(event.key===Qt.Key_D&&(event.modifiers&Qt.ControlModifier)){if(!root.commands&&root.entries[grid.currentIndex]){const e=root.entries[grid.currentIndex];LauncherPreferences.update("favorite",e.id,!LauncherPreferences.favorites.includes(e.id));event.accepted=true;}}else if(event.text&&!(event.modifiers&(Qt.ControlModifier|Qt.AltModifier|Qt.MetaModifier))){search.forceActiveFocus();search.insert(search.cursorPosition,event.text);event.accepted=true;}else event.accepted=false;}
  delegate:StyledRect {
   id:tile;required property var modelData;required property int index
   width:grid.cellWidth-8;height:grid.cellHeight-8;radius:17;color:GridView.isCurrentItem?Colours.palette.m3secondaryContainer:"transparent"
   ToolTip.visible:tileHover.hovered&&!root.commands
   ToolTip.text:tile.modelData.name
   ToolTip.delay:700
   HoverHandler {id:tileHover}
   Image {id:appIcon;x:root.commands?12:(parent.width-width)/2;y:root.commands?14:14;width:root.commands?36:48;height:width;sourceSize.width:96;sourceSize.height:96;fillMode:Image.PreserveAspectFit;source:root.commands?"":Quickshell.iconPath(tile.modelData.icon)}
   MaterialIcon {anchors.centerIn:appIcon;text:root.commands?tile.modelData.icon:"apps";font.pointSize:root.commands?22:30;visible:root.commands||appIcon.status!==Image.Ready;color:Colours.palette.m3primary}
   StyledText {x:root.commands?60:6;y:root.commands?11:71;width:parent.width-x-6;text:tile.modelData.name;font.pointSize:11;horizontalAlignment:root.commands?Text.AlignLeft:Text.AlignHCenter;elide:Text.ElideRight}
   StyledText {x:60;y:32;width:parent.width-72;visible:root.commands;text:tile.modelData.description??"";font.pointSize:10;color:Colours.palette.m3onSurfaceVariant;elide:Text.ElideRight}
   MouseArea {anchors.fill:parent;hoverEnabled:true;acceptedButtons:Qt.LeftButton|Qt.RightButton;cursorShape:Qt.PointingHandCursor;onEntered:grid.currentIndex=tile.index;onClicked:mouse=>{grid.currentIndex=tile.index;if(mouse.button===Qt.RightButton&&!root.commands)root.menuFor(tile.modelData,tile);else root.choose();}}
   Item {anchors.right:parent.right;anchors.top:parent.top;width:28;height:28;visible:!root.commands;z:2
    MaterialIcon {anchors.centerIn:parent;text:"favorite";fill:LauncherPreferences.favorites.includes(tile.modelData.id)?1:0;font.pointSize:13;color:Colours.palette.m3primary}
    MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:LauncherPreferences.update("favorite",tile.modelData.id,!LauncherPreferences.favorites.includes(tile.modelData.id))}
   }
  }
  Column {anchors.centerIn:parent;visible:grid.count===0;spacing:10
   StyledText {text:root.category==="favorites"&&!search.text?"Add favorites with the heart on an app":"No matches";color:Colours.palette.m3onSurfaceVariant}
   ActionButton {anchors.horizontalCenter:parent.horizontalCenter;text:"All apps";visible:root.category==="favorites";onClicked:root.select("all")}
  }
 }
 StyledText {x:rail.x+rail.width+22;y:search.y-24;text:LauncherPreferences.error;visible:text.length>0;font.pointSize:10;color:Colours.palette.m3error}
 StyledTextField {id:search;objectName:"launcherSearch";x:16;y:parent.height-62;width:parent.width-32;height:46;leftPadding:18;rightPadding:54;placeholderText:"Search all apps or type > for commands"
  background:StyledRect {radius:23;color:Colours.palette.m3surfaceContainer}
  Keys.onEscapePressed:root.visibilities.launcher=false
  Keys.onDownPressed:{grid.forceActiveFocus();grid.currentIndex=Math.max(0,grid.currentIndex);}
  Keys.onUpPressed:{grid.forceActiveFocus();grid.currentIndex=Math.max(0,grid.currentIndex);}
  Keys.onTabPressed:{nav.forceActiveFocus();}
  onAccepted:root.choose()
  ActionButton {anchors.right:parent.right;anchors.rightMargin:6;anchors.verticalCenter:parent.verticalCenter;text:"";icon:"menu";selected:root.commands;onClicked:{search.text=root.commands?"":"> ";search.forceActiveFocus();search.cursorPosition=search.text.length;}}
 }
 Menu {id:appMenu
  MenuItem {text:LauncherPreferences.favorites.includes(root.contextEntry?.id)?"Remove favorite":"Add favorite";onTriggered:if(root.contextEntry)LauncherPreferences.update("favorite",root.contextEntry.id,!LauncherPreferences.favorites.includes(root.contextEntry.id))}
  MenuItem {text:root.category==="hidden"?"Show in launcher":"Hide app";onTriggered:if(root.contextEntry)LauncherPreferences.update("hide",root.contextEntry.id,root.category!=="hidden")}
 }
 IpcHandler {target:"appBrowser";function selectCategory(id:string):void{if(root.categories.some(c=>c.id===id))root.select(id);}function state():string{return JSON.stringify({top:root.mapToItem(null,0,0).y,searchBottom:search.mapToItem(null,0,search.height).y,category:root.category,query:search.text,count:root.entries.length,categories:root.categories.map(c=>c.id),width:root.width,height:root.height});}}
}
