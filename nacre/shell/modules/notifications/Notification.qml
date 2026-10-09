pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

NacreSurface {
    id: root

    required property Notifs.Notif modelData
    HoverHandler {
        onHoveredChanged: root.modelData.hovered = hovered
    }
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property int nonAnimHeight: summary.implicitHeight + (root.expanded ? appName.height + body.height + actions.height + actions.anchors.topMargin : bodyPreview.height) + inner.anchors.margins * 2
    property bool history: false
    property bool expanded

    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainer
    radius: NacreAppearance.rounding.normal
    implicitWidth: NacreNotifications.sizes.width
    implicitHeight: inner.implicitHeight

    x: NacreNotifications.sizes.width
    Component.onCompleted: x = 0

    RetainableLock {
        object: root.modelData.notification
        locked: true
    }

    MouseArea {
        property int startY

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        // HoverHandler owns pause state; keep the timer running binding intact.

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                Notifs.dismiss(root.modelData);
        }
        onReleased: event => {
            if (Math.abs(root.x) < NacreNotifications.sizes.width * NacreNotifications.clearThreshold)
                root.x = 0;
            else if (root.history)
                Notifs.dismiss(root.modelData);
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > NacreNotifications.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (!NacreNotifications.actionOnClick || event.button !== Qt.LeftButton)
                return;

            const actions = root.modelData.actions;
            if (actions?.length === 1)
                actions[0].invoke();
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.emphasizedDecel
        }
    }

    Item {
        id: inner

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: NacreAppearance.padding.normal

        implicitHeight: root.nonAnimHeight

        Behavior on implicitHeight {
            Anim {}
        }

        Loader {
            id: image

            active: root.hasImage
            asynchronous: true

            anchors.left: parent.left
            anchors.top: parent.top
            width: NacreNotifications.sizes.image
            height: NacreNotifications.sizes.image
            visible: root.hasImage || root.hasAppIcon

            sourceComponent: ClippingRectangle {
                radius: NacreAppearance.rounding.full
                implicitWidth: NacreNotifications.sizes.image
                implicitHeight: NacreNotifications.sizes.image

                Image {
                    anchors.fill: parent
                    source: Qt.resolvedUrl(root.modelData.image)
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                }
            }
        }

        Loader {
            id: appIcon

            active: root.hasAppIcon || !root.hasImage
            asynchronous: true

            anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
            anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
            anchors.right: root.hasImage ? image.right : undefined
            anchors.bottom: root.hasImage ? image.bottom : undefined

            sourceComponent: NacreSurface {
                radius: NacreAppearance.rounding.full
                color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3surfaceContainerHighest : Colours.palette.m3tertiaryContainer
                implicitWidth: root.hasImage ? NacreNotifications.sizes.badge : NacreNotifications.sizes.image
                implicitHeight: root.hasImage ? NacreNotifications.sizes.badge : NacreNotifications.sizes.image

                Loader {
                    id: icon

                    active: root.hasAppIcon
                    asynchronous: true

                    anchors.centerIn: parent
                    visible: !root.modelData.appIcon.endsWith("symbolic")

                    width: Math.round(parent.width * 0.6)
                    height: Math.round(parent.width * 0.6)

                    sourceComponent: IconImage {
                        implicitSize: Math.round(parent.width * 0.6)
                        source: Quickshell.iconPath(root.modelData.appIcon)
                        asynchronous: true
                    }
                }

                Loader {
                    active: root.modelData.appIcon.endsWith("symbolic")
                    asynchronous: true
                    anchors.fill: icon

                    sourceComponent: NacreTint {
                        source: icon
                        colorizationColor: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onTertiaryContainer
                    }
                }

                Loader {
                    active: !root.hasAppIcon
                    asynchronous: true
                    anchors.centerIn: parent

                    sourceComponent: NacreIcon {
                        text: {
                            const summary = root.modelData.summary.toLowerCase();
                            if (summary.includes("reboot"))
                                return "restart_alt";
                            if (summary.includes("recording"))
                                return "screen_record";
                            if (summary.includes("battery"))
                                return "power";
                            if (summary.includes("screenshot"))
                                return "screenshot_monitor";
                            if (summary.includes("welcome"))
                                return "waving_hand";
                            if (summary.includes("time") || summary.includes("a break"))
                                return "schedule";
                            if (summary.includes("installed"))
                                return "download";
                            if (summary.includes("update"))
                                return "update";
                            if (summary.startsWith("file"))
                                return "folder_copy";
                            if (root.modelData.urgency === NotificationUrgency.Critical)
                                return "release_alert";
                            return "chat";
                        }

                        color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onTertiaryContainer
                        font.pointSize: NacreAppearance.font.size.large
                    }
                }
            }
        }

        NacreText {
            id: appName

            anchors.top: parent.top
            anchors.left: image.right
            anchors.leftMargin: NacreAppearance.spacing.smaller

            animate: true
            text: appNameMetrics.elidedText
            maximumLineCount: 1
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.small

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }
        }

        TextMetrics {
            id: appNameMetrics

            text: root.modelData.appName
            font.family: appName.font.family
            font.pointSize: appName.font.pointSize
            elide: Text.ElideRight
            elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - NacreAppearance.spacing.small * 3
        }

        NacreText {
            id: summary

            anchors.top: parent.top
            anchors.left: image.right
            anchors.leftMargin: NacreAppearance.spacing.smaller

            animate: true
            text: summaryMetrics.elidedText
            maximumLineCount: 1
            height: implicitHeight

            states: State {
                name: "expanded"
                when: root.expanded

                PropertyChanges {
                    summary.maximumLineCount: undefined
                }

                AnchorChanges {
                    target: summary
                    anchors.top: appName.bottom
                }
            }

            transitions: Transition {
                PropertyAction {
                    target: summary
                    property: "maximumLineCount"
                }
                AnchorAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }

            Behavior on height {
                Anim {}
            }
        }

        TextMetrics {
            id: summaryMetrics

            text: root.modelData.summary
            font.family: summary.font.family
            font.pointSize: summary.font.pointSize
            elide: Text.ElideRight
            elideWidth: expandBtn.x - time.width - timeSep.width - summary.x - NacreAppearance.spacing.small * 3
        }

        NacreText {
            id: timeSep

            anchors.top: parent.top
            anchors.left: summary.right
            anchors.leftMargin: NacreAppearance.spacing.small

            text: "•"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.small

            states: State {
                name: "expanded"
                when: root.expanded

                AnchorChanges {
                    target: timeSep
                    anchors.left: appName.right
                }
            }

            transitions: Transition {
                AnchorAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }

        NacreText {
            id: time

            anchors.top: parent.top
            anchors.left: timeSep.right
            anchors.leftMargin: NacreAppearance.spacing.small

            animate: true
            horizontalAlignment: Text.AlignLeft
            text: root.modelData.timeStr
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.small
        }

        Item {
            id: expandBtn

            anchors.right: parent.right
            anchors.top: parent.top

            implicitWidth: expandIcon.height
            implicitHeight: expandIcon.height

            NacreInteraction {
                radius: NacreAppearance.rounding.full

                function onClicked() {
                    root.expanded = !root.expanded;
                }
            }

            NacreIcon {
                id: expandIcon

                anchors.centerIn: parent

                animate: true
                text: root.expanded ? "expand_less" : "expand_more"
                font.pointSize: NacreAppearance.font.size.normal
            }
        }

        NacreText {
            id: bodyPreview

            anchors.left: summary.left
            anchors.right: expandBtn.left
            anchors.top: summary.bottom
            anchors.rightMargin: NacreAppearance.spacing.small

            animate: true
            textFormat: Text.MarkdownText
            text: bodyPreviewMetrics.elidedText
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.small

            opacity: root.expanded ? 0 : 1

            Behavior on opacity {
                Anim {}
            }
        }

        TextMetrics {
            id: bodyPreviewMetrics

            text: root.modelData.body
            font.family: bodyPreview.font.family
            font.pointSize: bodyPreview.font.pointSize
            elide: Text.ElideRight
            elideWidth: bodyPreview.width
        }

        NacreText {
            id: body

            anchors.left: summary.left
            anchors.right: expandBtn.left
            anchors.top: summary.bottom
            anchors.rightMargin: NacreAppearance.spacing.small

            animate: true
            textFormat: Text.MarkdownText
            text: root.modelData.body
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: NacreAppearance.font.size.small
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }
        }

        RowLayout {
            id: actions

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: body.bottom
            anchors.topMargin: NacreAppearance.spacing.small

            spacing: NacreAppearance.spacing.smaller

            opacity: root.expanded ? 1 : 0

            Behavior on opacity {
                Anim {}
            }

            Repeater {
                model: root.modelData.actions

                delegate: NacreSurface {
                    id: action

                    required property NotificationAction modelData

                    radius: NacreAppearance.rounding.full
                    color: Colours.palette.m3surfaceContainerHigh

                    Layout.preferredWidth: actionText.width + NacreAppearance.padding.normal * 2
                    Layout.preferredHeight: actionText.height + NacreAppearance.padding.small * 2
                    implicitWidth: actionText.width + NacreAppearance.padding.normal * 2
                    implicitHeight: actionText.height + NacreAppearance.padding.small * 2

                    NacreInteraction {
                        radius: NacreAppearance.rounding.full

                        function onClicked(): void {
                            action.modelData.invoke();
                        }
                    }

                    NacreText {
                        id: actionText

                        anchors.centerIn: parent
                        text: actionTextMetrics.elidedText
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: NacreAppearance.font.size.small
                    }

                    TextMetrics {
                        id: actionTextMetrics

                        text: modelData.text
                        font.family: actionText.font.family
                        font.pointSize: actionText.font.pointSize
                        elide: Text.ElideRight
                        elideWidth: {
                            const numActions = root.modelData.actions.length;
                            return (inner.width - actions.spacing * (numActions - 1)) / numActions - NacreAppearance.padding.normal * 2;
                        }
                    }
                }
            }
        }
    }

    component Anim: NumberAnimation {
        duration: NacreAppearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: NacreAppearance.anim.curves.standard
    }
}
