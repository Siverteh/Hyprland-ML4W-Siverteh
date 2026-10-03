'use strict';
const $=id=>document.getElementById(id), canvas=$('cosmos'), ctx=canvas.getContext('2d');
let graph={nodes:[],links:[]}, byId=new Map(), expanded=new Set(), selected=null, hits=[], W=0,H=0,dpr=1;
let yaw=.12,pitch=-.1,zoom=1,mode='recent',motion=!matchMedia('(prefers-reduced-motion: reduce)').matches;
const reducedMotion=matchMedia('(prefers-reduced-motion: reduce)').matches;
let camera={x:0,y:0,z:0},cameraTarget={x:0,y:0,z:0,zoom:1};
let focusIds=null;
let history=[],hovered=null,labelBoxes=[];
let worldAnchors={};try{const stored=JSON.parse(localStorage.getItem('observatory-world-anchors')||'{}');if(stored&&typeof stored==='object'&&!Array.isArray(stored))worldAnchors=stored;}catch(e){}
let drag=null, lastFrame=0, pointerMoved=false, activeTab='universe';
const colors={hub:'#80d9cc',topic:'#80d9cc',note:'#b7c8c9'};
const stars=Array.from({length:240},(_,i)=>({x:random(i*3+1),y:random(i*3+2),r:.4+random(i*3+3)*1.1,z:random(i+800)}));
function random(seed){const x=Math.sin(seed*127.1+311.7)*43758.5453;return x-Math.floor(x);}
async function apiAction(name,value=''){try{const r=await fetch('/api/action',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({name,value})});if(!r.ok)throw Error('Action unavailable');}catch(e){$('footer-status').textContent=e.message;}}
document.querySelectorAll('[data-action]').forEach(b=>b.addEventListener('click',()=>apiAction(b.dataset.action)));
async function load(){
 try{const r=await fetch('/api/brain');if(!r.ok)throw Error('Could not read local knowledge');const previousCount=graph.nodes.filter(n=>n.kind==='hub').length;graph=await r.json();document.documentElement.style.setProperty('--accent',graph.accent||'#80d9cc');byId=new Map(graph.nodes.map(n=>[n.id,n]));$('loading').hidden=true;$('index-status').textContent=graph.noteCount+' notes connected';$('footer-status').textContent='Local knowledge · refreshed '+new Date(graph.generated).toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});renderNav();renderResults();if(!selected&&graph.nodes.filter(n=>n.kind==='hub').length!==previousCount)fitOverview();if(selected&&byId.has(selected.id)){select(byId.get(selected.id),false);focusIds=new Set([selected.id,...descendants(selected).map(c=>c.id)]);}}
 catch(e){$('loading').textContent=e.message;}
}
function renderNav(){const nav=$('hubs');nav.replaceChildren();for(const n of graph.nodes.filter(n=>n.kind==='hub')){const b=document.createElement('button');b.className='hub-link'+(selected?.id===n.id?' active':'');const dot=document.createElement('span');dot.className='hub-dot';dot.style.color=n.color;const label=document.createElement('span');label.className='hub-name';label.textContent=n.label;const count=document.createElement('span');count.className='hub-count';count.textContent=n.count;b.append(dot,label,count);b.onclick=()=>{setTab('universe');select(n);};nav.append(b);}}
function children(n){return graph.links.filter(e=>e.kind==='group'&&e.source===n.id).map(e=>byId.get(e.target)).filter(Boolean);}
function descendants(n,kind){const out=new Map();function walk(v,seen=new Set()){if(seen.has(v.id))return;seen.add(v.id);for(const c of children(v)){if(!kind||c.kind===kind)out.set(c.id,c);if(c.kind!=='note')walk(c,seen);}}walk(n);return [...out.values()];}
function revealAncestors(n,seen=new Set()){
 if(seen.has(n.id))return;seen.add(n.id);
 const edge=graph.links.find(e=>e.kind==='group'&&e.target===n.id);
 if(edge){const parent=byId.get(edge.source);if(parent){expanded.add(parent.id);revealAncestors(parent,seen);}}
}
function focusNode(n){
 revealAncestors(n);
 const pos=positions(),center=pos.get(n.id);
 if(!center)return;
 const near=children(n).map(c=>pos.get(c.id)).filter(Boolean);
 const extent=Math.max(n.kind==='hub'?125:n.kind==='topic'?75:35,...near.map(p=>Math.hypot(p.x-center.x,p.y-center.y,p.z-center.z)*.85));
 const base=Math.min(W/650,H/650)||1;
 const fit=Math.min(W*.78,H*.64)/(extent*2*base);
 cameraTarget={...center,zoom:Math.max(1.35,Math.min(n.kind==='hub'?2.3:n.kind==='topic'?4:5,fit))};
 focusIds=new Set([n.id,...descendants(n).map(c=>c.id)]);
 if(n.kind==='note')for(const edge of graph.links.filter(e=>e.kind==='source'&&(e.source===n.id||e.target===n.id))){focusIds.add(edge.source);focusIds.add(edge.target);}
}
function select(n,expand=true){
 if(expand&&selected?.id!==n.id)history.push(selected?.id||null);
 selected=n;
 $('back').disabled=history.length===0;
 if(expand){if(n.kind!=='note')expanded.add(n.id);focusNode(n);}
 renderNav();renderInspector(n);
 document.querySelector('.scene-heading h1').textContent=n.label;
 document.querySelector('.scene-kicker').textContent=n.kind==='hub'?'Exploring a knowledge world':'Following a constellation';
 $('scene-subtitle').textContent=n.kind==='note'?'An observation in your knowledge constellation':n.count+' related notes · click to explore further';
}
function text(tag,value,cls){const el=document.createElement(tag);el.textContent=value;if(cls)el.className=cls;return el;}
async function renderInspector(n){
 const panel=$('inspector');panel.replaceChildren();panel.append(text('div',n.kind==='hub'?'Star · project or personal world':n.kind==='topic'?'Planet · topic':'Moon · evidence note','detail-kind'),text('h2',n.label));
 if(n.themeLabel)panel.append(text('div',n.themeLabel+' · '+n.themeReason+' color theme','detail-subhead'));
 const meta=document.createElement('div');meta.className='detail-meta';for(const s of n.kind==='note'?[n.date||'Undated',n.confidence]:[n.count+' related notes',mode==='recent'?'Recent focus':'All knowledge'])meta.append(text('span',s));panel.append(meta);
 if(n.kind==='note'){
  const open=text('button','Open original in Obsidian ↗','detail-action');open.onclick=()=>apiAction('open-note',n.path);panel.append(open,text('div',n.path,'detail-subhead'));
  const body=text('div','Reading note…','note-body');panel.append(body);
  try{const r=await fetch('/api/note?path='+encodeURIComponent(n.path));if(!r.ok)throw Error('Note unavailable');const data=await r.json();if(selected?.id===n.id)body.textContent=data.text;}catch(e){body.textContent=e.message;}
  const sources=graph.links.filter(e=>e.kind==='source'&&(e.source===n.id||e.target===n.id)).map(e=>byId.get(e.source===n.id?e.target:e.source)).filter(Boolean);
  if(sources.length){panel.append(text('div','Connected evidence','detail-subhead'));for(const c of sources)appendNote(panel,c);}
 }else{
  panel.append(text('p',n.summary));
  const b=text('button',expanded.has(n.id)?'Fold this constellation':'Unfold constellation','detail-action');b.onclick=()=>{if(expanded.has(n.id))expanded.delete(n.id);else expanded.add(n.id);renderInspector(n);};panel.append(b);
  if(n.kind==='hub')panel.append(text('p',graph.activityModel));
  panel.append(text('div','In this constellation','detail-subhead'));
  for(const c of children(n).filter(c=>c.kind==='topic')){const b=text('button',c.label+'  ·  '+c.count,'detail-note');b.onclick=()=>select(c);panel.append(b);}
  const notes=descendants(n,'note').sort((a,b)=>b.date.localeCompare(a.date));for(const c of notes.slice(0,35))appendNote(panel,c);
  if(notes.length>35)panel.append(text('p',(notes.length-35)+' more notes available in Knowledge.'));
 }
}
function appendNote(panel,n){const b=text('button',n.label,'detail-note');b.append(text('small',n.date||n.kind));b.onclick=()=>select(n);panel.append(b);}
function setTab(tab){activeTab=tab;$('library-view').hidden=tab!=='library';$('universe').classList.toggle('active',tab==='universe');$('library').classList.toggle('active',tab==='library');if(tab==='library')$('search').focus();}
$('library').onclick=()=>setTab('library');$('universe').onclick=()=>setTab('universe');
function renderResults(){const q=$('search').value.toLowerCase(),out=$('results');out.replaceChildren();const matches=graph.nodes.filter(n=>n.kind==='note'&&(!q||(n.label+' '+n.path).toLowerCase().includes(q))).sort((a,b)=>b.date.localeCompare(a.date));for(const n of matches){const b=text('button',n.label,'search-result');b.append(text('small',(n.date||'Undated')+' · '+n.path));b.onclick=()=>select(n);out.append(b);}if(!matches.length)out.append(text('p','No matching notes.'));}
$('search').oninput=renderResults;$('refresh').onclick=load;
function overview(){
 expanded.clear();selected=null;focusIds=null;history=[];$('back').disabled=true;yaw=.12;pitch=-.1;cameraTarget={x:0,y:0,z:0,zoom:1};renderNav();
 document.querySelector('.scene-heading h1').innerHTML='Your knowledge,<br>in constellation.';
 document.querySelector('.scene-kicker').textContent='A map of what matters to you';
 $('scene-subtitle').textContent='Explore a world. Follow a connection.';
 $('inspector').replaceChildren(text('div','✦','empty-star'),text('h2','Choose a world to explore.'),text('p','Select a star to explore its planets and moons.'));
}
function fitOverview(){const hubs=graph.nodes.filter(n=>n.kind==='hub');if(hubs.length<=6){cameraTarget.zoom=1;return;}const pos=[...positions().values()],base=Math.min(W/650,H/650)||1,extentX=Math.max(...pos.map(p=>Math.abs(p.x)+55)),extentY=Math.max(...pos.map(p=>Math.abs(p.y)+55));cameraTarget.zoom=Math.max(.15,Math.min(1,W*.82/(2*extentX*base),H*.72/(2*extentY*base)));}
$('home').onclick=()=>{overview();fitOverview();};
$('back').onclick=()=>{const previous=selected,id=history.pop();if(previous?.kind!=='note')expanded.delete(previous?.id);if(id&&byId.has(id)){const n=byId.get(id);select(n,false);focusNode(n);}else overview();$('back').disabled=history.length===0;};
$('zoom-out').onclick=()=>{cameraTarget.zoom=Math.max(.45,cameraTarget.zoom/1.4);};
$('motion').onclick=()=>{motion=!motion;$('motion').textContent=motion?'Orbit on':'Orbit off';$('motion').setAttribute('aria-pressed',String(motion));};
$('mode').onclick=()=>{mode=mode==='recent'?'all':'recent';$('mode').textContent=mode==='recent'?'Recent focus':'All knowledge';if(selected)renderInspector(selected);};
function positions(){
 const pos=new Map(),hubs=graph.nodes.filter(n=>n.kind==='hub'),fixed={newbringer:[-210,-50,-40],personal:[20,160,60],os:[220,-20,0],musikki:[-230,170,65],research:[5,-165,-20],archive:[270,185,-65]};
 for(const h of hubs){const a=fixed[h.id];if(a)pos.set(h.id,{x:a[0],y:a[1],z:a[2]});}
 for(const h of hubs.filter(h=>!fixed[h.id])){let p=worldAnchors[h.id];if(!p||![p.x,p.y,p.z].every(Number.isFinite)){const seed=[...h.id].reduce((a,c)=>a*31+c.charCodeAt(0),7)>>>0;for(let i=0;i<100;i++){const a=random(seed)*Math.PI*2+i*2.4,r=400+Math.floor(i/8)*170;p={x:Math.cos(a)*r,y:Math.sin(a)*r*.72,z:Math.sin(a*2)*55};if([...pos.values()].every(q=>Math.hypot(p.x-q.x,p.y-q.y)>165))break;}worldAnchors[h.id]=p;try{localStorage.setItem('observatory-world-anchors',JSON.stringify(worldAnchors));}catch(e){}}pos.set(h.id,p);}
 for(const hub of hubs){const p=pos.get(hub.id);children(hub).filter(n=>n.kind==='topic').forEach((n,i)=>{const a=i*2.4+random(hub.id.length+19)*6,rad=45+i*18;pos.set(n.id,{x:p.x+Math.cos(a)*rad,y:p.y+Math.sin(a)*rad*.6,z:p.z+Math.sin(a)*rad*.4,parent:hub.id});});}
 const preferred=selected?.kind==='topic'?selected.id:[...history].reverse().find(id=>byId.get(id)?.kind==='topic'&&children(byId.get(id)).some(n=>n.id===selected?.id));
 const parents=graph.nodes.filter(n=>expanded.has(n.id)).sort((a,b)=>a.id===preferred?-1:b.id===preferred?1:0);
 for(const parent of parents){const p=pos.get(parent.id);if(!p)continue;const all=children(parent).filter(n=>n.kind==='note'),ch=all.slice(0,18);if(selected&&all.some(n=>n.id===selected.id)&&!ch.some(n=>n.id===selected.id))ch.push(selected);
  ch.forEach((n,i)=>{if(pos.has(n.id))return;const a=i/ch.length*Math.PI*2-.9,rad=45+(i%3)*12;pos.set(n.id,{x:p.x+Math.cos(a)*rad,y:p.y+Math.sin(a)*rad*.72,z:p.z+Math.sin(a)*rad*.3,parent:parent.id});});
 }
 return pos;
}
function project(p){const px=p.x-camera.x,py=p.y-camera.y,pz=p.z-camera.z;const x=px*Math.cos(yaw)-pz*Math.sin(yaw),z=px*Math.sin(yaw)+pz*Math.cos(yaw);const y=py*Math.cos(pitch)-z*Math.sin(pitch),zz=py*Math.sin(pitch)+z*Math.cos(pitch);const scale=720/Math.max(180,720+zz)*zoom*Math.min(W/650,H/650);return {x:W*.5+x*scale,y:H*.56+y*scale,z:zz,scale};}
function lightColor(hex,amount){const h=hex.replace('#','');return '#'+[0,2,4].map(i=>Math.round(parseInt(h.slice(i,i+2),16)*(1-amount)+255*amount).toString(16).padStart(2,'0')).join('');}
function rgba(hex,a){const h=hex.replace('#','');return `rgba(${parseInt(h.slice(0,2),16)},${parseInt(h.slice(2,4),16)},${parseInt(h.slice(4,6),16)},${a})`;}
function planet(n,p,t){
 const color=n.color||colors[n.kind];const radius=(n.kind==='hub'?(mode==='recent'?n.radius:26+Math.min(28,Math.log1p(n.count)*6))*.38:n.kind==='topic'?(expanded.has(n.parent)||selected?.id===n.id?n.radius*.65:5):3)*p.scale;
 const r=Math.max(n.kind==='note'?2:6,radius),on=selected?.id===n.id;
 if(n.kind==='topic'&&n.id.endsWith(':systems')){
  const glow=ctx.createRadialGradient(p.x,p.y,r*.4,p.x,p.y,r*2.6);glow.addColorStop(0,rgba(color,on?.25:.1));glow.addColorStop(1,rgba(color,0));ctx.fillStyle=glow;ctx.beginPath();ctx.arc(p.x,p.y,r*2.6,0,Math.PI*2);ctx.fill();
  ctx.save();ctx.translate(p.x,p.y);ctx.rotate(n.kind==='hub'?-.32:.25);ctx.scale(1,.34);ctx.strokeStyle=rgba(color,on?.55:.2);ctx.lineWidth=1;ctx.beginPath();ctx.arc(0,0,r*1.65,0,Math.PI*2);ctx.stroke();ctx.restore();
 }
 const shade=ctx.createRadialGradient(p.x-r*.36,p.y-r*.42,r*.05,p.x+r*.25,p.y+r*.3,r*1.3);shade.addColorStop(0,n.kind==='note'?'#d7eeee':color);shade.addColorStop(.45,rgba(color,.85));shade.addColorStop(1,'#10232d');ctx.fillStyle=shade;ctx.beginPath();ctx.arc(p.x,p.y,r,0,Math.PI*2);ctx.fill();
 if(n.kind==='hub'){
  const corona=ctx.createRadialGradient(p.x,p.y,r*.3,p.x,p.y,r*3.8);
  corona.addColorStop(0,rgba(color,.3));corona.addColorStop(.4,rgba(color,.08));corona.addColorStop(1,rgba(color,0));
  ctx.fillStyle=corona;ctx.beginPath();ctx.arc(p.x,p.y,r*3.8,0,Math.PI*2);ctx.fill();
  const core=ctx.createRadialGradient(p.x-r*.22,p.y-r*.25,0,p.x,p.y,r*1.1);
  core.addColorStop(0,'#fffbed');core.addColorStop(.45,lightColor(color,.65));core.addColorStop(.85,color);core.addColorStop(1,rgba(color,.75));
  ctx.fillStyle=core;ctx.beginPath();ctx.arc(p.x,p.y,r,0,Math.PI*2);ctx.fill();
  ctx.save();ctx.beginPath();ctx.arc(p.x,p.y,r,0,Math.PI*2);ctx.clip();
  for(let j=0;j<120;j++){const a=random(j+7)*Math.PI*2,d=r*Math.sqrt(random(j+122));ctx.fillStyle='rgba(179,83,27,.06)';ctx.beginPath();ctx.arc(p.x+Math.cos(a)*d,p.y+Math.sin(a)*d,r*(.012+random(j+8)*.025),0,Math.PI*2);ctx.fill();}ctx.restore();
 }
 if(n.kind==='note'){
  ctx.save();ctx.beginPath();ctx.arc(p.x,p.y,r,0,Math.PI*2);ctx.clip();
  for(let j=0;j<4;j++){const a=random(j+n.id.length)*Math.PI*2,d=r*random(j+93)*.65;ctx.fillStyle='rgba(17,31,37,.32)';ctx.beginPath();ctx.arc(p.x+Math.cos(a)*d,p.y+Math.sin(a)*d,r*.2,0,Math.PI*2);ctx.fill();}ctx.restore();
 }
 if(on){ctx.strokeStyle=rgba(color,.85);ctx.setLineDash([2,5]);ctx.beginPath();ctx.arc(p.x,p.y,r+8,0,Math.PI*2);ctx.stroke();ctx.setLineDash([]);}
 if((n.kind==='hub'&&!focusIds)||on||(focusIds&&focusIds.has(n.id)))labelBoxes.push({n,p,r});
 hits.push({n,x:p.x,y:p.y,r:Math.max(r+9,15)});
}
function drawLabels(){
 const heading=document.querySelector('.scene-heading').getBoundingClientRect(),box=canvas.getBoundingClientRect();
 const occupied=[{x:heading.left-box.left-5,y:heading.top-box.top-5,w:heading.width+10,h:heading.height+10}];
 const overlap=(a,b)=>a.x<b.x+b.w+5&&a.x+a.w+5>b.x&&a.y<b.y+b.h+5&&a.y+a.h+5>b.y;
 for(const {n,p,r} of labelBoxes.sort((a,b)=>(a.n.id===selected?.id?-1:b.n.id===selected?.id?1:0))){
  const moon=n.kind==='note';ctx.font=(moon?'12px':'500 14px')+' Cantarell, sans-serif';
  const words=n.label.split(/\s+/),lines=[];let line='';
  for(const word of words){if(ctx.measureText((line?line+' ':'')+word).width>165&&line){lines.push(line);line=word;}else line+=(line?' ':'')+word;}
  if(line)lines.push(line);if(lines.length>2){lines.length=2;lines[1]=lines[1].slice(0,23)+'…';}
  const w=Math.max(...lines.map(l=>ctx.measureText(l).width))+14,h=lines.length*16+10;
  let target=null;const side=p.x>=W*.5?1:-1;
  for(const dy of [0,-24,24,-48,48,-72,72,-96,96,-128,128,-160,160]){
   for(const sign of [side,-side]){const candidate={x:sign>0?p.x+r+9:p.x-r-9-w,y:p.y-h/2+dy,w,h};
    if(candidate.x<8||candidate.x+w>W-8||candidate.y<8||candidate.y+h>H-60||occupied.some(o=>overlap(candidate,o)))continue;
    target=candidate;break;
   }if(target)break;
  }
  if(!target)continue;
  occupied.push(target);hits.push({n,x:target.x+w/2,y:target.y+h/2,r:0,box:target});ctx.strokeStyle='rgba(145,190,194,.45)';ctx.lineWidth=.7;ctx.beginPath();ctx.moveTo(p.x,p.y);ctx.lineTo(Math.max(target.x,Math.min(target.x+w,p.x)),target.y+h/2);ctx.stroke();
  ctx.fillStyle='rgba(11,23,28,.91)';ctx.fillRect(target.x,target.y,w,h);ctx.textAlign='left';ctx.fillStyle='#e9f2ec';
  lines.forEach((l,i)=>ctx.fillText(l,target.x+7,target.y+17+i*16));
 }
}
function draw(time){
 requestAnimationFrame(draw);if(document.hidden||activeTab!=='universe'||time-lastFrame<33)return;
 const ease=reducedMotion?1:1-Math.exp(-Math.min(time-lastFrame,80)/150);lastFrame=time;
 for(const axis of ['x','y','z'])camera[axis]+=(cameraTarget[axis]-camera[axis])*ease;
 zoom+=(cameraTarget.zoom-zoom)*ease;
 ctx.clearRect(0,0,W,H);const t=motion?time/1000:0;
 for(const s of stars){ctx.fillStyle=`rgba(181,219,218,${.13+s.z*.25+(motion?Math.sin(t*.4+s.z*20)*.06:0)})`;ctx.beginPath();ctx.arc(s.x*W,s.y*H,s.r,0,Math.PI*2);ctx.fill();}
 const pos=positions(),projected=new Map([...pos].map(([id,p])=>[id,project(p)]));
 const drawnOrbits=new Set();
 for(const e of graph.links){
  const a=projected.get(e.source),b=projected.get(e.target);if(!a||!b)continue;
  const primary=!focusIds||(focusIds.has(e.source)&&focusIds.has(e.target));
  if(e.kind==='group'){
   const origin=pos.get(e.source),target=pos.get(e.target);if(target.parent!==e.source)continue;
   const squash=byId.get(e.source).kind==='hub'?.6:.72,tilt=byId.get(e.source).kind==='hub'?.4:.3;
   const rad=Math.hypot(target.x-origin.x,(target.y-origin.y)/squash),key=e.source+':'+Math.round(rad);
   if(drawnOrbits.has(key))continue;drawnOrbits.add(key);
   ctx.strokeStyle=primary?'rgba(139,185,193,.24)':'rgba(139,185,193,.035)';ctx.lineWidth=.8;ctx.beginPath();
   for(let i=0;i<=90;i++){const angle=i/90*Math.PI*2,q=project({x:origin.x+Math.cos(angle)*rad,y:origin.y+Math.sin(angle)*rad*squash,z:origin.z+Math.sin(angle)*rad*tilt});if(i===0)ctx.moveTo(q.x,q.y);else ctx.lineTo(q.x,q.y);}ctx.stroke();
  }else{
   ctx.strokeStyle=primary?'rgba(230,188,137,.35)':'rgba(230,188,137,.035)';ctx.lineWidth=.7;ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();
  }
 }
 hits=[];labelBoxes=[];for(const [id,p] of [...projected].sort((a,b)=>b[1].z-a[1].z)){ctx.save();ctx.globalAlpha=!focusIds||focusIds.has(id)?1:.16;planet(byId.get(id),p,t);ctx.restore();}
 drawLabels();
}
new ResizeObserver(()=>{const box=canvas.getBoundingClientRect();W=box.width;H=box.height;dpr=Math.min(devicePixelRatio,2);canvas.width=W*dpr;canvas.height=H*dpr;ctx.setTransform(dpr,0,0,dpr,0,0);}).observe(canvas);
function containsHit(h,x,y){return h.box?x>=h.box.x&&x<=h.box.x+h.box.w&&y>=h.box.y&&y<=h.box.y+h.box.h:Math.hypot(h.x-x,h.y-y)<h.r;}
canvas.addEventListener('pointerdown',e=>{drag={x:e.clientX,y:e.clientY};pointerMoved=false;canvas.setPointerCapture(e.pointerId);});
canvas.addEventListener('pointermove',e=>{if(!drag){const b=canvas.getBoundingClientRect();hovered=[...hits].reverse().find(h=>containsHit(h,e.clientX-b.left,e.clientY-b.top))?.n||null;canvas.title=hovered?.label||'';}if(drag){const dx=e.clientX-drag.x,dy=e.clientY-drag.y;if(Math.abs(dx)+Math.abs(dy)>2)pointerMoved=true;yaw+=dx*.005;pitch=Math.max(-1,Math.min(1,pitch+dy*.005));drag={x:e.clientX,y:e.clientY};}});
canvas.addEventListener('pointerup',e=>{drag=null;if(!pointerMoved){const box=canvas.getBoundingClientRect(),x=e.clientX-box.left,y=e.clientY-box.top;const hit=[...hits].reverse().find(h=>containsHit(h,x,y));if(hit)select(hit.n);}});
canvas.addEventListener('pointercancel',()=>{drag=null;});
canvas.addEventListener('wheel',e=>{e.preventDefault();cameraTarget.zoom=Math.max(.45,Math.min(6,cameraTarget.zoom*Math.exp(-e.deltaY*.001)));},{passive:false});
document.addEventListener('keydown',e=>{if(e.key==='Escape'){setTab('universe');if(history.length)$('back').click();else overview();}});
$('motion').textContent=motion?'Orbit on':'Orbit off';load();requestAnimationFrame(draw);setInterval(load,120000);
