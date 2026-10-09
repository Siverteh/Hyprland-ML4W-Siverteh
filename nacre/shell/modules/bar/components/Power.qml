import qs.widgets
import qs.services
import qs.config
import Quickshell

NacreIcon {
    text: "power_settings_new"
    color: NacreColours.palette.m3error
    font.bold: true
    font.pointSize: NacreAppearance.font.size.normal

    NacreInteraction {
        anchors.fill: undefined
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1

        implicitWidth: parent.implicitHeight + NacreAppearance.padding.small * 2
        implicitHeight: implicitWidth

        radius: NacreAppearance.rounding.full

        function onClicked(): void {
            const v = Visibilities.screens[QsWindow.window.screen.name];
            v.osd = false;
            v.launcher = false;
            v.dashboard = false;
            const p = Visibilities.panels[QsWindow.window.screen.name];
            if (p)
                p.popouts.hasCurrent = false;
            v.session = !v.session;
        }
    }
}
