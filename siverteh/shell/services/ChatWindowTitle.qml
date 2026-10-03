pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
Singleton {
    id:root
    readonly property int pid:Hyprland.activeClient?.wmClass==="siverteh-ai-task"?(Hyprland.activeClient?.pid??0):0
    property var titles:({})
    property var pending:[]
    IpcHandler {target:"chatTitle";function state():string{return JSON.stringify({pid:root.pid,title:root.title,resolved:root.resolved,cached:Object.keys(root.titles).length});}}
    readonly property string title:titles[pid]??""
    readonly property bool resolved:pid===0||titles[pid]!==undefined

    // Resolve open chat windows before focus, and retain their names across switches.
    function scan(){
        const pids=Hyprland.clients.filter(c=>c.wmClass==="siverteh-ai-task").map(c=>c.pid);
        if(pid&&!pids.includes(pid))pids.unshift(pid);
        const retained={};for(const p of pids)if(titles[p]!==undefined)retained[p]=titles[p];
        titles=retained;pending=pids;next();
    }
    function next(){
        if(reader.running||pending.length===0)return;
        reader.requestPid=pending.shift();reader.running=true;
    }
    onPidChanged:{if(pid&&titles[pid]===undefined){pending=[pid,...pending.filter(p=>p!==pid)];next();}}
    Connections {target:Hyprland;function onClientsChanged(){root.scan();}}
    Timer {interval:2000;running:true;repeat:true;onTriggered:root.scan()}
    Component.onCompleted:scan()
    Process {
        id:reader
        property int requestPid
        command:["python3",Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/window-chat-title.py",requestPid.toString()]
        stdout:SplitParser {splitMarker:"";onRead:data=>{try{const updated=Object.assign({},root.titles);updated[reader.requestPid]=JSON.parse(data).title;root.titles=updated;}catch(e){}}}
        onExited:root.next()
    }
}
