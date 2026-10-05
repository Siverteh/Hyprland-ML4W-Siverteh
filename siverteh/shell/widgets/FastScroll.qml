import QtQuick
WheelHandler {
    id:root
    required property var view
    property real step:150
    property real pixelMultiplier:1
    property real destination:0
    signal scrolled()
    target:null
    acceptedDevices:PointerDevice.Mouse|PointerDevice.TouchPad
    function scrollBy(delta,smooth){
        view.cancelFlick();
        const base=motion.running?destination:view.contentY;
        destination=Math.max(view.originY,Math.min(view.originY+Math.max(0,view.contentHeight-view.height),base+delta));
        motion.stop();
        if(smooth){motion.from=view.contentY;motion.to=destination;motion.start();}else view.contentY=destination;
    }
    onWheel:event=>{
        scrolled();
        if(event.pixelDelta.y)scrollBy(-event.pixelDelta.y*pixelMultiplier,false);
        else if(event.angleDelta.y)scrollBy(-event.angleDelta.y/120*step,true);
        event.accepted=true;
    }
    readonly property NumberAnimation motion:NumberAnimation {target:root.view;property:"contentY";duration:100;easing.type:Easing.OutCubic}
}
