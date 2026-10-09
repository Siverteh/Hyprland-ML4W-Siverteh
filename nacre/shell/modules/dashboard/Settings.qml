import qs.widgets
import qs.services
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "settings"

Item {
    id: root
    implicitWidth: Math.min(1120, Quickshell.screens[0].width - 100)
    implicitHeight: Math.min(740, Quickshell.screens[0].height - 220)
    property bool active: true
    property string page: Visibilities.settingsPage
    property string query: ""
    readonly property var pages: [
        {
            id: "appearance",
            label: "NacreAppearance",
            icon: "palette",
            detail: "Wallpaper, colors and desktop frame",
            terms: "wallpaper colors theme dark light frame top bar edge corners radius"
        },
        {
            id: "desktop",
            label: "Desktop",
            icon: "desktop_windows",
            detail: "Windows, effects and input",
            terms: "windows spacing gaps border animations blur shadows focus mouse touchpad natural scroll"
        },
        {
            id: "displays",
            label: "Displays",
            icon: "monitor",
            detail: "Screens, scaling and arrangement",
            terms: "displays monitor resolution scaling mirror extend layout"
        },
        {
            id: "sound",
            label: "Sound",
            icon: "volume_up",
            detail: "Speakers, microphones and app volumes",
            terms: "audio speaker microphone mute volume output input devices applications"
        },
        {
            id: "network",
            label: "Network",
            icon: "wifi",
            detail: "Wi-Fi and connection profiles",
            terms: "wifi wireless ethernet vpn internet connections network"
        },
        {
            id: "bluetooth",
            label: "Bluetooth",
            icon: "bluetooth",
            detail: "Connected and paired devices",
            terms: "bluetooth devices pair connect headphones controller"
        },
        {
            id: "notifications",
            label: "Notifications",
            icon: "notifications",
            detail: "Quiet mode and notification history",
            terms: "notifications history alerts do not disturb quiet"
        },
        {
            id: "workflows",
            label: "Workflows",
            icon: "workspaces",
            detail: "Presets and personal startup apps",
            terms: "presets normal focused presentation minimal meeting music docked startup apps workflow"
        },
        {
            id: "lock",
            label: "Lock screen",
            icon: "lock",
            detail: "Media, weather and notification visibility",
            terms: "lockscreen password weather location temperature media notification privacy clock"
        },
        {
            id: "time",
            label: "Date and time",
            icon: "schedule",
            detail: "Local time and automatic travel timezone",
            terms: "date time timezone clock travel automatic location"
        },
        {
            id: "ai",
            label: "Nacre AI",
            icon: "neurology",
            detail: "Assistants, accounts and sidebar",
            terms: "ai codex claude accounts usage sidebar brain"
        },
        {
            id: "maintenance",
            label: "Maintenance",
            icon: "build",
            detail: "Health, releases and recovery",
            terms: "maintenance health release rollback restart resources cpu memory wallet updates diagnostics"
        }
    ]
    readonly property var current: pages.find(p => p.id === page) ?? pages[0]
    readonly property var matches: pages.filter(p => query.trim().toLowerCase().split(/\s+/).every(word => (p.label + " " + p.detail + " " + p.terms).toLowerCase().includes(word)))
    function open(id) {
        if (!pages.some(p => p.id === id))
            return;
        Visibilities.settingsPage = id;
        page = id;
        query = "";
        search.text = "";
    }
    Connections {
        target: Visibilities
        function onSettingsPageChanged() {
            root.open(Visibilities.settingsPage);
        }
    }
    NacreSurface {
        id: rail
        width: 190
        height: parent.height
        radius: 17
        color: Colours.palette.m3surfaceContainer
        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 12
            Row {
                spacing: 8
                BrandLogo {
                    implicitWidth: 26
                    implicitHeight: 26
                }
                NacreText {
                    text: "Settings"
                    font.pointSize: 16
                    color: Colours.palette.m3primary
                }
            }
            NacreTextField {
                id: search
                objectName: "settingsSearch"
                width: parent.width
                height: 38
                placeholderText: "Search settings"
                leftPadding: 10
                text: root.query
                onTextChanged: root.query = text
                background: NacreSurface {
                    radius: 12
                    color: Colours.palette.m3surfaceContainerHigh
                }
            }
        }
        ListView {
            id: nav
            objectName: "settingsNavigation"
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            spacing: 3
            clip: true
            model: root.pages
            FastScroll {
                view: nav
            }
            ScrollBar.vertical: ScrollBar {}
            delegate: NacreSurface {
                required property var modelData
                width: nav.width
                height: 40
                radius: 20
                color: root.page === modelData.id ? Colours.palette.m3secondaryContainer : "transparent"
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    spacing: 10
                    NacreIcon {
                        text: modelData.icon
                        font.pointSize: 15
                        color: root.page === modelData.id ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                    }
                    NacreText {
                        text: modelData.label
                        font.pointSize: 11
                    }
                }
                NacreInteraction {
                    function onClicked() {
                        root.open(modelData.id);
                    }
                }
            }
        }
    }
    Column {
        id: heading
        anchors.left: rail.right
        anchors.leftMargin: 24
        anchors.right: parent.right
        spacing: 4
        NacreText {
            text: root.query.trim() ? "Search settings" : root.current.label
            font.pointSize: 20
            font.weight: 500
            color: Colours.palette.m3primary
        }
        NacreText {
            text: root.query.trim() ? root.matches.length + " matching pages" : root.current.detail
            font.pointSize: 11
            color: Colours.palette.m3onSurfaceVariant
        }
    }
    Loader {
        id: pageLoader
        objectName: "settingsPage"
        anchors.top: heading.bottom
        anchors.topMargin: 20
        anchors.left: rail.right
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        active: root.active && !root.query.trim()
        visible: active
        sourceComponent: root.page === "appearance" ? appearance : root.page === "sound" ? sound : root.page === "network" ? network : root.page === "bluetooth" ? bluetooth : root.page === "lock" ? lock : root.page === "time" ? timePage : root.page === "ai" ? ai : root.page === "notifications" ? notifications : controls
        onLoaded: if (item && item.hasOwnProperty("page"))
            item.page = Qt.binding(() => root.page)
    }
    ListView {
        id: results
        objectName: "settingsResults"
        anchors.fill: pageLoader
        visible: root.query.trim().length > 0
        model: root.matches
        spacing: 8
        clip: true
        FastScroll {
            view: results
        }
        delegate: NacreSurface {
            required property var modelData
            width: results.width
            height: 76
            radius: 14
            color: Colours.palette.m3surfaceContainer
            Column {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                NacreText {
                    text: modelData.label
                    color: Colours.palette.m3primary
                    font.pointSize: 13
                }
                NacreText {
                    text: modelData.detail
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 11
                }
            }
            NacreInteraction {
                function onClicked() {
                    root.open(modelData.id);
                }
            }
        }
        NacreText {
            anchors.centerIn: parent
            visible: results.count === 0
            text: "No matching settings"
            color: Colours.palette.m3onSurfaceVariant
        }
    }
    Component {
        id: controls
        DesktopControls {}
    }
    Component {
        id: appearance
        AppearancePage {}
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
        id: lock
        LockPage {}
    }
    Component {
        id: timePage
        TimePage {}
    }
    Component {
        id: ai
        AiPage {}
    }
    Component {
        id: notifications
        NotificationPage {}
    }
    IpcHandler {
        target: "settingsView"
        function open(page: string): void {
            if (root.pages.some(p => p.id === page))
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
