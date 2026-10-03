pragma Singleton
pragma ComponentBehavior: Bound

import "root:/utils"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string thumbDir: `${Paths.cache}/thumbnails`.slice(7)

    function go(obj: var): var {
        return thumbComp.createObject(obj, {
            originalPath: obj.path,
            width: obj.width,
            height: obj.height,
            loadOriginal: obj.loadOriginal
        });
    }

    component Thumbnail: QtObject {
        id: obj

        required property string originalPath
        required property int width
        required property int height
        required property bool loadOriginal

        property string path

        readonly property Process proc: Process {
            running: true
            command: ["python3",Quickshell.shellDir+"/utils/thumbnail.py",obj.originalPath,String(obj.width),String(obj.height),root.thumbDir]
            stdout: SplitParser {
                onRead: data => {
                    if (data === "start") {
                        if (obj.loadOriginal)
                            obj.path = obj.originalPath;
                    } else {
                        obj.path = data;
                    }
                }
            }
        }

        function reload(): void {
            proc.signal(9);
            proc.running = true;
        }
    }

    Component {
        id: thumbComp

        Thumbnail {}
    }
}
