.pragma library
var categories = [
 {id:"favorites",label:"Favorites",icon:"favorite"},
 {id:"all",label:"All apps",icon:"apps"},
 {id:"development",label:"Development",icon:"code",xdg:["Development"]},
 {id:"media",label:"Media",icon:"movie",xdg:["AudioVideo","Audio","Video"]},
 {id:"games",label:"Games",icon:"sports_esports",xdg:["Game"]},
 {id:"graphics",label:"Graphics",icon:"palette",xdg:["Graphics"]},
 {id:"internet",label:"Internet",icon:"public",xdg:["Network"]},
 {id:"office",label:"Office",icon:"description",xdg:["Office"]},
 {id:"education",label:"Education",icon:"school",xdg:["Education","Science"]},
 {id:"system",label:"System",icon:"settings",xdg:["System","Settings"]},
 {id:"utilities",label:"Utilities",icon:"build",xdg:["Utility"]},
 {id:"other",label:"Other",icon:"category",xdg:[]}
];
function category(app) {
 var raw=app.categories||[],list=typeof raw==="string"?raw.split(";"):Array.from(raw);
 for(var i=2;i<categories.length-1;i++)if(categories[i].xdg.some(c=>list.includes(c)))return categories[i].id;
 return "other";
}
function visible(apps){return categories.filter(c=>c.id==="all"||c.id==="favorites"||apps.some(a=>category(a)===c.id));}
function browse(apps,id,favorites){
 if(id==="all")return apps;
 if(id==="favorites")return apps.filter(a=>favorites.includes(a.id));
 return apps.filter(a=>category(a)===id);
}
