import QtQuick
import QtTest
import qs.widgets
import qs.services

TestCase {
    id: test
    name: "NacreFoundation"
    width: 800
    height: 500
    visible: true
    when: windowShown

    function init() {
        NacreTokens.reduceMotion = false;
        DesktopSettings.data = {
            animations: true
        };
    }
    function cleanup() {
        NacreTokens.reduceMotion = false;
        DesktopSettings.data = {
            animations: true
        };
    }
    function test_transparent_surface_and_explicit_geometry() {
        const view = createTemporaryObject(surface, test);
        compare(view.color.a, 0);
        compare(view.radius, 0);
        view.animateColor = false;
        view.color = "#123456";
        view.radius = 20;
        view.border.width = 2;
        view.border.color = "white";
        compare(String(view.color), "#123456");
        compare(view.radius, 20);
        compare(view.width, 120);
        compare(view.border.width, 2);
    }
    function test_text_metrics_theme_and_consumer_overrides() {
        const view = createTemporaryObject(label, test);
        compare(view.font.family, "IBM Plex Sans");
        compare(view.font.pointSize, 12);
        compare(view.textFormat, Text.PlainText);
        compare(view.renderType, Text.NativeRendering);
        verify(view.implicitWidth > 0);
        verify(view.implicitHeight > 0);
        view.width = 65;
        view.text = "Several words wrap naturally";
        view.wrapMode = Text.Wrap;
        view.forceLayout();
        verify(view.lineCount > 1);
        view.font.pointSize = 18;
        compare(view.font.pointSize, 18);
        const prior = Colours.palette;
        Colours.palette = Object.assign({}, prior, {
            m3onSurface: "#d4eac7"
        });
        compare(String(view.color), "#d4eac7");
        Colours.palette = prior;
        view.wrapMode = Text.NoWrap;
        view.elide = Text.ElideRight;
        view.forceLayout();
        verify(view.truncated);
    }
    function test_text_motion_settles_after_rapid_hidden_or_reduced_changes() {
        const view = createTemporaryObject(label, test, {
            animate: true,
            animateDuration: 70
        });
        compare(view.scale, 1);
        view.text = "Next";
        verify(view.textTransitionRunning);
        view.text = "Newest";
        wait(110);
        verify(!view.textTransitionRunning);
        compare(view.scale, 1);
        view.text = "Reduce";
        NacreTokens.reduceMotion = true;
        verify(!view.textTransitionRunning);
        compare(view.scale, 1);
        view.text = "No motion";
        verify(!view.textTransitionRunning);
        NacreTokens.reduceMotion = false;
        view.text = "Hide";
        view.visible = false;
        verify(!view.textTransitionRunning);
        compare(view.scale, 1);
        view.text = "Hidden update";
        verify(!view.textTransitionRunning);
    }
    function test_surface_color_motion_stops_with_motion_preference() {
        const view = createTemporaryObject(surface, test, {
            color: "#123456",
            transitionDuration: 100
        });
        view.color = "#aabbcc";
        wait(160);
        compare(String(view.color), "#aabbcc");
        view.color = "#ff0000";
        NacreTokens.reduceMotion = true;
        tryCompare(view, "color", Qt.color("#ff0000"));
        view.color = "#00ff00";
        compare(String(view.color), "#00ff00");
    }
    function test_round_hit_regions_hover_and_one_activation() {
        const view = createTemporaryObject(control, test);
        verify(!view.containsPoint(Qt.point(1, 1)));
        verify(view.containsPoint(Qt.point(50, 30)));
        mouseMove(view, 50, 30);
        tryCompare(view, "hovered", true);
        mouseClick(view, 1, 1);
        compare(view.clicks, 0);
        mouseClick(view, 50, 30);
        compare(view.clicks, 1);
        verify(!view.pressed);
        verify(!view.keyboardFocusVisible);
        mouseMove(test, 500, 450);
        tryCompare(view, "hovered", false);
    }
    function test_disabled_and_hidden_controls_never_activate() {
        const view = createTemporaryObject(control, test);
        view.disabled = true;
        verify(!view.activeFocusOnTab);
        mouseClick(view, 50, 30);
        compare(view.clicks, 0);
        view.activate(null);
        compare(view.clicks, 0);
        verify(!view.hovered);
        view.disabled = false;
        view.enabled = false;
        view.activate(null);
        compare(view.clicks, 0);
        view.enabled = true;
        view.visible = false;
        view.activate(null);
        compare(view.clicks, 0);
    }
    function test_keyboard_focus_activation_and_escape_propagation() {
        const view = createTemporaryObject(control, test);
        view.forceActiveFocus(Qt.TabFocusReason);
        tryCompare(view, "activeFocus", true);
        verify(view.keyboardFocusVisible);
        const ring = findChild(view, "nacreInteractionFocus");
        verify(ring.visible);
        compare(ring.radius, view.radius);
        keyClick(Qt.Key_Return);
        compare(view.clicks, 1);
        keyPress(Qt.Key_Space);
        verify(view.pressed);
        compare(view.clicks, 1);
        keyRelease(Qt.Key_Space);
        compare(view.clicks, 2);
        verify(!view.pressed);
        keyClick(Qt.Key_Escape);
        compare(test.escapes, 1);
        keyPress(Qt.Key_Space);
        view.disabled = true;
        keyRelease(Qt.Key_Space);
        compare(view.clicks, 2);
    }
    function test_pending_feedback_is_safe_when_control_is_destroyed() {
        const view = control.createObject(test);
        verify(view);
        mouseMove(view, 50, 30);
        view.visible = false;
        view.destroy();
        NacreTokens.reduceMotion = true;
        wait(30);
    }

    function test_production_action_button_uses_new_interaction() {
        const view = createTemporaryObject(button, test);
        verify(view.implicitWidth > 60);
        compare(view.implicitHeight, 34);
        compare(view.radius, 17);
        const interaction = view.children.find(child => child.activated !== undefined);
        verify(interaction);
        compare(interaction.Accessible.name, "Action");
        mouseClick(view, view.width / 2, 17);
        compare(view.clicks, 1);
        view.enabled = false;
        mouseClick(view, view.width / 2, 17);
        compare(view.clicks, 1);
    }

    property int escapes: 0
    Keys.onEscapePressed: escapes += 1
    Component {
        id: surface
        StyledRect {
            width: 120
            height: 60
        }
    }
    Component {
        id: label
        StyledText {
            text: "Foundation"
        }
    }
    Component {
        id: control
        StateLayer {
            anchors.fill: undefined
            width: 100
            height: 60
            radius: 30
            property int clicks: 0
            function onClicked(event) {
                clicks += 1;
            }
        }
    }
    Component {
        id: button
        ActionButton {
            text: "Action"
            width: implicitWidth
            height: implicitHeight
            property int clicks: 0
            onClicked: clicks += 1
        }
    }
}
