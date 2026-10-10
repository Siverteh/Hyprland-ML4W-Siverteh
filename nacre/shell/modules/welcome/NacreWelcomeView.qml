import QtQuick
import QtQuick.Controls
import qs.widgets
import qs.services
import "welcome-catalog.js" as Catalog

Item {
    id: root
    focus: true
    readonly property bool narrow: width < 820
    function page(name) {
        NacreWelcomeApp.page = name;
        canvas.contentY = 0;
    }
    Keys.onEscapePressed: NacreWelcomeApp.close()
    Flow {
        id: navigation
        objectName: "welcomeNavigation"
        width: parent.width
        spacing: 8
        Repeater {
            model: [
                {
                    id: "home",
                    name: "Start here"
                },
                {
                    id: "shortcuts",
                    name: "Shortcuts"
                },
                {
                    id: "apps",
                    name: "Nacre apps"
                },
                {
                    id: "help",
                    name: "Help"
                }
            ]
            ActionButton {
                required property var modelData
                objectName: "welcomePage_" + modelData.id
                text: modelData.name
                selected: NacreWelcomeApp.page === modelData.id
                onClicked: root.page(modelData.id)
            }
        }
    }
    NacreText {
        id: error
        y: navigation.height + 10
        width: parent.width
        text: NacreWelcomeApp.error
        visible: text.length > 0
        wrapMode: Text.Wrap
        color: NacreColours.palette.m3error
    }
    Flickable {
        id: canvas
        objectName: "welcomeCanvas"
        x: 0
        y: navigation.height + (error.visible ? error.implicitHeight + 20 : 14)
        width: parent.width
        height: Math.max(0, footer.y - y - 12)
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        maximumFlickVelocity: 3400
        FastScroll {
            view: canvas
        }
        ScrollBar.vertical: NacreScrollBar {}
        Column {
            id: body
            width: canvas.width
            spacing: 14
            Column {
                width: parent.width
                spacing: 12
                visible: NacreWelcomeApp.page === "home"
                Item {
                    width: parent.width
                    height: root.narrow ? 132 : 120
                    BrandLogo {
                        id: heroLogo
                        x: root.narrow ? 8 : 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.narrow ? 100 : 112
                        height: width
                        compact: false
                        motionEnabled: NacreTokens.motionEnabled
                    }
                    Column {
                        x: root.narrow ? 132 : 164
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x - 16
                        spacing: 10
                        NacreText {
                            text: "Nacre"
                            font.pointSize: root.narrow ? 28 : 32
                            font.weight: Font.Medium
                        }
                        NacreText {
                            width: parent.width
                            text: "Mother-of-pearl. Colors shaped by your wallpaper."
                            font.pointSize: root.narrow ? 11 : 13
                            wrapMode: Text.Wrap
                        }
                        NacreText {
                            width: parent.width
                            text: "Nacre is the iridescent lining inside a shell. Here, your wallpaper brings those colors to a desktop for Hyprland."
                            color: NacreTokens.mutedInk
                            font.pointSize: 11
                            wrapMode: Text.Wrap
                        }
                    }
                }
                NacreWelcomeDemo {
                    width: parent.width
                }
                Flow {
                    width: parent.width
                    spacing: 8
                    ActionButton {
                        objectName: "welcomeColors"
                        text: "Open Colors"
                        icon: "palette"
                        onClicked: NacreWelcomeApp.route("colors")
                    }
                    ActionButton {
                        objectName: "welcomeWallpaper"
                        text: "More wallpapers"
                        icon: "wallpaper"
                        onClicked: NacreWelcomeApp.route("wallpaper")
                    }
                    ActionButton {
                        text: "Settings"
                        onClicked: NacreWelcomeApp.route("settings:desktop")
                    }
                    ActionButton {
                        text: "Shortcuts"
                        onClicked: root.page("shortcuts")
                    }
                    ActionButton {
                        text: "Maintenance"
                        onClicked: NacreWelcomeApp.route("settings:maintenance")
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 12
                visible: NacreWelcomeApp.page === "shortcuts"
                NacreText {
                    text: "A few keys go a long way"
                    font.pointSize: 23
                }
                NacreText {
                    width: parent.width
                    text: "Super is usually the Windows key. These are the bindings registered in your current Hyprland session."
                    color: NacreTokens.mutedInk
                    wrapMode: Text.Wrap
                }
                NacreText {
                    width: parent.width
                    visible: !!NacreWelcomeApp.data.shortcutError
                    text: NacreWelcomeApp.data.shortcutError || ""
                    wrapMode: Text.Wrap
                    color: NacreTokens.mutedInk
                }
                ActionButton {
                    text: "Refresh bindings"
                    enabled: !NacreWelcomeApp.busy
                    onClicked: NacreWelcomeApp.refresh()
                }
                Repeater {
                    model: NacreWelcomeApp.data.shortcuts || []
                    NacreSurface {
                        required property var modelData
                        width: body.width
                        height: Math.max(76, info.implicitHeight + 24, keyLabel.implicitHeight + 32)
                        radius: 10
                        color: NacreTokens.raised
                        NacreText {
                            id: keyLabel
                            x: 16
                            y: 16
                            width: root.narrow ? 172 : 220
                            text: modelData.key
                            font.family: NacreTokens.monoFamily
                            font.pointSize: 10
                            wrapMode: Text.Wrap
                            color: NacreTokens.accent
                        }
                        Column {
                            id: info
                            x: root.narrow ? 204 : 248
                            y: 12
                            width: parent.width - x - 16
                            spacing: 4
                            NacreText {
                                width: parent.width
                                text: modelData.title
                                wrapMode: Text.Wrap
                                font.pointSize: 12
                            }
                            NacreText {
                                width: parent.width
                                text: modelData.detail
                                wrapMode: Text.Wrap
                                color: NacreTokens.mutedInk
                                font.pointSize: 10.5
                            }
                        }
                    }
                }
            }
            Column {
                width: parent.width
                spacing: 14
                visible: NacreWelcomeApp.page === "apps"
                NacreText {
                    text: "The Nacre suite"
                    font.pointSize: 23
                }
                NacreText {
                    width: parent.width
                    text: "Tools for longer tasks, with quick controls always close by in the shell."
                    color: NacreTokens.mutedInk
                    wrapMode: Text.Wrap
                }
                NacreSurface {
                    id: setupGuide
                    width: parent.width
                    visible: !!NacreWelcomeApp.optionalApp
                    implicitHeight: setupText.implicitHeight + 32
                    radius: 12
                    color: NacreTokens.raised
                    readonly property var guide: Catalog.optional[NacreWelcomeApp.optionalApp] || {}
                    Column {
                        id: setupText
                        x: 16
                        y: 16
                        width: parent.width - 32
                        spacing: 10
                        NacreText {
                            width: parent.width
                            text: setupGuide.guide.title || ""
                            font.pointSize: 16
                            wrapMode: Text.Wrap
                        }
                        NacreText {
                            width: parent.width
                            text: setupGuide.guide.detail || ""
                            wrapMode: Text.Wrap
                        }
                        NacreText {
                            width: parent.width
                            text: setupGuide.guide.setup || ""
                            wrapMode: Text.Wrap
                            color: NacreTokens.mutedInk
                        }
                        NacreText {
                            width: parent.width
                            text: setupGuide.guide.status || ""
                            wrapMode: Text.Wrap
                            color: NacreTokens.mutedInk
                            font.pointSize: 10.5
                        }
                        ActionButton {
                            text: "Back to apps"
                            onClicked: NacreWelcomeApp.optionalApp = ""
                        }
                    }
                }
                Repeater {
                    model: Catalog.apps
                    Item {
                        required property var modelData
                        width: body.width
                        height: appRow.implicitHeight
                        BrandLogo {
                            id: appLogo
                            x: 14
                            y: 20
                            width: 44
                            height: 44
                            ai: modelData.logo === "ai"
                            brain: modelData.logo === "brain"
                            settings: modelData.logo === "settings"
                            colorsApp: modelData.logo === "colors"
                            motionEnabled: NacreTokens.motionEnabled
                            opacity: ready ? (appRow.optional ? .4 : 1) : 0
                            z: 1
                        }
                        NacreWelcomeRow {
                            id: appRow
                            objectName: "welcomeAppRow_" + modelData.logo
                            width: parent.width
                            heading: modelData.title
                            leadingSpace: 76
                            icon: modelData.icon
                            showGlyph: !appLogo.ready
                            optional: !!modelData.availability && NacreWelcomeApp.data.available?.[modelData.availability] !== true
                            buttonText: optional ? "Setup guide" : "Open"
                            available: true
                            detail: (optional ? "Optional. " : "") + modelData.detail
                            onClicked: {
                                if (optional) {
                                    NacreWelcomeApp.setup(modelData.availability);
                                    Qt.callLater(() => canvas.contentY = 0);
                                } else
                                    NacreWelcomeApp.route(modelData.action);
                            }
                        }
                    }
                }
                NacreText {
                    width: parent.width
                    text: "AI and Brain are optional. Welcome uses what is already installed; it does not set up accounts or download models."
                    color: NacreTokens.mutedInk
                    wrapMode: Text.Wrap
                    font.pointSize: 10.5
                }
            }
            Column {
                width: parent.width
                spacing: 14
                visible: NacreWelcomeApp.page === "help"
                NacreText {
                    text: "A little guidance, when you need it"
                    font.pointSize: 23
                }
                Repeater {
                    model: Catalog.help
                    Column {
                        required property var modelData
                        width: body.width
                        spacing: 6
                        NacreText {
                            width: parent.width
                            text: modelData.title
                            font.pointSize: 13
                            wrapMode: Text.Wrap
                        }
                        NacreText {
                            width: parent.width
                            text: modelData.detail
                            color: NacreTokens.mutedInk
                            font.pointSize: 11
                            wrapMode: Text.Wrap
                        }
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: NacreTokens.outline
                            opacity: .2
                        }
                    }
                }
                Flow {
                    width: parent.width
                    spacing: 8
                    ActionButton {
                        text: "Maintenance"
                        onClicked: NacreWelcomeApp.route("settings:maintenance")
                    }
                    ActionButton {
                        text: "Display setup"
                        onClicked: NacreWelcomeApp.route("settings:displays")
                    }
                }
                NacreText {
                    text: "Read more online"
                    font.pointSize: 15
                }
                Flow {
                    width: parent.width
                    spacing: 8
                    ActionButton {
                        text: "Nacre project"
                        onClicked: NacreWelcomeApp.link("project")
                    }
                    ActionButton {
                        text: "Hyprland guide"
                        onClicked: NacreWelcomeApp.link("hyprland")
                    }
                    ActionButton {
                        text: "Quickshell docs"
                        onClicked: NacreWelcomeApp.link("quickshell")
                    }
                    ActionButton {
                        text: "CachyOS docs"
                        onClicked: NacreWelcomeApp.link("cachyos")
                    }
                }
                NacreText {
                    width: parent.width
                    text: "Nacre is a desktop for Hyprland, built with Quickshell. System packages stay with your distribution; personal configuration stays on this computer."
                    color: NacreTokens.mutedInk
                    font.pointSize: 10.5
                    wrapMode: Text.Wrap
                }
            }
        }
    }
    Item {
        id: footer
        objectName: "welcomeFooter"
        width: parent.width
        height: 64
        y: parent.height - height
        Rectangle {
            width: parent.width
            height: 1
            color: NacreTokens.outline
            opacity: .3
        }
        Switch {
            id: startup
            objectName: "welcomeStartupToggle"
            x: 0
            anchors.verticalCenter: parent.verticalCenter
            text: "Show at login"
            checked: NacreWelcomeApp.data.preferences?.showAtLogin !== false
            enabled: !NacreWelcomeApp.busy
            onToggled: NacreWelcomeApp.setStartup(checked)
            Accessible.name: text
            indicator: NacreSurface {
                implicitWidth: 42
                implicitHeight: 24
                x: 0
                y: (startup.height - height) / 2
                radius: 12
                color: startup.checked ? NacreTokens.accent : NacreTokens.raised
                border.width: 1
                border.color: NacreTokens.outline
                NacreSurface {
                    width: 18
                    height: 18
                    y: 3
                    x: startup.checked ? 21 : 3
                    radius: 9
                    color: startup.checked ? NacreColours.palette.m3onPrimary : NacreTokens.mutedInk
                }
            }
            contentItem: NacreText {
                text: startup.text
                leftPadding: 52
                verticalAlignment: Text.AlignVCenter
                color: NacreTokens.ink
                font.pointSize: 11
            }
        }
        NacreText {
            x: startup.x + startup.width + 20
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.narrow
            text: "Always available in the launcher"
            font.pointSize: 10
            color: NacreTokens.mutedInk
        }
        ActionButton {
            objectName: "welcomeDone"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "Start using Nacre"
            selected: true
            onClicked: NacreWelcomeApp.close()
        }
    }
}
