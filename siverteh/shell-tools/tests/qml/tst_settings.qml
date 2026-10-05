import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"SettingsControlCenter";width:1120;height:300;visible:true;when:windowShown
 Component {id:settings;Settings {width:1120;height:300;page:"desktop"}}
 function test_pages_search_and_visible_only_loading(){
  const view=createTemporaryObject(settings,test);verify(view);wait(30);
  const loader=findChild(view,"settingsPage");verify(loader.item);compare(loader.item.page,"desktop");
  view.query="microphone";wait(20);verify(!loader.active);compare(view.matches.length,1);compare(view.matches[0].id,"sound");
  view.open("sound");wait(30);verify(loader.item);compare(view.page,"sound");compare(view.query,"");
  view.active=false;wait(20);verify(!loader.active);verify(!loader.item);
 }
 function test_shared_wheel_glides_and_page_switch_resets_position(){
  const view=createTemporaryObject(settings,test);wait(30);const scroll=findChild(view,"settingsScroll");verify(scroll.contentHeight>scroll.height);
  const limit=scroll.contentHeight-scroll.height;mouseWheel(scroll,600,80,0,-120);wait(100);verify(scroll.contentY>0);wait(220);verify(Math.abs(scroll.contentY-Math.min(limit,480))<2);
  view.open("maintenance");wait(30);compare(scroll.contentY,0);
 }
 function test_all_device_and_lock_pages_load_without_warnings(){
  const view=createTemporaryObject(settings,test);wait(20);
  for(const page of ["displays","network","bluetooth","notifications","workflows","lock","ai","maintenance"]){view.open(page);wait(20);verify(findChild(view,"settingsPage").item,page);}
 }
}
