pragma Singleton
import QtQuick
QtObject {
 property bool busy:false;property bool inWorkspace:false;property string threadId:"fixture";property string provider:"codex";property string title:"Test"
 property string status:"";property string error:"";property var question:null;property var answers:({});property string draft:""
 property var messages:ListModel {};property int replies:0;property int sends:0;property int stops:0;property string lastText:""
 function start(){}
function send(text){sends++;lastText=text}
function stop(){stops++}
function newChat(){}
function workspace(){}
function answer(){replies++}
function setAnswer(id,text){const next=Object.assign({},answers);next[id]={answers:[text]};answers=next}
}