pragma ComponentBehavior: Bound
import qs.widgets
import qs.services
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Item {
    id: root
    required property PersistentProperties visibilities
    implicitWidth: Math.min(1360, Quickshell.screens[0].width - 140)
    implicitHeight: fullScreen ? Quickshell.screens[0].height - 100 : 360
    readonly property bool fullScreen: layout !== "carousel"
    readonly property string kind: Wallpapers.preferences.kind ?? "static"
    readonly property string layout: Wallpapers.preferences.layout ?? "carousel"
    readonly property var entries: Wallpapers.list.filter(w => w.dynamic === (kind === "dynamic") && search.text.toLowerCase().trim().split(/\s+/).every(word => (w.name + " " + w.path).toLowerCase().includes(word)))
    readonly property int count: entries.length
    property int currentIndex: 0
    readonly property var currentEntry: entries[currentIndex] ?? null
    property bool initializing: true
    property var motionStatus: ({})
    readonly property bool motionEnabled: visibilities.launcher && kind === "dynamic" && !Wallpapers.preferences.paused
    onCurrentEntryChanged: motionStatus = ({})
    function receiveMotion(data) {
        if (data.path === currentEntry?.path)
            motionStatus = data;
    }
    property string shownLayout: "carousel"
    onLayoutChanged: {
        if (bodyView?.item?.snapBeforeUnload)
            bodyView.item.snapBeforeUnload();
        shownLayout = layout;
    }
    function captureUiState() {
        return {
            path: currentEntry?.path ?? "",
            query: search.text
        };
    }
    function restoreUiState(data) {
        search.text = data.query || "";
        Qt.callLater(() => {
            const index = entries.findIndex(e => e.path === data.path);
            if (index >= 0)
                currentIndex = index;
        });
    }
    function restoreIndex() {
        initializing = true;
        currentIndex = Math.max(0, entries.findIndex(w => w.path === Wallpapers.current));
        Qt.callLater(() => initializing = false);
    }
    function select(index) {
        if (!count)
            return;
        currentIndex = Math.max(0, Math.min(count - 1, index));
        if (currentEntry)
            Wallpapers.browse(currentEntry.path);
    }
    function move(delta) {
        if (count)
            select((currentIndex + delta + count) % count);
    }
    property real wheelDistance: 0
    function wheel(event) {
        const angle = event.angleDelta.y;
        if (angle)
            move(angle > 0 ? -1 : 1);
        else {
            wheelDistance += event.pixelDelta.y;
            if (Math.abs(wheelDistance) >= 80) {
                move(wheelDistance > 0 ? -1 : 1);
                wheelDistance = 0;
            }
        }
        event.accepted = true;
    }
    function choose() {
        if (currentEntry)
            Wallpapers.setWallpaper(currentEntry.path);
    }
    onEntriesChanged: restoreIndex()
    Component.onCompleted: {
        shownLayout = layout;
        restoreIndex();
        forceActiveFocus();
    }
    Connections {
        target: root.visibilities
        function onLauncherChanged() {
            if (root.visibilities.launcher)
                root.forceActiveFocus();
            else
                Wallpapers.commitSelection();
        }
    }
    Keys.onLeftPressed: move(-1)
    Keys.onRightPressed: move(1)
    Keys.onUpPressed: move(-1)
    Keys.onDownPressed: move(1)
    Keys.onReturnPressed: choose()
    Keys.onEscapePressed: visibilities.launcher = false
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.visibilities.launcher = false
    }
    Row {
        id: toolbar
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.fullScreen ? 22 : 16
        spacing: 8
        ActionButton {
            text: "Static"
            icon: "image"
            selected: root.kind === "static"
            onClicked: Wallpapers.preference({
                kind: "static"
            })
        }
        ActionButton {
            text: "Dynamic"
            icon: "motion_photos_on"
            selected: root.kind === "dynamic"
            onClicked: Wallpapers.preference({
                kind: "dynamic"
            })
        }
        Rectangle {
            width: 1
            height: 26
            color: Colours.palette.m3outlineVariant
            anchors.verticalCenter: parent.verticalCenter
        }
        Repeater {
            model: [
                {
                    id: "carousel",
                    label: "Carousel",
                    icon: "view_carousel"
                },
                {
                    id: "spotlight",
                    label: "Spotlight",
                    icon: "crop_landscape"
                },
                {
                    id: "hexagons",
                    label: "Hexagons",
                    icon: "hexagon"
                }
            ]
            ActionButton {
                required property var modelData
                compact: true
                text: modelData.label
                icon: modelData.icon
                selected: root.layout === modelData.id
                onClicked: Wallpapers.preference({
                    layout: modelData.id
                })
            }
        }
        ActionButton {
            text: ""
            icon: "add_photo_alternate"
            onClicked: Wallpapers.pickFiles()
            ToolTip.text: "Add local wallpapers"
            ToolTip.visible: addHover.hovered
            HoverHandler {
                id: addHover
            }
        }
        ActionButton {
            text: ""
            icon: Wallpapers.preferences.paused ? "play_arrow" : "pause"
            visible: root.kind === "dynamic"
            onClicked: Wallpapers.preference({
                paused: !Wallpapers.preferences.paused
            })
        }
    }
    NacreTextField {
        id: search
        objectName: "wallpaperSearch"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: toolbar.bottom
        anchors.topMargin: 12
        width: Math.min(640, parent.width - 80)
        height: 42
        leftPadding: 14
        placeholderText: "Search wallpapers"
        background: NacreSurface {
            radius: 19
            color: Colours.palette.m3surfaceContainer
        }
        Keys.onEscapePressed: root.visibilities.launcher = false
        Keys.onDownPressed: {
            root.forceActiveFocus();
            root.move(1);
        }
        onAccepted: root.choose()
    }
    NacreText {
        anchors.top: search.bottom
        anchors.topMargin: 8
        x: 24
        width: parent.width - 48
        text: Wallpapers.error
        visible: text.length > 0
        color: Colours.palette.m3error
        font.pointSize: 10
        elide: Text.ElideRight
    }
    Item {
        id: body
        anchors.top: search.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.fullScreen ? 16 : 24
        anchors.rightMargin: root.fullScreen ? 16 : 24
        anchors.bottom: footer.top
        anchors.bottomMargin: 20
        Loader {
            id: bodyView
            anchors.fill: parent
            active: root.count > 0
            sourceComponent: root.shownLayout === "hexagons" ? honeycomb : root.shownLayout === "spotlight" ? spotlight : carousel
        }
        Column {
            anchors.centerIn: parent
            spacing: 14
            visible: root.count === 0
            NacreText {
                text: Wallpapers.loading ? "Loading wallpapers…" : search.text.trim() ? "No matching wallpapers" : root.kind === "dynamic" ? "Add a local video or animated GIF" : "No static wallpapers yet"
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 15
            }
            ActionButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Add wallpapers"
                icon: "add"
                onClicked: Wallpapers.pickFiles()
            }
        }
    }
    Row {
        id: footer
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.fullScreen ? 22 : 16
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14
        ActionButton {
            compact: true
            text: ""
            icon: "chevron_left"
            enabled: root.count > 1
            onClicked: root.move(-1)
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            width: Math.min(420, root.width - 180)
            NacreText {
                width: parent.width
                text: root.currentEntry?.name ?? ""
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.pointSize: 12
                color: Colours.palette.m3primary
            }
            NacreText {
                width: parent.width
                text: root.count ? (root.currentIndex + 1) + " / " + root.count : ""
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 10
                color: Colours.palette.m3onSurfaceVariant
            }
        }
        ActionButton {
            compact: true
            text: ""
            icon: "chevron_right"
            enabled: root.count > 1
            onClicked: root.move(1)
        }
    }
    Component {
        id: carousel
        PathView {
            id: compactStrip
            objectName: "carouselStrip"
            function snapBeforeUnload() {
                if (count > 0 && currentIndex >= 0)
                    positionViewAtIndex(currentIndex, PathView.SnapPosition);
            }
            Component.onDestruction: snapBeforeUnload()
            readonly property int candidateSlots: Math.min(root.count, Math.max(1, Math.floor(width / 246)))
            readonly property int slots: candidateSlots > 1 && candidateSlots % 2 === 0 ? candidateSlots - 1 : candidateSlots
            readonly property real cardWidth: Math.min(280, (width - (slots - 1) * 16) / slots)
            model: root.entries
            pathItemCount: slots
            cacheItemCount: Math.min(2, Math.max(0, root.count - slots))
            currentIndex: root.currentIndex
            preferredHighlightBegin: .5
            preferredHighlightEnd: .5
            highlightRangeMode: PathView.StrictlyEnforceRange
            snapMode: PathView.SnapToItem
            highlightMoveDuration: 300
            clip: true
            onCurrentIndexChanged: if (currentIndex >= 0 && currentIndex < count && root.visibilities.launcher && !root.initializing && currentIndex !== root.currentIndex)
                root.select(currentIndex)
            delegate: WallpaperCard {
                required property var modelData
                required property int index
                objectName: "carouselCard" + index
                width: compactStrip.cardWidth
                height: Math.min(compactStrip.height - 8, width * .70 + 36)
                entry: modelData
                selected: index === root.currentIndex
                previewMotion: root.motionEnabled
                onMotionChanged: data => root.receiveMotion(data)
                visible: PathView.onPath
                scale: PathView.isCurrentItem ? 1 : .91
                z: PathView.isCurrentItem ? 2 : 1
                onClicked: root.select(index)
                Behavior on scale {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.InOutCubic
                    }
                }
            }
            path: Path {
                startX: 0
                startY: compactStrip.height / 2
                PathLine {
                    x: compactStrip.width
                    y: compactStrip.height / 2
                }
            }
            Connections {
                target: root
                function onCurrentIndexChanged() {
                    if (root.currentIndex >= 0 && root.currentIndex < compactStrip.count && compactStrip.currentIndex !== root.currentIndex)
                        compactStrip.currentIndex = root.currentIndex;
                }
            }
            WheelHandler {
                target: null
                onWheel: event => root.wheel(event)
            }
        }
    }
    Component {
        id: spotlight
        Item {
            id: wideStrip
            objectName: "spotlightStrip"
            clip: true
            readonly property int sideSlots: Math.min(4, Math.floor((root.count - 1) / 2))
            readonly property real heroWidth: Math.min(width * .52, 1000)
            readonly property real sideWidth: Math.max(36, (width - heroWidth - sideSlots * 2 * 10) / (Math.max(1, sideSlots * 2)))
            Repeater {
                model: root.entries
                WallpaperCard {
                    id: motionCard
                    objectName: "spotlightCard" + index
                    required property var modelData
                    required property int index
                    property int previousOffset: 0
                    property bool animateTravel: false
                    readonly property int offset: ((index - root.currentIndex + Math.floor(root.count / 2) + root.count) % root.count) - Math.floor(root.count / 2)
                    onOffsetChanged: {
                        animateTravel = Math.abs(offset - previousOffset) <= 1;
                        previousOffset = offset;
                    }
                    Component.onCompleted: previousOffset = offset
                    x: offset === 0 ? (wideStrip.width - wideStrip.heroWidth) / 2 : offset < 0 ? (wideStrip.width - wideStrip.heroWidth) / 2 + offset * (wideStrip.sideWidth + 10) : (wideStrip.width + wideStrip.heroWidth) / 2 + 10 + (offset - 1) * (wideStrip.sideWidth + 10)
                    anchors.verticalCenter: wideStrip.verticalCenter
                    width: offset === 0 ? wideStrip.heroWidth : wideStrip.sideWidth
                    height: Math.min(wideStrip.height - 12, wideStrip.heroWidth * .70)
                    entry: modelData
                    selected: offset === 0
                    previewMotion: root.motionEnabled
                    onMotionChanged: data => root.receiveMotion(data)
                    imageOnly: true
                    imageEnabled: Math.abs(offset) <= wideStrip.sideSlots + 1
                    z: selected ? 2 : 1
                    opacity: Math.abs(offset) > wideStrip.sideSlots ? 0 : offset === 0 ? 1 : 0.68
                    visible: opacity > 0.001
                    onClicked: offset === 0 ? root.choose() : root.select(index)
                    Behavior on x {
                        enabled: motionCard.animateTravel
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }
            WheelHandler {
                target: null
                onWheel: event => root.wheel(event)
            }
        }
    }
    Component {
        id: honeycomb
        Flickable {
            id: view
            anchors.fill: parent
            contentWidth: width
            clip: true
            readonly property int columns: Math.max(3, Math.min(7, Math.floor(width / 230)))
            readonly property real hexWidth: Math.min(340, (width - 48) / (1 + (columns - 1) * .77))
            readonly property real hexHeight: hexWidth * .87
            readonly property real rowStep: hexHeight + 12
            readonly property real gridWidth: hexWidth + (columns - 1) * hexWidth * .77
            readonly property real startX: (width - gridWidth) / 2
            contentHeight: Math.ceil(root.count / columns) * rowStep + rowStep / 2
            FastScroll {
                view: view
            }
            ScrollBar.vertical: ScrollBar {}
            Repeater {
                model: root.entries
                WallpaperHex {
                    required property var modelData
                    required property int index
                    width: view.hexWidth
                    height: view.hexHeight
                    x: view.startX + (index % view.columns) * view.hexWidth * .77
                    y: Math.floor(index / view.columns) * view.rowStep + (index % view.columns) % 2 * view.rowStep / 2
                    entry: modelData
                    imageEnabled: y + height >= view.contentY - view.height && y <= view.contentY + view.height * 2
                    selected: index === root.currentIndex
                    previewMotion: root.motionEnabled
                    onMotionChanged: data => root.receiveMotion(data)
                    onClicked: root.select(index)
                }
            }
        }
    }
    component WallpaperCard: NacreSurface {
        id: card
        property var entry
        property bool selected: false
        property bool previewMotion: false
        signal motionChanged(var data)
        property bool imageOnly: false
        property bool imageEnabled: true
        signal clicked
        radius: imageOnly ? 8 : 17
        color: Colours.palette.m3surfaceContainer
        border.width: selected ? 2 : 0
        border.color: Colours.palette.m3primary
        Image {
            id: quickImage
            x: 6
            y: 6
            width: parent.width - 12
            height: parent.height - (card.imageOnly ? 12 : 42)
            source: card.imageEnabled && card.entry?.poster ? "file://" + (card.entry.thumbnail ?? card.entry.poster) : ""
            sourceSize.width: 600
            sourceSize.height: 600
            fillMode: Image.PreserveAspectCrop
            asynchronous: !card.entry?.thumbnail
        }
        Image {
            anchors.fill: quickImage
            source: card.imageEnabled && card.imageOnly && card.entry?.preview ? "file://" + card.entry.preview : ""
            sourceSize.width: 1200
            sourceSize.height: 840
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: status === Image.Ready ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }
        }

        WallpaperMotionPreview {
            anchors.fill: quickImage
            entry: card.entry
            running: card.selected && card.previewMotion && card.visible && card.imageEnabled
            onStateChanged: data => card.motionChanged(data)
        }

        NacreText {
            visible: !card.imageOnly
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            width: parent.width - 12
            anchors.horizontalCenter: parent.horizontalCenter
            text: card.entry?.name ?? ""
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: 10
        }
        ToolTip.text: card.entry?.name ?? ""
        ToolTip.visible: cardHover.hovered
        ToolTip.delay: 500
        HoverHandler {
            id: cardHover
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.clicked()
        }
    }
    DropArea {
        anchors.fill: parent
        onDropped: drop => {
            if (drop.hasUrls) {
                Wallpapers.addFiles(drop.urls);
                drop.acceptProposedAction();
            }
        }
    }
    IpcHandler {
        target: "wallpaperPicker"
        function view(kind: string, layout: string): void {
            Wallpapers.preference({
                kind: kind,
                layout: layout
            });
        }
        function state(): string {
            return JSON.stringify({
                query: search.text,
                kind: root.kind,
                layout: root.layout,
                count: root.count,
                index: root.currentIndex,
                width: root.width,
                height: root.height,
                fullScreen: root.fullScreen,
                motion: root.motionStatus
            });
        }
    }
}
