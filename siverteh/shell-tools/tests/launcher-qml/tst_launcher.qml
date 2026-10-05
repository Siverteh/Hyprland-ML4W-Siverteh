import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"CategorizedLauncher";width:980;height:570;visible:true;when:windowShown
 Component {id:launcher;AppGrid {width:980;height:implicitHeight;visibilities:QtObject {property bool launcher:true}}}
 function init(){LauncherPreferences.favorites=[];LauncherPreferences.hidden=[];}
 function test_category_browsing_and_global_search(){
  const view=createTemporaryObject(launcher,test);wait(30);compare(view.category,"favorites");compare(view.entries.length,0);view.select("all");compare(view.entries.length,3);verify(!view.categories.some(c=>c.id==="games"));
  view.select("development");compare(view.entries.length,1);compare(view.entries[0].id,"editor");
  const input=findChild(view,"launcherSearch");input.text="Music";compare(view.entries.length,1);compare(view.entries[0].id,"music");
  input.text=">";compare(view.entries.length,1);compare(view.entries[0].action,"settings");
 }
 function test_favorites_hidden_and_restore(){
  LauncherPreferences.favorites=["music"];
  const view=createTemporaryObject(launcher,test);wait(30);compare(view.category,"favorites");compare(view.entries.length,1);
  LauncherPreferences.hidden=["music"];compare(view.entries.length,0);view.select("all");compare(view.entries.length,2);
  view.select("hidden");compare(view.entries.length,1);LauncherPreferences.hidden=[];view.select("all");compare(view.entries.length,3);
 }
 function test_keyboard_navigation_and_escape(){
  const view=createTemporaryObject(launcher,test);wait(30);const input=findChild(view,"launcherSearch");const grid=findChild(view,"launcherApps");input.forceActiveFocus();keyClick(Qt.Key_Down);verify(grid.activeFocus);
  keyClick(Qt.Key_Left);keyClick(Qt.Key_Right);keyClick(Qt.Key_M);wait(20);compare(input.text,"m");verify(input.activeFocus);
  keyClick(Qt.Key_Escape);compare(view.visibilities.launcher,false);
 }
 function test_favorite_change_keeps_all_apps_selection(){
  const view=createTemporaryObject(launcher,test);wait(30);view.select("all");wait(20);
  const grid=findChild(view,"launcherApps");grid.currentIndex=2;LauncherPreferences.update("favorite","editor",true);wait(30);compare(grid.currentIndex,2);
 }

 function test_favorites_open_compact_and_all_apps_expand_upward(){
  const view=createTemporaryObject(launcher,test);wait(30);compare(view.category,"favorites");compare(view.height,300);
  const search=findChild(view,"launcherSearch");const bottomGap=view.height-search.y-search.height;
  view.select("all");wait(30);compare(view.height,570);compare(view.height-search.y-search.height,bottomGap);
  view.visibilities.launcher=false;view.visibilities.launcher=true;wait(30);compare(view.category,"favorites");compare(view.height,300);compare(search.text,"");
 }

}
