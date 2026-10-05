import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls
Item {
    id:root
    implicitWidth:900;implicitHeight:Math.min(content.implicitHeight+navigation.height+16,Math.max(360,Quickshell.screens[0].height-210))
    property string page:"desktop"
    onPageChanged:{settingsWheel.cancel();settingsScroll.contentY=0;rollbackConfirm.visible=false;}
    Row {
        id:navigation;objectName:"settingsNavigation";width:parent.width;spacing:8
        Repeater {model:[{id:"desktop",title:"Desktop"},{id:"appearance",title:"Appearance"},{id:"workflows",title:"Workflows"},{id:"maintenance",title:"Maintenance"}]
            Action {required property var modelData;label:modelData.title;selected:root.page===modelData.id;onActivated:root.page=modelData.id}
        }
    }
    property var workflowRoles:[]
    property string primary:DesktopSettings.monitors[0]?.name??""
    Flickable {
        id:settingsScroll;objectName:"settingsScroll"
        FastScroll {id:settingsWheel;view:settingsScroll}
        anchors.top:navigation.bottom;anchors.topMargin:16;anchors.bottom:parent.bottom;anchors.left:parent.left;anchors.right:parent.right;clip:true;contentWidth:width;contentHeight:content.implicitHeight;flickableDirection:Flickable.VerticalFlick
        ScrollBar.vertical:ScrollBar {}
        Column {
            id:content;width:parent.width;spacing:16
            StyledText {
                visible:DesktopSettings.message.length>0&&DesktopSettings.message!=="Changes save automatically"
                text:DesktopSettings.message
                width:parent.width;wrapMode:Text.WordWrap;color:Colours.palette.m3error
            }
            Section {objectName:"settingsHealth";width:parent.width;visible:root.page==="maintenance";heading:"Desktop health"
                StyledText {width:parent.width;text:"Installed release: "+(Maintenance.data.release?.revision??"Unrecorded").slice(0,12);color:Colours.palette.m3onSurfaceVariant}
                Flow {width:parent.width;spacing:16
                    Repeater {model:Object.entries(Maintenance.data.services??{})
                        StyledText {required property var modelData;text:({"siverteh-os-shell.service":"Desktop","siverteh-sidebar-ai.service":"AI chat","siverteh-observatory-brain.service":"Brain","siverteh-session-watch.service":"Session monitor"}[modelData[0]]??modelData[0])+": "+modelData[1];color:modelData[1]==="active"?Colours.palette.m3onSurfaceVariant:Colours.palette.m3error}
                    }
                }
                StyledText {width:parent.width;wrapMode:Text.Wrap;text:(Maintenance.data.configErrors||"Compositor configuration is valid")+" · "+(Maintenance.data.drift??[]).length+" locally changed managed files";color:Maintenance.data.configErrors?Colours.palette.m3error:Colours.palette.m3onSurfaceVariant}
                StyledText {width:parent.width;wrapMode:Text.Wrap;text:Maintenance.data.performance?.cpuCorePercent!==undefined?"Last sample: "+Maintenance.data.performance.cpuCorePercent+"% of one core · "+Maintenance.data.performance.memoryMiB+" MiB ("+Maintenance.data.performance.label+")":"No performance sample yet"}
                StyledText {width:parent.width;wrapMode:Text.Wrap;text:"Session: "+(Maintenance.data.session?.event??"not checked")+" · Wallet: "+(Maintenance.data.session?.wallet??"unknown")+" · Update cache: "+(Maintenance.data.updatesAgeSeconds===null?"not available":Math.round((Maintenance.data.updatesAgeSeconds??0)/60)+" minutes old")}
                Flow {width:parent.width;spacing:8
                    Action {label:"Refresh status";enabled:!Maintenance.busy;onActivated:Maintenance.refresh()}
                    Action {label:"Sample resource use";enabled:!Maintenance.busy;onActivated:Maintenance.request("profile")}
                    Action {label:"Check session";enabled:!Maintenance.busy;onActivated:Maintenance.request("session")}
                    Action {label:"Restart desktop";onActivated:Maintenance.recover("restart")}
                    Action {label:"Restore previous release";enabled:!!Maintenance.data.release?.release;onActivated:rollbackConfirm.visible=true}
                }
                Row {id:rollbackConfirm;visible:false;spacing:8
                    StyledText {text:"Restore the previous desktop release?";anchors.verticalCenter:parent.verticalCenter}
                    Action {label:"Restore";onActivated:{rollbackConfirm.visible=false;Maintenance.recover("rollback")}}
                    Action {label:"Cancel";onActivated:rollbackConfirm.visible=false}
                }
                StyledText {width:parent.width;wrapMode:Text.Wrap;text:Maintenance.message;visible:text.length>0;color:Colours.palette.m3onSurfaceVariant}
            }
            Section {objectName:"settingsPresets";width:parent.width;visible:root.page==="workflows";heading:"Desktop presets"
                Flow {width:parent.width;spacing:10
                    Repeater {model:["normal","focused","presentation","minimal","meeting","music","docked"]
                        Action {required property string modelData;label:modelData.charAt(0).toUpperCase()+modelData.slice(1);selected:(DesktopSettings.data.preset??"normal")===modelData;onActivated:DesktopSettings.request(["preset",modelData])}
                    }
                }
            }
            Section {width:parent.width;visible:root.page==="workflows";heading:"Personal workflow setup"
                StyledText {width:parent.width;wrapMode:Text.Wrap;text:"Save your current audio devices and display layout for the selected preset. Only connected devices are recalled; microphone mute stays unchanged."}
                Action {label:"Save current audio and display setup";onActivated:DesktopSettings.request(["save-workflow",DesktopSettings.data.preset??"normal",JSON.stringify(root.workflowRoles)])}
                Flow {width:parent.width;spacing:8
                    Repeater {model:["Browser","Siverteh AI","Discord","Spotify","Mail","Brain"]
                        Action {required property string modelData;label:modelData;selected:root.workflowRoles.includes(modelData);onActivated:root.workflowRoles=selected?root.workflowRoles.filter(name=>name!==modelData):[...root.workflowRoles,modelData]}
                    }
                }
            }
            StyledRect {
                objectName:"settingsDisplays";visible:root.page==="desktop";width:parent.width;height:DesktopSettings.pending?175:140;radius:17;color:Colours.palette.m3surfaceContainer
                Column {anchors.fill:parent;anchors.margins:16;spacing:12
                    StyledText {text:"Displays";font.weight:500}
                    Row {spacing:10
                        StyledText {text:DesktopSettings.monitors.length<2?"Connect a second screen to extend or mirror your desktop.":"Main screen";anchors.verticalCenter:parent.verticalCenter;color:Colours.palette.m3onSurfaceVariant}
                        Repeater {model:DesktopSettings.monitors.length>1?DesktopSettings.monitors:[]
                            Action {required property var modelData;label:modelData.name;selected:root.primary===modelData.name;onActivated:root.primary=modelData.name}
                        }
                    }
                    Row {spacing:10
                        Action {label:"Extend right";enabled:DesktopSettings.monitors.length>1&&!DesktopSettings.pending;onActivated:DesktopSettings.request(["display","extend-right",root.primary])}
                        Action {label:"Extend left";enabled:DesktopSettings.monitors.length>1&&!DesktopSettings.pending;onActivated:DesktopSettings.request(["display","extend-left",root.primary])}
                        Action {label:"Mirror";enabled:DesktopSettings.monitors.length>1&&!DesktopSettings.pending;onActivated:DesktopSettings.request(["display","mirror",root.primary])}
                        StyledText {text:DesktopSettings.monitors.map(m=>m.name+" · "+m.width+"×"+m.height).join("   ");font.pointSize:10;anchors.verticalCenter:parent.verticalCenter;color:Colours.palette.m3onSurfaceVariant}
                    }
                    Row {visible:DesktopSettings.pending;spacing:10
                        Action {label:"Keep layout";selected:true;onActivated:DesktopSettings.request(["confirm"])}
                        Action {label:"Revert";onActivated:DesktopSettings.request(["revert"])}
                        StyledText {text:"Reverts after 20 seconds unless kept";anchors.verticalCenter:parent.verticalCenter}
                    }
                }
            }
            Row {visible:root.page==="desktop";spacing:16
                Section {heading:"Windows & spacing"
                    NumberSetting {label:"Space between windows";setting:"gapsIn";maximum:30}
                    NumberSetting {label:"Space from screen edges";setting:"gapsOut";maximum:80}
                    NumberSetting {label:"Window border width";setting:"borderSize";maximum:8}
                    NumberSetting {label:"Window corner radius";setting:"rounding";maximum:40}
                }
                Section {heading:"Effects & input"
                    Toggle {label:"Animations";setting:"animations"}
                    Toggle {label:"Background blur";setting:"blur"}
                    Toggle {label:"Window shadows";setting:"shadow"}
                    Toggle {label:"Focus follows pointer";setting:"followMouse"}
                    Toggle {label:"Natural touchpad scrolling";setting:"naturalScroll"}
                }
            }
            Row {visible:root.page==="appearance";spacing:16
                Section {heading:"Desktop panels"
                    Toggle {label:"Left-edge hover drawer";setting:"leftDrawer"}
                    Toggle {label:"Native command palette";setting:"nativePalette"}
                    Toggle {label:"Native window overview";setting:"nativeOverview"}
                    Toggle {label:"Native clipboard panel";setting:"nativeClipboard"}
                }
                Section {heading:"Desktop behavior"
                    Toggle {label:"Live window previews";setting:"livePreviews"}
                    Toggle {label:"Do not disturb";setting:"dnd"}
                }
            }
            Section {
                visible:root.page==="appearance";width:parent.width;heading:"Desktop frame"
                Row {spacing:12
                    Action {label:"Top bar";selected:DesktopSettings.data.topEdge!==false;onActivated:DesktopSettings.set("topEdge",!selected)}
                    Action {label:"Left edge";selected:DesktopSettings.data.leftEdge!==false;onActivated:DesktopSettings.set("leftEdge",!selected)}
                    Action {label:"Right edge";selected:DesktopSettings.data.rightEdge!==false;onActivated:DesktopSettings.set("rightEdge",!selected)}
                    Action {label:"Bottom edge";selected:DesktopSettings.data.bottomEdge!==false;onActivated:DesktopSettings.set("bottomEdge",!selected)}
                }
                Row {spacing:24
                    NumberSetting {width:420;label:"Frame thickness";setting:"frameWidth";maximum:30}
                    NumberSetting {width:420;label:"Frame corner radius";setting:"frameRounding";maximum:40}
                }
            }
        }
    }
    component Action:StyledRect {
        id:action
        property string label
        property bool selected:false
        signal activated()
        implicitWidth:Math.max(100,title.implicitWidth+26);implicitHeight:34;radius:17;opacity:enabled?1:.4
        color:selected?Colours.palette.m3primary:Colours.palette.m3surfaceContainerHigh
        StyledText {id:title;anchors.centerIn:parent;text:action.label;color:action.selected?Colours.palette.m3onPrimary:Colours.palette.m3onSurface}
        StateLayer {function onClicked(){action.activated()}}
    }
    component Section:StyledRect {
        id:section
        property string heading
        default property alias contents:stack.data
        width:442;implicitHeight:stack.implicitHeight+32;radius:17;color:Colours.palette.m3surfaceContainer
        Column {id:stack;anchors.left:parent.left;anchors.right:parent.right;anchors.top:parent.top;anchors.margins:16;spacing:12
            StyledText {text:section.heading;font.weight:500;color:Colours.palette.m3primary}
        }
    }
    component Toggle:Item {
        id:toggle
        property string label
        property string setting
        readonly property bool checked:DesktopSettings.data[setting]===true
        width:parent.width;height:36
        StyledText {text:toggle.label;anchors.verticalCenter:parent.verticalCenter}
        StyledRect {anchors.right:parent.right;anchors.verticalCenter:parent.verticalCenter;width:48;height:26;radius:13;color:toggle.checked?Colours.palette.m3primary:Colours.palette.m3surfaceContainerHighest
            Rectangle {x:toggle.checked?25:3;y:3;width:20;height:20;radius:10;color:toggle.checked?Colours.palette.m3onPrimary:Colours.palette.m3onSurfaceVariant}
        }
        MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor;onClicked:DesktopSettings.set(toggle.setting,!toggle.checked)}
    }
    component NumberSetting:Column {
        id:number
        property string label
        property string setting
        property int maximum:40
        width:parent.width;spacing:3
        Row {width:parent.width
            StyledText {width:parent.width-55;text:number.label}
            StyledText {width:55;horizontalAlignment:Text.AlignRight;text:Math.round(control.value)+" px";color:Colours.palette.m3primary}
        }
        Slider {
            id:control;width:parent.width;height:25;from:0;to:number.maximum;stepSize:1
            value:DesktopSettings.data[number.setting]??0
            onMoved:if(!pressed)DesktopSettings.set(number.setting,Math.round(value))
            onPressedChanged:if(!pressed)DesktopSettings.set(number.setting,Math.round(value))
            background:Rectangle {x:control.leftPadding;y:control.topPadding+control.availableHeight/2-height/2;width:control.availableWidth;height:4;radius:2;color:Colours.palette.m3surfaceContainerHighest
                Rectangle {width:control.visualPosition*parent.width;height:parent.height;radius:2;color:Colours.palette.m3primary}
            }
            handle:Rectangle {x:control.leftPadding+control.visualPosition*(control.availableWidth-width);y:control.topPadding+control.availableHeight/2-height/2;width:16;height:16;radius:8;color:Colours.palette.m3primary}
        }
    }
}
