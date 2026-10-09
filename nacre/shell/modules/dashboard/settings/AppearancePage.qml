import qs.widgets
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls
import ".."

SettingsPage {
    id: root
    property string paletteGroup: "vivid"
    SettingsSection {
        title: "Wallpaper"
        description: "Choose a scene from your personal collection."
        Row {
            width: parent.width
            spacing: 16
            Image {
                width: Math.min(300, parent.width * .44)
                height: 150
                source: Wallpapers.preview ? "file://" + Wallpapers.preview : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 600
                sourceSize.height: 300
            }
            Column {
                width: parent.width - Math.min(300, parent.width * .44) - 16
                spacing: 12
                StyledText {
                    width: parent.width
                    text: Wallpapers.current.split("/").pop().replace(" - 4K", "")
                    wrapMode: Text.Wrap
                    font.pointSize: 11
                }
                ActionButton {
                    text: "Wallpaper picker"
                    icon: "wallpaper"
                    onClicked: AppLaunch.run(["nacre-shell", "wallpaper"])
                }
            }
        }
    }
    SettingsSection {
        title: "Wallpaper motion"
        description: "Choose desktop animation while keeping the same scene and colors. Picker previews remain available."
        Flow {
            width: parent.width
            spacing: 8
            Repeater {
                model: [
                    {
                        id: "full",
                        name: "Full motion"
                    },
                    {
                        id: "battery",
                        name: "Still on battery"
                    },
                    {
                        id: "still",
                        name: "Always still"
                    }
                ]
                ActionButton {
                    required property var modelData
                    text: modelData.name
                    selected: (Wallpapers.preferences.motionMode ?? "full") === modelData.id
                    onClicked: Wallpapers.preference({
                        motionMode: modelData.id
                    })
                }
            }
        }
    }
    SettingsSection {
        title: "Wallpaper rotation"
        description: "Automatically change scenes while you use the desktop."
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                text: "Manual"
                selected: !Wallpapers.preferences.rotationEnabled
                onClicked: Wallpapers.preference({
                    rotationEnabled: false
                })
            }
            ActionButton {
                text: "Rotate automatically"
                selected: Wallpapers.preferences.rotationEnabled === true
                onClicked: Wallpapers.preference({
                    rotationEnabled: true
                })
            }
            ActionButton {
                text: "Next now"
                icon: "skip_next"
                enabled: Wallpapers.rotationReady
                onClicked: Wallpapers.advanceRotation(true)
            }
        }
        Column {
            width: parent.width
            spacing: 12
            visible: Wallpapers.preferences.rotationEnabled === true
            Flow {
                width: parent.width
                spacing: 8
                Repeater {
                    model: [15, 30, 60, 120]
                    ActionButton {
                        required property int modelData
                        text: modelData === 30 ? "30 min · recommended" : modelData + " min"
                        selected: Wallpapers.preferences.rotationMinutes === modelData
                        onClicked: Wallpapers.preference({
                            rotationMinutes: modelData
                        })
                    }
                }
            }
            Row {
                spacing: 12
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Custom interval (minutes)"
                    font.pointSize: 10
                }
                SpinBox {
                    id: intervalControl
                    objectName: "wallpaperRotationMinutes"
                    implicitWidth: 150
                    implicitHeight: 40
                    leftPadding: 38
                    rightPadding: 38
                    font.family: Appearance.font.family.sans
                    font.pointSize: 10
                    background: StyledRect {
                        radius: 20
                        color: Colours.palette.m3surfaceContainerHigh
                        border.width: 1
                        border.color: intervalControl.activeFocus ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3outlineVariant, 0.6)
                    }
                    contentItem: TextInput {
                        text: intervalControl.textFromValue(intervalControl.value, intervalControl.locale)
                        font: intervalControl.font
                        color: Colours.palette.m3onSurface
                        selectionColor: Colours.palette.m3primary
                        selectedTextColor: Colours.palette.m3onPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        readOnly: !intervalControl.editable
                        validator: intervalControl.validator
                        inputMethodHints: Qt.ImhDigitsOnly
                        selectByMouse: true
                    }
                    up.indicator: StyledRect {
                        x: intervalControl.mirrored ? 0 : intervalControl.width - width
                        implicitWidth: 36
                        height: intervalControl.height
                        radius: 18
                        color: intervalControl.up.pressed ? Qt.alpha(Colours.palette.m3primary, 0.18) : intervalControl.up.hovered ? Qt.alpha(Colours.palette.m3primary, 0.1) : "transparent"
                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "add"
                            color: Colours.palette.m3primary
                            opacity: intervalControl.up.enabled ? 1 : 0.4
                            font.pointSize: 16
                        }
                    }
                    down.indicator: StyledRect {
                        x: intervalControl.mirrored ? intervalControl.width - width : 0
                        implicitWidth: 36
                        height: intervalControl.height
                        radius: 18
                        color: intervalControl.down.pressed ? Qt.alpha(Colours.palette.m3primary, 0.18) : intervalControl.down.hovered ? Qt.alpha(Colours.palette.m3primary, 0.1) : "transparent"
                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "remove"
                            color: Colours.palette.m3primary
                            opacity: intervalControl.down.enabled ? 1 : 0.4
                            font.pointSize: 16
                        }
                    }
                    from: 5
                    to: 1440
                    stepSize: 5
                    editable: true
                    value: Wallpapers.preferences.rotationMinutes ?? 30
                    onValueModified: Wallpapers.preference({
                        rotationMinutes: value
                    })
                }
            }
            StyledText {
                width: parent.width
                text: "30 minutes gives you variety without frequent changes. Use a longer interval if you prefer fewer interruptions."
                wrapMode: Text.Wrap
                font.pointSize: 10
                color: Colours.palette.m3onSurfaceVariant
            }
            Flow {
                width: parent.width
                spacing: 8
                Repeater {
                    model: [
                        {
                            id: "all",
                            name: "All wallpapers"
                        },
                        {
                            id: "static",
                            name: "Static only"
                        },
                        {
                            id: "dynamic",
                            name: "Dynamic only"
                        }
                    ]
                    ActionButton {
                        required property var modelData
                        text: modelData.name
                        selected: (Wallpapers.preferences.rotationKind ?? "all") === modelData.id
                        onClicked: Wallpapers.preference({
                            rotationKind: modelData.id
                        })
                    }
                }
            }
            Flow {
                width: parent.width
                spacing: 8
                ActionButton {
                    text: "Shuffle"
                    selected: Wallpapers.preferences.rotationShuffle !== false
                    onClicked: Wallpapers.preference({
                        rotationShuffle: true
                    })
                }
                ActionButton {
                    text: "In order"
                    selected: Wallpapers.preferences.rotationShuffle === false
                    onClicked: Wallpapers.preference({
                        rotationShuffle: false
                    })
                }
            }
            StyledText {
                width: parent.width
                text: "Rotation pauses while you are locked, asleep or browsing settings and wallpapers. A scheduled change waits until you return, without restarting the countdown."
                wrapMode: Text.Wrap
                font.pointSize: 10
                color: Colours.palette.m3onSurfaceVariant
            }
            StyledText {
                width: parent.width
                text: Wallpapers.rotationStatus
                wrapMode: Text.Wrap
                font.pointSize: 10
                color: Colours.palette.m3primary
            }
        }
    }
    SettingsSection {
        title: "Desktop colors"
        description: "Follow the wallpaper, or keep one palette across every scene."
        Flow {
            width: parent.width
            spacing: 8
            ActionButton {
                text: "Match wallpaper"
                icon: "palette"
                selected: (Wallpapers.preferences.palettePreset ?? "wallpaper") === "wallpaper"
                enabled: !Wallpapers.themeBusy
                onClicked: Wallpapers.preference({
                    palettePreset: "wallpaper"
                })
            }
            ActionButton {
                text: "Dark"
                selected: !Colours.light
                enabled: !Wallpapers.themeBusy
                onClicked: Colours.setMode("dark")
            }
            ActionButton {
                text: "Light"
                selected: Colours.light
                enabled: !Wallpapers.themeBusy
                onClicked: Colours.setMode("light")
            }
        }
        Flow {
            width: parent.width
            spacing: 8
            Repeater {
                model: [
                    {
                        id: "vivid",
                        name: "Vivid"
                    },
                    {
                        id: "soft",
                        name: "Soft"
                    },
                    {
                        id: "all",
                        name: "All colors"
                    }
                ]
                ActionButton {
                    required property var modelData
                    text: modelData.name
                    selected: root.paletteGroup === modelData.id
                    onClicked: root.paletteGroup = modelData.id
                }
            }
        }
        Flow {
            width: parent.width
            spacing: 10
            objectName: "paletteOptions"
            Repeater {
                model: Wallpapers.palettePresets.filter(p => root.paletteGroup === "all" || (p.group ?? "soft") === root.paletteGroup)
                StyledRect {
                    required property var modelData
                    objectName: "paletteColorTile"
                    property bool chosen: Wallpapers.preferences.palettePreset === modelData.id
                    width: Math.floor(parent.width >= 840 ? (parent.width - 50) / 6 : (parent.width - 20) / 3)
                    height: 86
                    radius: 12
                    color: "#" + modelData.surface.replace("#", "")
                    border.width: chosen ? 2 : 1
                    border.color: chosen ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                    opacity: Wallpapers.themeBusy ? .5 : 1
                    Column {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: 10
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8
                            Repeater {
                                model: parent.parent.parent.modelData.swatches
                                Rectangle {
                                    required property string modelData
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: "#" + modelData.replace("#", "")
                                }
                            }
                        }
                        StyledText {
                            width: parent.parent.width - 16
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: parent.parent.modelData.name + (parent.parent.chosen ? "  ✓" : "")
                            color: "#f1edf6"
                            font.pointSize: 10
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: !Wallpapers.themeBusy
                        onClicked: Wallpapers.preference({
                            palettePreset: parent.modelData.id,
                            paletteMode: Colours.light ? "light" : "dark"
                        })
                    }
                }
            }
        }
        StyledText {
            width: parent.width
            text: (Wallpapers.preferences.palettePreset ?? "wallpaper") === "wallpaper" ? "Colors change with the wallpaper across the shell, apps, terminal, lock screen and login." : (Wallpapers.palettePresets.find(p => p.id === Wallpapers.preferences.palettePreset)?.name ?? "This palette") + " stays fixed as wallpapers change. Light and dark mode remain your choice."
            wrapMode: Text.Wrap
            font.pointSize: 10
            color: Colours.palette.m3onSurfaceVariant
        }
        StyledText {
            visible: Wallpapers.error.length > 0
            width: parent.width
            text: Wallpapers.error
            wrapMode: Text.Wrap
            color: Colours.palette.m3error
            font.pointSize: 10
        }
    }
    SettingsSection {
        title: "Your wallpapers"
        description: Wallpapers.list.length + " scenes in your collection"
        collapsible: true
        GridView {
            id: wallGrid
            objectName: "settingsWallpaperGrid"
            width: parent.width
            cellWidth: 158
            cellHeight: 115
            height: Math.ceil(count / Math.max(1, Math.floor(width / cellWidth))) * cellHeight
            interactive: false
            model: Wallpapers.list
            delegate: Item {
                objectName: "wallpaperTile"
                required property var modelData
                width: wallGrid.cellWidth
                height: wallGrid.cellHeight
                StyledRect {
                    x: 0
                    y: 0
                    width: 148
                    height: 105
                    radius: 8
                    visible: thumb.status !== Image.Ready
                    color: Colours.palette.m3surfaceContainerHigh
                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "landscape"
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
                Image {
                    id: thumb
                    x: 0
                    y: 0
                    width: 148
                    height: 105
                    source: "file://" + (parent.modelData.thumbnail ?? parent.modelData.poster)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: !parent.modelData.thumbnail
                    sourceSize.width: 296
                    sourceSize.height: 210
                }
                Rectangle {
                    x: 0
                    y: 0
                    width: 148
                    height: 105
                    color: "transparent"
                    border.width: Wallpapers.current === parent.modelData.path ? 3 : 0
                    border.color: Colours.palette.m3primary
                }
                MouseArea {
                    x: 0
                    y: 0
                    width: 148
                    height: 105
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpapers.setWallpaper(parent.modelData.path)
                }
            }
        }
    }
    SettingsSection {
        title: "Panels and frame"
        description: "Desktop edges, previews and panel behavior"
        collapsible: true
        DesktopControls {
            width: parent.width
            height: implicitHeight
            page: "appearance"
        }
    }
}
