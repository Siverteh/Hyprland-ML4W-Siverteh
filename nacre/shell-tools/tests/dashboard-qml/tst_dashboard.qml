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
        for (const [index, name] of ["NacreOverview", "NacreMediaPage", "NacrePerformancePage", "NacreWorkspacePage"].entries()) {
            mouseClick(findChild(view, "dashboardTab" + index), 35, 35);
            compare(view.visibilities.dashboardTab, index);
            compare(navigation.currentIndex, index);
            compare(marker.x, index * navigation.width / 4 + 16);
            compare(view.visibilities.dashboardPinned, false);
            compare(loader.item.pageName, name);
        }
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
        tryCompare(view, "height", 0, 500);
        compare(loader.active, false);
        compare(loader.item, null);
    }
    function test_legacy_settings_tab_is_not_a_dashboard_page() {
        const view = createTemporaryObject(panel, test);
        view.visibilities.dashboardTab = 4;
        wait(30);
        compare(view.currentIndex, 0);
        compare(findChild(view, "dashboardPage").item.pageName, "NacreOverview");
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
