import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls
Item {
    id:root
    implicitWidth:900;implicitHeight:Math.min(content.implicitHeight,Math.max(360,Quickshell.screens[0].height-210))
    property string primary:DesktopSettings.monitors[0]?.name??""
    Flickable {
        anchors.fill:parent;clip:true;contentWidth:width;contentHeight:content.implicitHeight;flickableDirection:Flickable.VerticalFlick
        ScrollBar.vertical:ScrollBar {}
        Column {
            id:content;width:parent.width;spacing:16
            StyledText {
                visible:DesktopSettings.message.length>0&&DesktopSettings.message!=="Changes save automatically"
                text:DesktopSettings.message
                width:parent.width;wrapMode:Text.WordWrap;color:Colours.palette.m3error
            }
            Section {width:900;heading:"Desktop presets"
                Row {spacing:10
                    Repeater {model:["normal","focused","presentation","minimal"]
                        Action {required property string modelData;label:modelData.charAt(0).toUpperCase()+modelData.slice(1);selected:(DesktopSettings.data.preset??"normal")===modelData;onActivated:DesktopSettings.request(["preset",modelData])}
                    }
                }
            }
            StyledRect {
                width:900;height:DesktopSettings.pending?175:140;radius:17;color:Colours.palette.m3surfaceContainer
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
            Row {spacing:16
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
            Row {spacing:16
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
                width:900;heading:"Desktop frame"
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
