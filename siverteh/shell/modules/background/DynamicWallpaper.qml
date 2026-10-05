import QtQuick
import QtMultimedia
import Quickshell.Io
Item {
 id:root
 property string screenName:""
 property string path:""
 property bool running:false
 property string failure:""
 readonly property int position:player.position
 readonly property bool playing:player.playing
 MediaPlayer {id:player;source:root.path?"file://"+root.path:"";loops:MediaPlayer.Infinite;videoOutput:output;activeAudioTrack:-1
  onTracksChanged:activeAudioTrack=-1
  onErrorOccurred:(error,errorString)=>{root.failure=errorString;player.stop();}
  onMediaStatusChanged:if(mediaStatus===MediaPlayer.LoadedMedia&&root.running)play()
 }
 VideoOutput {id:output;anchors.fill:parent;fillMode:VideoOutput.PreserveAspectCrop}
 onRunningChanged:if(running&&!failure)player.play();else player.pause()
 onPathChanged:{failure="";if(running)Qt.callLater(()=>player.play());}
 Component.onCompleted:if(running)player.play()
 Component.onDestruction:player.stop()
 IpcHandler {target:"wallpaperMotion-"+root.screenName;function state():string{return JSON.stringify({playing:player.playing,position:player.position,hasVideo:player.hasVideo,audioTrack:player.activeAudioTrack,failure:root.failure,running:root.running});}}
}
