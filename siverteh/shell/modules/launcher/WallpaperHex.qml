import "root:/widgets"
import "root:/services"
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
Item {
 id:root
 property var entry
 property bool selected:false
 signal clicked()
 width:200;height:174
 function inside(x,y){return x>=0&&x<=width&&y>=0&&y<=height&&(x>=width/4&&x<=width*3/4||Math.abs(y-height/2)<=height/2*(Math.min(x,width-x)/(width/4)));}
 Image {id:image;anchors.fill:parent;source:root.entry?.poster?"file://"+root.entry.poster:"";sourceSize.width:400;sourceSize.height:348;fillMode:Image.PreserveAspectCrop;asynchronous:true;visible:false}
 Shape {id:mask;anchors.fill:parent;visible:false;layer.enabled:true;layer.smooth:true
  ShapePath {strokeWidth:0;fillColor:"white";startX:root.width/4;startY:0
   PathLine {x:root.width*3/4;y:0}PathLine {x:root.width;y:root.height/2}PathLine {x:root.width*3/4;y:root.height}PathLine {x:root.width/4;y:root.height}PathLine {x:0;y:root.height/2}PathLine {x:root.width/4;y:0}
  }
 }
 MultiEffect {anchors.fill:parent;source:image;maskEnabled:true;maskSource:mask;maskThresholdMin:0.5;maskSpreadAtMin:1}
 Shape {anchors.fill:parent
  ShapePath {strokeWidth:root.selected?3:1;strokeColor:root.selected?Colours.palette.m3primary:Colours.palette.m3outlineVariant;fillColor:"transparent";startX:root.width/4;startY:0
   PathLine {x:root.width*3/4;y:0}PathLine {x:root.width;y:root.height/2}PathLine {x:root.width*3/4;y:root.height}PathLine {x:root.width/4;y:root.height}PathLine {x:0;y:root.height/2}PathLine {x:root.width/4;y:0}
  }
 }
 StyledRect {x:25;y:parent.height-50;width:parent.width-50;height:28;radius:14;color:Qt.alpha(Colours.palette.m3surface,0.85)
  StyledText {anchors.fill:parent;anchors.margins:5;text:root.entry?.name??"";horizontalAlignment:Text.AlignHCenter;elide:Text.ElideRight;font.pointSize:9}
 }
 ToolTip.text:root.entry?.name??"";ToolTip.visible:hover.hovered;ToolTip.delay:500
 HoverHandler {id:hover}
 MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:mouse=>{if(root.inside(mouse.x,mouse.y))root.clicked();else mouse.accepted=false;}}
}
