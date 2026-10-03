import "root:/services"
import QtQuick
import QtQuick.Shapes
Item {
    implicitWidth:30;implicitHeight:30
    Accessible.name:"Siverteh OS apps"
    Accessible.role:Accessible.Button
    Shape {
        anchors.centerIn:parent;width:28;height:28
        preferredRendererType:Shape.CurveRenderer
        ShapePath {
            fillColor:"transparent";strokeColor:Colours.palette.m3primary;strokeWidth:2.6
            capStyle:ShapePath.RoundCap;joinStyle:ShapePath.RoundJoin
            PathSvg {path:"M 14 5 L 7 5 Q 3 5 3 9 Q 3 12 8 13 L 10 13 Q 15 14 15 18 Q 15 22 11 22 L 3 22"}
        }
        ShapePath {
            fillColor:"transparent";strokeColor:Colours.palette.m3secondary;strokeWidth:2.6
            capStyle:ShapePath.RoundCap;joinStyle:ShapePath.RoundJoin
            PathSvg {path:"M 18 5 L 18 22 M 26 5 L 26 22 M 18 13.5 L 26 13.5"}
        }
    }
}
