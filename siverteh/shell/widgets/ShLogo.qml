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
            fillColor:"transparent";strokeColor:Colours.palette.m3primary;strokeWidth:3
            capStyle:ShapePath.SquareCap;joinStyle:ShapePath.MiterJoin
            PathSvg {path:"M 14 8 L 14 5 L 3 5 L 3 13.5 L 14 13.5 L 14 22 L 3 22"}
        }
        ShapePath {
            fillColor:"transparent";strokeColor:Colours.palette.m3secondary;strokeWidth:3
            capStyle:ShapePath.SquareCap;joinStyle:ShapePath.MiterJoin
            PathSvg {path:"M 19 5 L 19 22 M 27 5 L 27 22 M 19 13.5 L 27 13.5"}
        }
    }
}
