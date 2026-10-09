import QtQuick
import QtTest
import "fixtures"

TestCase {
    id: test
    name: "WallpaperPicker"
    width: 1160
    height: 650
    visible: true
    when: windowShown
    Component {
        id: picker
        NacreWallpaperPicker {
            width: 1160
            height: implicitHeight
            visibilities: QtObject {
                property bool launcher: true
                property bool previewOnly: false
            }
        }
    }
    Component {
        id: presentation
        ThemePresentation {}
    }
    Component {
        id: backdrop
        NacreWallpaperBackdrop {
            width: 500
            height: 300
        }
    }
    Component {
        id: hex
        NacreWallpaperHex {
            entry: Wallpapers.list[0]
        }
    }
    function init() {
        Wallpapers.preferences = {
            kind: "static",
            layout: "carousel"
        };
        Wallpapers.current = "one";
        Wallpapers.browsed = "";
    }
    Component {
        id: motionPreview
        NacreWallpaperMotion {
            width: 300
            height: 180
        }
    }
    function test_preview_navigation_does_not_apply_wallpaper() {
        const view = createTemporaryObject(picker, test);
        view.visibilities.previewOnly = true;
        view.move(1);
        compare(view.currentIndex, 1);
        compare(Wallpapers.browsed, "");
        view.choose();
        compare(Wallpapers.current, "one");
    }
    function test_preview_cancels_decode_when_selection_moves_before_settling() {
        const view = createTemporaryObject(motionPreview, test, {
            entry: {
                path: "unused.mp4",
                dynamic: true
            },
            running: true
        });
        wait(60);
        verify(!view.active);
        view.running = false;
        wait(220);
        verify(!view.active);
    }
    function test_gallery_motion_respects_pause_and_close() {
        const view = createTemporaryObject(picker, test);
        Wallpapers.preference({
            kind: "dynamic",
            paused: true
        });
        verify(!view.motionEnabled);
        Wallpapers.preference({
            paused: false
        });
        verify(view.motionEnabled);
        view.visibilities.launcher = false;
        verify(!view.motionEnabled);
    }
    function test_static_dynamic_filter_and_search() {
        const view = createTemporaryObject(picker, test);
        wait(40);
        compare(view.count, 2);
        const input = findChild(view, "wallpaperSearch");
        input.text = "hollow";
        compare(view.count, 1);
        compare(view.currentEntry.path, "two");
        compare(Wallpapers.browsed, "");
        view.choose();
        compare(Wallpapers.browsed, "two");
        input.text = "";
        Wallpapers.preference({
            kind: "dynamic"
        });
        compare(view.count, 1);
        compare(view.currentEntry.path, "three");
    }
    function test_layout_switch_preserves_selection_and_escape() {
        const view = createTemporaryObject(picker, test);
        wait(40);
        view.select(1);
        compare(view.currentEntry.path, "two");
        for (const layout of ["spotlight", "hexagons", "carousel"]) {
            Wallpapers.preference({
                layout: layout
            });
            wait(40);
            compare(view.currentEntry.path, "two");
        }
        view.forceActiveFocus();
        keyClick(Qt.Key_Escape);
        compare(view.visibilities.launcher, false);
    }
    function test_repeated_layout_switch_during_carousel_animation() {
        const view = createTemporaryObject(picker, test);
        wait(40);
        for (let i = 0; i < 12; i++) {
            Wallpapers.preference({
                layout: "carousel"
            });
            view.select(i % 2);
            wait(10);
            Wallpapers.preference({
                layout: "spotlight"
            });
            wait(10);
            compare(view.currentEntry.path, i % 2 === 0 ? "one" : "two");
        }
    }
    function test_full_screen_modes_and_complete_carousel_cards() {
        const original = Wallpapers.list;
        try {
            Wallpapers.list = Array.from({
                length: 12
            }, (_, i) => ({
                        path: "wall" + i,
                        name: "Wallpaper " + i,
                        poster: original[0].poster,
                        dynamic: false
                    }));
            const view = createTemporaryObject(picker, test);
            wait(60);
            verify(!view.fullScreen);
            compare(view.implicitHeight, 360);
            const strip = findChild(view, "carouselStrip");
            verify(strip.slots % 2 === 1);
            for (let i = 0; i < 12; i++) {
                const card = findChild(view, "carouselCard" + i);
                if (!card || !card.visible)
                    continue;
                const point = card.mapToItem(strip, 0, 0), end = card.mapToItem(strip, card.width, card.height);
                verify(point.x >= 0, "left " + point.x);
                verify(end.x <= strip.width + 1, "right " + end.x + " / " + strip.width);
                verify(point.y >= 0, "top " + point.y);
                verify(end.y <= strip.height + 1, "bottom " + end.y + " / " + strip.height);
            }
            for (const layout of ["spotlight", "hexagons"]) {
                Wallpapers.preference({
                    layout: layout
                });
                wait(40);
                verify(view.fullScreen);
                compare(view.implicitHeight, 1100);
            }
        } finally {
            Wallpapers.list = original;
        }
    }
    function test_carousel_slides_through_intermediate_position() {
        const original = Wallpapers.list;
        try {
            Wallpapers.list = Array.from({
                length: 9
            }, (_, i) => ({
                        path: "wall" + i,
                        name: "Wallpaper " + i,
                        poster: original[0].poster,
                        dynamic: false
                    }));
            const view = createTemporaryObject(picker, test);
            wait(400);
            const strip = findChild(view, "carouselStrip"), next = findChild(view, "carouselCard1");
            const start = next.x, end = (strip.width - next.width) / 2;
            view.move(1);
            wait(110);
            verify(next.x < start && next.x > end);
            wait(300);
            fuzzyCompare(next.x, end, 1);
        } finally {
            Wallpapers.list = original;
        }
    }
    function test_spotlight_motion_has_intermediate_position_and_width() {
        const original = Wallpapers.list;
        try {
            Wallpapers.list = Array.from({
                length: 9
            }, (_, i) => ({
                        path: "wall" + i,
                        name: "Wallpaper " + i,
                        poster: original[0].poster,
                        dynamic: false
                    }));
            Wallpapers.preference({
                layout: "spotlight"
            });
            const view = createTemporaryObject(picker, test);
            wait(400);
            const strip = findChild(view, "spotlightStrip"), next = findChild(view, "spotlightCard1");
            const startX = next.x, startWidth = next.width, endX = (strip.width - strip.heroWidth) / 2;
            view.select(1);
            wait(110);
            verify(next.x < startX && next.x > endX);
            verify(next.width > startWidth && next.width < strip.heroWidth);
            wait(300);
            compare(next.x, endX);
            compare(next.width, strip.heroWidth);
        } finally {
            Wallpapers.list = original;
        }
    }
    function test_theme_waits_for_matching_image_ready_and_rejects_stale_ack() {
        const view = createTemporaryObject(presentation, test);
        const first = {
            poster: "one",
            mode: "dark",
            colours: {
                primary: "112233"
            }
        }, next = {
            poster: "two",
            mode: "light",
            colours: {
                primary: "aabbcc"
            }
        };
        view.accept(first);
        compare(view.active.poster, "one");
        view.accept(next);
        compare(view.active.poster, "one");
        view.activate("one");
        compare(view.active.poster, "one");
        view.activate("two");
        compare(view.active.poster, "two");
        compare(view.active.colours.primary, "aabbcc");
        view.accept({
            poster: "two",
            mode: "dark",
            colours: {
                primary: "445566"
            }
        });
        compare(view.active.mode, "dark");
    }
    function test_backdrop_holds_loaded_image_until_replacement_ready() {
        const path = Wallpapers.list[0].poster;
        const view = createTemporaryObject(backdrop, test, {
            path: path
        });
        tryCompare(view, "hasImage", true);
        const previous = view.current;
        view.path = path.replace("poster.png", "second.png");
        compare(view.current, previous);
        wait(650);
        verify(view.current !== previous);
        compare(view.current.status, Image.Ready);
        view.path = path;
        wait(650);
        compare(view.current, previous);
        verify(view.hasImage);
    }
    function test_hexagonal_hit_shape_excludes_transparent_corners() {
        const view = createTemporaryObject(hex, test);
        verify(view.inside(100, 80));
        verify(!view.inside(0, 0));
        verify(!view.inside(199, 1));
        verify(view.inside(1, 87));
    }
}
