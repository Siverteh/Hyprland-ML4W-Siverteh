import QtQuick
import qs.widgets
import qs.services

Column {
    id: root
    spacing: 10
    property bool showCredits: false
    readonly property var entries: NacreWelcomeApp.demoEntries
    NacreText {
        text: "Try the colors"
        font.pointSize: 15
    }
    Row {
        id: scenes
        objectName: "welcomeScenes"
        width: parent.width
        spacing: 10
        Repeater {
            model: root.entries
            NacreSurface {
                id: tile
                required property var modelData
                required property int index
                objectName: "welcomeScene_" + index
                width: (scenes.width - Math.max(0, root.entries.length - 1) * scenes.spacing) / Math.max(1, root.entries.length)
                height: imageFrame.height + 44
                radius: 10
                color: NacreTokens.raised
                border.width: selected ? 2 : 1
                border.color: selected ? NacreTokens.accent : Qt.alpha(NacreTokens.outline, .35)
                readonly property bool selected: NacreWallpapers.displayPath === modelData.path
                enabled: !NacreWelcomeApp.demoBusy
                NacreClip {
                    id: imageFrame
                    x: 3
                    y: 3
                    width: parent.width - 6
                    height: width * .56
                    radius: 8
                    Image {
                        id: picture
                        anchors.fill: parent
                        source: "file://" + (modelData.preview || modelData.thumbnail || modelData.poster)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        retainWhileLoading: true
                        sourceSize.width: 512
                        sourceSize.height: 288
                    }
                    NacreIcon {
                        anchors.centerIn: parent
                        text: "wallpaper"
                        color: NacreTokens.mutedInk
                        visible: picture.status !== Image.Ready
                    }
                }
                NacreText {
                    x: 9
                    y: imageFrame.y + imageFrame.height + 5
                    width: parent.width - 18
                    text: modelData.name
                    font.pointSize: 9.5
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
                NacreInteraction {
                    accessibleName: "Use wallpaper " + modelData.name
                    function onClicked() {
                        NacreWelcomeApp.selectDemo(tile.modelData.path);
                    }
                }
            }
        }
    }
    Column {
        width: parent.width
        spacing: 8
        visible: !root.entries.length
        NacreText {
            width: parent.width
            text: NacreWelcomeApp.demoStarting ? "Preparing your starting point and four curated wallpapers…" : "The demo could not be prepared. Reopen Welcome to try again."
            color: NacreTokens.mutedInk
            wrapMode: Text.Wrap
        }
        ActionButton {
            text: "More wallpapers"
            onClicked: NacreWallpapers.pickFiles()
        }
    }
    Flow {
        objectName: "welcomeColorModes"
        width: parent.width
        spacing: 14
        visible: root.entries.length > 0
        Row {
            spacing: 6
            Repeater {
                model: ["dark", "light"]
                ActionButton {
                    required property string modelData
                    objectName: "welcomeMode_" + modelData
                    compact: true
                    text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    selected: NacreWelcomeApp.appearance.paletteMode === modelData
                    enabled: !NacreWelcomeApp.demoBusy
                    onClicked: NacreWelcomeApp.themeDemo(modelData, "")
                }
            }
        }
        Rectangle {
            width: 1
            height: 28
            color: NacreTokens.outline
            opacity: .45
        }
        Row {
            spacing: 6
            Repeater {
                model: ["natural", "pop", "pearl"]
                ActionButton {
                    required property string modelData
                    objectName: "welcomePersonality_" + modelData
                    compact: true
                    text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    selected: NacreWelcomeApp.appearance.palettePreset === "wallpaper" && (NacreWelcomeApp.appearance.palettePersonality || "natural") === modelData
                    enabled: !NacreWelcomeApp.demoBusy
                    onClicked: NacreWelcomeApp.themeDemo("", modelData)
                }
            }
        }
    }
    Flow {
        width: parent.width
        spacing: 8
        ActionButton {
            objectName: "welcomeRestoreDemo"
            text: "Back to how it was"
            icon: "history"
            compact: true
            enabled: !NacreWelcomeApp.demoBusy && NacreWelcomeApp.demoChanged
            onClicked: NacreWelcomeApp.restoreDemo()
        }
        ActionButton {
            objectName: "welcomeWallpaperCredits"
            text: root.showCredits ? "Hide wallpaper credits" : "Wallpaper credits"
            compact: true
            onClicked: root.showCredits = !root.showCredits
        }
    }
    Column {
        objectName: "welcomeWallpaperCreditList"
        width: parent.width
        spacing: 6
        visible: root.showCredits
        Repeater {
            model: root.entries
            NacreText {
                required property var modelData
                width: parent.width
                font.pointSize: 9
                color: NacreTokens.mutedInk
                linkColor: NacreTokens.accent
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                text: modelData.name + " — " + modelData.artist + " · <a href=\"" + modelData.licenseUrl + "\">" + modelData.license + "</a> · <a href=\"" + modelData.source + "\">Source</a>"
                onLinkActivated: url => NacreWelcomeApp.openCredit(url)
            }
        }
    }
    NacreText {
        width: parent.width
        text: NacreWelcomeApp.demoError || (NacreWelcomeApp.demoBusy ? (NacreWelcomeApp.demoStarting ? "Preparing the demo…" : "Applying to your desktop…") : NacreWelcomeApp.demoRestored ? "Your starting wallpaper and colors are restored." : "Changes apply live. Colors offers previews and more choices.")
        color: NacreWelcomeApp.demoError ? NacreColours.palette.m3error : NacreTokens.mutedInk
        font.pointSize: 10
        wrapMode: Text.Wrap
    }
}
