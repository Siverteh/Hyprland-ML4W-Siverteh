import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test
    name: "NacreWorkspaces"
    width: 1100
    height: 1100
    visible: true
    when: windowShown
    Component {
        id: page
        NacreWorkspacePage {
            visibilities: QtObject {
                property bool dashboard: true
                property bool previewOnly: false
            }
        }
    }
    function init() {
        Hyprland.request = "";
        Hyprland.clients = [
            {
                workspace: 1,
                wmClass: "chrome",
                title: "A tab"
            },
            {
                workspace: {
                    id: 1
                },
                wmClass: "chrome",
                title: "Other tab"
            },
            {
                workspace: 2,
                wmClass: "unknown",
                title: "My editor"
            }
        ];
    }
    function test_counts_metadata_and_single_dispatch() {
        const view = createTemporaryObject(page, test);
        wait(20);
        compare(view.clientsFor(1).length, 2);
        compare(view.summary(1), "Browser");
        compare(view.summary(2), "My editor");
        compare(view.summary(7), "Empty");
        mouseClick(findChild(view, "workspaceCard3"), 40, 40);
        compare(Hyprland.request, "workspace 3");
        compare(view.visibilities.dashboard, false);
    }
    function test_invalid_hidden_preview_and_narrow_geometry() {
        const view = createTemporaryObject(page, test);
        wait(10);
        for (const invalid of [0, 8, -1, NaN, 2.5])
            view.activate(invalid);
        compare(Hyprland.request, "");
        view.visibilities.previewOnly = true;
        view.activate(2);
        compare(Hyprland.request, "");
        view.visibilities.previewOnly = false;
        view.visibilities.dashboard = false;
        view.activate(2);
        compare(Hyprland.request, "");
        for (const width of [300, 508, 796]) {
            view.width = width;
            wait(40);
            for (let id = 1; id <= 7; id++) {
                const card = findChild(view, "workspaceCard" + id);
                const point = card.mapToItem(view, 0, 0);
                verify(point.x + card.width <= width + .01, width + " / " + id + " x=" + point.x + " width=" + card.width);
            }
        }
    }
}
