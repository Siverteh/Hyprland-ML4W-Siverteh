import "root:/widgets"
import "root:/services"
import QtQuick
import QtQuick.Controls
import Quickshell
Item {
    id:root
    required property PersistentProperties visibilities
    property bool active:false
    onActiveChanged:if(active){SidebarChat.start();if(transcript.follow)transcript.latest();}
    Component.onCompleted:transcript.latest()
    Column {
        id:tools;anchors.top:parent.top;width:parent.width;spacing:7
        Row {spacing:8
            ActionButton {text:"New chat";icon:"add_comment";enabled:!SidebarChat.busy;onClicked:SidebarChat.newChat()}
            ActionButton {text:"Workspace";icon:"open_in_new";enabled:!SidebarChat.busy&&SidebarChat.threadId.length>0;onClicked:SidebarChat.workspace()}
        }
        StyledText {width:parent.width;elide:Text.ElideRight;text:(SidebarChat.provider?SidebarChat.provider.charAt(0).toUpperCase()+SidebarChat.provider.slice(1):"Assistant")+" · "+SidebarChat.title;color:Colours.palette.m3onSurfaceVariant;font.pointSize:10}
    }
    ListView {
        id:transcript;objectName:"sidebarTranscript";anchors.top:tools.bottom;anchors.bottom:footer.top;anchors.left:parent.left;anchors.right:parent.right;anchors.topMargin:12;anchors.bottomMargin:10
        model:SidebarChat.messages;clip:true;spacing:12;cacheBuffer:100
        ScrollBar.vertical:ScrollBar {onPressedChanged:{if(pressed){wheel.cancel();transcript.follow=false;}else if(!transcript.restoring)transcript.follow=transcript.nearBottom();}}
        FastScroll {id:wheel;objectName:"sidebarWheel";view:transcript;step:480;pixelMultiplier:2.4;smoothDuration:260;kinetic:true;onScrolled:transcript.follow=false;onSettled:if(!transcript.restoring)transcript.follow=transcript.nearBottom()}
        boundsBehavior:Flickable.StopAtBounds;maximumFlickVelocity:4000;flickDeceleration:6500
        property bool follow:true
        property bool restoring:false
        property var savedPosition:({})
        function nearBottom(){return contentHeight<=height||originY+contentHeight-height-contentY<48;}
        function latest(){
            if(wheel)wheel.cancel();follow=true;
            Qt.callLater(()=>{if(follow&&!restoring){forceLayout();positionViewAtEnd();}});
        }
        function savePosition(){
            const bottom=follow||nearBottom();let index=indexAt(12,contentY+1);
            if(index<0)index=indexAt(12,contentY+16);
            const item=index>=0?itemAtIndex(index):null;
            savedPosition={bottom:bottom,id:index>=0?SidebarChat.messages.get(index).id:"",offset:item?contentY-item.y:0,y:contentY-originY};
            restoring=true;wheel.cancel();
        }
        function restorePosition(){
            Qt.callLater(()=>{
                forceLayout();follow=!!savedPosition.bottom;
                if(follow)positionViewAtEnd();
                else {
                    const index=SidebarChat.itemIndex(savedPosition.id);
                    if(index>=0){positionViewAtIndex(index,ListView.Beginning);forceLayout();const item=itemAtIndex(index);if(item)contentY=item.y+savedPosition.offset;}
                    else contentY=originY+Math.min(savedPosition.y,Math.max(0,contentHeight-height));
                }
                restoring=false;
                if(follow)Qt.callLater(()=>{if(follow&&!restoring){forceLayout();positionViewAtEnd();}});
            });
        }
        onDraggingChanged:if(dragging)follow=false
        onContentHeightChanged:if(follow&&!restoring)Qt.callLater(()=>{if(follow&&!restoring){forceLayout();positionViewAtEnd();}})
        onHeightChanged:if(follow&&!restoring)latest()
        delegate:StyledRect {
            id:bubble
            required property string role
            required property string text
            width:transcript.width;implicitHeight:message.implicitHeight+45;radius:13
            color:role==="user"?Colours.palette.m3secondaryContainer:Colours.palette.m3surfaceContainer
            StyledText {x:12;y:9;text:bubble.role==="user"?"You":"Siverteh AI";font.pointSize:9;color:Colours.palette.m3primary}
            TextEdit {id:message;x:12;y:29;width:parent.width-24;text:bubble.text;readOnly:true;selectByMouse:true;wrapMode:TextEdit.Wrap;textFormat:TextEdit.PlainText
                color:Colours.palette.m3onSurface;font.family:"IBM Plex Sans";font.pointSize:12;selectionColor:Colours.palette.m3primary;selectedTextColor:Colours.palette.m3onPrimary
            }
        }
        StyledText {anchors.centerIn:parent;visible:transcript.count===0;text:"Start a conversation";color:Colours.palette.m3onSurfaceVariant}
    }
    Connections {target:SidebarChat;function onHistoryReplacing(){transcript.savePosition();}function onHistoryReplaced(){transcript.restorePosition();}function onThreadIdChanged(){transcript.savedPosition={bottom:true};transcript.latest();}}
    Column {
        id:footer;anchors.bottom:parent.bottom;width:parent.width;spacing:8
        StyledText {width:parent.width;wrapMode:Text.Wrap;visible:SidebarChat.error.length>0||SidebarChat.status.length>0;text:SidebarChat.error||SidebarChat.status;color:SidebarChat.error?Colours.palette.m3error:Colours.palette.m3onSurfaceVariant;font.pointSize:10}
        ScrollView {
            id:questionScroll;objectName:"sidebarQuestions";width:parent.width
            height:visible?Math.min(240,root.height*0.35,Math.max(80,questionColumn.implicitHeight)):0
            visible:SidebarChat.question!==null;clip:true
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            ScrollBar.vertical.policy:ScrollBar.AsNeeded
            Column {id:questionColumn;width:questionScroll.availableWidth;spacing:10
            Repeater {model:SidebarChat.question?.questions??[]
                Column {id:q;required property var modelData;width:parent.width;spacing:6
                    StyledText {width:parent.width;wrapMode:Text.Wrap;text:q.modelData.question}
                    Flow {width:parent.width;spacing:5
                        Repeater {model:q.modelData.options??[]
                            ActionButton {required property var modelData;text:modelData.label;selected:SidebarChat.answers[q.modelData.id]?.answers?.[0]===text;onClicked:SidebarChat.setAnswer(q.modelData.id,text)}
                        }
                    }
                    StyledTextField {objectName:"questionAnswer-"+q.modelData.id;width:parent.width;height:35;placeholderText:"Your answer";leftPadding:10;background:StyledRect {radius:10;color:Colours.palette.m3surfaceContainerHigh} onPressed:root.visibilities.leftPinned=true;onTextChanged:SidebarChat.setAnswer(q.modelData.id,text)}
                }
            }
            ActionButton {objectName:"sidebarReply";text:"Reply";enabled:!SidebarChat.inWorkspace&&SidebarChat.question!==null&&SidebarChat.question.questions.every(q=>(SidebarChat.answers[q.id]?.answers?.[0]??"").trim().length>0);onClicked:SidebarChat.answer()}
        }
        }
        ScrollView {
            id:composer;objectName:"sidebarComposerScroll";width:parent.width;height:Math.min(160,Math.max(100,input.implicitHeight));clip:true
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            ScrollBar.vertical.policy:ScrollBar.AsNeeded
            TextArea {
                id:input;objectName:"sidebarComposer";enabled:!SidebarChat.inWorkspace;width:composer.availableWidth;wrapMode:TextEdit.Wrap
                text:SidebarChat.draft
                onTextChanged:if(SidebarChat.draft!==text)SidebarChat.draft=text
                placeholderText:SidebarChat.inWorkspace?"Chat moved to the workspace":SidebarChat.busy?"Add a message while I work":"Message Siverteh AI"
                color:Colours.palette.m3onSurface;placeholderTextColor:Colours.palette.m3onSurfaceVariant
                selectionColor:Colours.palette.m3primary;selectedTextColor:Colours.palette.m3onPrimary;font.family:"IBM Plex Sans";font.pointSize:12
                background:StyledRect {radius:14;color:Colours.palette.m3surfaceContainerHigh}
                TapHandler {onTapped:root.visibilities.leftPinned=true}
                Keys.onReturnPressed:event=>{if(event.modifiers&Qt.ShiftModifier){event.accepted=false;}else{root.send();event.accepted=true;}}
            }
        }
        Connections {target:SidebarChat;function onDraftChanged(){if(input.text!==SidebarChat.draft)input.text=SidebarChat.draft;}}
        Row {spacing:8
            ActionButton {text:"Send";icon:"arrow_upward";selected:true;enabled:!SidebarChat.inWorkspace&&input.text.trim().length>0;onClicked:root.send()}
            ActionButton {text:"Stop";icon:"stop";visible:SidebarChat.busy;onClicked:SidebarChat.stop()}
            ActionButton {text:"Latest";icon:"arrow_downward";onClicked:{transcript.latest();}}
        }
    }
    function send(){if(!SidebarChat.inWorkspace&&input.text.trim()){root.visibilities.leftPinned=true;transcript.latest();SidebarChat.send(input.text);SidebarChat.draft="";input.text="";}}
}
