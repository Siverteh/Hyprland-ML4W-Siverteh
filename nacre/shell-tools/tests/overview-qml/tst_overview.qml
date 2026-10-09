import QtQuick
import QtTest
import "fixtures"
import "overview/overview.js" as Model

TestCase {
    id: test
    name: "NacreOverview"
    width: 1100
    height: 1500
    visible: true
    when: windowShown
    Component {
        id: overview
        NacreOverview {
            shouldUpdate: true
        }
    }
    Component {
        id: player
        QtObject {
            property string trackTitle: "Track title"
            property string trackArtist: "Artist"
            property string trackAlbum: "Album"
            property string trackArtUrl: ""
            property string identity: "Fixture player"
            property real position: 120
            property real length: 400
            property bool positionSupported: true
            property bool lengthSupported: true
            property bool isPlaying: true
            property bool canControl: true
            property bool canGoPrevious: true
            property bool canTogglePlaying: true
            property bool canGoNext: true
            property int previousCalls: 0
            property int toggleCalls: 0
            property int nextCalls: 0
            signal trackChanged
            signal postTrackChanged
            function previous() {
                previousCalls++;
            }
            function togglePlaying() {
                toggleCalls++;
                isPlaying = !isPlaying;
            }
            function next() {
                nextCalls++;
            }
        }
    }
    function init() {
        Players.active = null;
        Weather.temperature = 22;
        Weather.displayTemperature = "22°C";
        Weather.description = "Clear";
        Weather.stale = false;
        Time.date = new Date(2026, 9, 9, 12, 34);
        DesktopSettings.data = {
            animations: false
        };
    }
    function test_calendar_civil_boundaries_and_locale_week_order() {
        const leap = Model.calendar(2000, 1, 0), common = Model.calendar(1900, 1, 0);
        compare(leap.length, 42);
        compare(leap.filter(d => d.inMonth).length, 29);
        compare(common.filter(d => d.inMonth).length, 28);
        const sunday = Model.calendar(2026, 9, 0), monday = Model.calendar(2026, 9, 1);
        compare(sunday[0].key, "2026-9-27");
        compare(monday[0].key, "2026-9-28");
        verify(Model.calendar(2026, 11, 0).some(d => d.key === "2027-1-1"));
        verify(Model.calendar(2027, 0, 0).some(d => d.key === "2026-12-31"));
        const view = createTemporaryObject(overview, test);
        const calendar = findChild(view, "overviewCalendar");
        calendar.monthOffset = 3;
        compare(calendar.displayed.getFullYear(), 2027);
        compare(calendar.displayed.getMonth(), 0);
        compare(calendar.todayKey, "2026-10-9");
        Time.date = new Date(2026, 9, 10, 0, 1);
        compare(calendar.todayKey, "2026-10-10");
    }
    function test_layout_bounds_and_nonoverlap_at_multiple_widths() {
        for (const width of [300, 508, 699, 700, 874, 1200]) {
            const geometry = Model.layout(width);
            const rows = Object.entries(geometry).filter(([key]) => key !== "height");
            for (const [key, box] of rows) {
                verify(box[0] >= 0, key);
                verify(box[0] + box[2] <= width + .01, key);
                verify(box[1] + box[3] <= geometry.height + .01, key);
                verify(box[2] > 0 && box[3] > 0, key);
            }
            for (let i = 0; i < rows.length; i++)
                for (let j = i + 1; j < rows.length; j++) {
                    const a = rows[i][1], b = rows[j][1];
                    verify(a[0] + a[2] <= b[0] || b[0] + b[2] <= a[0] || a[1] + a[3] <= b[1] || b[1] + b[3] <= a[1], rows[i][0] + " overlaps " + rows[j][0]);
                }
            const view = createTemporaryObject(overview, test, {
                width
            });
            wait(10);
            const media = findChild(view, "overviewMedia");
            const button = findChild(media, "mediaToggle");
            verify(button.mapToItem(media, 0, 0).y + button.height <= media.height - 18);
        }
    }
    function test_clock_weather_and_host_fallbacks() {
        const view = createTemporaryObject(overview, test);
        wait(30);
        compare(findChild(view, "clockHour").text, "12");
        compare(findChild(view, "clockMinute").text, "34");
        Time.date = new Date(2026, 9, 10, 0, 1);
        compare(findChild(view, "clockHour").text, "00");
        compare(findChild(view, "clockMinute").text, "01");
        Weather.temperature = NaN;
        Weather.description = "";
        compare(findChild(view, "weatherTemperature").text, "—");
        compare(findChild(view, "weatherDescription").text, "Weather unavailable");
        Weather.temperature = -5;
        Weather.displayTemperature = "-5°C";
        Weather.stale = true;
        compare(findChild(view, "weatherTemperature").text, "-5°C");
        const host = findChild(view, "overviewHost");
        compare(host.operatingSystem, "Fixture Linux");
        compare(host.uptimeSeconds, 9001);
        verify(host.sampling);
        host.username = "A very long host user name ".repeat(10);
        verify(findChild(view, "hostLine0").width < host.width);
        compare(Model.osName("NAME=Fallback\n"), "Fallback");
        compare(Model.osName("PRETTY_NAME='Quoted Linux'\n"), "Quoted Linux");
        compare(Model.uptime(NaN), "Uptime unavailable");
        compare(Model.uptime(90061), "Up 1d 1h 1m");
        view.shouldUpdate = false;
        compare(host.sampling, false);
    }
    function test_offscreen_cards_stop_sampling_until_scrolled_into_view() {
        const current = createTemporaryObject(player, test);
        Players.active = current;
        const view = createTemporaryObject(overview, test, {
            width: 508,
            height: 400
        });
        wait(30);
        const media = findChild(view, "overviewMedia");
        const host = findChild(view, "overviewHost");
        const scroll = findChild(view, "overviewScroll");
        compare(media.active, false);
        compare(media.sampling, false);
        verify(host.sampling);
        scroll.contentY = 356;
        wait(20);
        verify(media.active);
        verify(media.sampling);
        compare(host.sampling, false);
        scroll.contentY = 0;
        compare(media.sampling, false);
    }
    function test_gauges_and_progress_are_bounded_and_missing_safe() {
        compare(Model.fraction(-1), 0);
        compare(Model.fraction(2), 1);
        compare(Model.fraction(NaN), 0);
        compare(Model.percent(NaN), "—");
        compare(Model.percent(.326), "33%");
        compare(Model.progress(20, 0), 0);
        compare(Model.progress(500, 400), 1);
        const view = createTemporaryObject(overview, test);
        const resources = findChild(view, "overviewResources");
        compare(resources.gauges.length, 3);
        compare(resources.gauges[1].value, .63);
    }
    function test_transport_capabilities_pointer_and_player_removal() {
        const current = createTemporaryObject(player, test);
        Players.active = current;
        const view = createTemporaryObject(overview, test);
        wait(30);
        const media = findChild(view, "overviewMedia");
        verify(media.sampling);
        compare(media.progress, .3);
        mouseClick(findChild(view, "mediaPrevious"), 17, 17);
        mouseClick(findChild(view, "mediaToggle"), 17, 17);
        mouseClick(findChild(view, "mediaNext"), 17, 17);
        compare(current.previousCalls, 1);
        compare(current.toggleCalls, 1);
        compare(current.nextCalls, 1);
        compare(media.sampling, false);
        current.canControl = false;
        media.perform("previous");
        media.perform("toggle");
        media.perform("next");
        compare(current.nextCalls, 1);
        current.canControl = true;
        current.canGoNext = false;
        media.perform("next");
        compare(current.nextCalls, 1);
        current.isPlaying = true;
        verify(media.sampling);
        current.trackChanged();
        compare(media.positionSeconds, 0);
        current.position = 20;
        current.postTrackChanged();
        compare(media.positionSeconds, 20);
        current.trackTitle = "Very long track name ".repeat(20);
        verify(findChild(media, "mediaTitle").width < media.width);
        current.lengthSupported = false;
        compare(media.progress, 0);
        compare(media.sampling, false);
        current.lengthSupported = true;
        view.shouldUpdate = false;
        compare(media.sampling, false);
        media.perform("toggle");
        compare(current.toggleCalls, 1);
        Players.active = null;
        compare(media.positionSeconds, 0);
        compare(media.progress, 0);
        compare(findChild(media, "mediaTitle").text, "No media playing");
    }
}
