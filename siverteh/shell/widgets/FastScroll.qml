import QtQuick
WheelHandler {
    id:root
    required property var view
    property real step:150
    property real pixelMultiplier:1
    property real destination:0
    property int smoothDuration:100
    property bool kinetic:false
    property real velocity:0
    property real lastPixelTime:0
    property int pixelSamples:0
    signal scrolled()
    signal settled()
    target:null
    acceptedDevices:PointerDevice.Mouse|PointerDevice.TouchPad
    function scrollBy(delta,smooth){
        view.cancelFlick();
        const base=motion.running?destination:view.contentY;
        destination=Math.max(view.originY,Math.min(view.originY+Math.max(0,view.contentHeight-view.height),base+delta));
        motion.stop();
        if(smooth){motion.from=view.contentY;motion.to=destination;motion.start();}else view.contentY=destination;
    }
    function pixelScroll(delta){
        const now=Date.now();const elapsed=now-lastPixelTime;
        if(elapsed>120||velocity*delta<0){velocity=0;pixelSamples=0;}
        const sample=delta*1000/Math.max(8,Math.min(50,elapsed||16));
        velocity=pixelSamples?velocity*0.55+sample*0.45:sample;
        lastPixelTime=now;pixelSamples++;
        scrollBy(delta,false);
        if(kinetic)release.restart();else settled();
    }
    function cancel(){release.stop();motion.stop();view.cancelFlick();velocity=0;pixelSamples=0;}
    onWheel:event=>{
        scrolled();
        if(event.pixelDelta.y)pixelScroll(-event.pixelDelta.y*pixelMultiplier);
        else if(event.angleDelta.y){release.stop();velocity=0;pixelSamples=0;scrollBy(-event.angleDelta.y/120*step,true);}
        event.accepted=true;
    }
    readonly property Timer release:Timer {
        interval:65
        onTriggered:{
            if(root.pixelSamples>1&&Math.abs(root.velocity)>100)
                root.view.flick(0,-Math.max(-2600,Math.min(2600,root.velocity)));
            else root.settled();
            root.velocity=0;root.pixelSamples=0;
        }
    }
    readonly property Connections movement:Connections {target:root.view;function onMovementEnded(){root.settled();}}
    readonly property NumberAnimation motion:NumberAnimation {target:root.view;property:"contentY";duration:root.smoothDuration;easing.type:Easing.OutCubic;onFinished:root.settled()}
}
