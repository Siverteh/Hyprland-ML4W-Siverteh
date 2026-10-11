import QtQuick
import qs.widgets
import qs.services
import "../colors"

Column {
    id: root
    spacing: 12
    readonly property var entries: NacreWelcomeApp.demoEntries
    Row {
        id: scenes
        objectName: "welcomeScenes"
        width: parent.width
        spacing: 12
        Repeater {
            model: root.entries
            Column {
                id: tile
                required property var modelData
                required property int index
                width: (scenes.width - 36) / 4
                spacing: 7
                NacreSurface {
                    id: card
                    objectName: "welcomeScene_" + tile.index
                    width: parent.width
                    height: Math.min(120, width * .56)
                    radius: 12
                    color: NacreTokens.raised
                    border.width: selected ? 2 : 1
                    border.color: selected ? Qt.alpha(NacreTokens.ink, .65) : Qt.alpha(NacreTokens.outline, .4)
                    readonly property bool selected: NacreWallpapers.displayPath === tile.modelData.path
                    enabled: !NacreWelcomeApp.demoBusy
                    NacreClip {
                        x: 4
                        y: 4
                        width: parent.width - 8
                        height: parent.height - 8
                        radius: 9
                        Image {
                            anchors.fill: parent
                            source: "file://" + (tile.modelData.preview || tile.modelData.poster)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            retainWhileLoading: true
                            sourceSize: Qt.size(512, 288)
                        }
                        NacreSurface {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 6
                            width: 24
                            height: 24
                            radius: 12
                            visible: card.selected
                            color: NacreTokens.body
                            NacreIcon {
                                anchors.centerIn: parent
                                text: "check"
                                font.pointSize: 10
                            }
                        }
                    }
                    NacreInteraction {
                        accessibleName: "Use wallpaper " + tile.modelData.name
                        function onClicked() {
                            NacreWelcomeApp.selectDemo(tile.modelData.path);
                        }
                    }
                }
                NacreText {
                    width: parent.width
                    text: tile.modelData.name
                    font.pointSize: 10
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
                NacreText {
                    width: parent.width
                    textFormat: Text.RichText
                    font.pointSize: 8.5
                    wrapMode: Text.Wrap
                    color: NacreTokens.mutedInk
                    linkColor: NacreTokens.mutedInk
                    text: "<a href=\"" + tile.modelData.source + "\">" + tile.modelData.artist + "</a> · " + tile.modelData.license.replace(/-/g, " ")
                    onLinkActivated: url => NacreWelcomeApp.openCredit(url)
                }
            }
        }
    }
    NacreText {
        visible: !root.entries.length
        text: NacreWelcomeApp.demoStarting ? "Preparing the demo…" : NacreWelcomeApp.demoError
        font.pointSize: 10
        color: NacreTokens.mutedInk
    }
    Item {
        width: parent.width
        height: 38
        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter
            NacreText {
                text: "Style"
                font.pointSize: 11
                anchors.verticalCenter: parent.verticalCenter
                rightPadding: 8
            }
            Repeater {
                model: ["natural", "pop", "pearl"]
                ActionButton {
                    required property string modelData
                    objectName: "welcomePersonality_" + modelData
                    text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    compact: true
                    selected: NacreWelcomeApp.appearance.palettePersonality === modelData
                    enabled: !NacreWelcomeApp.demoBusy
                    onClicked: NacreWelcomeApp.themeDemo("", modelData)
                }
            }
        }
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Repeater {
                model: ["dark", "light"]
                ActionButton {
                    required property string modelData
                    objectName: "welcomeMode_" + modelData
                    text: ""
                    accessibleLabel: modelData === "dark" ? "Dark colors" : "Light colors"
                    icon: modelData === "dark" ? "dark_mode" : "light_mode"
                    compact: true
                    selected: NacreWelcomeApp.appearance.paletteMode === modelData
                    enabled: !NacreWelcomeApp.demoBusy
                    onClicked: NacreWelcomeApp.themeDemo(modelData, "")
                }
            }
        }
    }
    NacreText {
        width: parent.width
        wrapMode: Text.Wrap
        text: ({
                natural: "The original balance of the wallpaper's own colors",
                pop: "A bold contrasting detail becomes the accent",
                pearl: "Neutral surfaces and Nacre's mother-of-pearl tones"
            })[NacreWelcomeApp.appearance.palettePersonality] || "Your chosen color style"
        font.pointSize: 10
        color: NacreTokens.mutedInk
    }
    Row {
        width: parent.width
        spacing: 18
        Item {
            width: Math.min(440, parent.width * .58)
            height: 140
            clip: true
            NacreThemePreview {
                width: parent.width
                height: 280
                palette: NacrePresentation.active.colours || {}
                wallpaper: NacreWallpapers.displayPreview || ""
            }
        }
        Column {
            width: Math.max(0, parent.width - parent.children[0].width - 18)
            spacing: 12
            NacreText {
                text: "Your desktop colors"
                font.pointSize: 11
            }
            Row {
                spacing: 8
                Repeater {
                    model: ["primary", "secondary", "tertiary", "surface"]
                    Rectangle {
                        required property string modelData
                        width: 32
                        height: 32
                        radius: 16
                        color: "#" + (NacrePresentation.active.colours?.[modelData] || "202020")
                        border.width: 1
                        border.color: NacreTokens.outline
                    }
                }
            }
            ActionButton {
                objectName: "welcomeRestoreDemo"
                text: "Undo: back to your colors"
                compact: true
                visible: NacreWelcomeApp.demoChanged
                enabled: !NacreWelcomeApp.demoBusy
                onClicked: NacreWelcomeApp.restoreDemo()
            }
        }
    }
    NacreText {
        width: parent.width
        text: NacreWelcomeApp.demoError || (NacreWelcomeApp.demoBusy ? "Applying to your desktop…" : NacreWelcomeApp.demoRestored ? "Your starting colors are restored." : "")
        visible: !!text
        font.pointSize: 10
        wrapMode: Text.Wrap
        color: NacreTokens.mutedInk
    }
}
