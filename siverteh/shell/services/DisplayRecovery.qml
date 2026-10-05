pragma Singleton
import Quickshell
import QtQuick
Singleton {
 id:root
 readonly property string signature:Quickshell.screens.map(s=>[s.name,s.x,s.y,s.width,s.height,s.devicePixelRatio].join(":")).sort().join(";")
 property string previous:""
 property bool ready:false
 Timer {interval:2000;running:true;onTriggered:{root.previous=root.signature;root.ready=true;}}
 onSignatureChanged:if(ready&&signature!==previous){previous=signature;settle.restart();}
 Timer {id:settle;interval:700;onTriggered:{
  const v=Visibilities.getForActive();if(!v)return;
  const p=Visibilities.panels[Hyprland.focusedMonitor?.name];
  const view={dashboard:v.dashboard,tab:v.dashboardTab,left:v.left,leftPinned:v.leftPinned,leftSection:p?.leftDrawer?.section??"chat",launcher:v.launcher,mode:v.launcherMode};
  AppLaunch.run(["python3",Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/display-recover.py",JSON.stringify(view)]);
 }}
}
