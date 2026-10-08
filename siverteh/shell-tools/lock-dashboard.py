#!/usr/bin/env python3
"""Prepare the single-tile lock presentation; never handle authentication.

Coordinates use the reference's 2048x1152 canvas. The native locker scales this
1440x810 panel uniformly, leaving clock, password and controls as native widgets.
"""

from datetime import datetime
from functools import lru_cache
import hashlib
import fcntl
import io
import json
import math
import os
from pathlib import Path
import pwd
import subprocess

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageOps

WIDTH, HEIGHT = 1440, 810
RESOLUTION = 2


def layout(monitor):
    width = monitor.get("width", 1920)
    height = monitor.get("height", 1080)
    if monitor.get("transform", 0) % 2:
        width, height = height, width
    return min(width / 2048, height / 1152)


@lru_cache(maxsize=16)
def font(size, family="IBM Plex Sans", style="Regular"):
    path = subprocess.check_output(
        ["fc-match", "--format=%{file}", family + ":style=" + style],
        text=True,
        timeout=2,
    ).strip()
    return ImageFont.truetype(path, round(size * RESOLUTION))


def rgb(value):
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError("Invalid palette color")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def blend(a, b, amount):
    return tuple(round(x + (y - x) * amount) for x, y in zip(a, b))


def fitted(picture, size):
    return ImageOps.fit(picture.convert("RGBA"), size, method=Image.Resampling.LANCZOS)


def rounded_mask(size, radius):
    mask = Image.new("L", size)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius, fill=255
    )
    return mask


def avatar_mask(size):
    # A rounded pentagon, drawn from our own geometry rather than KDE components.
    vertices = [
        (
            size / 2 + size * 0.49 * math.sin(i * 2 * math.pi / 5),
            size / 2 - size * 0.49 * math.cos(i * 2 * math.pi / 5),
        )
        for i in range(5)
    ]
    points = []
    for i, vertex in enumerate(vertices):
        prev, following = vertices[i - 1], vertices[(i + 1) % 5]
        start = tuple(v + 0.18 * (p - v) for v, p in zip(vertex, prev))
        end = tuple(v + 0.18 * (p - v) for v, p in zip(vertex, following))
        for step in range(17):
            t = step / 16
            points.append(
                tuple(
                    (1 - t) ** 2 * a + 2 * (1 - t) * t * v + t * t * b
                    for a, v, b in zip(start, vertex, end)
                )
            )
    mask = Image.new("L", (size, size))
    ImageDraw.Draw(mask).polygon(points, fill=255)
    return mask


def system_info(home):
    try:
        os_name = next(
            line.split("=", 1)[1].strip('"')
            for line in Path("/etc/os-release").read_text().splitlines()
            if line.startswith("NAME=")
        )
    except (OSError, StopIteration):
        os_name = "Linux"
    try:
        minutes = int(float(Path("/proc/uptime").read_text().split()[0])) // 60
        uptime = f"{minutes // 60}h {minutes % 60:02d}m"
    except (OSError, ValueError):
        uptime = "Unavailable"
    return dict(
        os=os_name, user=pwd.getpwuid(home.stat().st_uid).pw_name, uptime=uptime
    )


def notification_icon(name, app, home):
    """Resolve only local system artwork, never arbitrary notification URLs."""
    aliases = {
        "google chrome": "google-chrome",
        "network management": "nm-device-wireless",
    }
    names = [name, aliases.get(app.lower(), app.lower())]
    for value in names:
        if not value or "/" in value or ".." in value:
            continue
        for root in (
            Path("/usr/share/icons/hicolor/48x48/apps"),
            Path("/usr/share/icons/Papirus/48x48/apps"),
            Path("/usr/share/pixmaps"),
        ):
            for suffix in (".png", ".svg"):
                source = root / (value + suffix)
                if not source.is_file():
                    continue
                if suffix == ".png":
                    return source
                identity = f"{source}:{source.stat().st_mtime_ns}"
                target = (
                    home
                    / ".cache/siverteh-os/lock-ready"
                    / (
                        "icon-"
                        + hashlib.sha256(identity.encode()).hexdigest()[:20]
                        + ".png"
                    )
                )
                if target.exists():
                    return target
                try:
                    raw = subprocess.check_output(
                        ["rsvg-convert", "-w", "72", "-h", "72", str(source)],
                        timeout=2,
                        stderr=subprocess.DEVNULL,
                    )
                    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
                    target.write_bytes(raw)
                    target.chmod(0o600)
                    return target
                except (OSError, subprocess.SubprocessError):
                    pass
    return None


def render(data, colors, wallpaper, artwork, home, monitor=None):
    """Bounded raster work happens before locking, on existing desktop events."""
    scale = RESOLUTION
    size = (WIDTH * scale, HEIGHT * scale)
    surface = rgb(colors["surface"])
    container = rgb(colors["surfaceContainer"])
    text_color = rgb(colors["onSurface"])
    muted = rgb(colors.get("onSurfaceVariant", colors["onSurface"]))
    accent = rgb(colors["primary"])
    image = Image.new("RGBA", size, (*surface, 235))
    # Crop the actual wallpaper exactly where the centered panel sits, then blur
    # only this bounded texture. The rest of the desktop wallpaper stays sharp.
    try:
        with Image.open(wallpaper) as source:
            monitor = monitor or dict(width=2048, height=1152)
            factor = layout(monitor)
            w, h = monitor.get("width", 2048), monitor.get("height", 1152)
            if monitor.get("transform", 0) % 2:
                w, h = h, w
            canvas = fitted(source, (round(w / factor), round(h / factor)))
            x, y = (canvas.width - WIDTH) // 2, (canvas.height - HEIGHT) // 2
            crop = canvas.crop((x, y, x + WIDTH, y + HEIGHT))
            image = crop.resize(size).filter(ImageFilter.GaussianBlur(40 * scale))
            image.alpha_composite(Image.new("RGBA", size, (*surface, 135)))
    except (OSError, ValueError, Image.DecompressionBombError):
        pass
    image.putalpha(rounded_mask(size, 42 * scale))
    draw = ImageDraw.Draw(image)

    def composite(layer, position, mask=None):
        if mask is not None:
            layer.putalpha(ImageChops.multiply(layer.getchannel("A"), mask))
        image.alpha_composite(layer, position)

    def rect(box, color, radius=26):
        left, top, right, bottom = (round(v * scale) for v in box)
        card = Image.new("RGBA", (right - left, bottom - top))
        ImageDraw.Draw(card).rounded_rectangle(
            (0, 0, card.width - 1, card.height - 1), radius * scale, fill=color
        )
        composite(card, (left, top))

    def copy(
        value, xy, pixels=16, color=None, width=None, lines=1, bold=False, center=False
    ):
        from html.parser import HTMLParser

        class PlainText(HTMLParser):
            def __init__(self):
                super().__init__()
                self.parts = []

            def handle_data(self, text):
                self.parts.append(text)

        parser = PlainText()
        parser.feed(str(value or "")[:2048])
        value = " ".join(" ".join(parser.parts).split())[:1024]
        face = font(pixels, style="Medium" if bold else "Regular")
        words, rows, line = value.split(), [], ""
        for word in words:
            candidate = (line + " " + word).strip()
            if width and face.getlength(candidate) > width * scale and line:
                rows.append(line)
                line = word
            else:
                line = candidate
        rows.append(line)
        if len(rows) > lines:
            rows = rows[:lines]
            rows[-1] += "…"
        for i, row in enumerate(rows):
            if width:
                while face.getlength(row) > width * scale and len(row) > 1:
                    row = row[:-2] + "…"
            x, y = xy
            if center:
                x -= face.getlength(row) / scale / 2
            draw.text(
                (round(x * scale), round((y + i * pixels * 1.45) * scale)),
                row,
                font=face,
                fill=(*(color or text_color), 255),
            )

    def icon(code, xy, pixels=30, color=None):
        # Material Symbols has Unicode glyphs; Pillow doesn't need QML ligatures.
        draw.text(
            tuple(round(v * scale) for v in xy),
            chr(code),
            font=font(pixels, "Material Symbols Rounded"),
            fill=(*(color or accent), 255),
        )

    def picture(path, box, mask=None):
        try:
            with Image.open(path) as art:
                target = tuple(round((box[i + 2] - box[i]) * scale) for i in (0, 1))
                art = fitted(art, target)
                image.paste(
                    art,
                    (round(box[0] * scale), round(box[1] * scale)),
                    mask or rounded_mask(target, 26 * scale),
                )
                return True
        except (OSError, ValueError, Image.DecompressionBombError):
            return False

    card_color = (*container, 180)
    preferences = data.get("preferences", {})
    if preferences.get("lockWeather", True):
        rect((16, 16, 460, 150), card_color)
        weather = data.get("weather", {})
        copy(
            str(weather.get("temperature") or "—").removesuffix(" (cached)"),
            (92, 60),
            38,
            accent,
            width=150,
            center=True,
        )
        weather_icon = {
            "sunny": 0xE81A,
            "clear_day": 0xE81A,
            "rainy": 0xF176,
            "thunderstorm": 0xEBDB,
            "snowing": 0xE80F,
        }.get(weather.get("icon"), 0xE2BD)
        icon(weather_icon, (174, 61), 38)
        draw.line(
            (250 * scale, 58 * scale, 250 * scale, 115 * scale),
            fill=(*muted, 90),
            width=scale,
        )
        copy(
            weather.get("description") or "Weather unavailable",
            (269, 54),
            16,
            width=175,
        )
        copy(
            weather.get("detail") or weather.get("location") or "",
            (269, 80),
            12,
            muted,
            width=175,
        )
        copy(
            "Cached forecast" if weather.get("stale") else weather.get("range", ""),
            (269, 101),
            12,
            muted,
            width=175,
        )

    rect((16, 168, 460, 428), card_color)
    rect((30, 184, 60, 214), (*accent, 255), 9)
    copy("›", (45, 182), 27, surface, center=True)
    copy("sivertehfetch.sh", (69, 188), 14)
    # Arch silhouette drawn locally, with an inset cutout; no external artwork.
    draw.polygon(
        [
            (x * scale, y * scale)
            for x, y in [
                (160, 246),
                (101, 356),
                (142, 337),
                (160, 308),
                (178, 337),
                (219, 356),
            ]
        ],
        fill=(*accent, 255),
    )
    details = system_info(home)
    for i, line in enumerate(
        [
            "OS : " + details["os"],
            "WM : Hyprland",
            "USER : " + details["user"],
            "UP : " + details["uptime"],
        ]
    ):
        copy(line, (238, 253 + i * 25), 14, width=200)
    for i in range(7):
        color = blend(surface, accent, 0.2 + i * 0.13)
        draw.ellipse(
            ((111 + i * 38) * scale, 383 * scale, (136 + i * 38) * scale, 408 * scale),
            fill=(*color, 255),
        )

    if preferences.get("lockMedia", True):
        rect((16, 446, 460, 794), card_color)
        media = data.get("media") or {}
        if media and picture(artwork, (16, 446, 460, 794)):
            overlay = Image.new("RGBA", (444 * scale, 348 * scale), (0, 0, 0, 145))
            composite(
                overlay,
                (16 * scale, 446 * scale),
                rounded_mask(overlay.size, 26 * scale),
            )
        else:
            icon(0xE405, (220, 499), 42)
        media_text = (245, 238, 243) if media else text_color
        copy(
            media.get("title") or "Nothing playing",
            (238, 563),
            20,
            media_text,
            width=380,
            lines=2,
            bold=True,
            center=True,
        )
        copy(
            media.get("artist") or "Your music appears here",
            (238, 622),
            15,
            media_text,
            width=370,
            center=True,
        )
        rect((202, 666, 274, 708), (*accent, 255), 21)
        rect((146, 669, 184, 707), (*container, 190), 19)
        rect((292, 669, 330, 707), (*container, 190), 19)
        copy(
            media.get("album") or "MPRIS media",
            (238, 754),
            11,
            media_text,
            width=360,
            center=True,
        )

    # Avatar is always a private local account picture, with an SH fallback.
    avatar = next(
        (
            path
            for path in (
                home / ".face",
                home / ".face.icon",
                home / ".local/share/siverteh-ai/branding/sh-lock.png",
            )
            if path.is_file()
        ),
        None,
    )
    mask = avatar_mask(270 * scale)
    image.paste(
        Image.new("RGBA", mask.size, (*surface, 255)), (585 * scale, 237 * scale), mask
    )
    if avatar and avatar.name in (".face", ".face.icon"):
        picture(avatar, (585, 237, 855, 507), mask)
    elif avatar:
        with Image.open(avatar) as logo:
            logo = logo.convert("RGBA")
            logo.thumbnail((180 * scale, 180 * scale), Image.Resampling.LANCZOS)
            image.alpha_composite(
                logo, (720 * scale - logo.width // 2, 372 * scale - logo.height // 2)
            )
    rect((610, 537, 830, 579), (*container, 140), 21)
    hour = datetime.now().hour
    greeting = (
        "Good morning"
        if 5 <= hour < 12
        else "Good afternoon"
        if hour < 18
        else "Good evening"
        if hour < 22
        else "Good night"
    )
    copy(
        greeting + ", " + details["user"],
        (720, 547),
        14,
        accent,
        width=210,
        center=True,
    )
    copy(data.get("batteryLabel") or "Siverteh OS", (720, 747), 12, muted, center=True)

    rect((972, 16, 1424, 190), card_color)
    stats = data.get("system", {})
    for i, (key, code, role) in enumerate(
        [
            ("cpu", 0xE322, "primary"),
            ("memory", 0xE322, "secondary"),
            ("storage", 0xE1DB, "tertiary"),
        ]
    ):
        left = 990 + i * 143
        base = rgb(colors.get(role + "Container", colors["surfaceContainer"]))
        fill = rgb(colors.get(role, colors["primary"]))
        gauge = Image.new("RGBA", (126 * scale, 126 * scale), (*base, 210))
        value = stats.get(key)
        fraction = max(0, min(1, float(value))) if value is not None else 0
        points = [(0, 126 * scale), (126 * scale, 126 * scale)]
        for x in range(126, -1, -2):
            y = 126 * (1 - fraction) + 4 * math.sin(x / 16 + i)
            points.append((x * scale, max(0, min(126, y)) * scale))
        ImageDraw.Draw(gauge).polygon(points, fill=(*fill, 125))
        mask = (
            avatar_mask(126 * scale) if i != 1 else rounded_mask(gauge.size, 28 * scale)
        )
        composite(gauge, (left * scale, 42 * scale), mask)
        icon(code, (left + 46, 63), 31, text_color)
        copy(
            f"{round(fraction * 100)}%" if value is not None else "—",
            (left + 63, 109),
            30,
            text_color,
            center=True,
        )
    temp = stats.get("temperature")
    if temp is not None:
        copy(f"{round(temp)}°C", (1063, 23), 14, muted)

    if preferences.get("lockNotifications", True):
        rect((972, 208, 1424, 794), card_color)
        notifications = data.get("notifications", [])
        copy(
            str(data.get("count", len(notifications))) + " notifications",
            (994, 229),
            14,
            muted,
        )
        icon(0xE164, (1383, 229), 19, muted)
        groups = {}
        for entry in notifications:
            groups.setdefault(entry.get("app") or "Notification", []).append(entry)
        if not groups:
            icon(0xE7F4, (1180, 403), 37, accent)
            copy("You are all caught up", (1198, 469), 17, muted, center=True)
        for i, (app, entries) in enumerate(list(groups.items())[:4]):
            y = 289 + i * 116
            rect((1003, y, 1051, y + 48), (*surface, 130), 24)
            app_icon = notification_icon(entries[0].get("icon", ""), app, home)
            if app_icon:
                picture(app_icon, (1011, y + 8, 1043, y + 40))
            else:
                icon(0xE7F4, (1015, y + 12), 25, accent)
            try:
                timestamp = datetime.fromisoformat(entries[0].get("time", ""))
                minutes = max(
                    0,
                    round(
                        (datetime.now(timestamp.tzinfo) - timestamp).total_seconds()
                        / 60
                    ),
                )
                age = f"{minutes}m" if minutes < 60 else f"{minutes // 60}h"
                copy(age, (1342, y + 3), 12, muted, center=True)
            except ValueError:
                pass
            copy(app, (1067, y), 16, width=235, bold=True)
            copy(str(len(entries)), (1382, y + 3), 12, muted, center=True)
            if preferences.get("lockNotificationContents", False):
                copy(
                    entries[0].get("summary"),
                    (1067, y + 29),
                    14,
                    muted,
                    width=325,
                    lines=2,
                )
                copy(entries[0].get("body"), (1067, y + 70), 12, muted, width=325)
            else:
                copy("Message previews hidden", (1067, y + 32), 14, muted, width=325)
    return image


def publish(data, colors, wallpaper, artwork, home, monitors):
    ready = home / ".cache/siverteh-os/lock-ready"
    ready.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (ready / "dashboard.lock").open("w") as guard:
        os.chmod(guard.name, 0o600)
        fcntl.flock(guard, fcntl.LOCK_EX)
        return publish_locked(data, colors, wallpaper, artwork, home, monitors)


def publish_locked(data, colors, wallpaper, artwork, home, monitors):
    ready = home / ".cache/siverteh-os/lock-ready"
    output = []
    for monitor in monitors or [dict(name="", width=1920, height=1080)]:
        # Geometry-keyed file keeps independent monitor crops without raw names.
        key = hashlib.sha256(
            json.dumps(
                {k: monitor.get(k) for k in ("name", "width", "height", "transform")},
                sort_keys=True,
            ).encode()
        ).hexdigest()[:12]
        picture = render(data, colors, wallpaper, artwork, home, monitor)
        buffer = io.BytesIO()
        picture.save(buffer, format="PNG", compress_level=2)
        raw = buffer.getvalue()
        fingerprint = hashlib.sha256(raw).hexdigest()[:16]
        path = ready / f"dashboard-{key}-{fingerprint}.png"
        if not path.exists():
            temporary = path.with_suffix(".next")
            temporary.write_bytes(raw)
            temporary.chmod(0o600)
            temporary.replace(path)
        # A stable startup path always points at the latest complete image.
        # Immutable reload images may be pruned without breaking an older config.
        initial = ready / f"dashboard-{key}-initial.png"
        temporary = initial.with_suffix(".next")
        temporary.unlink(missing_ok=True)
        os.link(path, temporary)
        temporary.replace(initial)
        pointer = ready / f"dashboard-{key}.txt"
        temporary = pointer.with_suffix(".next")
        temporary.write_text(str(path))
        temporary.chmod(0o600)
        temporary.replace(pointer)
        output.append(
            dict(monitor=monitor.get("name", ""), path=str(path), pointer=str(pointer))
        )
    # Retain current and recent paths, so an in-flight Hyprlock reload can finish.
    current = {row["path"] for row in output}
    old = sorted(
        (
            path
            for path in ready.glob("dashboard-*-*.png")
            if not path.stem.endswith("-initial")
        ),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    limit = max(12, len(output) * 3)
    recent = [str(path) for path in old if str(path) not in current]
    keep = current | set(recent[: max(0, limit - len(current))])
    for path in old:
        if str(path) not in keep:
            path.unlink()
    metadata = dict(data, panel=output[0]["path"], wallpaper=wallpaper, colors=colors)
    target = ready / "dashboard.json"
    temporary = target.with_suffix(".next")
    temporary.write_text(json.dumps(metadata))
    temporary.chmod(0o600)
    temporary.replace(target)
    return output
