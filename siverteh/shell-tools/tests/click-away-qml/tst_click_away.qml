import QtQuick
import QtTest

TestCase {
    id: test
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
            screen: null
            visibilities: QtObject {
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
    function test_clicks_inside_keep_open_and_outside_dismiss() {
        const view = createTemporaryObject(scene, test);
        verify(view);
        mouseClick(view, 150, 400);
        verify(view.visibilities.launcher);
        mouseClick(view, 50, 100);
        verify(!view.visibilities.launcher);
    }
    function test_right_click_outside_also_dismisses() {
        const view = createTemporaryObject(scene, test);
        verify(view);
        mouseClick(view, 450, 400, Qt.RightButton);
        verify(!view.visibilities.launcher);
    }
}
