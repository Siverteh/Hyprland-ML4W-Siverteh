import "root:/services"
import QtQuick
StyledRect {
    id:root
    property string text
    property string icon:""
    property bool selected:false
    signal clicked()
    implicitHeight:34;implicitWidth:label.implicitWidth+28+(icon?25:0);radius:17
    color:selected?Colours.palette.m3primary:Colours.palette.m3surfaceContainerHigh
    opacity:enabled?1:.4
    Row {anchors.centerIn:parent;spacing:7
        MaterialIcon {text:root.icon;visible:root.icon.length>0;font.pointSize:14;color:root.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurface}
        StyledText {id:label;text:root.text;color:root.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurface}
    }
    StateLayer {function onClicked(){root.clicked()}}
}
