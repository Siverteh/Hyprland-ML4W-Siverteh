import QtQuick
import QtTest
import "registry.js" as Registry

TestCase {
    name: "PanelOwnership"
    function test_replacement_then_old_teardown_keeps_new_output_and_other_screen() {
        const service = createTemporaryObject(store, this);
        const oldState = createTemporaryObject(value, this);
        const oldHost = createTemporaryObject(value, this);
        const newState = createTemporaryObject(value, this);
        const newHost = createTemporaryObject(value, this);
        const otherState = createTemporaryObject(value, this);
        const otherHost = createTemporaryObject(value, this);
        Registry.register(service, "first", oldState, oldHost);
        Registry.register(service, "second", otherState, otherHost);
        const oldMap = service.screens;
        Registry.register(service, "first", newState, newHost);
        verify(oldMap !== service.screens);
        compare(service.screens.first, newState);
        Registry.release(service, "first", oldState, oldHost);
        compare(service.screens.first, newState);
        compare(service.panels.first, newHost);
        compare(service.screens.second, otherState);
        Registry.release(service, "first", newState, newHost);
        verify(!("first" in service.screens));
        verify(!("first" in service.panels));
        compare(service.screens.second, otherState);
        compare(service.panels.second, otherHost);
    }
    function test_partial_registration_cleanup_does_not_remove_unrelated_host() {
        const service = createTemporaryObject(store, this);
        const state = createTemporaryObject(value, this);
        const host = createTemporaryObject(value, this);
        Registry.register(service, "first", state, host);
        Registry.release(service, "first", state, null);
        verify(!("first" in service.screens));
        compare(service.panels.first, host);
        Registry.release(null, "first", state, host);
    }
    Component {
        id: store
        QtObject {
            property var screens: ({})
            property var panels: ({})
        }
    }
    Component {
        id: value
        QtObject {}
    }
}
