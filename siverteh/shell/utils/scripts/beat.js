// Adaptive low-frequency onset detector. Consumes existing Cava frames only.
function create() { return {previous:[],energy:0,flux:0,frames:0,lastBeat:-10000,intervals:[]}; }
function update(state, values, now) {
    const bands=values.slice(0,Math.max(1,Math.floor(values.length/3))).map(v=>Math.max(0,Number(v)||0));
    if(!bands.length)return {beat:false,bpm:0};
    const energy=bands.reduce((a,b)=>a+b,0)/bands.length;
    const flux=bands.reduce((sum,v,i)=>sum+Math.max(0,v-(state.previous[i]??v)),0)/bands.length;
    const beat=state.frames>12 && energy>6 && flux>Math.max(1.1,state.flux*2.2) && energy>state.energy*1.08 && now-state.lastBeat>=170;
    if(beat) {
        const interval=now-state.lastBeat;
        if(interval>=200 && interval<=2000) {state.intervals.push(interval);if(state.intervals.length>6)state.intervals.shift();}
        state.lastBeat=now;
    }
    state.previous=bands;state.energy=state.energy*.93+energy*.07;state.flux=state.flux*.94+flux*.06;state.frames++;
    const sorted=state.intervals.slice().sort((a,b)=>a-b),middle=sorted[Math.floor(sorted.length/2)];
    return {beat:beat,bpm:middle?Math.round(60000/middle):0};
}
