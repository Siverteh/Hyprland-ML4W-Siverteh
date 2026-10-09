import qs.widgets
import qs.services
import qs.config
import QtQuick

Item {
    id: root

    required property Actions.Action modelData
    required property var list

    implicitHeight: NacreLauncher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    NacreInteraction {
        radius: NacreAppearance.rounding.full

        function onClicked(): void {
            root.modelData?.onClicked(root.list);
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: NacreAppearance.padding.larger
        anchors.rightMargin: NacreAppearance.padding.larger
        anchors.margins: NacreAppearance.padding.smaller

        NacreIcon {
            id: icon

            text: root.modelData?.icon ?? ""
            font.pointSize: NacreAppearance.font.size.extraLarge

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            anchors.left: icon.right
            anchors.leftMargin: NacreAppearance.spacing.larger
            anchors.verticalCenter: icon.verticalCenter

            implicitWidth: parent.width - icon.width
            implicitHeight: name.implicitHeight + desc.implicitHeight

            NacreText {
                id: name

                text: root.modelData?.name ?? ""
                font.pointSize: NacreAppearance.font.size.normal
            }

            NacreText {
                id: desc

                text: root.modelData?.desc ?? ""
                font.pointSize: NacreAppearance.font.size.small
                color: Colours.alpha(Colours.palette.m3outline, true)

                elide: Text.ElideRight
                width: root.width - icon.width - NacreAppearance.rounding.normal * 2

                anchors.top: name.bottom
            }
        }
    }
}
