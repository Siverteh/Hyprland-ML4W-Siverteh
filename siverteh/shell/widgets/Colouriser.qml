import QtQuick
import QtQuick.Effects
import qs.config

MultiEffect {
    colorization: 1

    Behavior on colorizationColor {
        ColorAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.standard
        }
    }
}
