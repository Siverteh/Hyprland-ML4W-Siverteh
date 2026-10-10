import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import Quickshell
import qs.widgets
import qs.services

Item {
    id: root
    focus: true
    property string page: "studio"
    property string libraryTab: "wallpapers"
    property string query: ""
    property string family: "All"
    property string vision: "normal"
    property var inspected: null
    readonly property var candidate: NacreColorsApp.preview
    readonly property var palette: candidate.palette?.colours || {}
    readonly property var audit: candidate.palette?.accessibility || {}
    readonly property int railWidth: width < 940 ? 180 : 210
    readonly property bool ready: NacreColorsApp.ready
    function search() {
        searchField.forceActiveFocus();
        searchField.selectAll();
    }
    function choosePath(value) {
        const text = value.toString();
        if (!text.startsWith("file://")) {
            NacreColorsApp.error = "Choose a local wallpaper file.";
            return;
        }
        NacreColorsApp.choose(decodeURIComponent(text.slice(7)));
    }
    Keys.onEscapePressed: query ? query = "" : NacreColorsApp.close()
    FileDialog {
        id: fileDialog
        title: "Choose a wallpaper to explore"
        nameFilters: ["Wallpapers (*.png *.jpg *.jpeg *.webp *.gif *.mp4 *.webm *.mkv)", "All files (*)"]
        onAccepted: root.choosePath(selectedFile)
    }
    onVisibleChanged: if (!visible)
        fileDialog.close()
    DropArea {
        anchors.fill: parent
        onDropped: drop => {
            if (drop.urls.length)
                root.choosePath(drop.urls[0]);
        }
    }
    Flow {
        id: toolbar
        width: parent.width
        spacing: 7
        Repeater {
            model: ["natural", "harmony", "pop", "mist", "vivid", "pearl", "tide"]
            ActionButton {
                required property string modelData
                objectName: modelData + "Personality"
                text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                selected: !NacreColorsApp.options.favoriteId && NacreColorsApp.options.personality === modelData
                onClicked: NacreColorsApp.change({
                    personality: modelData
                })
            }
        }
        ActionButton {
            text: "Dark"
            selected: NacreColorsApp.options.mode === "dark"
            onClicked: NacreColorsApp.change({
                mode: "dark",
                autoMode: false
            })
        }
        ActionButton {
            text: "Light"
            selected: NacreColorsApp.options.mode === "light"
            onClicked: NacreColorsApp.change({
                mode: "light",
                autoMode: false
            })
        }
        ActionButton {
            text: "Open image"
            icon: "folder_open"
            onClicked: fileDialog.open()
        }
    }
    Row {
        id: navigation
        y: toolbar.height + 8
        spacing: 8
        Repeater {
            model: ["studio", "compare", "accessibility"]
            ActionButton {
                required property string modelData
                text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                selected: root.page === modelData
                onClicked: {
                    root.page = modelData;
                    canvas.contentY = 0;
                }
            }
        }
    }
    Flow {
        id: backgroundControls
        y: navigation.y + navigation.height + 8
        width: parent.width
        spacing: 12
        Switch {
            id: backgroundSwitch
            objectName: "wallpaperBackgroundSwitch"
            text: "Background from wallpaper"
            checked: NacreColorsApp.options.backgroundFromWallpaper === true
            enabled: NacreColorsApp.options.personality !== "pearl"
            onToggled: NacreColorsApp.change({
                backgroundFromWallpaper: checked
            })
            indicator: NacreSurface {
                implicitWidth: 42
                implicitHeight: 24
                x: 0
                y: (backgroundSwitch.height - height) / 2
                radius: 12
                color: backgroundSwitch.checked ? NacreTokens.accent : NacreTokens.raised
                border.width: 1
                border.color: NacreTokens.outline
                NacreSurface {
                    x: backgroundSwitch.checked ? 22 : 4
                    y: 4
                    width: 16
                    height: 16
                    radius: 8
                    color: NacreTokens.focusInk(parent.color)
                }
            }
            contentItem: NacreText {
                text: backgroundSwitch.text
                leftPadding: 52
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 11
                color: backgroundSwitch.enabled ? NacreTokens.ink : NacreTokens.mutedInk
            }
        }
        NacreText {
            height: backgroundSwitch.height
            verticalAlignment: Text.AlignVCenter
            text: NacreColorsApp.options.personality === "pearl" ? "Pearl uses neutral signature surfaces" : backgroundSwitch.checked ? "Sampled shadow and highlight tones" : "Subtle accent tint"
            color: NacreTokens.mutedInk
            font.pointSize: 10
        }
    }
    NacreSurface {
        id: rail
        y: backgroundControls.y + backgroundControls.height + 12
        width: root.railWidth
        height: Math.max(0, footer.y - y - 12)
        radius: 18
        color: NacreTokens.raised
        NacreTextField {
            id: searchField
            x: 12
            y: 12
            width: parent.width - 24
            placeholderText: "Find a wallpaper"
            text: root.query
            onTextEdited: root.query = text
        }
        Item {
            id: tabs
            x: 12
            y: 62
            width: parent.width - 24
            height: 34
            ActionButton {
                width: parent.width
                compact: true
                text: root.libraryTab === "wallpapers" ? "Wallpapers" : root.libraryTab === "saved" ? "Favorites" : "History"
                icon: "expand_more"
                onClicked: tabMenu.open()
            }
            Popup {
                id: tabMenu
                y: 38
                width: tabs.width
                padding: 8
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                background: NacreSurface {
                    color: NacreTokens.raised
                    border.width: 1
                    border.color: NacreTokens.outline
                }
                contentItem: Column {
                    width: tabMenu.width - 16
                    spacing: 4
                    Repeater {
                        model: [
                            {
                                id: "wallpapers",
                                name: "Wallpapers"
                            },
                            {
                                id: "saved",
                                name: "Favorites"
                            },
                            {
                                id: "history",
                                name: "History"
                            }
                        ]
                        ActionButton {
                            required property var modelData
                            width: parent.width
                            compact: true
                            text: modelData.name
                            selected: root.libraryTab === modelData.id
                            onClicked: {
                                root.libraryTab = modelData.id;
                                tabMenu.close();
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: families
            x: 12
            y: tabs.y + tabs.height + 10
            width: parent.width - 24
            height: 34
            visible: root.libraryTab === "wallpapers"
            ActionButton {
                width: parent.width
                compact: true
                text: "Color: " + root.family
                icon: "expand_more"
                onClicked: familyMenu.open()
            }
            Popup {
                id: familyMenu
                y: 38
                width: families.width
                padding: 8
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                background: NacreSurface {
                    color: NacreTokens.raised
                    border.width: 1
                    border.color: NacreTokens.outline
                }
                contentItem: Column {
                    width: familyMenu.width - 16
                    spacing: 4
                    Repeater {
                        model: ["All", "Blue", "Green", "Teal", "Rose", "Gold", "Copper", "Lilac", "Neutral"]
                        ActionButton {
                            required property string modelData
                            width: parent.width
                            compact: true
                            text: modelData
                            selected: root.family === modelData
                            onClicked: {
                                root.family = modelData;
                                familyMenu.close();
                            }
                        }
                    }
                }
            }
        }
        ListView {
            id: entries
            x: 8
            y: families.y + (families.visible ? families.height : 0) + 10
            width: parent.width - 16
            height: Math.max(0, parent.height - y - 8)
            clip: true
            spacing: 6
            model: root.libraryTab === "saved" ? NacreColorsApp.favorites : root.libraryTab === "history" ? NacreColorsApp.history : NacreColorsApp.library.filter(w => (!root.query || w.name.toLowerCase().includes(root.query.toLowerCase())) && (root.family === "All" || (w.families || []).includes(root.family)))
            delegate: NacreSurface {
                id: entry
                required property var modelData
                width: entries.width
                height: root.libraryTab === "wallpapers" ? 88 : 72
                color: root.libraryTab === "wallpapers" && NacreColorsApp.options.image === modelData.path ? NacreColours.palette.m3secondaryContainer : "transparent"
                Image {
                    x: 8
                    y: 8
                    width: 60
                    height: 42
                    source: root.libraryTab === "wallpapers" ? "file://" + entry.modelData.thumbnail : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    retainWhileLoading: true
                    visible: root.libraryTab === "wallpapers"
                }
                NacreText {
                    x: root.libraryTab === "wallpapers" ? 77 : 10
                    y: 10
                    width: parent.width - x - 10
                    text: entry.modelData.name
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    font.pointSize: 10
                }
                NacreText {
                    x: 8
                    y: 62
                    width: parent.width - 16
                    text: root.libraryTab === "wallpapers" ? (entry.modelData.dynamic ? "Dynamic" : "Static") : ""
                    font.pointSize: 9
                    color: NacreTokens.mutedInk
                }
                NacreInteraction {
                    accessibleName: entry.modelData.name
                    function onClicked() {
                        if (root.libraryTab === "wallpapers")
                            NacreColorsApp.choose(entry.modelData.path);
                        else if (root.libraryTab === "saved")
                            NacreColorsApp.useFavorite(entry.modelData.id);
                        else
                            NacreColorsApp.useHistory(entry.modelData);
                    }
                }
            }
            FastScroll {
                view: entries
            }
            NacreText {
                anchors.centerIn: parent
                width: parent.width - 16
                visible: entries.count === 0
                text: root.libraryTab === "saved" ? "Save a palette with Favorite." : root.libraryTab === "history" ? "Applied palettes appear here." : "No matching wallpapers. Open an image to explore it."
                wrapMode: Text.Wrap
                font.pointSize: 10
                color: NacreTokens.mutedInk
            }
        }
    }
    Flickable {
        id: canvas
        objectName: "colorsCanvas"
        x: rail.width + 16
        y: rail.y
        width: parent.width - x
        height: rail.height
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        FastScroll {
            view: canvas
        }
        Column {
            id: body
            width: parent.width
            spacing: 18
            NacreText {
                width: parent.width
                text: root.candidate.name || "Explore a wallpaper"
                font.pointSize: 20
                wrapMode: Text.Wrap
            }
            NacreText {
                width: parent.width
                text: NacreColorsApp.previewBusy ? "Preparing a preview. Your desktop stays unchanged." : root.candidate.favorite ? "Saved palette on this wallpaper. Source colors belong to the original saved image." : root.candidate.frames > 1 ? "Colors combine " + root.candidate.frames + " sampled frames. Regions show their combined coverage." : "Hover a sample to see its source area. Click the image to pick an accent."
                font.pointSize: 10
                color: NacreTokens.mutedInk
                wrapMode: Text.Wrap
            }
            Flow {
                id: studio
                visible: root.page !== "compare"
                width: parent.width
                spacing: 16
                readonly property bool split: width >= 720
                Column {
                    width: studio.split ? (studio.width - 16) * .48 : studio.width
                    spacing: 10
                    Item {
                        id: photo
                        width: parent.width
                        height: Math.min(300, width * .62)
                        Image {
                            id: wallpaper
                            anchors.fill: parent
                            source: root.candidate.thumbnail ? "file://" + root.candidate.thumbnail : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            retainWhileLoading: true
                            sourceSize: Qt.size(960, 600)
                        }
                        Repeater {
                            model: !root.candidate.favorite && root.inspected?.regions ? root.inspected.regions.cells : []
                            Rectangle {
                                required property var modelData
                                readonly property var regions: root.inspected.regions
                                width: wallpaper.paintedWidth / regions.columns
                                height: wallpaper.paintedHeight / regions.rows
                                x: (photo.width - wallpaper.paintedWidth) / 2 + (modelData.index % regions.columns) * width
                                y: (photo.height - wallpaper.paintedHeight) / 2 + Math.floor(modelData.index / regions.columns) * height
                                color: Qt.alpha("#" + root.inspected.hex, .30)
                                border.width: 1
                                border.color: "#" + root.inspected.hex
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: event => {
                                const x = (event.x - (photo.width - wallpaper.paintedWidth) / 2) / wallpaper.paintedWidth;
                                const y = (event.y - (photo.height - wallpaper.paintedHeight) / 2) / wallpaper.paintedHeight;
                                if (x >= 0 && x <= 1 && y >= 0 && y <= 1)
                                    NacreColorsApp.change({
                                        pick: {
                                            x: x,
                                            y: y
                                        }
                                    });
                            }
                        }
                    }
                    Flow {
                        width: parent.width
                        spacing: 7
                        Repeater {
                            model: root.candidate.favorite ? [] : root.candidate.palette?.source?.candidates || []
                            NacreColorSample {
                                required property var modelData
                                entry: modelData
                                onPicked: value => NacreColorsApp.change({
                                        accent: value
                                    })
                                onInspect: entry => root.inspected = entry
                                onLeave: root.inspected = null
                            }
                        }
                    }
                    NacreText {
                        width: parent.width
                        wrapMode: Text.Wrap
                        font.pointSize: 9
                        color: NacreTokens.mutedInk
                        text: root.inspected ? "#" + root.inspected.hex + " · " + Math.round(root.inspected.coverage * 1000) / 10 + "% coverage · salience " + root.inspected.salience : "Coverage is real sampled area; salience is a separate center/detail heuristic."
                    }
                }
                Column {
                    width: studio.split ? (studio.width - 16) * .52 : studio.width
                    spacing: 10
                    NacreThemePreview {
                        width: parent.width
                        height: 280
                        visible: !!root.candidate.palette
                        palette: root.vision === "normal" ? root.palette : root.audit.simulated?.[root.vision] || root.palette
                        wallpaper: root.candidate.thumbnail || ""
                        workspaceColors: NacreColorsApp.options.workspaceColors === true
                    }
                    NacreText {
                        width: parent.width
                        text: root.candidate.palette ? "Text contrast: " + (root.audit.textPasses ? "all audited pairs pass" : "check the report") + " · minimum " + Math.round(root.audit.minimumTextContrast * 100) / 100 + ":1" : ""
                        wrapMode: Text.Wrap
                        font.pointSize: 10
                        color: NacreTokens.ink
                    }
                    NacreText {
                        width: parent.width
                        text: root.audit.warnings?.length ? root.audit.warnings.join("\n") : "Accents are distinguishable in the tested simulations. Keep labels and shapes."
                        wrapMode: Text.Wrap
                        font.pointSize: 9
                        color: NacreTokens.mutedInk
                        visible: !!root.candidate.palette
                    }
                }
            }
            NacreText {
                text: "Accent roles"
                font.pointSize: 14
                visible: !!root.candidate.palette && root.page === "studio"
            }
            Flow {
                id: roles
                visible: root.page === "studio"
                width: parent.width
                spacing: 10
                Repeater {
                    model: root.candidate.palette ? ["primary", "secondary", "tertiary"] : []
                    NacreAccentTarget {
                        required property string modelData
                        role: modelData
                        width: Math.max(145, Math.floor((roles.width - 20) / 3))
                        value: root.candidate.palette.roleSources?.[modelData]?.sourceColor || root.palette[modelData]
                        pinned: !!NacreColorsApp.options.overrides?.[modelData]
                        onAssign: value => NacreColorsApp.setRole(modelData, value)
                        onClear: NacreColorsApp.setRole(modelData, "")
                    }
                }
            }
            Flow {
                width: parent.width
                spacing: 8
                visible: root.page === "studio"
                NacreText {
                    text: "Brightness"
                    height: 36
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                }
                ActionButton {
                    text: "−"
                    onClicked: NacreColorsApp.change({
                        brightness: Math.max(-.15, (NacreColorsApp.options.brightness || 0) - .02)
                    })
                }
                NacreText {
                    text: Math.round((NacreColorsApp.options.brightness || 0) * 100)
                    height: 36
                    verticalAlignment: Text.AlignVCenter
                }
                ActionButton {
                    text: "+"
                    onClicked: NacreColorsApp.change({
                        brightness: Math.min(.15, (NacreColorsApp.options.brightness || 0) + .02)
                    })
                }
                NacreText {
                    text: "Saturation"
                    height: 36
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                }
                ActionButton {
                    text: "−"
                    onClicked: NacreColorsApp.change({
                        saturation: Math.max(0, (NacreColorsApp.options.saturation ?? 1) - .1)
                    })
                }
                NacreText {
                    text: Math.round((NacreColorsApp.options.saturation ?? 1) * 100) + "%"
                    height: 36
                    verticalAlignment: Text.AlignVCenter
                }
                ActionButton {
                    text: "+"
                    onClicked: NacreColorsApp.change({
                        saturation: Math.min(1.6, (NacreColorsApp.options.saturation ?? 1) + .1)
                    })
                }
                ActionButton {
                    text: "Reset"
                    onClicked: NacreColorsApp.change({
                        overrides: {},
                        brightness: 0,
                        saturation: 1,
                        accent: null
                    })
                }
            }
            Flow {
                width: parent.width
                spacing: 8
                visible: root.page === "studio"
                ActionButton {
                    text: "Color workspace chips"
                    selected: NacreColorsApp.options.workspaceColors === true
                    onClicked: NacreColorsApp.change({
                        workspaceColors: !NacreColorsApp.options.workspaceColors
                    })
                }
                NacreText {
                    text: "Preview hour"
                    height: 34
                    verticalAlignment: Text.AlignVCenter
                    visible: NacreColorsApp.options.personality === "tide"
                    font.pointSize: 10
                }
                ActionButton {
                    text: "−"
                    visible: NacreColorsApp.options.personality === "tide"
                    onClicked: NacreColorsApp.change({
                        hour: (NacreColorsApp.options.hour + 23) % 24,
                        tideAutomatic: false
                    })
                }
                NacreText {
                    text: NacreColorsApp.options.hour + ":00"
                    height: 34
                    verticalAlignment: Text.AlignVCenter
                    visible: NacreColorsApp.options.personality === "tide"
                }
                ActionButton {
                    text: "+"
                    visible: NacreColorsApp.options.personality === "tide"
                    onClicked: NacreColorsApp.change({
                        hour: (NacreColorsApp.options.hour + 1) % 24,
                        tideAutomatic: false
                    })
                }
                ActionButton {
                    text: "Follow local time"
                    visible: NacreColorsApp.options.personality === "tide"
                    selected: NacreColorsApp.options.tideAutomatic === true
                    onClicked: NacreColorsApp.change({
                        tideAutomatic: !NacreColorsApp.options.tideAutomatic
                    })
                }
                ActionButton {
                    text: "Automatic light / dark"
                    visible: NacreColorsApp.options.personality === "tide"
                    selected: NacreColorsApp.options.autoMode === true
                    onClicked: NacreColorsApp.change({
                        autoMode: !NacreColorsApp.options.autoMode
                    })
                }
            }
            Flow {
                width: parent.width
                spacing: 7
                visible: root.page === "accessibility"
                NacreText {
                    text: "Preview vision"
                    height: 36
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 10
                }
                Repeater {
                    model: ["normal", "protanopia", "deuteranopia", "tritanopia"]
                    ActionButton {
                        required property string modelData
                        text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                        selected: root.vision === modelData
                        onClicked: root.vision = modelData
                    }
                }
            }
            NacreText {
                width: parent.width
                visible: root.page === "accessibility"
                text: "Color-vision simulation is approximate. It changes only this preview, never the desktop palette."
                font.pointSize: 9
                color: NacreTokens.mutedInk
                wrapMode: Text.Wrap
            }
            NacreText {
                text: "Compare personalities"
                font.pointSize: 14
                visible: root.page === "compare"
            }
            Flow {
                id: comparisons
                visible: root.page === "compare"
                width: parent.width
                spacing: 12
                Repeater {
                    model: root.candidate.comparisons || []
                    Column {
                        required property var modelData
                        width: Math.floor((comparisons.width - 12) / 2)
                        spacing: 8
                        ActionButton {
                            text: parent.modelData.personality.charAt(0).toUpperCase() + parent.modelData.personality.slice(1)
                            selected: NacreColorsApp.options.personality === parent.modelData.personality
                            onClicked: NacreColorsApp.change({
                                personality: parent.modelData.personality
                            })
                        }
                        NacreThemePreview {
                            width: parent.width
                            height: 280
                            palette: parent.modelData.colours
                            wallpaper: root.candidate.thumbnail || ""
                        }
                    }
                }
            }
            NacreText {
                text: "Standard-vision contrast report"
                font.pointSize: 14
                visible: !!root.candidate.palette && root.page === "accessibility"
            }
            Flow {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.page === "accessibility" ? root.audit.text || [] : []
                    NacreSurface {
                        required property var modelData
                        width: Math.max(190, (parent.width - 12) / 3)
                        height: 54
                        color: "#" + root.palette[modelData.background]
                        border.width: 1
                        border.color: modelData.passes ? Qt.alpha(NacreTokens.outline, .4) : NacreTokens.accent
                        Text {
                            x: 8
                            y: 8
                            width: parent.width - 16
                            elide: Text.ElideRight
                            text: parent.modelData.foreground + " / " + parent.modelData.background
                            font.pointSize: 8
                            color: "#" + root.palette[parent.modelData.foreground]
                        }
                        Text {
                            x: 8
                            y: 30
                            text: parent.modelData.ratio + ":1 · " + (parent.modelData.passes ? "Pass" : "Review")
                            font.pointSize: 8
                            color: "#" + root.palette[parent.modelData.foreground]
                        }
                    }
                }
            }
        }
    }
    Item {
        id: footer
        y: parent.height - height
        width: parent.width
        height: actions.height + 42
        NacreText {
            x: 0
            y: 0
            width: parent.width
            text: NacreColorsApp.error || NacreColorsApp.status || (root.candidate.palette ? "Preview only · Apply when you are ready" : "Choose a wallpaper to begin")
            color: NacreColorsApp.error ? NacreColours.palette.m3error : NacreTokens.mutedInk
            font.pointSize: 10
            elide: Text.ElideRight
        }
        Flow {
            id: actions
            x: 0
            y: 30
            width: parent.width
            spacing: 8
            ActionButton {
                text: NacreColorsApp.applied ? "Applied" : "Apply"
                icon: "check"
                selected: true
                enabled: root.ready && !NacreColorsApp.actionBusy && !NacreColorsApp.applied
                onClicked: NacreColorsApp.action("apply")
            }
            ActionButton {
                text: "Favorite"
                icon: "favorite"
                enabled: root.ready && !NacreColorsApp.actionBusy
                onClicked: NacreColorsApp.action("favorite")
            }
            ActionButton {
                text: "Export themes"
                icon: "file_upload"
                enabled: root.ready && !NacreColorsApp.actionBusy
                onClicked: NacreColorsApp.action("export")
            }
            ActionButton {
                text: "Palette card"
                icon: "image"
                enabled: root.ready && !NacreColorsApp.actionBusy
                onClicked: NacreColorsApp.action("card")
            }
            ActionButton {
                text: "Open exports"
                icon: "folder_open"
                visible: !!NacreColorsApp.exportDirectory
                onClicked: AppLaunch.run(["xdg-open", NacreColorsApp.exportDirectory])
            }
        }
    }
}
