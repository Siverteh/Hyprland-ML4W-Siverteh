pragma ComponentBehavior: Bound

import qs.widgets
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls

ListView {
    id: root
    FastScroll {
        view: root
    }

    required property int padding
    required property TextField search
    required property PersistentProperties visibilities

    property bool isAction: search.text.startsWith(NacreLauncher.actionPrefix)

    function getModelValues() {
        let text = search.text;
        if (isAction)
            return Actions.fuzzyQuery(text);
        if (text.startsWith(NacreLauncher.actionPrefix))
            text = search.text.slice(NacreLauncher.actionPrefix.length);
        return Apps.fuzzyQuery(text);
    }

    model: ScriptModel {
        values: root.getModelValues()
        onValuesChanged: root.currentIndex = 0
    }

    spacing: NacreAppearance.spacing.small
    orientation: Qt.Vertical
    implicitHeight: (NacreLauncher.sizes.itemHeight + spacing) * Math.min(NacreLauncher.maxShown, count) - spacing

    highlightMoveDuration: NacreAppearance.anim.durations.normal
    highlightResizeDuration: 0

    highlight: NacreSurface {
        radius: NacreAppearance.rounding.full
        color: Colours.palette.m3onSurface
        opacity: 0.08
    }

    delegate: isAction ? actionItem : appItem

    ScrollBar.vertical: NacreScrollBar {}

    add: Transition {
        Anim {
            properties: "opacity,scale"
            from: 0
            to: 1
        }
    }

    remove: Transition {
        Anim {
            properties: "opacity,scale"
            from: 1
            to: 0
        }
    }

    move: Transition {
        Anim {
            property: "y"
        }
        Anim {
            properties: "opacity,scale"
            to: 1
        }
    }

    addDisplaced: Transition {
        Anim {
            property: "y"
            duration: NacreAppearance.anim.durations.small
        }
        Anim {
            properties: "opacity,scale"
            to: 1
        }
    }

    displaced: Transition {
        Anim {
            property: "y"
        }
        Anim {
            properties: "opacity,scale"
            to: 1
        }
    }

    Component {
        id: appItem

        AppItem {
            visibilities: root.visibilities
        }
    }

    Component {
        id: actionItem

        ActionItem {
            list: root
        }
    }

    Behavior on isAction {
        SequentialAnimation {
            ParallelAnimation {
                Anim {
                    target: root
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: NacreAppearance.anim.durations.small
                    easing.bezierCurve: NacreAppearance.anim.curves.standardAccel
                }
                Anim {
                    target: root
                    property: "scale"
                    from: 1
                    to: 0.9
                    duration: NacreAppearance.anim.durations.small
                    easing.bezierCurve: NacreAppearance.anim.curves.standardAccel
                }
            }
            PropertyAction {}
            ParallelAnimation {
                Anim {
                    target: root
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: NacreAppearance.anim.durations.small
                    easing.bezierCurve: NacreAppearance.anim.curves.standardDecel
                }
                Anim {
                    target: root
                    property: "scale"
                    from: 0.9
                    to: 1
                    duration: NacreAppearance.anim.durations.small
                    easing.bezierCurve: NacreAppearance.anim.curves.standardDecel
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
