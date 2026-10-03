import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
const context=vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('../../shell/utils/scripts/beat.js',import.meta.url),'utf8'),context);
function run(bpm) {
 const state=context.create();let count=0,result;
 for(let frame=0;frame<600;frame++) {
  const now=frame*1000/60,phase=now%(60000/bpm);
  const amplitude=phase<50?80:phase<100?25:2;
  result=context.update(state,Array(45).fill(amplitude),now);if(result.beat)count++;
 }
 return {count,bpm:result.bpm};
}
for(const bpm of [60,120,180]) {const r=run(bpm);assert.ok(Math.abs(r.bpm-bpm)<5,JSON.stringify(r));assert.ok(Math.abs(r.count-bpm/6)<=1,JSON.stringify(r));}
const quiet=context.create();for(let i=0;i<600;i++)assert.equal(context.update(quiet,Array(45).fill(0),i*16.67).beat,false);
const tone=context.create();for(let i=0;i<600;i++)assert.equal(context.update(tone,Array(45).fill(50),i*16.67).beat,false);
console.log('Beat checks passed: 60/120/180 BPM pulses, silence and steady tone.');
