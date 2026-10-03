pragma Singleton

import "root:/config"
import "root:/utils/scripts/beat.js" as Beats
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    signal beat()
    property int bpm:0
    property var detector:Beats.create()
    property list<int> values
    property bool restartRequested:false
    Connections {target:Audio;function onSinkChanged(){if(capture.running){root.detector=Beats.create();root.bpm=0;root.restartRequested=true;capture.running=false;}else capture.running=true;}}

    IpcHandler {target:"spectrum";function state():string{return JSON.stringify({samples:root.values.length,peak:Math.max(0,...root.values),bpm:root.bpm})}}
    Process {
        id:capture
        onExited:if(root.restartRequested){root.restartRequested=false;capture.running=true;}
        running: true
        command: ["sh", "-c", `printf '[general]\nframerate=60\nbars=${DashboardConfig.visualiserBars}\n[input]\nmethod=pulse\nsource=%s.monitor\n[output]\nchannels=mono\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100' "$(pactl get-default-sink)" | cava -p /dev/stdin`]
        stdout: SplitParser {
            onRead: data => {
                root.values=data.slice(0,-1).split(";").map(v=>parseInt(v,10));
                const detected=Beats.update(root.detector,root.values,Date.now());root.bpm=detected.bpm;
                if(detected.beat)root.beat();
            }
        }
    }
}
