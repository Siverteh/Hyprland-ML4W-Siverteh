import "modules"
import "modules/drawers"
import "modules/background"
import "modules/topbar"
import "modules/extras"
import "root:/services"
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    property var lockWidgets:LockWidgets
    property var displayRecovery:DisplayRecovery
    Background {}
    Drawers {}
    TopBar {}
    LeftHotspot {}

    Shortcuts {}
    Component.onCompleted:ChatWindowTitle.scan()
    IpcHandler {
        target:"siverteh"
        function state(): string { const v=Visibilities.getForActive();return JSON.stringify({active:Hyprland.activeWsId,workspaces:Hyprland.workspaces.values.length,dashboard:v?.dashboard,tab:v?.dashboardTab,launcher:v?.launcher,session:v?.session,osd:v?.osd,hidden:Visibilities.hidden,left:v?.left,leftPinned:v?.leftPinned,query:v?.launcherQuery,launcherMode:v?.launcherMode,reveal:Visibilities.reveal,notificationsSuppressed:Object.values(Visibilities.panels).some(p=>p.notifications.suppressed)}); }
        function restoreViews(data:string):void {
            const saved=JSON.parse(data),v=Visibilities.getForActive();if(!v)return;v.previewOnly=false;
            if(saved.dashboard===true){v.dashboard=true;v.dashboardTab=Math.max(0,Math.min(4,Number(saved.tab)||0));}
            if(saved.left===true){v.left=true;v.leftPinned=saved.leftPinned===true;const p=Visibilities.panels[Hyprland.focusedMonitor?.name];if(p&&["chat","chats","brain","settings"].includes(saved.leftSection))p.leftDrawer.section=saved.leftSection;}
            if(saved.launcher===true&&["apps","wallpaper","palette","overview","clipboard","keys"].includes(saved.mode))Visibilities.openMode(saved.mode);
        }
        function preview(name:string):void{Visibilities.openMode(name,"",true);}
        function previewDashboard(index:int):void{const v=Visibilities.getForActive();if(v){v.previewOnly=true;v.dashboardTab=index;v.dashboard=true;}}
        function previewSliders():void{const v=Visibilities.getForActive();if(v){v.previewOnly=true;v.osd=true;}}
        function previewLeft():void{const v=Visibilities.getForActive();if(v){v.previewOnly=true;v.left=true;}}
        function mode(name:string):void{Visibilities.openMode(name,"");}
        function settings():void{Visibilities.openSettings();}
        function left():void{Visibilities.toggleLeft();}
        function hide(): void { Visibilities.hidden=!Visibilities.hidden; }
        function launcher(query:string):void { const v=Visibilities.getForActive();if(v){v.previewOnly=false;Visibilities.hidden=false;v.session=false;v.osd=false;v.dashboard=false;for(const p of Object.values(Visibilities.panels))p.popouts.hasCurrent=false;const mode=query.startsWith(">wallpaper")?"wallpaper":"apps";const same=v.launcher&&v.launcherMode===mode;v.launcherMode=mode;v.launcherQuery=mode==="wallpaper"?"":query;v.launcherRequest++;v.launcher=mode==="wallpaper"||!same||query.length>0;} }
        function session():void { const v=Visibilities.getForActive();if(v){v.previewOnly=false;Visibilities.hidden=false;v.osd=false;v.dashboard=false;v.launcher=false;v.session=!v.session;const p=Visibilities.panels[Hyprland.focusedMonitor?.name];if(p)p.popouts.hasCurrent=false;} }
        function popout(name:string,center:real):void { Visibilities.popout(name,center,Hyprland.focusedMonitor?.name ?? Object.keys(Visibilities.screens)[0]); }
        function close(): void { const v=Visibilities.getForActive();if(v){v.dashboard=false;v.osd=false;v.launcher=false;v.session=false;v.left=false;v.leftPinned=false;v.previewOnly=false;} for(const p of Object.values(Visibilities.panels))p.popouts.hasCurrent=false; }
        function popupState():string{return JSON.stringify(Object.values(Visibilities.panels).map(p=>({name:p.popouts.currentName,open:p.popouts.hasCurrent,height:p.popouts.height,width:p.popouts.width,center:p.popouts.currentCenter,header:p.popouts.headerHovered})));}
        function galleryStep(delta:int):void { for(const p of Object.values(Visibilities.panels))p.launcher.galleryStep(delta); }
        function galleryState():string { return JSON.stringify(Object.values(Visibilities.panels).map(p=>({count:p.launcher.galleryCount,index:p.launcher.galleryIndex}))); }
        function workspace(id:int):void { Hyprland.dispatch("workspace "+id); }
        function tab(index:int):void { const v=Visibilities.getForActive();if(v){v.dashboardTab=index;v.dashboard=true;} }
    }
}
