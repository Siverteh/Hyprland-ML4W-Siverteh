pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property int padding: NacreAppearance.padding.large
    readonly property int rounding: NacreAppearance.rounding.large

    implicitWidth: listWrapper.width + padding * 2
    implicitHeight: searchWrapper.height + listWrapper.height + padding * 2

    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter

    Item {
        id: listWrapper

        implicitWidth: list.width
        implicitHeight: list.height + root.padding

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: searchWrapper.top
        anchors.bottomMargin: root.padding

        ContentList {
            id: list

            visibilities: root.visibilities
            search: search
            padding: root.padding
            rounding: root.rounding
        }
    }

    NacreSurface {
        id: searchWrapper

        color: Colours.alpha(Colours.palette.m3surfaceContainer, true)
        radius: NacreAppearance.rounding.full

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.padding

        implicitHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)

        NacreIcon {
            id: searchIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.padding

            text: "search"
            color: Colours.palette.m3onSurfaceVariant
        }

        NacreTextField {
            id: search
            Component.onCompleted: text = root.visibilities.launcherQuery
            Connections {
                target: root.visibilities
                function onLauncherRequestChanged() {
                    search.text = root.visibilities.launcherQuery;
                    search.forceActiveFocus();
                }
            }

            anchors.left: searchIcon.right
            anchors.right: clearIcon.left
            anchors.leftMargin: NacreAppearance.spacing.small
            anchors.rightMargin: NacreAppearance.spacing.small

            topPadding: NacreAppearance.padding.larger
            bottomPadding: NacreAppearance.padding.larger

            placeholderText: qsTr("Type \"%1\" for commands").arg(NacreLauncher.actionPrefix)
            background: null

            onAccepted: {
                const currentItem = list.currentList?.currentItem;
                if (currentItem) {
                    if (list.showWallpapers) {
                        Wallpapers.setWallpaper(currentItem.modelData.path);
                        root.visibilities.launcher = false;
                    } else if (text.startsWith(NacreLauncher.actionPrefix)) {
                        currentItem.modelData.onClicked(list.currentList);
                    } else {
                        Apps.launch(currentItem.modelData);
                        root.visibilities.launcher = false;
                    }
                }
            }

            Keys.onUpPressed: list.currentList?.decrementCurrentIndex()
            Keys.onDownPressed: list.currentList?.incrementCurrentIndex()

            Keys.onEscapePressed: root.visibilities.launcher = false

            Connections {
                target: root.visibilities

                function onLauncherChanged(): void {
                    if (root.visibilities.launcher)
                        search.forceActiveFocus();
                    else {
                        search.text = "";
                        const current = list.currentList;
                        if (current)
                            current.currentIndex = 0;
                    }
                }
            }
        }

        NacreIcon {
            id: clearIcon

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: root.padding

            width: search.text ? implicitWidth : implicitWidth / 2
            opacity: {
                if (!search.text)
                    return 0;
                if (mouse.pressed)
                    return 0.7;
                if (mouse.hovered)
                    return 0.8;
                return 1;
            }

            text: "close"
            color: Colours.palette.m3onSurfaceVariant

            MouseArea {
                id: mouse

                property bool hovered

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: search.text ? Qt.PointingHandCursor : undefined

                onEntered: hovered = true
                onExited: hovered = false
                onClicked: search.text = ""
            }

            Behavior on width {
                NumberAnimation {
                    duration: NacreAppearance.anim.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: NacreAppearance.anim.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }
    }
}
