import "root:/widgets"
import "root:/services"
import QtQuick
StyledRect {
 id:root
 property string title:""
 property string description:""
 property bool collapsible:false
 property bool expanded:!collapsible
 default property alias contents:body.data
 width:parent.width;implicitHeight:header.height+(body.visible?body.implicitHeight+18:0)+32;radius:17;color:Colours.palette.m3surfaceContainer
 Column {id:header;x:16;y:16;width:parent.width-32;spacing:5
  StyledText {width:parent.width;text:root.title+(root.collapsible?(root.expanded?"  −":"  +"):"");font.pointSize:13;color:Colours.palette.m3primary}
  StyledText {width:parent.width;visible:root.description.length>0;text:root.description;wrapMode:Text.Wrap;font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
 }
 MouseArea {x:header.x;y:header.y;width:header.width;height:header.height;enabled:root.collapsible;cursorShape:Qt.PointingHandCursor;onClicked:root.expanded=!root.expanded}
 Column {id:body;x:16;y:header.y+header.height+18;width:parent.width-32;spacing:12;visible:root.expanded}
}
