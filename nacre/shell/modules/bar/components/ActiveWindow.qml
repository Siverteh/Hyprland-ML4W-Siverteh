pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.utils
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Brightness.Monitor monitor
    property bool horizontal: false
    readonly property string displayTitle: {
        const client = NacreHyprland.activeClient;
        if (client?.wmClass === "siverteh-ai-dashboard")
            return "Nacre AI";
        if (client?.wmClass === "siverteh-ai-task") {
            // An unknown chat waits for its name instead of flashing a placeholder.
            if (!ChatWindowTitle.resolved)
                return "";
            if (ChatWindowTitle.title)
                return ChatWindowTitle.title;
            return ["Load chat", "Resume latest chat", "New chat"].includes(client.title) ? "Nacre AI chat" : client.title || "Nacre AI chat";
        }
        if (client?.wmClass === "kitty" && /^fish(?: in |$)/.test(client.title ?? ""))
            return "Terminal · " + (client.title.replace(/^fish in /, "").replace(/^fish$/, "") || "Home");
        return client?.title ?? qsTr("Desktop");
    }
    property color colour: Colours.palette.m3primary
    readonly property Item child: child

    implicitWidth: horizontal ? horizontalRow.implicitWidth : child.implicitWidth
    implicitHeight: horizontal ? horizontalRow.implicitHeight : child.implicitHeight

    MouseArea {
        anchors.top: parent.top
        anchors.bottom: child.top
        anchors.left: parent.left
        anchors.right: parent.right

        onWheel: event => {
            if (event.angleDelta.y > 0)
                NacreAudio.setVolume(NacreAudio.volume + 0.1);
            else if (event.angleDelta.y < 0)
                NacreAudio.setVolume(NacreAudio.volume - 0.1);
        }
    }

    MouseArea {
        anchors.top: child.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        onWheel: event => {
            const monitor = root.monitor;
            if (event.angleDelta.y > 0)
                monitor.setBrightness(monitor.brightness + 0.1);
            else if (event.angleDelta.y < 0)
                monitor.setBrightness(monitor.brightness - 0.1);
        }
    }

    Item {
        id: child
        visible: !root.horizontal

        property Item current: text1

        anchors.centerIn: parent

        clip: true
        implicitWidth: Math.max(icon.implicitWidth, current.implicitHeight)
        implicitHeight: icon.implicitHeight + current.implicitWidth + current.anchors.topMargin

        NacreIcon {
            id: icon
            rotation: -90

            animate: true
            text: NacreIcons.getAppCategoryIcon(NacreHyprland.activeClient?.wmClass, "desktop_windows")
            color: root.colour

            anchors.horizontalCenter: parent.horizontalCenter
        }

        Title {
            id: text1
        }

        Title {
            id: text2
        }

        TextMetrics {
            id: metrics

            text: root.displayTitle
            font.pointSize: NacreAppearance.font.size.smaller
            font.family: NacreAppearance.font.family.mono
            elide: Qt.ElideRight
            elideWidth: root.height - icon.height

            onTextChanged: {
                const next = child.current === text1 ? text2 : text1;
                next.text = elidedText;
                child.current = next;
            }
            onElideWidthChanged: child.current.text = elidedText
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.emphasized
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.emphasized
            }
        }
    }

    RowLayout {
        id: horizontalRow
        visible: root.horizontal
        anchors.centerIn: parent
        width: Math.min(implicitWidth, root.width)
        spacing: NacreAppearance.spacing.small
        NacreIcon {
            text: NacreIcons.getAppCategoryIcon(NacreHyprland.activeClient?.wmClass, "desktop_windows")
            color: root.colour
            Layout.alignment: Qt.AlignVCenter
        }
        NacreText {
            text: root.displayTitle
            color: root.colour
            font.pointSize: NacreAppearance.font.size.smaller
            font.family: NacreAppearance.font.family.mono
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    component Title: NacreText {
        id: text

        anchors.horizontalCenter: icon.horizontalCenter
        anchors.top: icon.bottom
        anchors.topMargin: NacreAppearance.spacing.small

        font.pointSize: metrics.font.pointSize
        font.family: metrics.font.family
        color: root.colour
        opacity: child.current === this ? 1 : 0

        transform: Rotation {
            angle: -90
            origin.x: text.implicitHeight / 2
            origin.y: text.implicitHeight / 2
        }

        width: implicitHeight
        height: implicitWidth

        Behavior on opacity {
            NumberAnimation {
                duration: NacreAppearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: NacreAppearance.anim.curves.standard
            }
        }
    }
}
