import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"SettingsPages";width:900;height:350;visible:true;when:windowShown
 Component {id:settings;Settings {width:900;height:350}}
 function test_pages_keep_health_and_workflows_out_of_everyday_controls(){
  const view=createTemporaryObject(settings,test);verify(view);wait(30);
  const health=findChild(view,"settingsHealth");const workflows=findChild(view,"settingsPresets");const displays=findChild(view,"settingsDisplays");
  verify(displays.visible);verify(!health.visible);verify(!workflows.visible);
  view.page="maintenance";wait(30);verify(health.visible);verify(!displays.visible);verify(!workflows.visible);
  view.page="workflows";wait(30);verify(workflows.visible);verify(!health.visible);verify(!displays.visible);
 }
 function test_shared_wheel_glides_and_page_switch_resets_position(){
  const view=createTemporaryObject(settings,test);wait(30);const scroll=findChild(view,"settingsScroll");verify(scroll.contentHeight>scroll.height);
  const limit=scroll.contentHeight-scroll.height;mouseWheel(scroll,600,80,0,-120);wait(100);verify(scroll.contentY>0);wait(220);verify(Math.abs(scroll.contentY-Math.min(limit,480))<2);
  view.page="appearance";wait(30);compare(scroll.contentY,0);
 }
}
