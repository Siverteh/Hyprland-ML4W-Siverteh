#!/usr/bin/env python3
"""Apply small, version-scoped Siverteh integrations to a copied upstream shell."""
import shutil,sys
from pathlib import Path
source=Path(__file__).resolve().parent;root=Path(sys.argv[1])
def replace(path,old,new):
 p=root/path;s=p.read_text()
 if new in s:return
 if old not in s:raise RuntimeError('Upstream anchor changed: '+str(path))
 p.write_text(s.replace(old,new,1))
# The system's status IPC reports Lua; the packaged Quickshell reports false.
replace('services/Hypr.qml','readonly property bool usingLua: Hyprland.usingLua','readonly property bool usingLua: true')
replace('services/Hypr.qml','usingLua: Hyprland.usingLua','usingLua: root.usingLua')
# Use the explicit Lua command route on this host instead of the legacy IPC dispatcher.
replace('services/Hypr.qml','Hyprland.dispatch(request);','Quickshell.execDetached(["hyprctl", "eval", "hl.dispatch(" + request + ")"]);')
for name in ['WorkspaceTab.qml','SivertehTab.qml']:shutil.copy2(source/name,root/'modules/dashboard'/name)
replace('modules/dashboard/Content.qml','            {\n                component: weatherComponent,','            {component: workspaceComponent, iconName: "workspaces", text: "Workspaces", enabled: true},\n            {component: sivertehComponent, iconName: "auto_awesome", text: "AI & brain", enabled: true},\n            {\n                component: weatherComponent,')
replace('modules/dashboard/Content.qml','id: dashComponent','id: dashComponent') # Version check without altering built-in panels.
replace('modules/dashboard/Content.qml','            Component {\n                id: dashComponent','            Component { id: workspaceComponent; WorkspaceTab {} }\n            Component { id: sivertehComponent; SivertehTab {} }\n\n            Component {\n                id: dashComponent')
# Preserve the native rail's compact icon presentation.
replace('modules/bar/Bar.qml','            DelegateChoice {\n                roleValue: "workspaces"','''            DelegateChoice {
                roleValue: "siverteh"
                delegate: EntryWrapper {
                    Item {
                        implicitWidth: 24; implicitHeight: 28
                        MaterialIcon { anchors.centerIn: parent; text: "auto_awesome" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["siverteh-observatory", "tasks"]) }
                    }
                }
            }
            DelegateChoice {
                roleValue: "updates"
                delegate: EntryWrapper {
                    Item {
                        implicitWidth: 24; implicitHeight: 28
                        MaterialIcon { anchors.centerIn: parent; text: "package_2" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["siverteh-observatory", "updates"]) }
                    }
                }
            }
            DelegateChoice {
                roleValue: "workspaces"''')

replace('modules/bar/components/workspaces/Workspace.qml','return mon && mon !== monitor;','return !!(mon && mon !== monitor);')

replace('services/ShellState.qml', '        return null;\n    }\n\n    function componentsFor(screen', '        return states.instances[0] ?? null;\n    }\n\n    function componentsFor(screen')
replace('shell.qml','import Quickshell\n','import Quickshell\nimport Quickshell.Io\nimport Quickshell.Hyprland\n')
replace('shell.qml','    GSFLoader {}', '    IpcHandler {\n        target: "siverteh"\n        function state(): string { const s=ShellState.forActive(); return JSON.stringify({workspaces:Hyprland.workspaces.values.length,monitors:Hyprland.monitors.values.length,active:Hypr.activeWsId,screen:!!s,dashboard:s?.dashboard,tab:s?.dashboardTab}); }\n        function workspace(id: int): void { Hypr.focusWorkspace(id); }\n        function tab(index: int): void { const s=ShellState.forActive(); if(s){s.dashboardTab=index;s.dashboard=true;} }\n        function close(): void { const s=ShellState.forActive(); if(s){s.dashboard=false;s.launcher=false;s.osd=false;s.sidebar=false;s.session=false;s.utilities=false;} }\n    }\n    GSFLoader {}')
