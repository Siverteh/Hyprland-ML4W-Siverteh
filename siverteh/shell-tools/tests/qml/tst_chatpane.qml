import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"SidebarComposer";width:460;height:700;when:windowShown
 Component {id:pane;ChatPane {width:460;height:700;visibilities:({leftPinned:true})}}
 function init(){SidebarChat.draft="";SidebarChat.busy=false;SidebarChat.sends=0;SidebarChat.stops=0}
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
}