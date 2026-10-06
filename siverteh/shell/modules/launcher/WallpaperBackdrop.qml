import QtQuick
import QtQuick.Effects
Item {
 id:root
 property string path:""
 property string pending:""
 property Image current:one
 property bool hasImage:false
 property real blend:1
 function request(){pending=path?"file://"+path:"";loadPending();}
 function loadPending(){if(!pending||fadeGate.running||current.loadedTag===pending)return;const next=current===one?two:one;next.requestTag=pending;next.source=pending;if(next.status===Image.Ready)ready(next);}
 function ready(image){if(image.status!==Image.Ready)return;if(image.requestTag!==pending)return;image.loadedTag=image.requestTag;blend=0;current=image;hasImage=true;fadeGate.restart();crossfade.restart();}
 onPathChanged:request()
 Component.onCompleted:request()
 NumberAnimation {id:crossfade;target:root;property:"blend";from:0;to:1;duration:280;easing.type:Easing.InOutCubic}
 Timer {id:fadeGate;interval:300;onTriggered:root.loadPending()}
 Image {id:one;property string requestTag:"";property string loadedTag:"";anchors.fill:parent;sourceSize.width:1600;fillMode:Image.PreserveAspectCrop;asynchronous:true;visible:false;onStatusChanged:root.ready(this)}
 Image {id:two;property string requestTag:"";property string loadedTag:"";anchors.fill:parent;sourceSize.width:1600;fillMode:Image.PreserveAspectCrop;asynchronous:true;visible:false;onStatusChanged:root.ready(this)}
 MultiEffect {anchors.fill:parent;source:one;blurEnabled:true;blur:0.65;blurMax:24;z:root.current===one?1:0;opacity:root.hasImage?(root.current===one?root.blend:fadeGate.running?1:0):0}
 MultiEffect {anchors.fill:parent;source:two;blurEnabled:true;blur:0.65;blurMax:24;z:root.current===two?1:0;opacity:root.hasImage?(root.current===two?root.blend:fadeGate.running?1:0):0}
}
