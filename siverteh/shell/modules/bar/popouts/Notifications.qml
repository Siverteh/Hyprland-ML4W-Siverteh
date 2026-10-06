import qs.widgets
import qs.services
import qs.config
import qs.modules.notifications as Cards
import Quickshell
import QtQuick
Column {
    width:400;spacing:12
    Row {width:400;spacing:12
        StyledText {width:310;text:"Notifications · "+Notifs.list.length;font.weight:500}
        StyledRect {implicitWidth:78;implicitHeight:30;radius:15;color:Colours.palette.m3surfaceContainer
            StyledText {anchors.centerIn:parent;text:"Clear all";font.pointSize:10}
            StateLayer {disabled:Notifs.list.length===0;function onClicked(){Notifs.clearHistory()}}
        }
    }
    Item {width:400;height:320
        StyledText {anchors.centerIn:parent;text:"No notifications";visible:Notifs.list.length===0;color:Colours.palette.m3onSurfaceVariant}
        ListView {
            id:historyList;anchors.fill:parent;clip:true;spacing:8
            FastScroll {view:historyList}
            model:ScriptModel {values:[...Notifs.list].reverse()}
            delegate:Cards.Notification {history:true}
        }
    }
}
