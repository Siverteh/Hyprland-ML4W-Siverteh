import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property bool shouldUpdate

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? active.position / active.length : 0;
    }

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    implicitWidth: NacreDashboard.sizes.mediaWidth

    Behavior on playerProgress {
        NumberAnimation {
            duration: NacreAppearance.anim.durations.large
            easing.type: Easing.BezierSpline
            easing.bezierCurve: NacreAppearance.anim.curves.standard
        }
    }

    Timer {
        running: root.shouldUpdate && (Players.active?.isPlaying ?? false)
        interval: NacreDashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    Shape {
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.palette.m3surfaceContainerHigh
            strokeWidth: NacreDashboard.sizes.mediaProgressThickness
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: cover.x + cover.width / 2
                centerY: cover.y + cover.height / 2
                radiusX: (cover.width + NacreDashboard.sizes.mediaProgressThickness) / 2 + NacreAppearance.spacing.small
                radiusY: (cover.height + NacreDashboard.sizes.mediaProgressThickness) / 2 + NacreAppearance.spacing.small
                startAngle: -90 - NacreDashboard.sizes.mediaProgressSweep / 2
                sweepAngle: NacreDashboard.sizes.mediaProgressSweep
            }

            Behavior on strokeColor {
                ColorAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Colours.palette.m3primary
            strokeWidth: NacreDashboard.sizes.mediaProgressThickness
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: cover.x + cover.width / 2
                centerY: cover.y + cover.height / 2
                radiusX: (cover.width + NacreDashboard.sizes.mediaProgressThickness) / 2 + NacreAppearance.spacing.small
                radiusY: (cover.height + NacreDashboard.sizes.mediaProgressThickness) / 2 + NacreAppearance.spacing.small
                startAngle: -90 - NacreDashboard.sizes.mediaProgressSweep / 2
                sweepAngle: NacreDashboard.sizes.mediaProgressSweep * root.playerProgress
            }

            Behavior on strokeColor {
                ColorAnimation {
                    duration: NacreAppearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: NacreAppearance.anim.curves.standard
                }
            }
        }
    }

    NacreClip {
        id: cover

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: NacreAppearance.padding.large + NacreDashboard.sizes.mediaProgressThickness + NacreAppearance.spacing.small

        implicitHeight: width
        color: Colours.palette.m3surfaceContainerHigh
        radius: NacreAppearance.rounding.full

        NacreIcon {
            anchors.centerIn: parent

            text: "art_track"
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: (parent.width * 0.4) || 1
        }

        Image {
            id: image

            anchors.fill: parent

            source: Players.active?.trackArtUrl ?? ""
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: width
            sourceSize.height: height
        }
    }

    NacreText {
        id: title

        anchors.top: cover.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: NacreAppearance.spacing.normal

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
        color: Colours.palette.m3primary
        font.pointSize: NacreAppearance.font.size.normal

        width: parent.implicitWidth - NacreAppearance.padding.large * 2
        elide: Text.ElideRight
    }

    NacreText {
        id: album

        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: NacreAppearance.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackAlbum ?? qsTr("No media")) || qsTr("Unknown album")
        color: Colours.palette.m3outline
        font.pointSize: NacreAppearance.font.size.small

        width: parent.implicitWidth - NacreAppearance.padding.large * 2
        elide: Text.ElideRight
    }

    NacreText {
        id: artist

        anchors.top: album.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: NacreAppearance.spacing.small

        animate: true
        horizontalAlignment: Text.AlignHCenter
        text: (Players.active?.trackArtist ?? qsTr("No media")) || qsTr("Unknown artist")
        color: Colours.palette.m3secondary

        width: parent.implicitWidth - NacreAppearance.padding.large * 2
        elide: Text.ElideRight
    }

    Row {
        id: controls

        anchors.top: artist.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: NacreAppearance.spacing.smaller

        spacing: NacreAppearance.spacing.small

        Control {
            icon: "skip_previous"
            canUse: Players.active?.canGoPrevious ?? false

            function onClicked(): void {
                Players.active?.previous();
            }
        }

        Control {
            icon: Players.active?.isPlaying ? "pause" : "play_arrow"
            canUse: Players.active?.canTogglePlaying ?? false

            function onClicked(): void {
                Players.active?.togglePlaying();
            }
        }

        Control {
            icon: "skip_next"
            canUse: Players.active?.canGoNext ?? false

            function onClicked(): void {
                Players.active?.next();
            }
        }
    }

    Spectrum {
        anchors.top: controls.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: NacreAppearance.padding.large
        active: root.shouldUpdate && (Players.active?.isPlaying ?? false)
    }

    component Control: NacreSurface {
        id: control

        required property string icon
        required property bool canUse
        function onClicked(): void {
        }

        implicitWidth: Math.max(icon.implicitHeight, icon.implicitHeight) + NacreAppearance.padding.small
        implicitHeight: implicitWidth

        NacreInteraction {
            disabled: !control.canUse
            radius: NacreAppearance.rounding.full

            function onClicked(): void {
                control.onClicked();
            }
        }

        NacreIcon {
            id: icon

            anchors.centerIn: parent
            anchors.verticalCenterOffset: font.pointSize * 0.05

            animate: true
            text: control.icon
            color: control.canUse ? Colours.palette.m3onSurface : Colours.palette.m3outline
            font.pointSize: NacreAppearance.font.size.large
        }
    }
}
