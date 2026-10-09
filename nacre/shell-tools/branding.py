#!/usr/bin/env python3
"""One layered SH geometry for web, Qt and Kitty, with wallpaper palette roles."""

import json, io, os, tempfile, signal, subprocess, shutil
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
GEOMETRY = next(
    p
    for p in (
        HERE.parent / "shell/branding/sh.json",
        HERE.parent / "source/branding/sh.json",
    )
    if p.exists()
)


def svg(template=True, colors=None):
    g = json.loads(GEOMETRY.read_text())
    parts = []
    for role, points in g["letters"].items():
        color = "@" + role.upper() + "@" if template else "#" + colors[role].lstrip("#")
        path = "M" + " L".join(f"{x} {y}" for x, y in points) + "Z"
        for x, y in g["outlines"]:
            parts.append(
                f'<path class="outline-{role}" d="{path}" transform="translate({x} {y})" fill="none" stroke="{color}" stroke-width="{g["stroke"]}"/>'
            )
        parts.append(f'<path class="face-{role}" d="{path}" fill="{color}"/>')
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 '
        + " ".join(map(str, g["size"]))
        + '">'
        + "".join(parts)
        + "</svg>"
    )


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent)
    with os.fdopen(fd, "wb") as f:
        f.write(data)
    os.chmod(tmp, 0o644)
    os.replace(tmp, path)


def refresh_terminal_menus(home, proc=Path("/proc")):
    """Wake the logo renderer with ncurses' normal resize event; never restart it."""
    expected = str(Path(home) / ".local/bin/siverteh-ai")
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        descriptor = None
        try:
            if entry.stat().st_uid != os.getuid():
                continue
            arguments = [
                part.decode()
                for part in (entry / "cmdline").read_bytes().split(b"\0")
                if part
            ]
            # Kitty also includes this command in its argv. Only notify Python's
            # menu controller, never its terminal server or assistant workers.
            if (
                len(arguments) < 3
                or not Path(arguments[0]).name.startswith("python")
                or arguments[1:3] != [expected, "dashboard"]
            ):
                continue
            descriptor = os.pidfd_open(int(entry.name))
            # Recheck after opening the stable process handle in case the PID
            # exited/recycled between discovery and notification.
            current = [
                part.decode()
                for part in (entry / "cmdline").read_bytes().split(b"\0")
                if part
            ]
            if current != arguments:
                continue
            signal.pidfd_send_signal(descriptor, signal.SIGWINCH)
        except (OSError, UnicodeError):
            continue
        finally:
            if descriptor is not None:
                os.close(descriptor)


def publish(colors, home=None):
    home = Path.home() if home is None else Path(home)
    g = json.loads(GEOMETRY.read_text())
    scale = 16
    image = Image.new(
        "RGBA",
        (g["size"][0] * scale, g["size"][1] * scale),
        (0, 0, 0, 0),
    )
    draw = ImageDraw.Draw(image)
    for role, points in g["letters"].items():
        color = "#" + colors[role].lstrip("#")
        for dx, dy in g["outlines"]:
            p = [((x + dx) * scale, (y + dy) * scale) for x, y in points]
            draw.line(p + [p[0]], fill=color, width=max(1, round(g["stroke"] * scale)))
        draw.polygon([(x * scale, y * scale) for x, y in points], fill=color)
    out = io.BytesIO()
    image.save(out, format="PNG")
    folder = home / ".local/share/nacre/branding"
    atomic(folder / "sh-lock.png", out.getvalue())
    terminal = Image.new("RGB", image.size, "#" + colors["surface"].lstrip("#"))
    terminal.paste(image, mask=image.getchannel("A"))
    opaque = io.BytesIO()
    terminal.save(opaque, format="PNG")
    atomic(folder / "sh.png", opaque.getvalue())
    atomic(folder / "sh.svg", svg(False, colors).encode())
    refresh_terminal_menus(home)


def build():
    formatter = (
        "/usr/lib/qt6/bin/qmlformat"
        if Path("/usr/lib/qt6/bin/qmlformat").exists()
        else shutil.which("qmlformat")
    )
    if not formatter:
        raise RuntimeError("Regenerating QML branding requires qmlformat")
    root = HERE.parent
    template = svg()
    (root / "shell/branding/sh.svg").write_text(template)
    expression = json.dumps(template)
    common = """Item {
 id:root
 implicitWidth:30;implicitHeight:30
 property color primary:DEFAULT_PRIMARY
 property color secondary:DEFAULT_SECONDARY
 Image {anchors.fill:parent;fillMode:Image.PreserveAspectFit;sourceSize.width:192;sourceSize.height:192;source:"data:image/svg+xml;utf8,"+encodeURIComponent(TEMPLATE.replace(/@PRIMARY@/g,String(root.primary)).replace(/@SECONDARY@/g,String(root.secondary)))}
}
""".replace("TEMPLATE", expression)
    (root / "shell/widgets/BrandLogo.qml").write_text(
        "import qs.services\nimport QtQuick\n"
        + common.replace("DEFAULT_PRIMARY", "Colours.palette.m3primary")
        .replace("DEFAULT_SECONDARY", "Colours.palette.m3secondary")
        .replace(
            " implicitWidth:30;implicitHeight:30",
            ' implicitWidth:30;implicitHeight:30\n Accessible.name:"Nacre apps";Accessible.role:Accessible.Button',
        )
    )
    widget = root / "shell/widgets/BrandLogo.qml"
    text = widget.read_text()
    text = text.replace(
        " property color primary:",
        ' property bool compact:false\n function adjust(value){return compact?value.replace(/L24 2 L24 12/g,"L24.6 2 L24.6 12").replace(/L24 14 L24 24/g,"L24.6 14 L24.6 24"):value;}\n property color primary:',
    )
    text = text.replace(
        "encodeURIComponent(", "encodeURIComponent(root.adjust("
    ).replace("String(root.secondary)))}", "String(root.secondary))))}")
    widget.write_text(text)

    (root / "login/Logo.qml").write_text(
        "import QtQuick\n"
        + common.replace("DEFAULT_PRIMARY", '"#dbc492"').replace(
            "DEFAULT_SECONDARY", '"#d2c5ad"'
        )
    )
    for qml in (widget, root / "login/Logo.qml"):
        for _ in range(3):
            formatted = subprocess.check_output(
                [formatter, str(qml.resolve())], text=True
            )
            if formatted == qml.read_text():
                break
            qml.write_text(formatted)

    web = root.parent / "brain/web/index.html"
    text = web.read_text()
    a = text.index('<symbol id="sh"')
    b = text.index("</symbol>", a) + len("</symbol>")
    inner = (
        template.split(">", 1)[1]
        .rsplit("</svg>", 1)[0]
        .replace("@PRIMARY@", "currentColor")
        .replace("@SECONDARY@", "currentColor")
    )
    text = (
        text[:a]
        + '<symbol id="sh" viewBox="0 0 34 28">'
        + inner
        + "</symbol>"
        + text[b:]
    )
    web.write_text(text)


if __name__ == "__main__":
    import sys

    if "--build" in sys.argv:
        build()
    colors = json.loads((Path.home() / ".local/state/nacre/scheme.json").read_text())[
        "colours"
    ]
    publish(colors)
