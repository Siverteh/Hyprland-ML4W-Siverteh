import "root:/widgets"
import "root:/config"
import QtQuick

// Overlap the independently antialiased panel/frame edges before the shared shadow.
Item {
    id: root
    required property Panels panels
    required property Item bar
    anchors.fill: parent
    readonly property real overlap: 2
    Rectangle {
        visible: root.panels.notifications.height > 0
        x: root.width-BorderConfig.thickness-root.overlap
        y: BorderConfig.thickness
        width: BorderConfig.thickness+root.overlap
        height: root.panels.notifications.height+BorderConfig.rounding
        color: BorderConfig.colour
    }
    Rectangle {
        visible: root.panels.osd.width > 0
        x: root.width-BorderConfig.thickness-root.overlap-root.panels.session.width
        y: BorderConfig.thickness+root.panels.osd.y-BorderConfig.rounding
        width: BorderConfig.thickness+root.overlap+root.panels.session.width
        height: root.panels.osd.height+BorderConfig.rounding*2
        color: BorderConfig.colour
    }
    Rectangle {
        visible: root.panels.launcher.height > 0
        x: root.bar.implicitWidth+root.panels.launcher.x-BorderConfig.rounding
        y: root.height-BorderConfig.thickness-root.overlap
        width: root.panels.launcher.width+BorderConfig.rounding*2
        height: BorderConfig.thickness+root.overlap
        color: BorderConfig.colour
    }
}
