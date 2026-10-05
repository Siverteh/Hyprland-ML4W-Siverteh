import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"WallpaperPicker";width:1160;height:650;visible:true;when:windowShown
 Component {id:picker;WallpaperGallery {width:1160;height:implicitHeight;visibilities:QtObject {property bool launcher:true}}}
 Component {id:hex;WallpaperHex {entry:Wallpapers.list[0]}}
 function init(){Wallpapers.preferences={kind:"static",layout:"carousel"};Wallpapers.current="one";Wallpapers.browsed="";}
 function test_static_dynamic_filter_and_search(){
  const view=createTemporaryObject(picker,test);wait(40);compare(view.count,2);
  const input=findChild(view,"wallpaperSearch");input.text="hollow";compare(view.count,1);compare(view.currentEntry.path,"two");compare(Wallpapers.browsed,"");view.choose();compare(Wallpapers.browsed,"two");
  input.text="";Wallpapers.preference({kind:"dynamic"});compare(view.count,1);compare(view.currentEntry.path,"three");
 }
 function test_layout_switch_preserves_selection_and_escape(){
  const view=createTemporaryObject(picker,test);wait(40);view.select(1);compare(view.currentEntry.path,"two");
  for(const layout of ["spotlight","hexagons","carousel"]){Wallpapers.preference({layout:layout});wait(40);compare(view.currentEntry.path,"two");}
  view.forceActiveFocus();keyClick(Qt.Key_Escape);compare(view.visibilities.launcher,false);
 }
 function test_hexagonal_hit_shape_excludes_transparent_corners(){
  const view=createTemporaryObject(hex,test);verify(view.inside(100,80));verify(!view.inside(0,0));verify(!view.inside(199,1));verify(view.inside(1,87));
 }
}
