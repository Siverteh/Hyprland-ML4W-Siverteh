import "modules"
import "modules/drawers"
import "modules/background"
import "modules/topbar"
import "root:/services"
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    Background {}
    Drawers {}
    TopBar {}

    Shortcuts {}
    IpcHandler {
        target:"siverteh"
        function state(): string { const v=Visibilities.getForActive();return JSON.stringify({active:Hyprland.activeWsId,workspaces:Hyprland.workspaces.values.length,dashboard:v?.dashboard,tab:v?.dashboardTab,launcher:v?.launcher,session:v?.session,osd:v?.osd,hidden:Visibilities.hidden,query:v?.launcherQuery}); }
        function hide(): void { close(); Visibilities.hidden=!Visibilities.hidden; }
        function launcher(query:string):void { const v=Visibilities.getForActive();if(v){Visibilities.hidden=false;v.session=false;v.osd=false;v.launcherQuery=query;v.launcher=!v.launcher||query.length>0;} }
        function session():void { const v=Visibilities.getForActive();if(v){Visibilities.hidden=false;v.osd=false;v.dashboard=false;v.launcher=false;v.session=!v.session;const p=Visibilities.panels[Hyprland.focusedMonitor?.name];if(p)p.popouts.hasCurrent=false;} }
        function popout(name:string,center:real):void { Visibilities.popout(name,center,Hyprland.focusedMonitor.name); }
        function close(): void { const v=Visibilities.getForActive();if(v){v.dashboard=false;v.osd=false;v.launcher=false;v.session=false;} for(const p of Object.values(Visibilities.panels))p.popouts.hasCurrent=false; }
        function workspace(id:int):void { Hyprland.dispatch("workspace "+id); }
        function tab(index:int):void { const v=Visibilities.getForActive();if(v){v.dashboardTab=index;v.dashboard=true;} }
    }
}
