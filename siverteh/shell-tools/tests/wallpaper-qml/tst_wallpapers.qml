import QtQuick
import QtTest
import "fixtures"
TestCase {
 id:test;name:"WallpaperPicker";width:1160;height:650;visible:true;when:windowShown
 Component {id:picker;WallpaperGallery {width:1160;height:implicitHeight;visibilities:QtObject {property bool launcher:true}}}
 Component {id:backdrop;WallpaperBackdrop {width:500;height:300}}
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
 function test_full_screen_modes_and_complete_carousel_cards(){
  const original=Wallpapers.list;
  try {
   Wallpapers.list=Array.from({length:12},(_,i)=>({path:"wall"+i,name:"Wallpaper "+i,poster:original[0].poster,dynamic:false}));
   const view=createTemporaryObject(picker,test);wait(60);
   verify(!view.fullScreen);compare(view.implicitHeight,360);
   const strip=findChild(view,"carouselStrip"),cards=findChild(view,"carouselCards");
   verify(strip.slots%2===1);verify(cards.width<=strip.width);
   for(const card of cards.children){if(card.entry===undefined)continue;const point=card.mapToItem(strip,0,0),end=card.mapToItem(strip,card.width,card.height);verify(point.x>=0,"left "+point.x);verify(end.x<=strip.width+1,"right "+end.x+" / "+strip.width);verify(point.y>=0,"top "+point.y);verify(end.y<=strip.height+1,"bottom "+end.y+" / "+strip.height);}
   for(const layout of ["spotlight","hexagons"]){Wallpapers.preference({layout:layout});wait(40);verify(view.fullScreen);compare(view.implicitHeight,1100);}
  } finally {Wallpapers.list=original;}
 }
 function test_backdrop_holds_loaded_image_until_replacement_ready(){
  const path=Wallpapers.list[0].poster;
  const view=createTemporaryObject(backdrop,test,{path:path});tryCompare(view,"hasImage",true);
  const previous=view.current;view.path=path.replace("poster.png","second.png");compare(view.current,previous);
  wait(650);verify(view.current!==previous);compare(view.current.status,Image.Ready);
  view.path=path;wait(650);compare(view.current,previous);verify(view.hasImage);
 }
 function test_hexagonal_hit_shape_excludes_transparent_corners(){
  const view=createTemporaryObject(hex,test);verify(view.inside(100,80));verify(!view.inside(0,0));verify(!view.inside(199,1));verify(view.inside(1,87));
 }
}
