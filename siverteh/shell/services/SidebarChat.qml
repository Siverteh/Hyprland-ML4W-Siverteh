pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
Singleton {
    id:root
    property string provider:""
    property string defaultProvider:"codex"
    property bool inWorkspace:false
    property string account:""
    property string title:"New chat"
    property string threadId:""
    property string model:""
    property bool busy:false
    property bool connected:false
    property string status:""
    property string error:""
    property var question:null
    property var answers:({})
    property var outgoing:[]
    property string draft:""
    property alias messages:messages
    ListModel {id:messages;dynamicRoles:true}
    function start(){if(!wire.running)wire.running=true;}
    function command(value){start();if(connected)wire.write(JSON.stringify(value)+"\n");else outgoing.push(value);}
    function send(text){if(!inWorkspace&&text.trim()){busy=true;command({action:"send",text:text});}}
    function newChat(){if(!busy)command({action:"new"});}
    function load(key){if(!busy)command({action:"load",key:key});}
    function stop(){command({action:"stop"});}
    function setProvider(provider){command({action:"provider",provider:provider});}
    function workspace(){command({action:"workspace"});}
    function answer(){if(question)command({action:"answer",id:question.id,answers:answers});}
    function setAnswer(id,text){const result=Object.assign({},answers);result[id]={answers:[text]};answers=result;}
    function itemIndex(id){for(let i=0;i<messages.count;i++)if(messages.get(i).id===id)return i;return -1;}
    function accept(event){
        if(event.type==="connection"){connected=event.connected;error=event.error??"";return;}
        if(event.type==="state"){
            defaultProvider=event.defaultProvider??defaultProvider;inWorkspace=event.inWorkspace??false;provider=event.provider??provider;account=event.account??account;title=event.title??title;threadId=event.threadId??"";model=event.model??"";
            busy=event.busy??false;status=event.status??"";error=event.error??"";
            if(question?.id!==event.question?.id)answers={};question=event.question??null;
            connected=true;
            while(outgoing.length)wire.write(JSON.stringify(outgoing.shift())+"\n");
        }else if(event.type==="sendFailed"){
            draft=event.text+(draft?"\n\n"+draft:"");
        }else if(event.type==="history"){
            messages.clear();for(const item of event.messages)messages.append(item);
        }else if(event.type==="delta"){
            const index=itemIndex(event.id);
            if(index<0)messages.append({id:event.id,role:"assistant",text:event.text});else messages.setProperty(index,"text",messages.get(index).text+event.text);
        }else if(event.type==="message"){
            const index=itemIndex(event.id);
            if(index<0)messages.append({id:event.id,role:event.role,text:event.text});else messages.setProperty(index,"text",event.text);
        }
    }
    Process {
        id:wire
        stdinEnabled:true
        command:["python3",Quickshell.env("HOME")+"/.local/share/siverteh-ai/siverteh-shell/tools/sidebar-chat.py","client"]
        stdout:SplitParser {onRead:line=>{try{root.accept(JSON.parse(line));}catch(e){root.error="Could not read the assistant response";}}}
        onExited:{root.connected=false;if(root.busy){root.error="Reopen the drawer to reconnect to the assistant";root.busy=false;}}
    }
    IpcHandler {target:"sidebarChat";function state():string{return JSON.stringify({provider:root.provider,title:root.title,threadId:root.threadId,busy:root.busy,inWorkspace:root.inWorkspace,connected:root.connected,messages:messages.count,error:root.error});}function send(text:string):void{root.send(text);}function stop():void{root.stop();}}
}
