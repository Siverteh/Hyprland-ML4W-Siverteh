// Track a repeating rhythm from playback novelty; no microphone or extra process.
function create() {return {previous:[],history:[],energy:0,noise:0,frames:0,lastTime:0,frameMs:1000/60,lastOnset:-10000,lastBeat:-10000,period:0,bpm:0,confidence:0};}
function update(s,values,now) {
 const v=values.map(x=>Math.max(0,Number(x)||0));if(!v.length)return {beat:false,bpm:0,confidence:0};
 const dt=now-s.lastTime;if(dt>=5&&dt<100)s.frameMs=s.frameMs*.96+dt*.04;s.lastTime=now;
 let flux=0,weight=0;
 for(let i=0;i<v.length;i++){const w=i<v.length*.3?1:i<v.length*.7?.75:.2;flux+=Math.max(0,v[i]-(s.previous[i]??v[i]))*w;weight+=w;}
 flux/=weight;
 const energy=v.reduce((a,b)=>a+b,0)/v.length;
 const onset=s.frames>6&&energy>2&&flux>Math.max(.45,s.noise*1.8)&&now-s.lastOnset>=150;
 if(onset)s.lastOnset=now;
 s.previous=v;s.energy=s.energy*.85+energy*.15;s.noise=s.noise*.97+flux*.03;s.frames++;
 s.history.push(flux);if(s.history.length>180)s.history.shift();
 if(s.frames%30===0&&s.history.length>=110){
  let best=0,lagBest=0;const h=s.history;
  for(let lag=Math.round(60000/210/s.frameMs);lag<=Math.round(60000/55/s.frameMs);lag++){
   let dot=0,a=0,b=0;
   for(let i=lag;i<h.length;i++){const aligned=Math.max(h[i-lag]??0,h[i-lag-1]??0,h[i-lag+1]??0);dot+=h[i]*aligned;a+=h[i]*h[i];b+=h[i-lag]*h[i-lag];}
   const score=a&&b?Math.min(1,dot/Math.sqrt(a*b)):0;
   if(score>best+.025){best=score;lagBest=lag;}
  }
  s.confidence=best;
  if(best>.48&&lagBest){const period=lagBest*s.frameMs;s.period=s.period&&Math.abs(period-s.period)<s.period*.12?s.period*.7+period*.3:period;s.bpm=Math.round(60000/s.period);}
  else{s.period=0;s.bpm=0;}
 }
 let beat=false;
 if(s.period&&s.confidence>.48){
  const audible=energy>2&&now-s.lastOnset<Math.max(1200,s.period*2.5);
  const elapsed=now-s.lastBeat;
  if(audible&&onset&&Math.abs(elapsed-s.period)<s.period*.22){beat=true;s.lastBeat=now;}
  else if(audible&&elapsed>=s.period*1.10){beat=true;s.lastBeat+=s.period;}
 }else if(onset&&now-s.lastBeat>=180){beat=true;s.lastBeat=now;}
 if(energy<1&&s.energy<2){s.period=0;s.bpm=0;s.confidence=0;}
 return {beat:beat,bpm:s.bpm,confidence:s.confidence};
}
