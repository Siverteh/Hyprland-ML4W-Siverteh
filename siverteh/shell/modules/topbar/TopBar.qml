pragma ComponentBehavior: Bound
import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/modules/bar/components" as Native

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Variants {
    model: Quickshell.screens
    StyledWindow {
        id: win
        required property ShellScreen modelData
        screen: modelData
        name: "topbar"
        contentItem.opacity: Visibilities.reveal
        mask: Region { width: Visibilities.hidden ? 0 : win.width; height: win.height }
        anchors.top:true; anchors.left:true; anchors.right:true
        implicitHeight:BorderConfig.headerHeight
        WlrLayershell.exclusionMode:ExclusionMode.Ignore
        WlrLayershell.layer:WlrLayer.Top
        color:"transparent"
        Rectangle { anchors.fill:parent; color:Colours.palette.m3surface }
        readonly property var visibility:Visibilities.screens[screen.name]
        Process { id: connectionManager }
        property int updateCount:0
        Process {id:updateCheck;command:[Quickshell.env("HOME")+"/.config/hypr/scripts/waybar/updates_status.sh"];running:true}
        Timer {interval:1800000;repeat:true;running:true;onTriggered:if(!updateCheck.running)updateCheck.running=true}
        FileView { path:Quickshell.env("HOME")+"/.cache/siverteh/updates-waybar.json";watchChanges:true;onFileChanged:reload()
            onLoaded:{try{const d=JSON.parse(text());win.updateCount=parseInt(String(d.text??0).match(/\d+/)?.[0]??"0");}catch(e){win.updateCount=0;}}
        }
        Timer {
            id: dismissPopout
            interval:120
            onTriggered: {
                const p=Visibilities.panels[win.screen.name];
                if(p){p.popouts.headerHovered=statusHover.containsMouse||calendarHover.containsMouse;if(!p.popouts.pinned&&!p.popouts.headerHovered&&!p.parent.containsMouse)p.popouts.hasCurrent=false;}
            }
        }
        function openConnections(name,item) {
            if(name === "audio"){connectionManager.command=["pavucontrol"];connectionManager.startDetached();return;}
            const p=Visibilities.panels[screen.name];if(p)p.popouts.hasCurrent=false;
            connectionManager.command=["siverteh-os-shell",name === "network" ? "wifi" : "bluetooth"];
            connectionManager.startDetached();
        }
        function hoverMenu(name,item){dismissPopout.stop();const panel=Visibilities.panels[screen.name];if(panel)panel.popouts.headerHovered=true;const p=item.mapToItem(win.contentItem,item.width/2,0);Visibilities.popout(name,p.x,screen.name);}
        RowLayout {
            id:leftGroup
            anchors.left:parent.left;anchors.leftMargin:Appearance.padding.large;anchors.verticalCenter:parent.verticalCenter
            spacing:Appearance.spacing.normal
            ShLogo {MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{win.visibility.launcherMode="apps";win.visibility.launcherQuery="";win.visibility.launcherRequest++;win.visibility.launcher=!win.visibility.launcher;} } }
            StyledRect {
                radius:Appearance.rounding.full;color:Colours.palette.m3surfaceContainer
                implicitHeight:34;implicitWidth:workspaces.implicitWidth+Appearance.padding.small*2
                WorkspaceStrip {id:workspaces;anchors.centerIn:parent}
            }
        }
        Native.ActiveWindow {
            anchors.horizontalCenter:parent.horizontalCenter;anchors.verticalCenter:parent.verticalCenter
            width:Math.max(100,Math.min(650,win.width-2*Math.max(leftGroup.width,rightGroup.width)-50));height:30
            horizontal:true;monitor:Brightness.getMonitorForScreen(win.screen)
        }
        RowLayout {
            id:rightGroup
            anchors.right:parent.right;anchors.rightMargin:Appearance.padding.large;anchors.verticalCenter:parent.verticalCenter
            spacing:Appearance.spacing.normal
            Item {
                implicitWidth:updateRow.implicitWidth;implicitHeight:34
                Row {id:updateRow;anchors.centerIn:parent;spacing:4
                    MaterialIcon {text:"package_2";color:Colours.palette.m3tertiary}
                    StyledText {text:win.updateCount;color:Colours.palette.m3tertiary}
                }
                MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:{connectionManager.command=["siverteh-os-shell","updates"];connectionManager.startDetached();}}
            }
            Item {
                implicitWidth:clockRow.implicitWidth;implicitHeight:34
                Row { id:clockRow;anchors.centerIn:parent;spacing:Appearance.spacing.small
                    MaterialIcon {text:"calendar_month";color:Colours.palette.m3tertiary}
                    StyledText {text:Time.format("HH:mm");color:Colours.palette.m3tertiary}
                }
                MouseArea { id:calendarHover;anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
                    onEntered:win.hoverMenu("calendar",this)
                    onExited:{const p=Visibilities.panels[win.screen.name];if(p)p.popouts.headerHovered=statusHover.containsMouse;dismissPopout.restart();}
                    onClicked:win.hoverMenu("calendar",this)
                }
            }
            StyledRect {
                radius:Appearance.rounding.full;color:Colours.palette.m3surfaceContainer
                implicitWidth:status.implicitHeight+Appearance.padding.small*2;implicitHeight:34
                Native.StatusIcons {id:status;anchors.centerIn:parent;rotation:-90;horizontal:true}
                MouseArea {
                    id:statusHover
                    anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor
                    function menuName(){
                        const icons=[status.audioItem,status.network,status.bluetoothItem,status.battery,status.notificationsItem];let best=Infinity,index=0;
                        for(let i=0;i<icons.length;i++){const icon=icons[i],x=icon.mapToItem(statusHover,icon.width/2,icon.height/2).x,d=Math.abs(mouseX-x);if(d<best){best=d;index=i;}}
                        return ["audio","network","bluetooth","battery","notifications"][index];
                    }
                    function showMenu(){
                        const name=menuName(),p=Visibilities.panels[win.screen.name];
                        dismissPopout.stop();if(p)p.popouts.headerHovered=true;
                        if(p && (!p.popouts.hasCurrent||p.popouts.currentName!==name)) {
                            const index=["audio","network","bluetooth","battery","notifications"].indexOf(name);
                            const icon=[status.audioItem,status.network,status.bluetoothItem,status.battery,status.notificationsItem][index];
                            const pt=icon.mapToItem(win.contentItem,icon.width/2,icon.height/2);
                            dismissPopout.stop();p.popouts.headerHovered=true;Visibilities.popout(name,pt.x,win.screen.name);
                        }
                    }
                    onEntered:showMenu()
                    onPositionChanged:if(containsMouse)showMenu()
                    onExited:{const p=Visibilities.panels[win.screen.name];if(p)p.popouts.headerHovered=calendarHover.containsMouse;dismissPopout.restart();}
                    onClicked:{
                        const name=menuName(),p=Visibilities.panels[win.screen.name];
                        if(name==="notifications") {if(p.popouts.hasCurrent&&p.popouts.pinned&&p.popouts.currentName===name)p.popouts.hasCurrent=false;else{showMenu();p.popouts.pinned=true;}}
                        else if(name==="battery")showMenu();else win.openConnections(name,this);
                    }
                }
            }
            Native.Power {}
        }
        MouseArea {
            anchors.horizontalCenter:parent.horizontalCenter;width:Math.min(700,parent.width*0.45);height:win.height
            hoverEnabled:true;acceptedButtons:Qt.NoButton
            onEntered:if(win.visibility&&!win.visibility.session){const p=Visibilities.panels[win.screen.name];if(p)p.popouts.hasCurrent=false;win.visibility.dashboard=true;}
            onExited:if(win.visibility&&mouseY<height-2)win.visibility.dashboard=false
        }
    }
}
