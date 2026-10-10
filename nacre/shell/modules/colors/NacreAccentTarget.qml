import QtQuick
import qs.widgets
import qs.services

NacreSurface {
    id: root
    required property string role
    required property string value
    property bool pinned: false
    signal assign(string value)
    signal clear
    width: 180
    height: 112
    radius: 12
    color: NacreTokens.raised
    border.width: drop.containsDrag ? 2 : 1
    border.color: drop.containsDrag ? NacreTokens.accent : NacreTokens.outline
    Rectangle {
        x: 12
        y: 12
        width: 30
        height: 30
        radius: 8
        color: "#" + root.value
    }
    NacreText {
        x: 52
        y: 11
        text: root.role.charAt(0).toUpperCase() + root.role.slice(1)
        font.pointSize: 11
    }
    NacreText {
        x: 52
        y: 31
        text: "#" + root.value
        font.family: NacreTokens.monoFamily
        font.pointSize: 9
        color: NacreTokens.mutedInk
    }
    ActionButton {
        x: 12
        y: 63
        text: root.pinned ? "Unpin" : "Pin color"
        icon: root.pinned ? "lock" : "lock_open"
        onClicked: root.pinned ? root.clear() : root.assign(root.value)
    }
    DropArea {
        id: drop
        anchors.fill: parent
        keys: ["orient-color"]
        onDropped: drop => {
            const value = drop.source?.colorHex;
            if (typeof value === "string" && /^[0-9a-f]{6}$/.test(value)) {
                root.assign(value);
                drop.accept();
            }
        }
    }
}
