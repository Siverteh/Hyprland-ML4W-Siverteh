pragma ComponentBehavior: Bound
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
Item {
    id:root
    required property ShellScreen screen
    property string currentName
    property real currentCenter
    property bool hasCurrent
    property real lastWidth:200
    property real lastHeight:80
    readonly property real targetWidth:(body.item?.implicitWidth>0?body.item.implicitWidth:lastWidth)+Appearance.padding.large*2
    readonly property real targetHeight:(body.item?.implicitHeight>0?body.item.implicitHeight:lastHeight)+Appearance.padding.large*2
    anchors.centerIn:parent
    implicitWidth:targetWidth
    implicitHeight:hasCurrent?targetHeight:0
    Loader {
        id:body
        anchors.fill:parent;anchors.margins:Appearance.padding.large
        clip:true;asynchronous:false
        source:({network:"Network.qml",bluetooth:"Bluetooth.qml",calendar:"Calendar.qml",battery:"Battery.qml"})[root.currentName]??""
        onLoaded:{if(item.implicitWidth>0)root.lastWidth=item.implicitWidth;if(item.implicitHeight>0)root.lastHeight=item.implicitHeight;}
    }
    Behavior on implicitWidth {Anim {}}
    Behavior on implicitHeight {Anim {}}
    Behavior on currentCenter {Anim {}}
    component Anim:NumberAnimation {
        duration:Appearance.anim.durations.normal
        easing.type:Easing.BezierSpline
        easing.bezierCurve:Appearance.anim.curves.standard
    }
}
