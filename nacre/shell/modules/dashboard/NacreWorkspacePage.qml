import QtQuick
import Quickshell
import qs.widgets
import qs.services
import qs.config
import qs.utils

Item {
    id: root
    required property PersistentProperties visibilities
    readonly property int columns: Math.max(1, Math.min(4, Math.floor((width + 12) / 200)))
    readonly property int rows: Math.ceil(7 / columns)
    implicitWidth: 796
    implicitHeight: 50 + rows * 134 + (rows - 1) * 12
    function clientsFor(id) {
        return NacreHyprland.clients.filter(c => (typeof c.workspace === "number" ? c.workspace : c.workspace?.id) === id);
    }
    function summary(id) {
        const names = clientsFor(id).map(c => NacreIcons.getDesktopEntry(c.wmClass)?.name || c.title || c.wmClass || "Window");
        return [...new Set(names)].join(", ") || "Empty";
    }
    function activate(id) {
        if (!Number.isInteger(id) || id < 1 || id > 7 || !visibilities.dashboard || visibilities.previewOnly)
            return;
        NacreHyprland.dispatch("workspace " + id);
        visibilities.dashboard = false;
    }
    Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: root.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        FastScroll {
            view: scroll
        }
        NacreText {
            text: "Workspaces"
            font.pointSize: 18
        }
        Grid {
            y: 50
            width: parent.width
            columns: root.columns
            spacing: 12
            Repeater {
                model: 7
                delegate: NacreSurface {
                    id: card
                    required property int index
                    readonly property int workspaceId: index + 1
                    readonly property color ink: NacreHyprland.activeWsId === workspaceId ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
                    objectName: "workspaceCard" + workspaceId
                    width: (parent.width - (root.columns - 1) * 12) / root.columns
                    height: 134
                    radius: 18
                    color: NacreHyprland.activeWsId === workspaceId ? NacreColours.palette.m3primaryContainer : NacreColours.palette.m3surfaceContainer
                    Column {
                        x: 16
                        y: 16
                        width: parent.width - 32
                        spacing: 12
                        Row {
                            width: parent.width
                            spacing: 8
                            NacreIcon {
                                text: NacreBar.workspaceIcons[card.index] || "apps"
                                font.pointSize: 15
                                color: card.ink
                            }
                            NacreText {
                                width: Math.max(0, parent.width - 30)
                                text: card.workspaceId + " " + (NacreBar.workspaceNames[card.index] || "Workspace")
                                font.pointSize: 12
                                font.weight: Font.DemiBold
                                color: card.ink
                                elide: Text.ElideRight
                            }
                        }
                        NacreText {
                            objectName: "workspaceSummary" + card.workspaceId
                            width: parent.width
                            text: root.summary(card.workspaceId)
                            font.pointSize: 11
                            color: NacreHyprland.activeWsId === card.workspaceId ? card.ink : NacreTokens.mutedInk
                            elide: Text.ElideRight
                        }
                        NacreText {
                            width: parent.width
                            text: root.clientsFor(card.workspaceId).length + " " + (root.clientsFor(card.workspaceId).length === 1 ? "window" : "windows")
                            font.pointSize: 9
                            color: NacreHyprland.activeWsId === card.workspaceId ? card.ink : NacreTokens.mutedInk
                        }
                    }
                    NacreInteraction {
                        accessibleName: "Open workspace " + card.workspaceId + " " + (NacreBar.workspaceNames[card.index] || "")
                        function onClicked() {
                            root.activate(card.workspaceId);
                        }
                    }
                }
            }
        }
    }
}
