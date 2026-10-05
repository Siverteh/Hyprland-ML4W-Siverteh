pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
Item {
    id:root
    required property PersistentProperties visibilities
    implicitWidth:740;implicitHeight:410
    function choose(){const entry=grid.model.values[grid.currentIndex];if(entry){Apps.launch(entry);visibilities.launcher=false;}}
    Component.onCompleted:if(visibilities.launcher)search.forceActiveFocus()
    Connections {target:root.visibilities;function onLauncherChanged(){if(root.visibilities.launcher)search.forceActiveFocus();else search.text="";}}
    StyledTextField {
        id:search
        anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;anchors.margins:20
        height:45;placeholderText:"Search apps"
        leftPadding:16;rightPadding:16
        background:StyledRect {color:Colours.palette.m3surfaceContainer;radius:Appearance.rounding.full}
        Keys.onEscapePressed:root.visibilities.launcher=false
        Keys.onDownPressed:{grid.forceActiveFocus();grid.currentIndex=Math.max(0,grid.currentIndex);}
        onAccepted:root.choose()
    }
    GridView {
        id:grid
        anchors.top:search.bottom;anchors.bottom:parent.bottom;anchors.left:parent.left;anchors.right:parent.right;anchors.margins:20
        cellWidth:140;cellHeight:100;clip:true
        model:ScriptModel {values:Apps.fuzzyQuery(search.text);onValuesChanged:grid.currentIndex=0}
        Keys.onReturnPressed:root.choose()
        Keys.onEnterPressed:root.choose()
        Keys.onEscapePressed:root.visibilities.launcher=false
        delegate:StyledRect {
            id:tile
            required property var modelData
            required property int index
            implicitWidth:132;implicitHeight:92;radius:Appearance.rounding.normal
            color:GridView.isCurrentItem?Colours.palette.m3secondaryContainer:"transparent"
            Image {id:appIcon;anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top;anchors.topMargin:10;width:36;height:36;sourceSize.width:36;sourceSize.height:36;fillMode:Image.PreserveAspectFit;source:Quickshell.iconPath(tile.modelData.icon)}
            MaterialIcon {anchors.centerIn:appIcon;text:"apps";font.pointSize:26;visible:appIcon.status!==Image.Ready;color:Colours.palette.m3onSurfaceVariant}
            StyledText {anchors.bottom:parent.bottom;anchors.bottomMargin:12;anchors.horizontalCenter:parent.horizontalCenter;width:120;text:tile.modelData.name;horizontalAlignment:Text.AlignHCenter;elide:Text.ElideRight;font.pointSize:11}
            MouseArea {anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor;onEntered:grid.currentIndex=tile.index;onClicked:{grid.currentIndex=tile.index;root.choose();}}
        }
    }
}
