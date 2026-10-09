import QtQuick
import qs.config
import qs.services
import qs.widgets

Item {
    id: root

    property string icon: "expand_more"
    property bool externalHovered: false
    property bool shown: false
    readonly property bool hovered: externalHovered || mouse.containsMouse

    signal clicked

    implicitWidth: 40
    implicitHeight: 36
    onHoveredChanged: {
        if (hovered) {
            hideDelay.stop();
            revealDelay.restart();
        } else {
            revealDelay.stop();
            hideDelay.restart();
        }
    }
    onVisibleChanged: {
        if (!visible) {
            shown = false;
            revealDelay.stop();
            hideDelay.stop();
        }
    }

    Timer {
        id: revealDelay

        interval: 160
        onTriggered: root.shown = root.hovered
    }

    Timer {
        id: hideDelay

        interval: 280
        onTriggered: root.shown = false
    }

    NacreSurface {
        anchors.fill: parent
        radius: 18
        color: NacreColours.palette.m3surfaceContainerHigh
        border.width: 1
        border.color: Qt.alpha(NacreColours.palette.m3primary, 0.45)
        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.9

        NacreIcon {
            anchors.centerIn: parent
            text: root.icon
            color: NacreColours.palette.m3primary
            font.pointSize: 19
        }

        Behavior on opacity {
            NumberAnimation {
                duration: DesktopSettings.data.animations === false ? 0 : 140
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: DesktopSettings.data.animations === false ? 0 : 140
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: root.shown ? Qt.LeftButton : Qt.NoButton
        cursorShape: root.shown ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
