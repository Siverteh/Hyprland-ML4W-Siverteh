pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micAvailable: !!source?.ready && !!source?.audio
    function setMicVolume(value: real): void {
        if (micAvailable) source.audio.volume = Math.max(0, Math.min(1, value));
    }
    function toggleMute(): void { if (sink?.ready && sink?.audio) sink.audio.muted = !sink.audio.muted; }
    function toggleMic(): void { if (micAvailable) source.audio.muted = !source.audio.muted; }

    function setVolume(volume: real): void {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = volume;
        }
    }

    IpcHandler {target:"audioControls";function state():string{return JSON.stringify({micAvailable:root.micAvailable,micVolume:root.micVolume,micMuted:root.micMuted,volume:root.volume,muted:root.muted});}function microphone(value:real):void{root.setMicVolume(value);}}

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}
