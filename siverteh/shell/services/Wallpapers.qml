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
 property var preferences:({kind:"static",layout:"carousel",paused:false,pauseCovered:true})
 property var media:({})
 property string lastImage:""
 readonly property string actualCurrent:media.path&&media.poster===lastImage?media.path:lastImage
 property string selectedPath:""
 property string queuedPath:""
 property string error:""
 readonly property bool loading:catalog.running
 readonly property string current:selectedPath||actualCurrent
 readonly property var currentEntry:list.find(w=>w.path===current)??(media.path===current?media:null)
 readonly property string poster:currentEntry?.poster??current
 readonly property bool dynamic:currentEntry?.dynamic??false
 readonly property bool animated:currentEntry?.animated??false
 readonly property list<var> preppedWalls:list.map(w=>({name:Fuzzy.prepare(w.name),path:Fuzzy.prepare(w.path),wall:w}))
 function fuzzyQuery(search:string):var{return Fuzzy.go(search,preppedWalls,{all:true,keys:["name","path"],scoreFn:r=>r[0].score*.9+r[1].score*.1}).map(r=>r.obj.wall);}
 function refresh(){if(!catalog.running)catalog.running=true;}
 function browse(path:string):void{if(!path||path===current)return;selectedPath=path;settle.restart();}
 function commitSelection():void{settle.stop();if(!selectedPath)return;queuedPath=selectedPath;startCommit();}
 function setWallpaper(path:string):void{if(!path)return;selectedPath=path;commitSelection();}
 function startCommit():void{if(commit.running||!queuedPath)return;if(queuedPath===actualCurrent){queuedPath="";selectedPath="";return;}commit.requestPath=queuedPath;queuedPath="";commit.running=true;}
 property var preferenceQueue:[]
 function preference(value){preferenceQueue.push(value);nextPreference();}
 function nextPreference(){if(!prefWorker.running&&preferenceQueue.length){prefWorker.value=preferenceQueue.shift();prefWorker.running=true;}}
 function addFiles(paths){if(importer.running)return;importer.files=paths;importer.command=["python3",tool,"import"];importer.running=true;}
 function pickFiles(){if(importer.running)return;importer.files=null;importer.command=["python3",tool,"pick"];importer.running=true;}
 readonly property string tool:Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/wallpaper-media.py"
 Timer {id:settle;interval:300;onTriggered:root.commitSelection()}
 FileView {path:root.currentNamePath;watchChanges:true;onFileChanged:reload();onLoaded:root.lastImage=text().trim()}
 FileView {id:mediaFile;path:`${Paths.state}/wallpaper/media.json`;watchChanges:true;preload:false;onFileChanged:reload();onLoaded:{try{root.media=JSON.parse(text());}catch(e){}}}
 Process {id:catalog;running:true;command:["python3",root.tool,"catalog"];stdout:SplitParser {splitMarker:"";onRead:line=>{try{const data=JSON.parse(line);if(data.error){root.error=data.error;return;}wallpapers.model=data.entries;root.preferences=data.preferences;root.media=data.media;root.error=data.errors?.length?"Could not prepare "+data.errors.join(", "):"";}catch(e){root.error="Could not read wallpapers";}}}}
 Process {id:commit;property string requestPath;command:["python3",root.tool,"select",requestPath];stdout:SplitParser {splitMarker:"";onRead:line=>{try{const data=JSON.parse(line);if(data.error)root.error=data.error;else {root.media=data;root.lastImage=data.poster;root.error="";}}catch(e){root.error="Could not apply wallpaper";}}}onExited:code=>{if(code===0){if(root.selectedPath===requestPath&&!root.queuedPath)root.selectedPath="";}else root.selectedPath="";root.startCommit();}}
 Process {id:prefWorker;property var value;stdinEnabled:true;command:["python3",root.tool,"preferences"];onStarted:write(JSON.stringify(value)+"\n");stdout:SplitParser {splitMarker:"";onRead:line=>{try{const data=JSON.parse(line);if(data.error)root.error=data.error;else root.preferences=data;}catch(e){root.error="Could not save picker preferences";}}}onExited:root.nextPreference()}
 Process {id:importer;property var files;stdinEnabled:true;onStarted:if(files)write(JSON.stringify(files)+"\n");stdout:SplitParser {splitMarker:"";onRead:line=>{try{const data=JSON.parse(line);root.error=data.error??"";}catch(e){root.error="Could not import wallpapers";}}}onExited:root.refresh()}
 IpcHandler {target:"wallpaper";function get():string{return root.current;}function set(path:string):void{root.setWallpaper(path);}function list():string{return root.list.map(w=>w.path).join("\n");}function state():string{return JSON.stringify({selected:root.current,applied:root.actualCurrent,poster:root.poster,dynamic:root.dynamic,busy:commit.running,queued:root.queuedPath,preferences:root.preferences,error:root.error,count:root.list.length});}}
 Variants {id:wallpapers;Wallpaper {}}
 component Wallpaper:QtObject {
  required property var modelData
  readonly property string path:modelData.path
  readonly property string name:modelData.name
  readonly property string poster:modelData.poster
  readonly property bool dynamic:modelData.dynamic
  readonly property bool animated:modelData.animated
 }
}
