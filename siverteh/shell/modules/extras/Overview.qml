import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland as Native
import QtQuick
import QtQuick.Controls
SearchSurface {
    id:root;title:"Windows";placeholder:"Search windows or applications";implicitWidth:1020
    bodyHeight:Math.min(690,Quickshell.screens[0].height-230)
    property int selection:0
    property int previews:0
    property bool dragging:false
    property string draggedAddress:""
    readonly property var windows:Hyprland.clients.filter(c=>!c.lastIpcObject.hidden&&(c.title+" "+c.wmClass).toLowerCase().includes(query.toLowerCase()))
    readonly property var workspaces:[...new Set([1,2,3,4,5,6,7,...windows.map(c=>c.workspace?.id).filter(id=>id>0)])].sort((a,b)=>a-b)
    function focusWindow(client){if(client){visibilities.launcher=false;Hyprland.dispatch('hl.dsp.focus({window='+JSON.stringify('address:'+client.address)+'})');}}
    function moveWindow(address,workspace){if(/^0x[0-9a-f]+$/i.test(address))Hyprland.dispatch('hl.dsp.window.move({window='+JSON.stringify('address:'+address)+',workspace='+workspace+',follow=false})');}
    onChosen:focusWindow(windows[selection])
    onMoved:delta=>selection=Math.max(0,Math.min(windows.length-1,selection+delta))
    onQueryChanged:selection=0
    Component.onCompleted:Native.Hyprland.refreshToplevels()
    Flickable {
        id:viewport
        FastScroll {view:viewport}
        anchors.fill:parent;clip:true;contentWidth:width;contentHeight:workspacesGrid.implicitHeight
        ScrollBar.vertical:ScrollBar {}
        Grid {
            id:workspacesGrid;columns:3;spacing:12
            Repeater {model:root.workspaces
                StyledRect {
                    id:workspace;required property int modelData
                    width:320;height:215;radius:18
                    color:drop.containsDrag?Colours.palette.m3primaryContainer:Colours.palette.m3surfaceContainer
                    readonly property var windows:root.windows.filter(c=>c.workspace?.id===modelData)
                    Row {x:12;y:12;spacing:8
                        MaterialIcon {text:BarConfig.workspaceIcons[workspace.modelData-1]??"workspaces";font.pointSize:14;color:Colours.palette.m3primary}
                        StyledText {text:workspace.modelData+" · "+(BarConfig.workspaceNames[workspace.modelData-1]??"Workspace");color:Colours.palette.m3primary}
                    }
                    MouseArea {x:0;y:0;width:parent.width;height:38;cursorShape:Qt.PointingHandCursor;onClicked:{root.visibilities.launcher=false;Hyprland.dispatch("workspace "+workspace.modelData)}}
                    GridView {
                        id:tiles;x:10;y:43;width:300;height:160;cellWidth:workspace.windows.length===1?300:150;cellHeight:workspace.windows.length<=2?160:80;clip:true
                        model:workspace.windows
                        delegate:Item {
                            id:tile;required property var modelData;width:tiles.cellWidth-5;height:tiles.cellHeight-4
                            readonly property var nativeWindow:Native.Hyprland.toplevels.values.find(t=>t.address.replace(/^0x/,"")===modelData.address.replace(/^0x/,""))
                            StyledRect {id:preview;width:tile.width;height:tile.height-22;radius:8;color:root.windows[root.selection]?.address===tile.modelData.address?Colours.palette.m3secondaryContainer:Colours.palette.m3surfaceContainerHigh
                                ScreencopyView {id:copy;anchors.centerIn:parent;constraintSize:Qt.size(preview.width-8,preview.height-8);captureSource:root.visibilities.launcher?tile.nativeWindow?.wayland??null:null;live:false;onHasContentChanged:root.previews+=hasContent?1:-1;Component.onDestruction:if(hasContent)root.previews--
                                    Timer {interval:350;repeat:true;running:root.visibilities.launcher&&DesktopSettings.data.livePreviews!==false;onTriggered:copy.captureFrame()}
                                }
                                MaterialIcon {anchors.centerIn:parent;text:"window";visible:!copy.hasContent;font.pointSize:26;color:Colours.palette.m3onSurfaceVariant}
                            }
                            StyledText {anchors.bottom:parent.bottom;width:tile.width;font.pointSize:9;elide:Text.ElideRight;text:ChatWindowTitle.titles[tile.modelData.pid]||tile.modelData.title}
                            Item {id:dragProxy}
                            MouseArea {
                                id:mouse;anchors.fill:parent;hoverEnabled:true;cursorShape:Qt.PointingHandCursor;drag.target:dragProxy
                                onEntered:root.selection=root.windows.findIndex(c=>c.address===tile.modelData.address)
                                onPositionChanged:event=>{if(drag.active){const p=mapToItem(root,event.x,event.y);ghost.x=p.x-70;ghost.y=p.y-30;}}
                                onReleased:{if(root.dragging)ghost.Drag.drop();root.dragging=false;dragProxy.x=0;dragProxy.y=0;}
                                onClicked:root.focusWindow(tile.modelData)
                                Connections {target:mouse.drag;function onActiveChanged(){if(mouse.drag.active){root.draggedAddress=tile.modelData.address;root.dragging=true;}}}
                            }
                        }
                    }
                    StyledText {anchors.centerIn:tiles;visible:workspace.windows.length===0;text:"Empty";color:Colours.palette.m3onSurfaceVariant;font.pointSize:11}
                    DropArea {id:drop;anchors.fill:parent;keys:["siverteh-window"];onDropped:drop=>{root.moveWindow(drop.source.address,workspace.modelData);drop.acceptProposedAction();}}
                }
            }
        }
    }
    StyledRect {id:ghost;parent:root;visible:root.dragging;z:20;width:140;height:60;radius:12;color:Colours.palette.m3primaryContainer;opacity:.9
        property string address:root.draggedAddress
        Drag.active:root.dragging;Drag.keys:["siverteh-window"];Drag.source:ghost;Drag.hotSpot.x:70;Drag.hotSpot.y:30
        StyledText {anchors.centerIn:parent;text:"Move window";color:Colours.palette.m3onPrimaryContainer}
    }
    IpcHandler {target:"overview";function state():string{return JSON.stringify({windows:root.windows.length,workspaces:root.workspaces.length,previews:root.previews,matches:Native.Hyprland.toplevels.values.filter(t=>root.windows.some(c=>c.address.replace(/^0x/,"")===t.address.replace(/^0x/,""))).length,previewHandles:Native.Hyprland.toplevels.values.filter(t=>t.wayland).length});}function move(address:string,workspace:int):void{root.moveWindow(address,workspace);}}
}
