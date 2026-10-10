import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test
    name: "NacreDesktopWrappers"
    width: 800
    height: 600
    visible: true
    when: windowShown
    function init() {
        DesktopSettings.data = {
            animations: true
        };
        NacreAudio.available = false;
        NacreAudio.volume = 0;
        NacreAudio.writes = [];
        NacreKeyboardLight.writes = [];
        NacreBrightness.device.writes = [];
        WallpaperPlayback.locked = false;
        WallpaperPlayback.sleeping = false;
        WallpaperPlayback.paused = false;
        WallpaperPlayback.batteryPaused = false;
        NacreHyprland.focusedMonitor = {
            name: "test"
        };
        NacreHyprland.clients = [];
        NacrePanelState.screens = ({});
        NacreWallpapers.displayDynamic = false;
        NacreWallpapers.displayAnimated = false;
        NacrePresentation.pending = ({});
        NacrePresentation.active = ({});
        NacrePresentation.activations = [];
        AppLaunch.calls = [];
    }
    Component {
        id: osd
        NacreOsdPanel {
            screen: ({
                    name: "test"
                })
            visibility: false
        }
    }
    Component {
        id: events
        NacreOsdEvents {
            screen: ({
                    name: "test"
                })
            visibilities: QtObject {
                property bool osd: false
                property bool session: false
            }
            hovered: false
        }
    }
    Component {
        id: session
        NacreSessionPanel {
            visibilities: QtObject {
                property bool session: false
            }
        }
    }
    Component {
        id: scene
        NacreWallpaperScene {
            screenName: "test"
            width: 240
            height: 180
            source: ""
        }
    }
    property var sessionTarget: null
    Keys.onEscapePressed: event => {
        if (sessionTarget) {
            sessionTarget.visibilities.session = false;
            event.accepted = true;
        }
    }
    function test_session_focus_and_escape_reach_parent_controller() {
        const panel = createTemporaryObject(session, test);
        sessionTarget = panel;
        panel.visibilities.session = true;
        tryCompare(panel, "focus", true, 400);
        keyClick(Qt.Key_Escape);
        verify(!panel.visibilities.session);
        compare(AppLaunch.calls.length, 0);
        sessionTarget = null;
    }
    function test_ready_image_waits_for_late_matching_presentation() {
        const view = createTemporaryObject(scene, test);
        const path = decodeURIComponent(Qt.resolvedUrl("first.png").toString().slice(7));
        view.source = view.fileUrl(path);
        tryCompare(view.current, "status", Image.Ready, 1000);
        compare(view.displayedPath, "");
        NacrePresentation.pending = {
            poster: path
        };
        NacrePresentation.revision++;
        tryCompare(view, "displayedPath", path, 1000);
        compare(NacrePresentation.active.poster, path);
    }
    function test_osd_startup_readonly_user_actions_and_close_retention() {
        const panel = createTemporaryObject(osd, test);
        panel.visibility = true;
        tryVerify(() => panel.width > 0, 300);
        compare(NacreAudio.writes.length, 0);
        compare(NacreBrightness.device.writes.length, 0);
        NacreAudio.available = true;
        NacreAudio.volume = .6;
        const slider = findChild(panel, "osdVolume");
        compare(slider.value, .6);
        compare(NacreAudio.writes.length, 0);
        slider.value = .7;
        slider.moved();
        compare(NacreAudio.writes[0], .7);
        const keyboard = findChild(panel, "osdKeyboard");
        keyboard.value = .3;
        keyboard.moved();
        compare(NacreKeyboardLight.writes[0], .3);
        panel.visibility = false;
        verify(!panel.enabled);
        verify(panel.width > 0);
        wait(240);
        compare(panel.width, 0);
        DesktopSettings.data = {
            animations: false
        };
        panel.visibility = true;
        verify(panel.width >= 170 && panel.width <= 240);
        panel.visibility = false;
        compare(panel.width, 0);
    }
    function test_level_controls_are_two_by_two_with_contained_mutes() {
        DesktopSettings.data = {
            animations: false
        };
        const panel = createTemporaryObject(osd, test);
        panel.visibility = true;
        wait(0);
        const names = ["Screen", "Keyboard", "Volume", "Microphone"];
        const controls = names.map(name => findChild(panel, "osd" + name));
        verify(controls.every(control => !!control));
        const positions = controls.map(control => control.mapToItem(panel, 0, 0));
        compare(positions[0].y, positions[1].y);
        compare(positions[2].y, positions[3].y);
        verify(positions[0].x < positions[1].x && positions[2].x < positions[3].x);
        const verticalGap = positions[2].y - positions[0].y - controls[0].height;
        const horizontalGap = positions[1].x - positions[0].x - controls[0].width;
        verify(verticalGap >= 24 && verticalGap <= 40);
        verify(horizontalGap >= 36 && horizontalGap <= 52);
        verify(panel.height <= 350);
        for (let i = 0; i < controls.length; i++) {
            verify(positions[i].x >= 0 && positions[i].x + controls[i].width <= panel.width);
            verify(positions[i].y >= 0 && positions[i].y + controls[i].height <= panel.height);
            const level = controls[i].parent;
            const lower = level.mapToItem(panel, 0, level.height).y;
            verify(lower <= panel.height);
        }
        compare(NacreAudio.writes.length, 0);
        compare(NacreKeyboardLight.writes.length, 0);
        compare(NacreBrightness.device.writes.length, 0);
    }
    function test_osd_ready_baseline_focus_hover_and_deadline() {
        const view = createTemporaryObject(events, test);
        wait(1);
        NacreAudio.available = true;
        NacreAudio.volume = .4;
        wait(1);
        verify(!view.visibilities.osd);
        NacreAudio.volume = .5;
        verify(view.visibilities.osd);
        view.hovered = true;
        wait(120);
        verify(view.visibilities.osd);
        view.hovered = false;
        tryCompare(view.visibilities, "osd", false, 200);
        NacreHyprland.focusedMonitor = {
            name: "other"
        };
        NacreBrightness.device.adjusted();
        verify(!view.visibilities.osd);
        NacreHyprland.focusedMonitor = {
            name: "test"
        };
        NacreKeyboardLight.adjusted();
        verify(view.visibilities.osd);
        view.visibilities.osd = false;
        WallpaperPlayback.locked = true;
        NacreKeyboardLight.adjusted();
        verify(!view.visibilities.osd);
    }
    function test_session_display_no_commands_allowlist_and_closing() {
        const panel = createTemporaryObject(session, test);
        panel.visibilities.session = true;
        tryVerify(() => panel.width > 0, 300);
        compare(AppLaunch.calls.length, 0);
        const controls = panel.children[0].item;
        verify(controls);
        verify(!controls.activate("unknown"));
        compare(AppLaunch.calls.length, 0);
        verify(controls.activate("lock"));
        compare(AppLaunch.calls[0].join("|"), "loginctl|lock-session");
        verify(!panel.visibilities.session);
        verify(!controls.activate("restart"));
        wait(240);
        compare(panel.width, 0);
    }
    function record(view, file) {
        const path = decodeURIComponent(Qt.resolvedUrl(file).toString().slice(7));
        NacrePresentation.pending = {
            poster: path
        };
        view.source = view.fileUrl(path);
        return path;
    }
    function test_poster_latest_ready_pair_opaque_underlayer_and_literal_percent() {
        const view = createTemporaryObject(scene, test);
        const first = record(view, "first.png");
        tryCompare(view, "displayedPath", first, 1000);
        compare(view.current.opacity, 1);
        const old = view.current;
        const second = record(view, "second.png");
        tryCompare(view, "displayedPath", second, 1000);
        verify(view.transitioning);
        compare(old.opacity, 1);
        compare(NacrePresentation.active.poster, second);
        const third = record(view, "percent % picture.png");
        tryCompare(view, "displayedPath", third, 1500);
        wait(350);
        verify(!view.transitioning);
        compare(view.current.opacity, 1);
        compare(NacrePresentation.active.poster, third);
        compare(NacrePresentation.activations.length, 3);
    }
    function test_motion_policy_changes_do_not_publish_or_write() {
        const view = createTemporaryObject(scene, test);
        verify(view.motionAllowed);
        WallpaperPlayback.sleeping = true;
        verify(!view.motionAllowed);
        WallpaperPlayback.sleeping = false;
        WallpaperPlayback.locked = true;
        verify(!view.motionAllowed);
        WallpaperPlayback.locked = false;
        NacrePanelState.screens = {
            test: {
                launcher: true,
                launcherMode: "wallpaper"
            }
        };
        verify(!view.motionAllowed);
        NacrePanelState.screens = ({});
        NacreHyprland.clients = [
            {
                workspace: {
                    id: 1
                },
                floating: false,
                fullscreen: false
            }
        ];
        verify(!view.motionAllowed);
        compare(NacrePresentation.activations.length, 0);
        compare(AppLaunch.calls.length, 0);
    }
}
