import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets
import qs.modules.drawers

ShellRoot {
    FloatingWindow {
        id: window
        visible: true
        implicitWidth: 600
        implicitHeight: 400
        color: "#567d9a"
        mask: NacrePanelMask {
            id: region
            controller: input
        }
        Item {
            id: sheet
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                color: "#567d9a"
            }
            NacreChrome {
                anchors.fill: parent
                host: host
            }
            Item {
                id: host
                x: NacreFrame.left
                y: NacreFrame.headerHeight
                width: sheet.width - NacreFrame.left - NacreFrame.right
                height: sheet.height - NacreFrame.headerHeight - NacreFrame.bottom
                property alias dashboard: dash
                property alias launcher: launch
                property alias leftDrawer: left
                property alias osd: osd
                property alias session: session
                property alias popouts: popup
                property alias notifications: notice
                Item {
                    id: dash
                    x: 190
                    width: 0
                    height: 0
                }
                Item {
                    id: launch
                    property bool fullScreenGallery: false
                    x: 100
                    y: 250
                    width: 0
                    height: 0
                }
                Item {
                    id: left
                    y: 90
                    width: 0
                    height: 150
                }
                Item {
                    id: osd
                    y: 100
                    x: 500
                    width: 0
                    height: 140
                }
                Item {
                    id: session
                    width: 0
                    height: 0
                }
                Item {
                    id: popup
                    width: 0
                    height: 0
                    property bool joinsRight: false
                    property bool hasCurrent: false
                    property bool pinned: false
                    property bool headerHovered: false
                }
                Item {
                    id: notice
                    x: host.width - width
                    width: 0
                    height: 0
                }
            }
            QtObject {
                id: flags
                property bool previewOnly: true
                property bool launcher: false
                property bool dashboard: false
                property bool dashboardPinned: false
                property bool left: false
                property bool leftPinned: false
                property bool osd: false
                property bool session: false
                property string edgeMenu: ""
            }
            NacrePanelInput {
                id: input
                anchors.fill: parent
                panels: host
                visibilities: flags
                screen: ({
                        name: "test",
                        width: 600,
                        height: 400
                    })
            }
        }
        property int phase: 0
        Timer {
            id: capture
            interval: 300
            running: true
            onTriggered: {
                sheet.grabToImage(result => {
                    const names = ["closed", "joined", "recoloured", "no-edges", "notice-joined", "gallery-clear"];
                    if (!result.saveToFile(names[window.phase] + ".png"))
                        throw new Error("capture failed");
                    console.log("FRAME_CAPTURE " + names[window.phase]);
                    if (window.phase === 0) {
                        dash.width = 200;
                        dash.height = 100;
                        flags.dashboard = true;
                        flags.launcher = true;
                        launch.width = 300;
                        launch.height = 90;
                    } else if (window.phase === 1) {
                        flags.launcher = false;
                        if (input.launcherRect.width !== 0 || region.regions[1].width !== 0)
                            throw new Error("closing retained input region");
                        if (launch.width !== 300)
                            throw new Error("missing closing geometry");
                        NacreColours.palette = Object.assign({}, NacreColours.palette, {
                            m3surface: "#0c2e22"
                        });
                    } else if (window.phase === 2) {
                        dash.width = 0;
                        dash.height = 0;
                        launch.width = 0;
                        launch.height = 0;
                        flags.dashboard = false;
                        NacreFrame.left = 0;
                        NacreFrame.right = 0;
                        NacreFrame.bottom = 0;
                        NacreFrame.headerHeight = 0;
                    } else if (window.phase === 3) {
                        NacreFrame.left = 10;
                        NacreFrame.right = 10;
                        NacreFrame.bottom = 10;
                        NacreFrame.headerHeight = 50;
                        notice.width = 200;
                        notice.height = 100;
                    } else if (window.phase === 4) {
                        notice.width = 0;
                        notice.height = 0;
                        launch.x = 0;
                        launch.y = 0;
                        launch.width = host.width;
                        launch.height = host.height;
                        launch.fullScreenGallery = true;
                    } else {
                        console.log("FRAME_NATIVE_OK");
                        Qt.quit();
                        return;
                    }
                    window.phase++;
                    capture.restart();
                });
            }
        }
    }
}
