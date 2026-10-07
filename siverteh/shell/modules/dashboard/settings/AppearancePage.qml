import qs.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import ".."

SettingsPage {
    id: root
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
                    onClicked: AppLaunch.run(["siverteh-os-shell", "wallpaper"])
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
                    objectName: "wallpaperRotationMinutes"
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
                text: "Rotation pauses while you are locked, asleep or browsing settings and wallpapers. The interval starts fresh when you return."
                wrapMode: Text.Wrap
                font.pointSize: 10
                color: Colours.palette.m3onSurfaceVariant
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
            spacing: 10
            Repeater {
                model: Wallpapers.palettePresets
                StyledRect {
                    required property var modelData
                    property bool chosen: Wallpapers.preferences.palettePreset === modelData.id
                    width: parent.width >= 840 ? (parent.width - 50) / 6 : (parent.width - 20) / 3
                    height: 86
                    radius: 12
                    color: "#" + modelData.surface.replace("#", "")
                    border.width: chosen ? 2 : 1
                    border.color: chosen ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                    opacity: Wallpapers.themeBusy ? .5 : 1
                    Column {
                        anchors.centerIn: parent
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
            text: (Wallpapers.preferences.palettePreset ?? "wallpaper") === "wallpaper" ? "Colors change with the wallpaper across the shell, apps, terminal, lock screen and login." : "This palette stays fixed as wallpapers change. Light and dark mode remain your choice."
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
