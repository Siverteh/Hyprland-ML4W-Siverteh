pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.widgets
import qs.services
import "settings"
import "settings-catalog.js" as Catalog

Item {
    id: root
    property bool active: true
    property string page: Visibilities.settingsPage
    property string query: ""
    readonly property var pages: Catalog.pages
    readonly property var current: Catalog.find(page)
    readonly property var matches: Catalog.search(query)
    readonly property bool narrow: width < 760
    implicitWidth: 1120
    implicitHeight: 740
    function open(id) {
        const target = Catalog.find(id).id;
        page = target;
        query = "";
        if (Visibilities.settingsPage !== target)
            Visibilities.settingsPage = target;
        if (scroll)
            scroll.contentY = 0;
    }
    onPageChanged: if (scroll)
        scroll.contentY = 0
    onQueryChanged: if (scroll)
        scroll.contentY = 0
    Connections {
        target: Visibilities
        function onSettingsPageChanged() {
            root.open(Visibilities.settingsPage);
        }
    }
    NacreSurface {
        id: rail
        x: 0
        y: 0
        width: root.narrow ? root.width : 190
        height: root.narrow ? 160 : root.height
        radius: 18
        color: Colours.palette.m3surfaceContainer
        Row {
            x: 14
            y: 14
            spacing: 8
            BrandLogo {
                width: 26
                height: 26
            }
            NacreText {
                text: "Settings"
                font.pointSize: 16
                color: NacreTokens.accent
            }
        }
        NacreTextField {
            objectName: "settingsSearch"
            x: 12
            y: 52
            width: parent.width - 24
            height: 40
            padding: 10
            text: root.query
            placeholderText: "Search settings"
            onTextEdited: root.query = text
            onAccepted: if (root.matches.length)
                root.open(root.matches[0].id)
        }
        ListView {
            id: categories
            objectName: "settingsCategories"
            x: 10
            y: 100
            width: parent.width - 20
            height: parent.height - 110
            orientation: root.narrow ? ListView.Horizontal : ListView.Vertical
            model: root.pages
            spacing: 4
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            delegate: NacreSurface {
                required property var modelData
                width: root.narrow ? 130 : categories.width
                height: 38
                radius: 19
                color: root.page === modelData.id ? Colours.palette.m3secondaryContainer : "transparent"
                Row {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 9
                    NacreIcon {
                        text: parent.parent.modelData.icon
                        font.pointSize: 14
                    }
                    NacreText {
                        text: parent.parent.modelData.label
                        width: root.narrow ? 88 : 120
                        font.pointSize: 10
                        elide: Text.ElideRight
                    }
                }
                NacreInteraction {
                    accessibleName: parent.modelData.label
                    function onClicked() {
                        root.open(parent.modelData.id);
                    }
                }
            }
            FastScroll {
                view: categories
            }
        }
    }
    Flickable {
        id: scroll
        objectName: "settingsScroll"
        x: root.narrow ? 0 : 214
        y: root.narrow ? 172 : 0
        width: Math.max(0, parent.width - x)
        height: Math.max(0, parent.height - y)
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        FastScroll {
            view: scroll
        }
        Column {
            id: body
            width: parent.width
            spacing: 20
            NacreText {
                width: parent.width
                text: root.query.trim() ? "Search results" : root.current.label
                font.pointSize: 21
                color: NacreTokens.accent
                wrapMode: Text.Wrap
            }
            NacreText {
                width: parent.width
                text: root.query.trim() ? root.matches.length + " matching sections" : root.current.detail
                font.pointSize: 11
                color: NacreTokens.mutedInk
                wrapMode: Text.Wrap
            }
            Column {
                width: parent.width
                spacing: 10
                visible: root.query.trim().length > 0
                Repeater {
                    model: root.query.trim() ? root.matches : []
                    delegate: NacreSurface {
                        required property var modelData
                        width: parent.width
                        height: 78
                        radius: 16
                        color: Colours.palette.m3surfaceContainer
                        Column {
                            x: 16
                            y: 14
                            width: parent.width - 32
                            spacing: 8
                            NacreText {
                                width: parent.width
                                text: parent.parent.modelData.label
                                font.pointSize: 13
                                elide: Text.ElideRight
                            }
                            NacreText {
                                width: parent.width
                                text: parent.parent.modelData.detail
                                font.pointSize: 10
                                color: NacreTokens.mutedInk
                                elide: Text.ElideRight
                            }
                        }
                        NacreInteraction {
                            accessibleName: parent.modelData.label
                            function onClicked() {
                                root.open(parent.modelData.id);
                            }
                        }
                    }
                }
            }
            Loader {
                id: loaded
                objectName: "settingsPage"
                width: parent.width
                active: root.active && !root.query.trim()
                sourceComponent: ({
                        appearance: appearance,
                        desktop: desktop,
                        displays: displays,
                        sound: sound,
                        network: network,
                        bluetooth: bluetooth,
                        notifications: notifications,
                        workflows: workflows,
                        lock: lock,
                        time: time,
                        ai: ai,
                        maintenance: maintenance
                    })[root.current.kind]
            }
        }
    }
    Component {
        id: appearance
        NacreAppearancePage {}
    }
    Component {
        id: desktop
        DesktopControls {
            page: "desktop"
        }
    }
    Component {
        id: displays
        DesktopControls {
            page: "displays"
        }
    }
    Component {
        id: sound
        SoundPage {}
    }
    Component {
        id: network
        NetworkPage {}
    }
    Component {
        id: bluetooth
        BluetoothPage {}
    }
    Component {
        id: notifications
        NotificationPage {}
    }
    Component {
        id: workflows
        DesktopControls {
            page: "workflows"
        }
    }
    Component {
        id: lock
        LockPage {}
    }
    Component {
        id: time
        TimePage {}
    }
    Component {
        id: ai
        AiPage {}
    }
    Component {
        id: maintenance
        DesktopControls {
            page: "maintenance"
        }
    }
    IpcHandler {
        target: "settingsView"
        function open(page: string): void {
            root.open(page);
        }
        function state(): string {
            return JSON.stringify({
                page: root.page,
                search: root.query,
                width: root.width,
                height: root.height
            });
        }
    }
}
