//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root
    property bool opened: false
    property var selectedScreen: Quickshell.screens[0]
    property var targetBar: null
    property var state: ({clock:"…", date:"", windows:[], calendar:[], workspace:2, volume:0, brightness:50, network:"…", bluetooth:false, notifications:0, media:"", battery:null})
    property int activeWorkspace: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    property var activeWindows: Hyprland.toplevels.values.map(window => ({address: window.lastIpcObject?.address || window.address, title: window.title, app: window.wayland?.appId || window.lastIpcObject?.class || "", active: window.activated, workspace: window.workspace && window.workspace.id>0 ? window.workspace.id : 99}))
    function appInfo(window) {
        const app=window.app.toLowerCase();
        if(window.title === "Siverteh · Observatory") return {key:"brain",name:"Brain",icon:"󰠮"};
        if(app.indexOf("mail")>=0) return {key:"mail",name:"Mail",icon:"󰇮"};
        if(window.title==="Siverteh AI" || app.indexOf("siverteh-ai-dashboard")>=0) return {key:"ai",name:"AI",icon:"✦"};
        if(app.indexOf("siverteh-ai")>=0) return {key:"tasks",name:"Tasks",icon:""};
        if(app.indexOf("chrome")>=0) return {key:"chrome",name:"Chrome",icon:""};
        if(app.indexOf("discord")>=0) return {key:"discord",name:"Discord",icon:"󰙯"};
        if(app.indexOf("spotify")>=0) return {key:"spotify",name:"Music",icon:""};
        if(app.indexOf("code")>=0) return {key:"code",name:"Code",icon:"󰨞"};
        if(app.indexOf("kitty")>=0) return {key:"terminal",name:"Terminal",icon:""};
        return {key:app,name:window.app.split('.').pop() || "App",icon:""};
    }
    property var appGroups: {
        const groups={};
        for(const window of activeWindows){const info=appInfo(window);if(!groups[info.key])groups[info.key]={key:info.key,name:info.name,icon:info.icon,windows:[],active:false,workspace:99};groups[info.key].windows.push(window.address);groups[info.key].active=groups[info.key].active||window.active;groups[info.key].workspace=Math.min(groups[info.key].workspace,window.workspace);}
        return Object.values(groups).sort((a,b)=>a.workspace-b.workspace || (a.name>b.name?1:-1));
    }
    property double workspaceChangedAt: 0
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { root.workspaceChangedAt = Date.now(); }
    }
    property color accent: state.accent || "#80d9cc"
    property color surface: "#111f24"
    property color raised: "#1a2c32"
    property color ink: "#e2ebe6"
    property color quiet: "#a0b5b8"
    property string controller: Quickshell.shellDir + "/../control.py"
    function act(name, value) { Quickshell.execDetached(["python3", controller, "action", name, String(value === undefined ? "" : value)]); }
    Process {
        id: stateProcess
        command: ["python3", root.controller, "stream"]
        stdout: SplitParser { onRead: data => { try { root.state = JSON.parse(data); } catch(e) {} } }
        stderr: StdioCollector { onStreamFinished: console.warn(text) }
    }
    Timer { id: stateStartTimer; interval: 250; running: true; onTriggered: stateProcess.running = true }
    IpcHandler { target: "observatory"; function toggle(): void { root.opened = !root.opened; } function close(): void { root.opened = false; } function restartStatus(): void { stateProcess.running=false; stateStartTimer.restart(); } function buttonTargets(): string { return JSON.stringify(root.targetBar.buttonTargets()); } function diagnostic(): string { return JSON.stringify({workspace:root.activeWorkspace, windows:root.activeWindows.length, changedAt:root.workspaceChangedAt,opened:root.opened}); } }

    component Label: Text {
        color: root.ink
        font.family: "Cantarell"
        font.pixelSize: 14
        elide: Text.ElideRight
    }
    component Logo: Item { implicitWidth: 28; implicitHeight: 28; Image { anchors.fill: parent; source: "file://" + Quickshell.shellDir + "/../logo.svg"; sourceSize.width: 64; sourceSize.height: 64; fillMode: Image.PreserveAspectFit } }
    component Action: Rectangle {
        id: actionButton
        property string label: ""
        property string icon: ""
        property bool selected: false
        signal clicked()
        implicitWidth: content.implicitWidth + 28
        implicitHeight: 38
        radius: 8
        color: selected ? "#2d484c" : mouse.containsMouse ? "#253c42" : root.raised
        border.color: selected ? root.accent : "transparent"
        border.width: 1
        Row { id: content; anchors.centerIn: parent; spacing: 8
            Label { text: actionButton.icon; color: root.accent; font.family: "JetBrainsMono Nerd Font"; visible: text.length > 0 }
            Label { text: actionButton.label }
        }
        MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: actionButton.clicked() }
        Behavior on color { ColorAnimation { duration: 130 } }
    }
    component BarButton: Rectangle {
        id: barButton
        property string icon: ""
        property string label: ""
        property bool selected: false
        property string tooltip: ""
        signal clicked()
        implicitWidth: buttonContent.implicitWidth+12
        implicitHeight: 26
        radius: 5
        color: buttonMouse.pressed ? "#2d484f" : buttonMouse.containsMouse ? "#1a2c32" : "transparent"
        RowLayout { id: buttonContent; anchors.centerIn: parent; spacing: 5
            Label { text: icon; visible: text.length>0; color: selected ? root.accent : root.quiet; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; Layout.alignment: Qt.AlignVCenter }
            Label { text: label; visible: text.length>0; color: root.quiet; font.pixelSize: 12; Layout.alignment: Qt.AlignVCenter }
        }
        ToolTip.visible: buttonMouse.containsMouse && tooltip.length>0
        ToolTip.text: tooltip
        MouseArea { id: buttonMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onPressed: barButton.clicked() }
    }
    component Section: Label { color: root.quiet; font.pixelSize: 12; font.weight: Font.Medium }
    component Level: ColumnLayout {
        property string label: ""
        property string icon: ""
        property real amount: 0
        signal changed(real amount)
        Layout.fillWidth: true
        RowLayout { Layout.fillWidth: true
            Label { text: icon; color: root.accent; font.family: "JetBrainsMono Nerd Font" }
            Label { text: label; Layout.fillWidth: true }
            Label { text: Math.round(amount) + "%"; color: root.quiet; font.pixelSize: 12 }
        }
        Slider {
            id: slider; Layout.fillWidth: true; from: 0; to: 100; value: amount
            onPressedChanged: if (!pressed) changed(value)
            background: Rectangle { x: slider.leftPadding; y: slider.topPadding + slider.availableHeight / 2 - height / 2; width: slider.availableWidth; height: 5; radius: 3; color: "#30444a"
                Rectangle { width: parent.width * slider.visualPosition; height: parent.height; radius: 3; color: root.accent }
            }
            handle: Rectangle { x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width); y: slider.topPadding + slider.availableHeight / 2 - height / 2; width: 13; height: 13; radius: 7; color: root.ink }
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            Component.onCompleted: root.targetBar=bar
            function buttonTargets() {
                const out={};
                const buttons={wifi:wifiButton,bluetooth:bluetoothButton,updates:updatesButton};
                for(const name of Object.keys(buttons)){const b=buttons[name],p=b.mapToItem(null,0,0);out[name]={x:p.x+b.width/2,y:p.y+b.height/2,tooltip:b.tooltip};}
                return out;
            }
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 38
            color: "#0b171c"
            WlrLayershell.namespace: "siverteh-observatory-bar"
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#294047" }
            RowLayout {
                anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                width: Math.max(300, bar.width/2-100)
                Repeater { model: ["Browse", "Work", "Chat", "Music", "Mail", "Brain", "Spare"]
                    Rectangle {
                        required property int index
                        required property string modelData
                        implicitWidth: root.activeWorkspace === index+1 ? 74 : 27; Layout.preferredWidth: implicitWidth; height: 26; radius: 6
                        color: root.activeWorkspace === index+1 ? "#274047" : "transparent"
                        Label { anchors.centerIn: parent; text: root.activeWorkspace === index+1 ? (index+1)+"  "+modelData : String(index+1); font.pixelSize: 12; color: root.activeWorkspace === index+1 ? root.accent : root.quiet }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.act("workspace",index+1) }
                        Behavior on width { NumberAnimation { duration: 160 } }
                    }
                }
                Rectangle { width: 1; height: 14; color: "#345058"; Layout.leftMargin: 8; Layout.rightMargin: 8 }
                Repeater { model: root.appGroups
                    BarButton {
                        required property var modelData
                        icon: modelData.icon
                        label: modelData.windows.length>1 ? String(modelData.windows.length) : ""
                        selected: modelData.active
                        onClicked: root.act(modelData.windows.length===1 ? "focus" : "app-windows",modelData.windows.length===1 ? modelData.windows[0] : JSON.stringify(modelData.windows))
                    }
                }
                Item { Layout.fillWidth: true }
            }
            Rectangle {
                anchors.centerIn: parent; width: 156; height: 28; radius: 7
                color: centerMouse.containsMouse || root.opened ? "#253d43" : "#15292f"
                Logo { anchors.left: parent.left; anchors.leftMargin: 11; anchors.verticalCenter: parent.verticalCenter; width: 22; height: 22 }
                Label { anchors.centerIn: parent; width: 76; height: parent.height; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: "Siverteh"; font.weight: Font.Medium }
                Label { anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; width: 16; height: parent.height; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; text: root.opened ? "⌃" : "⌄"; color: root.quiet }
                MouseArea { id: centerMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onPressed: { root.selectedScreen=bar.screen; root.opened=!root.opened; } }
            }
            RowLayout { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                BarButton { id: updatesButton; icon: ""; label: root.state.updates===null || root.state.updates===undefined ? "…" : String(root.state.updates); selected: root.state.updates>0; onClicked: root.act("updates") }
                BarButton { icon: "󰂚"; label: root.state.notifications ? String(root.state.notifications) : ""; onClicked: root.act("notifications") }
                BarButton { icon: root.state.muted ? "󰝟" : "󰕾"; label: String(root.state.volume); onClicked: root.act("audio") }
                BarButton { id: wifiButton; icon: root.state.network === "Disconnected" ? "󰤭" : "󰤨"; selected: root.state.network!=="Disconnected"; onClicked: root.act("wifi") }
                BarButton { id: bluetoothButton; icon: ""; selected: root.state.bluetooth; onClicked: root.act("bluetooth") }
                BarButton { icon: root.state.charging ? "󰂄" : "󰁹"; label: root.state.battery===null ? "AC" : root.state.battery+"%"; onClicked: root.opened=!root.opened }
                BarButton { label: root.state.clock; onClicked: root.opened=!root.opened }
            }
        }
    }

    PanelWindow {
        id: panel
        screen: root.selectedScreen
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: screen.width
        implicitHeight: screen.height
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "siverteh-observatory-panel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        Rectangle { anchors.fill: parent; color: "#20070f14"; MouseArea { anchors.fill: parent; onPressed: root.opened=false } }
        Rectangle {
            width: Math.min(790,panel.width-32); height: Math.min(570,panel.height-60); x: (panel.width-width)/2; y: 48; radius: 18; color: root.surface; border.color: "#3a5960"; border.width: 1
            MouseArea { anchors.fill: parent; onClicked: mouse => mouse.accepted=true }
            focus: true
            Keys.onEscapePressed: root.opened = false
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 26; spacing: 19
                RowLayout { Layout.fillWidth: true; Layout.preferredWidth: parent.width; spacing: 14
                    Logo { Layout.preferredWidth: 46; Layout.preferredHeight: 46 }
                    ColumnLayout { spacing: 2
                        Label { text: "Siverteh OS"; font.pixelSize: 23; font.weight: Font.Medium }
                        Label { text: root.state.date; color: root.quiet; font.pixelSize: 13 }
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: root.state.clock; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 28; color: root.accent }
                    Action { label: "×"; implicitWidth: 34; onClicked: root.opened=false }
                }
                RowLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 26
                    ColumnLayout { Layout.fillWidth: true; Layout.preferredWidth: 380; spacing: 15
                        Section { text: "Connections" }
                        RowLayout { Layout.fillWidth: true
                            Action { label: root.state.network; icon: "󰤨"; Layout.fillWidth: true; onClicked: { root.opened=false; root.act("wifi"); } }
                            Action { label: "Bluetooth"; icon: ""; selected: root.state.bluetooth; onClicked: { root.opened=false; root.act("bluetooth"); } }
                        }
                        Level { label: root.state.muted ? "Audio · muted" : "Audio"; icon: "󰕾"; amount: root.state.volume; onChanged: amount => root.act("volume",Math.round(amount)) }
                        Level { label: "Brightness"; icon: "󰃠"; amount: root.state.brightness; onChanged: amount => root.act("brightness",Math.round(amount)) }
                        RowLayout {
                            Action { label: "Output device"; icon: "󰓃"; onClicked: root.act("audio") }
                            Action { label: root.state.muted ? "Unmute" : "Mute"; onClicked: root.act("mute") }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#2c444b" }
                        Section { text: "Now playing" }
                        Label { text: root.state.media || "Nothing playing"; Layout.fillWidth: true; maximumLineCount: 2; wrapMode: Text.WordWrap }
                        RowLayout {
                            Action { icon: "󰒮"; implicitWidth: 44; onClicked: root.act("previous") }
                            Action { label: root.state.playback === "Playing" ? "Pause" : "Play"; icon: root.state.playback === "Playing" ? "󰏤" : "󰐊"; onClicked: root.act("play") }
                            Action { icon: "󰒭"; implicitWidth: 44; onClicked: root.act("next") }
                            Item { Layout.fillWidth: true }
                        }
                        Item { Layout.fillHeight: true }
                    }
                    Rectangle { Layout.fillHeight: true; width: 1; color: "#2c444b" }
                    ColumnLayout { Layout.preferredWidth: 255; spacing: 11
                        Section { text: root.state.month || "Calendar" }
                        GridLayout { columns: 7; columnSpacing: 5; rowSpacing: 5
                            Repeater { model: ["M","T","W","T","F","S","S"]
                                Label { required property string modelData; text: modelData; Layout.preferredWidth: 29; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 12; color: root.quiet }
                            }
                            Repeater { model: root.state.calendar
                                Rectangle { required property int modelData; width: 29; height: 27; radius: 6; color: modelData===root.state.today ? root.accent : "transparent"
                                    Label { anchors.centerIn: parent; text: modelData || ""; font.pixelSize: 12; color: modelData===root.state.today ? "#10272c" : root.ink }
                                }
                            }
                        }
                        Label { text: "Calendar dates · no account connected"; color: root.quiet; font.pixelSize: 11 }
                        Action { label: "Notifications" + (root.state.notifications ? "  "+root.state.notifications : ""); icon: "󰂚"; Layout.fillWidth: true; onClicked: { root.opened=false; root.act("notifications"); } }
                        RowLayout {
                            Action { label: "Wallpaper"; icon: "󰸉"; onClicked: { root.opened=false; root.act("wallpaper"); } }
                            Action { icon: "󰒟"; implicitWidth: 40; onClicked: root.act("rotate") }
                            Action { icon: "󰏤"; implicitWidth: 40; selected: root.state.wallpaperHold || false; onClicked: root.act("hold") }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#2c444b" }
                RowLayout { Layout.fillWidth: true; spacing: 8
                    Action { label: "Brain"; icon: "✦"; selected: true; onClicked: { root.opened=false; root.act("brain"); } }
                    Action { label: "AI workspace"; icon: ""; onClicked: { root.opened=false; root.act("tasks"); } }
                    Action { label: "Capture"; icon: "󰎞"; onClicked: { root.opened=false; root.act("capture"); } }
                    Item { Layout.fillWidth: true }
                    Action { icon: "󰌾"; implicitWidth: 40; onClicked: { root.opened=false; root.act("lock"); } }
                    Action { icon: "󰐥"; implicitWidth: 40; onClicked: { root.opened=false; root.act("power"); } }
                }
            }
        }
    }
}
