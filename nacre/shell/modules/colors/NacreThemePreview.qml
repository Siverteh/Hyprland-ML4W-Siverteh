import QtQuick
import qs.widgets

Rectangle {
    id: root
    required property var palette
    property string wallpaper: ""
    property bool workspaceColors: false
    width: 400
    height: 280
    radius: 14
    color: root.c("frame")
    border.width: 1
    border.color: root.c("outline")
    function c(role) {
        return "#" + (palette?.[role] || palette?.onSurface || "e8e8e8");
    }
    Image {
        x: 5
        y: 35
        width: parent.width - 10
        height: parent.height - 40
        source: root.wallpaper ? "file://" + root.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        retainWhileLoading: true
        sourceSize: Qt.size(640, 360)
    }
    BrandLogo {
        x: 10
        y: 8
        width: 20
        height: 20
        primary: root.c("primary")
        secondary: root.c("secondary")
        tertiary: root.c("tertiary")
        highlight: root.c("primaryFixed")
        background: root.c("frame")
        foreground: root.c("onSurface")
        motionEnabled: false
    }
    Row {
        x: 40
        y: 8
        spacing: 5
        Repeater {
            model: 3
            Rectangle {
                required property int index
                width: 24
                height: 20
                radius: 5
                color: index === 0 || root.workspaceColors ? root.c(["primary", "secondary", "tertiary"][index]) : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: parent.index + 1
                    font.pointSize: 8
                    color: parent.index === 0 || root.workspaceColors ? root.c(["onPrimary", "onSecondary", "onTertiary"][parent.index]) : root.c("onSurface")
                }
            }
        }
    }
    Text {
        x: parent.width - 73
        y: 10
        text: "Nacre"
        font.pointSize: 9
        color: root.c("onSurface")
    }
    Rectangle {
        x: 14
        y: 50
        width: parent.width - 28
        height: 120
        radius: 9
        color: root.c("surfaceContainer")
        Rectangle {
            width: parent.width
            height: 27
            radius: 9
            color: root.c("surfaceContainerHigh")
        }
        Text {
            x: 12
            y: 6
            text: "Files"
            font.pointSize: 9
            color: root.c("onSurface")
        }
        Text {
            x: 12
            y: 40
            text: "Documents\nPictures\nProjects"
            font.pointSize: 9
            color: root.c("onSurface")
            lineHeight: 1.3
        }
        Rectangle {
            x: parent.width - 105
            y: 44
            width: 90
            height: 29
            radius: 6
            color: root.c("primary")
            Text {
                anchors.centerIn: parent
                text: "Open"
                font.pointSize: 9
                color: root.c("onPrimary")
            }
        }
        Rectangle {
            x: parent.width - 105
            y: 84
            width: 90
            height: 3
            color: root.c("secondary")
        }
    }
    Rectangle {
        x: 14
        y: 183
        width: (parent.width - 34) * .52
        height: 82
        radius: 7
        color: root.c("surfaceContainerLowest")
        Text {
            x: 9
            y: 9
            text: "$ build"
            font.family: "JetBrains Mono NF"
            font.pointSize: 8
            color: root.c("onSurface")
        }
        Text {
            x: 9
            y: 31
            text: "✓ Ready"
            font.pointSize: 8
            color: root.c("green")
        }
        Text {
            x: 9
            y: 53
            text: "! Warning"
            font.pointSize: 8
            color: root.c("yellow")
        }
    }
    Rectangle {
        x: parent.width * .57
        y: 190
        width: parent.width * .43 - 14
        height: 67
        radius: 8
        color: root.c("primaryContainer")
        Text {
            x: 9
            y: 9
            width: parent.width - 18
            text: "Message\nYour theme is ready"
            wrapMode: Text.Wrap
            font.pointSize: 8
            color: root.c("onPrimaryContainer")
        }
    }
    Accessible.role: Accessible.Graphic
    Accessible.name: "Desktop preview with bar, window, terminal and notification"
}
