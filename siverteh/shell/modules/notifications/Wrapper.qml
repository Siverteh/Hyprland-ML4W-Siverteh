import qs.config
import QtQuick

Item {
    id: root

    property bool suppressed: false
    visible: !suppressed && height > 0
    implicitHeight: suppressed ? 0 : content.implicitHeight
    implicitWidth: content.implicitWidth

    Content {
        id: content
    }
}
