import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls
Item {
    id:root
    required property PersistentProperties visibilities
    required property ShellScreen screen
    property bool captureOpen:false
    property real refreshedAt:0
    visible:width>0;clip:true
    implicitWidth:visibilities.left?390:0;implicitHeight:Math.min(780,screen.height-150)
    Behavior on implicitWidth {NumberAnimation {duration:Appearance.anim.durations.normal;easing.type:Easing.InOutCubic}}
    Connections {target:root.visibilities;function onLeftChanged(){if(root.visibilities.left&&Date.now()-root.refreshedAt>60000){root.refreshedAt=Date.now();DesktopExtras.request("chats",{});}}}
    Flickable {
        width:390;height:parent.height;contentWidth:width;contentHeight:content.implicitHeight+32;clip:true
        ScrollBar.vertical:ScrollBar {}
        Column {
            id:content;x:16;y:16;width:358;spacing:12
            Row {spacing:10
                ShLogo {implicitWidth:30;implicitHeight:30}
                StyledText {text:"AI & brain";width:130;anchors.verticalCenter:parent.verticalCenter;font.pointSize:17;color:Colours.palette.m3primary}
                ActionButton {text:"";icon:"push_pin";selected:root.visibilities.leftPinned;onClicked:root.visibilities.leftPinned=!selected}
                ActionButton {text:"";icon:"close";onClicked:{root.visibilities.left=false;root.visibilities.leftPinned=false;}}
            }
            Row {spacing:8
                ActionButton {text:"New chat";icon:"add";onClicked:DesktopActions.execute("new")}
                ActionButton {text:"Resume latest";icon:"history";onClicked:DesktopActions.execute("resume")}
            }
            StyledTextField {id:search;width:358;height:42;leftPadding:13;rightPadding:13;placeholderText:"Search your brain";text:DesktopExtras.brainQuery
                background:StyledRect {color:Colours.palette.m3surfaceContainerHigh;radius:21}
                onPressed:root.visibilities.leftPinned=true
                onActiveFocusChanged:if(activeFocus)root.visibilities.leftPinned=true
                onTextChanged:{DesktopExtras.brainQuery=text;DesktopExtras.notes=[];searchDelay.restart();}
                Connections {target:DesktopExtras;function onBrainQueryChanged(){if(search.text!==DesktopExtras.brainQuery)search.text=DesktopExtras.brainQuery;}}
                Timer {id:searchDelay;interval:250;onTriggered:DesktopExtras.request("brain",{query:search.text})}
            }
            Row {spacing:8
                ActionButton {text:"Open brain";icon:"neurology";onClicked:DesktopActions.execute("brain")}
                ActionButton {text:"Capture";icon:"edit_note";selected:root.captureOpen;onClicked:{root.captureOpen=!selected;root.visibilities.leftPinned=true;if(root.captureOpen)capture.forceActiveFocus();}}
            }
            Column {width:358;spacing:8;visible:root.captureOpen
                TextArea {id:capture;width:358;height:105;placeholderText:"A thought worth keeping";wrapMode:TextEdit.Wrap;color:Colours.palette.m3onSurface;placeholderTextColor:Colours.palette.m3onSurfaceVariant;selectionColor:Colours.palette.m3primary;selectedTextColor:Colours.palette.m3onPrimary
                    background:StyledRect {color:Colours.palette.m3surfaceContainerHigh;radius:12}
                    onActiveFocusChanged:if(activeFocus)root.visibilities.leftPinned=true
                }
                ActionButton {text:"Save to brain";icon:"save";enabled:capture.text.trim().length>0&&!DesktopExtras.busy.capture;onClicked:{DesktopExtras.captured="";DesktopExtras.request("capture",{text:capture.text});}}
                Connections {target:DesktopExtras;function onCapturedChanged(){if(DesktopExtras.captured){capture.text="";root.captureOpen=false;}}}
            }
            StyledText {width:358;wrapMode:Text.WordWrap;visible:DesktopExtras.message.length>0||DesktopExtras.captured.length>0;text:DesktopExtras.message||DesktopExtras.captured;color:Colours.palette.m3onSurfaceVariant;font.pointSize:11}
            Column {width:358;spacing:8;visible:search.text.trim().length>0
                StyledText {text:DesktopExtras.busy.brain?"Searching…":"Knowledge";color:Colours.palette.m3primary}
                Repeater {model:DesktopExtras.notes
                    StyledRect {id:note;required property var modelData;width:358;height:115;radius:13;color:Colours.palette.m3surfaceContainer
                        Column {anchors.fill:parent;anchors.margins:10;spacing:5
                            StyledText {width:338;elide:Text.ElideRight;text:note.modelData.title;textFormat:Text.PlainText;font.pointSize:11}
                            StyledText {width:338;height:32;wrapMode:Text.Wrap;maximumLineCount:2;elide:Text.ElideRight;text:note.modelData.preview;textFormat:Text.PlainText;font.pointSize:9;color:Colours.palette.m3onSurfaceVariant}
                            Row {spacing:8
                                ActionButton {text:"Read note";onClicked:DesktopExtras.request("note",{path:note.modelData.path})}
                                ActionButton {text:"Explore";onClicked:{root.visibilities.left=false;root.visibilities.leftPinned=false;DesktopExtras.request("explore",{path:note.modelData.path});}}
                            }
                        }
                    }
                }
                StyledText {text:"No matching notes";visible:DesktopExtras.notes.length===0&&!DesktopExtras.busy.brain;color:Colours.palette.m3onSurfaceVariant}
            }
            Column {width:358;spacing:8;visible:search.text.trim().length===0
                StyledText {text:"Open chats";color:Colours.palette.m3primary}
                Repeater {model:Hyprland.clients.filter(c=>c.wmClass==="siverteh-ai-task")
                    ChatCard {required property var modelData;label:ChatWindowTitle.titles[modelData.pid]||modelData.title;detail:"Workspace "+modelData.workspace?.id;onClicked:{root.visibilities.left=false;root.visibilities.leftPinned=false;Hyprland.dispatch('hl.dsp.focus({window='+JSON.stringify('address:'+modelData.address)+'})');}}
                }
                Row {spacing:8
                    StyledText {text:"Recent chats";width:195;anchors.verticalCenter:parent.verticalCenter;color:Colours.palette.m3primary}
                    ActionButton {text:"Refresh";icon:"refresh";enabled:!DesktopExtras.busy.chats;onClicked:DesktopExtras.request("chats",{})}
                }
                StyledText {visible:!!DesktopExtras.busy.chats;text:"Reading saved chats…";font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
                Repeater {model:DesktopExtras.chats.filter(c=>!Object.values(ChatWindowTitle.threadIds).includes(c.id)).slice(0,6)
                    ChatCard {required property var modelData;label:modelData.title;detail:modelData.agent+" · "+modelData.account+" · "+modelData.state;onClicked:{root.visibilities.left=false;root.visibilities.leftPinned=false;DesktopExtras.request("resume",{key:modelData.key});}}
                }
                ActionButton {text:"All saved chats";icon:"forum";onClicked:DesktopActions.execute("load")}
            }
        }
    }
    component ChatCard:StyledRect {
        id:card;property string label;property string detail;signal clicked()
        width:358;height:55;radius:12;color:Colours.palette.m3surfaceContainer
        Column {anchors.fill:parent;anchors.margins:9;spacing:2
            StyledText {width:338;elide:Text.ElideRight;text:card.label;textFormat:Text.PlainText;font.pointSize:11}
            StyledText {text:card.detail;font.pointSize:9;color:Colours.palette.m3onSurfaceVariant}
        }
        StateLayer {function onClicked(){card.clicked()}}
    }
}
