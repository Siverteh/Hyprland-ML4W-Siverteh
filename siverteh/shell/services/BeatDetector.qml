pragma Singleton
import QtQuick
import Quickshell
// Drive the reference animation from playback visualization, not the microphone.
Singleton {
    property real bpm: 120
    property real previous: 0
    property double lastBeat: 0
    Connections {
        target: Cava
        function onValuesChanged() {
            const values=Cava.values;
            if(!values.length)return;
            const energy=values.reduce((a,b)=>a+b,0)/values.length;
            const now=Date.now();
            if(energy>previous*1.25&&energy>12&&now-lastBeat>250){
                const delta=now-lastBeat;
                if(delta>300&&delta<1500)bpm=60000/delta;
                lastBeat=now;
            }
            previous=energy;
        }
    }
}
