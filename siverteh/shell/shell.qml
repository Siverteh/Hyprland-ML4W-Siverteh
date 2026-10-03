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
        function state(): string { const v=Visibilities.getForActive();return JSON.stringify({active:Hyprland.activeWsId,workspaces:Hyprland.workspaces.values.length,dashboard:v?.dashboard,tab:v?.dashboardTab}); }
        function close(): void { const v=Visibilities.getForActive();if(v){v.dashboard=false;v.osd=false;v.launcher=false;v.session=false;} }
        function workspace(id:int):void { Hyprland.dispatch("workspace "+id); }
        function tab(index:int):void { const v=Visibilities.getForActive();if(v){v.dashboardTab=index;v.dashboard=true;} }
    }
}
