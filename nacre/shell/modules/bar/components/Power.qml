import qs.widgets
import qs.services
import qs.config
import Quickshell

MaterialIcon {
    text: "power_settings_new"
    color: Colours.palette.m3error
    font.bold: true
    font.pointSize: Appearance.font.size.normal

    StateLayer {
        anchors.fill: undefined
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 1

        implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
        implicitHeight: implicitWidth

        radius: Appearance.rounding.full

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
