import qs.services
import QtQuick
StyledRect {
    id:root
    property string text
    property string icon:""
    property bool selected:false
    property bool compact:false
    signal clicked()
    implicitHeight:34;implicitWidth:label.implicitWidth+(compact?20:28)+(icon?(compact?22:25):0);radius:17
    color:selected?Colours.palette.m3primary:Colours.palette.m3surfaceContainerHigh
    opacity:enabled?1:.4
    Row {anchors.centerIn:parent;spacing:root.compact?5:7
        MaterialIcon {text:root.icon;visible:root.icon.length>0;font.pointSize:root.compact?12:14;color:root.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurface}
        StyledText {id:label;text:root.text;font.pointSize:root.compact?10:12;color:root.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurface}
    }
    StateLayer {function onClicked(){root.clicked()}}
}
