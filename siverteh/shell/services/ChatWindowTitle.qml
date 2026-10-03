pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
Singleton {
    id:root
    readonly property int pid:Hyprland.activeClient?.wmClass==="siverteh-ai-task"?(Hyprland.activeClient?.pid??0):0
    property string title
    function refresh(){if(pid&&!reader.running){reader.requestPid=pid;reader.running=true;}}
    onPidChanged:{title="";refresh();}
    Timer {interval:2000;running:root.pid>0;repeat:true;onTriggered:root.refresh()}
    Process {
        id:reader
        property int requestPid
        command:["python3",Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/window-chat-title.py",requestPid.toString()]
        stdout:SplitParser {splitMarker:"";onRead:data=>{if(root.pid===reader.requestPid)root.title=JSON.parse(data).title;}}
    }
}
