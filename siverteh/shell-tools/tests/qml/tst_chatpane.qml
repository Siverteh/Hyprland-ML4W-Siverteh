import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"SidebarComposer";width:460;height:700;visible:true;when:windowShown
 Component {id:pane;ChatPane {width:460;height:700;visibilities:({leftPinned:true})}}
 function init(){SidebarChat.draft="";SidebarChat.busy=false;SidebarChat.sends=0;SidebarChat.stops=0;SidebarChat.question=null;SidebarChat.answers={};SidebarChat.messages.clear();SidebarChat.replies=0}
 function test_long_draft_scrolls_and_cursor_stays_visible(){
  const view=createTemporaryObject(pane,test);verify(view);const input=findChild(view,"sidebarComposer");const scroll=findChild(view,"sidebarComposerScroll");verify(input);verify(scroll)
  input.text=Array(80).fill("Long message line to verify scrolling").join("\n");input.forceActiveFocus();input.cursorPosition=input.length;wait(200)
  verify(scroll.height<=160);verify(scroll.contentHeight>scroll.height);verify(scroll.contentItem.contentY>0)
  const cursor=input.cursorRectangle;verify(cursor.y-scroll.contentItem.contentY>=0);verify(cursor.y-scroll.contentItem.contentY+cursor.height<=scroll.height+2)
  const transcript=findChild(view,"sidebarTranscript");verify(transcript.height>250)
 }
 function test_enter_sends_while_busy_and_shift_enter_adds_newline(){
  const view=createTemporaryObject(pane,test);verify(view);const input=findChild(view,"sidebarComposer");SidebarChat.busy=true
  input.text="Follow up now";input.forceActiveFocus();keyClick(Qt.Key_Return);compare(SidebarChat.sends,1);compare(SidebarChat.lastText,"Follow up now");compare(input.text,"");SidebarChat.draft="Recovered draft";compare(input.text,"Recovered draft")
  input.text="Two lines";keyClick(Qt.Key_Return,Qt.ShiftModifier);compare(SidebarChat.sends,1);verify(input.text.indexOf("\n")>=0)
 }
 function test_question_cards_accept_free_text_and_stay_bounded(){
  const view=createTemporaryObject(pane,test);verify(view)
  SidebarChat.question={id:"card",questions:[{id:"0",question:"A question with a choice",options:[{label:"First"},{label:"Second"}]},{id:"1",question:"Another question",options:[]}]};wait(50)
  const questions=findChild(view,"sidebarQuestions");const reply=findChild(view,"sidebarReply");verify(questions.visible);verify(questions.height<=240);verify(!reply.enabled)
  const first=findChild(view,"questionAnswer-0");const second=findChild(view,"questionAnswer-1");first.text="Custom choice";second.text="My answer";verify(reply.enabled,"answers="+JSON.stringify(SidebarChat.answers));reply.clicked();compare(SidebarChat.replies,1)
  SidebarChat.question=null;wait(20);compare(questions.height,0)
 }
 function test_chat_wheel_moves_330_pixels_per_notch(){
  for(let i=0;i<80;i++)SidebarChat.messages.append({id:String(i),role:"assistant",text:"A transcript message to make the list scrollable."})
  const view=createTemporaryObject(pane,test);verify(view);wait(100)
  const transcript=findChild(view,"sidebarTranscript");transcript.follow=false;transcript.contentY=transcript.originY;wait(20)
  const before=transcript.contentY;mouseWheel(transcript,230,80,0,-120);wait(150);verify(transcript.contentY-before>=329,"scroll delta="+(transcript.contentY-before));verify(transcript.contentY-before<=331)
 }

 Component {id:roundButton;Rectangle {width:80;height:80;radius:40;color:"white";StateLayer {objectName:"roundHover"}}}
 function test_hover_layer_follows_round_button_shape(){
  const button=createTemporaryObject(roundButton,test);verify(button);const layer=findChild(button,"roundHover");compare(layer.radius,40)
  mouseMove(button,40,40);wait(20);verify(layer.hovered);compare(layer.radius,button.radius)
  button.radius=17;compare(layer.radius,17)
 }

}