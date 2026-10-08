import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test

    function test_edge_guard_rearms_only_after_leaving_and_respects_drag_fullscreen() {
        const screen = {
            "name": "test",
            "width": 500,
            "height": 600
        };
        HoverIntent.observe(screen, 250, 1);
        HoverIntent.dismiss(screen);
        verify(!HoverIntent.canOpen("dashboard", screen, Qt.NoButton));
        HoverIntent.observe(screen, 250, 2);
        verify(!HoverIntent.canOpen("dashboard", screen, Qt.NoButton));
        HoverIntent.observe(screen, 250, 40);
        verify(HoverIntent.canOpen("dashboard", screen, Qt.NoButton));
        verify(!HoverIntent.canOpen("dashboard", screen, Qt.LeftButton));
        Hyprland.activeClient = {
            "lastIpcObject": {
                "fullscreen": 2
            }
        };
        verify(!HoverIntent.canOpen("dashboard", screen, Qt.NoButton));
        Hyprland.activeClient = {
            "lastIpcObject": {
                "fullscreen": 1
            }
        };
        verify(HoverIntent.canOpen("dashboard", screen, Qt.NoButton));
        Hyprland.activeClient = null;
    }

    function test_clicks_inside_keep_open_and_outside_dismiss() {
        const view = createTemporaryObject(scene, test);
        verify(view);
        mouseClick(view, 150, 400);
        verify(view.visibilities.launcher);
        mouseClick(view, 50, 100);
        verify(!view.visibilities.launcher);
    }

    function test_click_opened_sidebar_stays_open_without_pinning_and_dismisses_outside() {
        const view = createTemporaryObject(scene, test);
        view.visibilities.launcher = false;
        view.visibilities.edgeMenu = "left";
        view.visibilities.left = true;
        mouseMove(view, 400, 500);
        wait(160);
        verify(view.visibilities.left);
        verify(!view.visibilities.leftPinned);
        mouseClick(view, 150, 200);
        verify(view.visibilities.left);
        mouseClick(view, 450, 500);
        verify(!view.visibilities.left);
    }

    function test_click_opened_controls_stay_open_and_dismiss_outside() {
        const view = createTemporaryObject(scene, test);
        view.visibilities.launcher = false;
        view.visibilities.edgeMenu = "osd";
        view.visibilities.osd = true;
        mouseMove(view, 20, 500);
        wait(160);
        verify(view.visibilities.osd);
        mouseClick(view, 350, 200);
        verify(view.visibilities.osd);
        mouseClick(view, 20, 500);
        verify(!view.visibilities.osd);
    }

    function test_right_click_outside_also_dismisses() {
        const view = createTemporaryObject(scene, test);
        verify(view);
        mouseClick(view, 450, 400, Qt.RightButton);
        verify(!view.visibilities.launcher);
    }

    name: "ClickAway"
    width: 500
    height: 600
    visible: true
    when: windowShown

    Component {
        id: scene

        Interactions {
            width: 500
            height: 600

            screen: QtObject {
                property string name: "test"
                property int width: 500
                property int height: 600
            }

            visibilities: QtObject {
                property string edgeMenu: ""
                property bool dashboardPinned: false
                property bool launcher: true
                property bool left: false
                property bool leftPinned: false
                property bool dashboard: false
                property bool osd: false
                property bool session: false
            }

            popouts: QtObject {
                property bool hasCurrent: false
                property bool headerHovered: false
                property bool pinned: false
            }

            bar: Item {
                implicitWidth: 10
            }

            panels: Item {
                property alias launcher: panel
                property alias leftDrawer: leftPanel
                property alias osd: rightPanel
                property alias dashboard: dashboardPanel
                property alias session: rightPanel

                Item {
                    id: leftPanel

                    x: 10
                    y: 100
                    width: 200
                    height: 300
                }

                Item {
                    id: rightPanel

                    x: 300
                    y: 100
                    width: 190
                    height: 300
                }

                Item {
                    id: dashboardPanel

                    x: 100
                    y: 0
                    width: 300
                    height: 200
                }

                Item {
                    id: panel

                    x: 100
                    y: 350
                    width: 200
                    height: 200
                }

            }

        }

    }

}
