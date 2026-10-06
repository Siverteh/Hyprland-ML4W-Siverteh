import qs.widgets
import qs.services
import QtQuick
import QtQuick.Controls
SearchSurface {
    id:root;title:"Keyboard shortcuts";placeholder:"Search a shortcut or action"
    Component.onCompleted:DesktopExtras.request("keys",{})
    readonly property var matches:DesktopExtras.keys.filter(k=>(k.key+" "+k.description).toLowerCase().includes(query.toLowerCase()))
    ListView {id:list;anchors.fill:parent;clip:true;spacing:5;model:root.matches
        ScrollBar.vertical:ScrollBar {}
        FastScroll {view:list}
        delegate:StyledRect {required property var modelData;width:list.width;height:42;radius:10;color:Colours.palette.m3surfaceContainer
            StyledText {anchors.left:parent.left;anchors.leftMargin:12;anchors.verticalCenter:parent.verticalCenter;width:340;text:modelData.key;font.family:"JetBrains Mono NF";font.pointSize:11;color:Colours.palette.m3primary}
            StyledText {anchors.left:parent.left;anchors.leftMargin:365;anchors.right:parent.right;anchors.rightMargin:12;anchors.verticalCenter:parent.verticalCenter;text:modelData.description;elide:Text.ElideRight;font.pointSize:11}
        }
        StyledText {anchors.centerIn:parent;visible:list.count===0;text:DesktopExtras.busy.keys?"Reading shortcuts…":"No matching shortcuts"}
    }
    onMoved:delta=>list.contentY=Math.max(0,Math.min(list.contentHeight-list.height,list.contentY+delta*47))
}
