import QtQuick
import Quickshell
import Quickshell.Io
import qs.widgets
import qs.services

Item {
    id: root
    required property PersistentProperties visibilities
    readonly property string kind: NacreWallpapers.preferences.kind || "static"
    readonly property string layout: NacreWallpapers.preferences.layout || "carousel"
    readonly property bool fullScreen: layout !== "carousel"
    readonly property bool motionEnabled: visibilities.launcher && kind === "dynamic" && !NacreWallpapers.preferences.paused
    readonly property var entries: NacreWallpapers.list.filter(entry => entry.dynamic === (kind === "dynamic") && query.text.trim().toLowerCase().split(/\s+/).every(word => (entry.name + " " + entry.path).toLowerCase().includes(word)))
    readonly property int count: entries.length
    property int currentIndex: 0
    readonly property var currentEntry: entries[currentIndex] || null
    property string selectionPath: ""
    property real travelTarget: 0
    property real travel: travelTarget
    property real wheelDelta: 0
    implicitWidth: Math.min(1360, Quickshell.screens[0].width - 140)
    implicitHeight: fullScreen ? Quickshell.screens[0].height - 100 : 360
    function reconcile() {
        const found = entries.findIndex(entry => entry.path === selectionPath);
        currentIndex = found >= 0 ? found : Math.max(0, Math.min(currentIndex, entries.length - 1));
        travelTarget = currentIndex;
    }
    function select(index) {
        if (!count)
            return;
        const next = (index % count + count) % count;
        const distance = ((next - currentIndex + count + Math.floor(count / 2)) % count) - Math.floor(count / 2);
        travelTarget += distance;
        currentIndex = next;
        selectionPath = currentEntry.path;
        if (!visibilities.previewOnly)
            NacreWallpapers.browse(selectionPath);
    }
    function move(delta) {
        select(currentIndex + delta);
    }
    function choose() {
        if (currentEntry && !visibilities.previewOnly) {
            selectionPath = currentEntry.path;
            NacreWallpapers.setWallpaper(selectionPath);
        }
    }
    onEntriesChanged: reconcile()
    Component.onCompleted: {
        selectionPath = NacreWallpapers.current;
        reconcile();
        query.forceActiveFocus();
    }
    Connections {
        target: root.visibilities
        function onLauncherChanged() {
            if (!root.visibilities.launcher && !root.visibilities.previewOnly)
                NacreWallpapers.commitSelection();
        }
    }
    Behavior on travel {
        NumberAnimation {
            duration: NacreTokens.motionEnabled ? 300 : 0
            easing.type: Easing.OutCubic
        }
    }
    NacreWallpaperBackdrop {
        anchors.fill: parent
        visible: root.fullScreen
        path: root.fullScreen ? root.currentEntry?.preview || root.currentEntry?.poster || "" : ""
    }
    Rectangle {
        anchors.fill: parent
        color: root.fullScreen ? "#66000000" : "transparent"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.visibilities.launcher = false
    }
    Column {
        id: toolbar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.fullScreen ? 18 : 12
        spacing: 8
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            ActionButton {
                text: "Static"
                compact: true
                selected: root.kind === "static"
                onClicked: NacreWallpapers.preference({
                    kind: "static"
                })
            }
            ActionButton {
                text: "Dynamic"
                compact: true
                selected: root.kind === "dynamic"
                onClicked: NacreWallpapers.preference({
                    kind: "dynamic"
                })
            }
            ActionButton {
                text: "Carousel"
                compact: true
                selected: root.layout === "carousel"
                onClicked: NacreWallpapers.preference({
                    layout: "carousel"
                })
            }
            ActionButton {
                text: "Spotlight"
                compact: true
                selected: root.layout === "spotlight"
                onClicked: NacreWallpapers.preference({
                    layout: "spotlight"
                })
            }
            ActionButton {
                text: "Hexagons"
                compact: true
                selected: root.layout === "hexagons"
                onClicked: NacreWallpapers.preference({
                    layout: "hexagons"
                })
            }
            ActionButton {
                text: "Add"
                icon: "add"
                compact: true
                onClicked: NacreWallpapers.pickFiles()
            }
        }
        NacreTextField {
            id: query
            objectName: "wallpaperSearch"
            width: Math.min(640, root.width - 80)
            height: 40
            padding: 12
            placeholderText: "Search wallpapers"
            onTextChanged: root.reconcile()
            Keys.onLeftPressed: root.move(-1)
            Keys.onRightPressed: root.move(1)
            Keys.onEscapePressed: root.visibilities.launcher = false
            onAccepted: root.choose()
        }
    }
    NacreText {
        anchors.centerIn: parent
        visible: !root.count
        text: NacreWallpapers.loading ? "Loading wallpapers…" : "No matching wallpapers"
        color: root.fullScreen ? "white" : NacreColours.palette.m3onSurface
    }
    Item {
        id: carousel
        objectName: "carouselStrip"
        anchors.horizontalCenter: parent.horizontalCenter
        y: toolbar.y + toolbar.height + 10
        width: root.width - 48
        height: root.height - y - 48
        visible: root.layout === "carousel"
        readonly property int candidate: Math.min(root.count, Math.max(1, Math.floor(width / 246)))
        readonly property int slots: candidate > 1 && candidate % 2 === 0 ? candidate - 1 : candidate
        readonly property real cardWidth: Math.min(280, (width - Math.max(0, slots - 1) * 16) / Math.max(1, slots))
        Repeater {
            model: root.entries
            Card {
                required property int index
                required property var modelData
                objectName: "carouselCard" + index
                entry: modelData
                decode: Math.min(Math.abs(index - root.currentIndex), root.count - Math.abs(index - root.currentIndex)) <= Math.max(2, Math.ceil(carousel.slots / 2) + 1)
                width: carousel.cardWidth
                height: carousel.height
                x: (carousel.width - width) / 2 + ((((index - root.travel + root.count / 2) % root.count) + root.count) % root.count - root.count / 2) * (width + 16)
                selected: index === root.currentIndex
                visible: x >= -0.01 && x + width <= carousel.width + 0.01
                onChosen: root.select(index)
            }
        }
        WheelHandler {
            onWheel: event => {
                root.wheelDelta += event.angleDelta.y || event.pixelDelta.y * 2;
                if (Math.abs(root.wheelDelta) >= 90) {
                    root.move(root.wheelDelta < 0 ? 1 : -1);
                    root.wheelDelta = 0;
                }
                event.accepted = true;
            }
        }
    }
    Item {
        id: spotlight
        objectName: "spotlightStrip"
        x: 24
        y: toolbar.y + toolbar.height + 24
        width: root.width - 48
        height: root.height - y - 68
        visible: root.layout === "spotlight"
        readonly property real heroWidth: Math.min(width * .52, 1000)
        readonly property int sideSlots: Math.min(4, Math.floor((root.count - 1) / 2))
        readonly property real sideWidth: Math.max(36, (width - heroWidth - Math.max(0, sideSlots * 2) * 12) / Math.max(1, sideSlots * 2))
        Repeater {
            model: root.entries
            Card {
                required property int index
                required property var modelData
                readonly property int offset: root.count ? ((index - root.currentIndex + Math.floor(root.count / 2) + root.count) % root.count) - Math.floor(root.count / 2) : 0
                objectName: "spotlightCard" + index
                entry: modelData
                decode: Math.abs(offset) <= spotlight.sideSlots + 1
                width: offset === 0 ? spotlight.heroWidth : spotlight.sideWidth
                height: spotlight.height
                x: offset === 0 ? (spotlight.width - spotlight.heroWidth) / 2 : offset > 0 ? (spotlight.width + spotlight.heroWidth) / 2 + 12 + (offset - 1) * (spotlight.sideWidth + 12) : (spotlight.width - spotlight.heroWidth) / 2 + offset * (spotlight.sideWidth + 12)
                selected: offset === 0
                visible: Math.abs(offset) <= spotlight.sideSlots
                onChosen: root.select(index)
                Behavior on x {
                    NumberAnimation {
                        duration: NacreTokens.motionEnabled ? 300 : 0
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: NacreTokens.motionEnabled ? 300 : 0
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        WheelHandler {
            onWheel: event => {
                root.move(event.angleDelta.y < 0 ? 1 : -1);
                event.accepted = true;
            }
        }
    }
    Flickable {
        id: hexagons
        x: 24
        y: toolbar.y + toolbar.height + 22
        width: root.width - 48
        height: root.height - y - 56
        visible: root.layout === "hexagons"
        clip: true
        readonly property int columns: Math.max(3, Math.min(7, Math.floor(width / 230)))
        readonly property real tileWidth: Math.min(340, (width - 30) / (1 + (columns - 1) * .76))
        readonly property real tileHeight: tileWidth * .87
        contentWidth: width
        contentHeight: Math.ceil(root.count / columns) * (tileHeight + 12) + tileHeight * .5
        Repeater {
            model: root.entries
            NacreWallpaperHex {
                required property var modelData
                required property int index
                entry: modelData
                width: hexagons.tileWidth
                height: hexagons.tileHeight
                x: (hexagons.width - (width + (hexagons.columns - 1) * width * .76)) / 2 + (index % hexagons.columns) * width * .76
                y: Math.floor(index / hexagons.columns) * (height + 12) + (index % hexagons.columns % 2) * height * .5
                visible: y + height >= hexagons.contentY - height && y <= hexagons.contentY + hexagons.height + height
                selected: index === root.currentIndex
                previewMotion: selected && root.motionEnabled
                onChosen: root.select(index)
            }
        }
        FastScroll {
            view: hexagons
        }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        spacing: 14
        ActionButton {
            text: ""
            icon: "chevron_left"
            compact: true
            enabled: root.count > 0
            onClicked: root.move(-1)
        }
        NacreText {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(420, root.width - 300)
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: root.currentEntry?.name || ""
            font.pointSize: 11
            color: root.fullScreen ? "white" : NacreColours.palette.m3onSurface
        }
        ActionButton {
            text: ""
            icon: "chevron_right"
            compact: true
            enabled: root.count > 0
            onClicked: root.move(1)
        }
    }
    Keys.onEscapePressed: root.visibilities.launcher = false
    Keys.onLeftPressed: root.move(-1)
    Keys.onRightPressed: root.move(1)
    Keys.onReturnPressed: root.choose()
    DropArea {
        anchors.fill: parent
        onDropped: drop => {
            if (drop.urls.length)
                NacreWallpapers.addFiles(drop.urls.map(String));
        }
    }
    component Card: NacreSurface {
        id: card
        required property var entry
        property bool selected: false
        property bool decode: true
        signal chosen
        radius: 15
        color: NacreColours.palette.m3surfaceContainer
        border.width: selected ? 2 : 0
        border.color: NacreColours.palette.m3primary
        NacreClip {
            anchors.fill: parent
            anchors.margins: 3
            radius: 12
            Image {
                id: image
                anchors.fill: parent
                source: card.decode ? "file://" + (card.entry.thumbnail || card.entry.poster) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                retainWhileLoading: true
                sourceSize.width: 640
                sourceSize.height: 420
            }
            Image {
                anchors.fill: image
                visible: card.selected && root.fullScreen && status === Image.Ready
                source: card.selected && root.fullScreen ? "file://" + (card.entry.preview || card.entry.poster) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                retainWhileLoading: true
                sourceSize.width: 1600
                sourceSize.height: 1000
            }
            NacreWallpaperMotion {
                anchors.fill: image
                entry: card.entry
                running: card.selected && root.motionEnabled
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.chosen()
        }
    }
}
