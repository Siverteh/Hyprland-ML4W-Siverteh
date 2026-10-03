pragma Singleton
import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import "root:/utils"
import Quickshell
import Quickshell.Io
import QtQuick
Singleton {
    id:root
    readonly property string currentNamePath:`${Paths.state}/wallpaper/last.txt`.slice(7)
    readonly property string path:`${Paths.pictures}/Wallpapers`.slice(7)
    readonly property list<Wallpaper> list:wallpapers.instances
    property string actualCurrent
    property string selectedPath
    property string queuedPath
    readonly property string current:selectedPath || actualCurrent
    readonly property list<var> preppedWalls:list.map(w=>({name:Fuzzy.prepare(w.name),path:Fuzzy.prepare(w.path),wall:w}))
    function fuzzyQuery(search:string):var {
        return Fuzzy.go(search,preppedWalls,{all:true,keys:["name","path"],scoreFn:r=>r[0].score*.9+r[1].score*.1}).map(r=>r.obj.wall);
    }
    function browse(path:string):void {
        if(!path || path===current)return;
        selectedPath=path;settle.restart();
    }
    function commitSelection():void {
        settle.stop();if(!selectedPath)return;
        queuedPath=selectedPath;startCommit();
    }
    function setWallpaper(path:string):void {
        if(!path)return;selectedPath=path;commitSelection();
    }
    function startCommit():void {
        if(commit.running || !queuedPath)return;
        if(queuedPath===actualCurrent){queuedPath="";selectedPath="";return;}
        commit.requestPath=queuedPath;queuedPath="";commit.running=true;
    }
    Timer {id:settle;interval:300;onTriggered:root.commitSelection()}
    FileView {
        path:root.currentNamePath;watchChanges:true;onFileChanged:reload()
        onLoaded:root.actualCurrent=text().trim()
    }
    Process {
        id:commit
        property string requestPath
        command:["siverteh_shell","wallpaper","-f",requestPath]
        onExited:code=>{
            if(code===0){root.actualCurrent=requestPath;if(root.selectedPath===requestPath&&!root.queuedPath)root.selectedPath="";}
            else console.warn("Wallpaper commit failed",code);
            root.startCommit();
        }
    }
    IpcHandler {
        target:"wallpaper"
        function get():string{return root.current;}
        function set(path:string):void{root.setWallpaper(path);}
        function list():string{return root.list.map(w=>w.path).join("\n");}
        function state():string{return JSON.stringify({selected:root.current,applied:root.actualCurrent,busy:commit.running,queued:root.queuedPath});}
    }
    Process {
        running:true
        command:["fd",".",root.path,"-t","f","-e","jpg","-e","jpeg","-e","png","-e","webp","-e","gif","-e","tif","-e","tiff"]
        stdout:SplitParser {splitMarker:"";onRead:data=>wallpapers.model=data.trim().split("\n").filter(Boolean).sort((a,b)=>a.localeCompare(b))}
    }
    Variants {id:wallpapers;Wallpaper {}}
    component Wallpaper:QtObject {
        required property string modelData
        readonly property string path:modelData
        readonly property string name:path.slice(path.lastIndexOf("/")+1,path.lastIndexOf(".")).replace(/_/g," ")
    }
}
