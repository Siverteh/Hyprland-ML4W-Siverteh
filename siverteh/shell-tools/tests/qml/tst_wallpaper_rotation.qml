import QtQuick
import QtTest
import "fixtures"
import "wallpaper-rotation.js" as Rotation

TestCase {
    id: test
    name: "WallpaperRotation"
    when: windowShown
    Component {
        id: walls
        RotatingWalls {}
    }
    function cleanup() {
        WallpaperPlayback.sleeping = false;
        WallpaperPlayback.locked = false;
        Visibilities.screens = ({});
    }
    function test_shuffle_visits_each_scene_before_repeating() {
        const pool = ["a", "b", "c", "d"];
        let bag = [], current = "a", seen = [];
        for (let i = 0; i < 3; i++) {
            const next = Rotation.next(pool, current, true, bag, .5);
            verify(next.path !== current);
            verify(!seen.includes(next.path));
            seen.push(next.path);
            current = next.path;
            bag = next.remaining;
        }
        compare(seen.length, 3);
        compare(Rotation.next(["a"], "a", true, [], .5).path, "");
    }
    function test_filter_and_sequential_order() {
        const entries = [
            {
                path: "a",
                dynamic: false
            },
            {
                path: "b",
                dynamic: true
            }
        ];
        compare(Rotation.pool(entries, "dynamic").join(","), "b");
        compare(Rotation.pool(entries, "static").join(","), "a");
        compare(Rotation.next(["a", "b", "c"], "c", false, [], .5).path, "a");
    }
    function test_disabled_timer_and_lifecycle_pause() {
        const view = createTemporaryObject(walls, test);
        const clock = findChild(view, "wallpaperRotationTimer");
        verify(clock);
        verify(!clock.running);
        view.preferences = Object.assign({}, view.preferences, {
            rotationEnabled: true
        });
        verify(clock.running);
        compare(clock.interval, 30 * 60000);
        WallpaperPlayback.locked = true;
        verify(!clock.running);
        WallpaperPlayback.locked = false;
        verify(clock.running);
        WallpaperPlayback.sleeping = true;
        verify(!clock.running);
        WallpaperPlayback.sleeping = false;
        verify(clock.running);
        Visibilities.screens = ({
                test: {
                    launcher: true,
                    launcherMode: "wallpaper"
                }
            });
        verify(!clock.running);
        Visibilities.screens = ({
                test: {
                    dashboard: true,
                    dashboardTab: 4
                }
            });
        verify(!clock.running);
        Visibilities.screens = ({});
        verify(clock.running);
        view.preferences = Object.assign({}, view.preferences, {
            rotationMinutes: 60
        });
        compare(clock.interval, 60 * 60000);
        view.preferences = Object.assign({}, view.preferences, {
            rotationEnabled: false
        });
        verify(!clock.running);
    }
    function test_timer_uses_single_existing_commit_queue() {
        const view = createTemporaryObject(walls, test);
        view.preferences = Object.assign({}, view.preferences, {
            rotationEnabled: true,
            rotationShuffle: false
        });
        const clock = findChild(view, "wallpaperRotationTimer");
        clock.interval = 20;
        tryCompare(view.commit, "running", true, 300);
        compare(view.commit.requestPath, "a");
        verify(!clock.running);
        view.advanceRotation(true);
        compare(view.commit.requestPath, "a");
    }
}
