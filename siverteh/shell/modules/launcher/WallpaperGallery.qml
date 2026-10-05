pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
Item {
 id:root
 required property PersistentProperties visibilities
 implicitWidth:Math.min(1160,Quickshell.screens[0].width-100)
 implicitHeight:Math.min(layout==="carousel"?360:layout==="spotlight"?560:650,Quickshell.screens[0].height-160)
 readonly property string kind:Wallpapers.preferences.kind??"static"
 readonly property string layout:Wallpapers.preferences.layout??"carousel"
 readonly property var entries:Wallpapers.list.filter(w=>w.dynamic===(kind==="dynamic")&&search.text.toLowerCase().trim().split(/\s+/).every(word=>(w.name+" "+w.path).toLowerCase().includes(word)))
 readonly property int count:entries.length
 property int currentIndex:0
 readonly property var currentEntry:entries[currentIndex]??null
 property bool initializing:true
 function restoreIndex(){initializing=true;currentIndex=Math.max(0,entries.findIndex(w=>w.path===Wallpapers.current));Qt.callLater(()=>initializing=false);}
 function select(index){if(!count)return;currentIndex=Math.max(0,Math.min(count-1,index));if(currentEntry)Wallpapers.browse(currentEntry.path);}
 function move(delta){if(count)select((currentIndex+delta+count)%count);}
 property real wheelDistance:0
 function wheel(event){const angle=event.angleDelta.y;if(angle)move(angle>0?-1:1);else {wheelDistance+=event.pixelDelta.y;if(Math.abs(wheelDistance)>=80){move(wheelDistance>0?-1:1);wheelDistance=0;}}event.accepted=true;}
 function choose(){if(currentEntry)Wallpapers.setWallpaper(currentEntry.path);}
 onEntriesChanged:restoreIndex()
 Component.onCompleted:{restoreIndex();forceActiveFocus();}
 Connections {target:root.visibilities;function onLauncherChanged(){if(root.visibilities.launcher)root.forceActiveFocus();else Wallpapers.commitSelection();}}
 Keys.onLeftPressed:move(-1)
 Keys.onRightPressed:move(1)
 Keys.onUpPressed:move(-1)
 Keys.onDownPressed:move(1)
 Keys.onReturnPressed:choose()
 Keys.onEscapePressed:visibilities.launcher=false
 Row {id:toolbar;x:20;y:14;spacing:8
  ActionButton {text:"Static";icon:"image";selected:root.kind==="static";onClicked:Wallpapers.preference({kind:"static"})}
  ActionButton {text:"Dynamic";icon:"motion_photos_on";selected:root.kind==="dynamic";onClicked:Wallpapers.preference({kind:"dynamic"})}
  Rectangle {width:1;height:26;color:Colours.palette.m3outlineVariant;anchors.verticalCenter:parent.verticalCenter}
  Repeater {model:[{id:"carousel",label:"Carousel",icon:"view_carousel"},{id:"spotlight",label:"Spotlight",icon:"crop_landscape"},{id:"hexagons",label:"Hexagons",icon:"hexagon"}]
   ActionButton {required property var modelData;compact:true;text:modelData.label;icon:modelData.icon;selected:root.layout===modelData.id;onClicked:Wallpapers.preference({layout:modelData.id})}
  }
  ActionButton {text:"";icon:"add_photo_alternate";onClicked:Wallpapers.pickFiles();ToolTip.text:"Add local wallpapers";ToolTip.visible:addHover.hovered;HoverHandler {id:addHover}}
  ActionButton {text:"";icon:Wallpapers.preferences.paused?"play_arrow":"pause";visible:root.kind==="dynamic";onClicked:Wallpapers.preference({paused:!Wallpapers.preferences.paused})}
 }
 StyledTextField {id:search;objectName:"wallpaperSearch";x:20;anchors.top:toolbar.bottom;anchors.topMargin:10;width:parent.width-40;height:38;leftPadding:14;placeholderText:"Search wallpapers";background:StyledRect {radius:19;color:Colours.palette.m3surfaceContainer}Keys.onEscapePressed:root.visibilities.launcher=false;Keys.onDownPressed:{root.forceActiveFocus();root.move(1);}onAccepted:root.choose()}
 StyledText {anchors.top:search.bottom;anchors.topMargin:8;x:24;width:parent.width-48;text:Wallpapers.error;visible:text.length>0;color:Colours.palette.m3error;font.pointSize:10;elide:Text.ElideRight}
 Item {id:body;anchors.top:search.bottom;anchors.topMargin:16;anchors.left:parent.left;anchors.right:parent.right;anchors.bottom:footer.top;anchors.bottomMargin:12
  Loader {anchors.fill:parent;active:root.count>0;sourceComponent:root.layout==="hexagons"?honeycomb:root.layout==="spotlight"?spotlight:carousel}
  Column {anchors.centerIn:parent;spacing:14;visible:root.count===0
   StyledText {text:Wallpapers.loading?"Loading wallpapers…":search.text.trim()?"No matching wallpapers":root.kind==="dynamic"?"Add a local video or animated GIF":"No static wallpapers yet";color:Colours.palette.m3onSurfaceVariant;font.pointSize:15}
   ActionButton {anchors.horizontalCenter:parent.horizontalCenter;text:"Add wallpapers";icon:"add";onClicked:Wallpapers.pickFiles()}
  }
 }
 Row {id:footer;anchors.bottom:parent.bottom;anchors.bottomMargin:15;x:22;spacing:12
  StyledText {text:root.currentEntry?.name??"";font.pointSize:11;color:Colours.palette.m3primary;anchors.verticalCenter:parent.verticalCenter}
  StyledText {text:root.count?(root.currentIndex+1)+" / "+root.count:"";font.pointSize:10;anchors.verticalCenter:parent.verticalCenter;color:Colours.palette.m3onSurfaceVariant}
  ActionButton {compact:true;text:"Pause behind tiled apps";visible:root.kind==="dynamic";selected:Wallpapers.preferences.pauseCovered??true;onClicked:Wallpapers.preference({pauseCovered:!Wallpapers.preferences.pauseCovered})}
 }
 Component {id:carousel
  PathView {id:strip;anchors.fill:parent;model:root.entries;pathItemCount:5;currentIndex:root.currentIndex;preferredHighlightBegin:0.5;preferredHighlightEnd:0.5;highlightRangeMode:PathView.StrictlyEnforceRange;snapMode:PathView.SnapToItem;clip:true
   onCurrentIndexChanged:if(!root.initializing&&currentIndex!==root.currentIndex)root.select(currentIndex)
   delegate:Item {required property var modelData;required property int index;width:240;height:200;scale:PathView.isCurrentItem?1:0.82;z:PathView.isCurrentItem?2:1
    WallpaperCard {anchors.fill:parent;entry:parent.modelData;selected:parent.index===root.currentIndex;onClicked:root.select(parent.index)}
   }
   path:Path {startX:-60;startY:strip.height/2;PathLine {x:strip.width+60;y:strip.height/2}}
   WheelHandler {target:null;onWheel:event=>root.wheel(event)}
   Connections {target:root;function onCurrentIndexChanged(){if(strip.currentIndex!==root.currentIndex)strip.currentIndex=root.currentIndex;}}
  }
 }
 Component {id:spotlight
  Item {
   WallpaperCard {x:30;anchors.verticalCenter:parent.verticalCenter;width:230;height:190;opacity:0.6;entry:root.entries[(root.currentIndex-1+root.count)%root.count];selected:false;onClicked:root.move(-1)}
   WallpaperCard {anchors.centerIn:parent;width:Math.min(parent.width*.55,630);height:parent.height-10;entry:root.currentEntry;selected:true;onClicked:root.choose()}
   WallpaperCard {anchors.right:parent.right;anchors.rightMargin:30;anchors.verticalCenter:parent.verticalCenter;width:230;height:190;opacity:0.6;entry:root.entries[(root.currentIndex+1)%root.count];selected:false;onClicked:root.move(1)}
   WheelHandler {target:null;onWheel:event=>root.wheel(event)}
  }
 }
 Component {id:honeycomb
  Flickable {id:view;anchors.fill:parent;contentWidth:width;contentHeight:Math.ceil(root.count/columns)*184+92;clip:true;readonly property int columns:Math.max(1,Math.floor((width-60)/160))
   FastScroll {view:view}
   ScrollBar.vertical:ScrollBar {}
   Repeater {model:root.entries
    WallpaperHex {required property var modelData;required property int index;x:20+(index%view.columns)*160;y:Math.floor(index/view.columns)*184+(index%view.columns)%2*92;entry:modelData;selected:index===root.currentIndex;onClicked:root.select(index)}
   }
  }
 }
 component WallpaperCard:StyledRect {
  id:card;property var entry;property bool selected:false;signal clicked()
  radius:17;color:Colours.palette.m3surfaceContainer;border.width:selected?2:0;border.color:Colours.palette.m3primary
  Image {x:6;y:6;width:parent.width-12;height:parent.height-42;source:card.entry?.poster?"file://"+card.entry.poster:"";sourceSize.width:1000;sourceSize.height:600;fillMode:Image.PreserveAspectCrop;asynchronous:true}
  StyledText {anchors.bottom:parent.bottom;anchors.bottomMargin:12;width:parent.width-12;anchors.horizontalCenter:parent.horizontalCenter;text:card.entry?.name??"";horizontalAlignment:Text.AlignHCenter;elide:Text.ElideRight;font.pointSize:10}
  MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:card.clicked()}
 }
 DropArea {anchors.fill:parent;onDropped:drop=>{if(drop.hasUrls){Wallpapers.addFiles(drop.urls);drop.acceptProposedAction();}}}
 IpcHandler {target:"wallpaperPicker";function view(kind:string,layout:string):void{Wallpapers.preference({kind:kind,layout:layout});}function state():string{return JSON.stringify({query:search.text,kind:root.kind,layout:root.layout,count:root.count,index:root.currentIndex,width:root.width,height:root.height});}}
}
