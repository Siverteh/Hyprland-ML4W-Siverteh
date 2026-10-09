import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test

    function test_pages_search_and_visible_only_loading() {
        const view = createTemporaryObject(settings, test);
        verify(view);
        wait(30);
        const loader = findChild(view, "settingsPage");
        verify(loader.item);
        compare(loader.item.page, "desktop");
        view.query = "microphone";
        wait(20);
        verify(!loader.active);
        compare(view.matches.length, 1);
        compare(view.matches[0].id, "sound");
        view.open("sound");
        wait(30);
        verify(loader.item);
        compare(view.page, "sound");
        compare(view.query, "");
        view.active = false;
        wait(20);
        verify(!loader.active);
        verify(!loader.item);
    }

    function test_palette_rows_fit_the_available_width() {
        const prior = Wallpapers.palettePresets;
        Wallpapers.palettePresets = Array.from({
            "length": 12
        }, (_, i) => {
            return ({
                    "id": "test" + i,
                    "name": "Color " + i,
                    "group": "vivid",
                    "surface": "102030",
                    "swatches": ["aabbcc", "ccbbaa", "abcabc"]
                });
        });
        const view = createTemporaryObject(settings, test);
        view.open("appearance");
        wait(30);
        const page = findChild(view, "settingsPage").item;
        const flow = findChild(page, "paletteOptions");
        verify(flow);
        const tiles = flow.children.filter(child => {
            return child.objectName === "paletteColorTile";
        });
        compare(tiles.length, 12);
        for (const tile of tiles)
            verify(tile.x + tile.width <= flow.width + 0.01);
        const columns = flow.width >= 840 ? 6 : 3;
        compare(tiles.filter(tile => {
            return tile.y === tiles[0].y;
        }).length, columns);
        Wallpapers.palettePresets = prior;
    }

    function test_wallpaper_palette_options_fit_and_select_an_accent() {
        const prior = Wallpapers.paletteOptions;
        const preferences = Wallpapers.preferences;
        Wallpapers.paletteOptions = ["aabbcc", "ccbbaa", "bbccdd", "ccbbdd", "ddbbcc"].map((accent, i) => ({
                    accent: accent,
                    name: "Image color " + i,
                    surface: "102030",
                    swatches: [accent, "ccbbaa", "abcabc"]
                }));
        const view = createTemporaryObject(settings, test);
        view.open("appearance");
        wait(30);
        const flow = findChild(findChild(view, "settingsPage").item, "wallpaperPaletteOptions");
        verify(flow);
        const tiles = flow.children.filter(child => child.objectName === "wallpaperPaletteTile");
        compare(tiles.length, 5);
        for (const tile of tiles)
            verify(tile.x + tile.width <= flow.width + 0.01);
        tiles[2].choose();
        compare(Wallpapers.preferences.paletteAccent, "bbccdd");
        Wallpapers.paletteOptions = prior;
        Wallpapers.preferences = preferences;
    }

    function test_palette_harmony_is_optional_and_keeps_accent_preference() {
        const prior = Wallpapers.preferences;
        Wallpapers.preferences = {
            palettePreset: "wallpaper",
            paletteAccent: "aabbcc"
        };
        const view = createTemporaryObject(settings, test);
        view.open("appearance");
        wait(30);
        const page = findChild(view, "settingsPage").item;
        const natural = findChild(page, "naturalPaletteButton");
        const harmony = findChild(page, "harmonyPaletteButton");
        verify(natural.selected);
        verify(!harmony.selected);
        harmony.clicked();
        verify(harmony.selected);
        compare(Wallpapers.preferences.paletteAccent, "aabbcc");
        natural.clicked();
        verify(natural.selected);
        Wallpapers.preferences = Object.assign({}, Wallpapers.preferences, {
            palettePreset: "ocean"
        });
        verify(!harmony.enabled);
        Wallpapers.preferences = prior;
    }

    function test_shared_wheel_glides_and_page_switch_resets_position() {
        const view = createTemporaryObject(settings, test);
        wait(30);
        const scroll = findChild(view, "settingsScroll");
        verify(scroll.contentHeight > scroll.height);
        const limit = scroll.contentHeight - scroll.height;
        mouseWheel(scroll, 600, 80, 0, -120);
        wait(100);
        verify(scroll.contentY > 0);
        wait(220);
        verify(Math.abs(scroll.contentY - Math.min(limit, 480)) < 2);
        view.open("maintenance");
        wait(30);
        compare(scroll.contentY, 0);
    }

    function test_all_device_and_lock_pages_load_without_warnings() {
        const view = createTemporaryObject(settings, test);
        wait(20);
        for (const page of ["appearance", "displays", "network", "bluetooth", "notifications", "workflows", "lock", "time", "ai", "maintenance"]) {
            view.open(page);
            wait(20);
            verify(findChild(view, "settingsPage").item, page);
        }
    }

    function test_lock_preview_contents_belong_to_the_window() {
        const view = createTemporaryObject(lockPreview, test);
        verify(view);
        wait(30);
        const window = findChild(view, "lockPreviewWindow");
        const content = findChild(view, "lockPreviewContent");
        verify(window);
        verify(content);
        compare(content.parent, window);
        compare(content.width, window.width);
        compare(content.height, window.height);
        compare(findChild(view, "lockPreviewHour").text, "02");
        verify(window.children.length >= 3);
        window.widgetData = {
            "count": 1,
            "notifications": [
                {
                    "app": "Mail"
                }
            ],
            "weather": {
                "location": "Test city",
                "temperature": "10°C",
                "description": "Overcast"
            }
        };
        wait(20);
        verify(content.visible);
    }

    name: "SettingsControlCenter"
    width: 1120
    height: 300
    visible: true
    when: windowShown

    Component {
        id: settings

        Settings {
            width: 1120
            height: 300
            page: "desktop"
        }
    }

    Component {
        id: lockPreview

        LockPreview {
            width: 1280
            height: 800
        }
    }
}
