import QtQuick
import qs.widgets

Item {
    id: root
    property string path: ""
    property Image current: front
    property bool fading: false
    property Image pendingImage: null
    readonly property bool hasImage: current.status === Image.Ready
    function request() {
        if (!path || fading)
            return;
        const image = hasImage ? (current === front ? back : front) : current;
        image.requestPath = path;
        image.source = "file://" + path;
        if (image.status === Image.Ready)
            ready(image);
    }
    function present(image) {
        if (image.status !== Image.Ready || image.requestPath !== path)
            return;
        if (!hasImage || image === current) {
            current = image;
            image.opacity = 1;
            return;
        }
        const previous = current;
        current = image;
        previous.opacity = 0;
        current.opacity = 1;
        fading = true;
        settle.restart();
    }
    function ready(image) {
        if (image.status === Image.Ready) {
            pendingImage = image;
            presentation.restart();
        }
    }
    Timer {
        id: presentation
        interval: 0
        onTriggered: root.present(root.pendingImage)
    }
    onPathChanged: request()
    Component.onCompleted: request()
    Timer {
        id: settle
        interval: NacreTokens.motionEnabled ? 320 : 0
        onTriggered: {
            root.fading = false;
            if (root.current.requestPath !== root.path)
                root.request();
        }
    }
    Image {
        id: front
        property string requestPath: ""
        anchors.fill: parent
        asynchronous: true
        cache: true
        retainWhileLoading: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: 1600
        sourceSize.height: 1000
        opacity: 0
        onStatusChanged: root.ready(this)
        Behavior on opacity {
            NumberAnimation {
                duration: NacreTokens.motionEnabled ? 300 : 0
                easing.type: Easing.InOutCubic
            }
        }
    }
    Image {
        id: back
        property string requestPath: ""
        anchors.fill: parent
        asynchronous: true
        cache: true
        retainWhileLoading: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: 1600
        sourceSize.height: 1000
        opacity: 0
        onStatusChanged: root.ready(this)
        Behavior on opacity {
            NumberAnimation {
                duration: NacreTokens.motionEnabled ? 300 : 0
                easing.type: Easing.InOutCubic
            }
        }
    }
}
