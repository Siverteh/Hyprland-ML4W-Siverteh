import QtQuick
import qs.widgets
import qs.services

NacreSurface {
    id: root
    property string icon: ""
    property string label: ""
    signal clicked
    width: 36
    height: 32
    radius: 8
    color: interaction.hovered ? NacreTokens.raised : "transparent"
    NacreIcon {
        anchors.centerIn: parent
        text: root.icon
        font.pointSize: 14
    }
    NacreInteraction {
        id: interaction
        accessibleName: root.label
        function onClicked() {
            root.clicked();
        }
    }
}
