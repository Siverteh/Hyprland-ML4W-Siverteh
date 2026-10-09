import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test
    name: "NacreDashboardAssembly"
    width: 1200
    height: 1000
    visible: true
    when: windowShown
    Component {
        id: panel
        NacreDashboardPanel {
            visibilities: QtObject {
                property bool dashboard: true
                property bool dashboardPinned: false
                property int dashboardTab: 0
            }
        }
    }
    function init() {
        DesktopSettings.data = {
            animations: true
        };
    }
    function test_pages_and_immediate_navigation_pinning() {
        const view = createTemporaryObject(panel, test);
        wait(300);
        const loader = findChild(view, "dashboardPage");
        const navigation = findChild(view, "dashboardNavigation");
        const marker = findChild(view, "dashboardSelection");
        compare(loader.item.pageName, "NacreOverview");
        compare(loader.item.shouldUpdate, true);
        for (const [index, name] of ["NacreOverview", "NacreMediaPage", "NacrePerformancePage", "NacreWorkspacePage", "Settings"].entries()) {
            mouseClick(findChild(view, "dashboardTab" + index), 35, 35);
            compare(view.visibilities.dashboardTab, index);
            compare(navigation.currentIndex, index);
            compare(marker.x, index * navigation.width / 5 + 16);
            compare(view.visibilities.dashboardPinned, index === 4);
            compare(loader.item.pageName, name);
        }
        verify(loader.item.active);
        mouseClick(findChild(view, "dashboardTab0"), 35, 35);
        compare(view.visibilities.dashboardPinned, false);
    }
    function test_closing_keeps_internal_geometry_then_unloads_and_reverses() {
        const view = createTemporaryObject(panel, test);
        wait(300);
        const loader = findChild(view, "dashboardPage");
        const content = loader.height;
        view.visibilities.dashboard = false;
        wait(90);
        verify(loader.active);
        compare(loader.height, content);
        compare(loader.item.shouldUpdate, false);
        verify(view.height > 0);
        view.visibilities.dashboard = true;
        wait(300);
        verify(loader.item.shouldUpdate);
        view.visibilities.dashboard = false;
        wait(300);
        compare(view.height, 0);
        compare(loader.active, false);
        compare(loader.item, null);
    }
    function test_settings_hidden_updates_and_escape() {
        const view = createTemporaryObject(panel, test);
        wait(300);
        view.select(4);
        const loader = findChild(view, "dashboardPage");
        verify(loader.item.active);
        view.visibilities.dashboard = false;
        compare(loader.item.active, false);
        view.visibilities.dashboard = true;
        view.forceActiveFocus();
        keyClick(Qt.Key_Escape);
        compare(view.visibilities.dashboard, false);
        compare(view.visibilities.dashboardPinned, false);
    }
    function test_viewport_and_reduced_motion() {
        DesktopSettings.data = {
            animations: false
        };
        const host = Qt.createQmlObject('import QtQuick; Item {width: 600;height: 500}', test);
        const view = createTemporaryObject(panel, host);
        wait(30);
        verify(view.width <= host.width - 48);
        verify(view.height <= host.height - 64);
        view.visibilities.dashboard = false;
        wait(10);
        compare(view.height, 0);
        compare(findChild(view, "dashboardPage").active, false);
        host.destroy();
    }
}
