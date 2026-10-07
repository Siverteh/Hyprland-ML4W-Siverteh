#!/usr/bin/env python3
"""Render the Siverteh Hyprlock layout; PAM and session locking stay Hyprlock-owned."""

import json, shlex, subprocess
from pathlib import Path


def widgets(kind, colors, helper, monitor="", width=1920):
    def block(widget, **options):
        return (
            widget
            + " {\n    monitor = "
            + monitor
            + "\n"
            + "".join(
                "    " + key + " = " + str(value) + "\n"
                for key, value in options.items()
            )
            + "}\n"
        )

    primary = "rgba(" + colors["primary"] + "ff)"
    text = "rgba(" + colors["onSurface"] + "ff)"
    surface = "rgba(" + colors["surfaceContainer"] + "ee)"
    command = "python3 " + shlex.quote(str(helper)) + " "

    def card(size, position):
        return block(
            "shape",
            size=size,
            position=position,
            halign="center",
            valign="center",
            rounding=22,
            color=surface,
            zindex=0,
        )

    def info(name, position, font=14):
        return block(
            "label",
            text="cmd[update:2000] " + command + name,
            position=position,
            halign="center",
            valign="center",
            color=text,
            font_size=font,
            font_family="IBM Plex Sans",
            text_align="center",
            zindex=1,
        )

    if kind == "weather":
        return card("340, 180", "-32%, 165") + info("weather", "-32%, 165", 16)
    if kind == "notifications":
        return card("340, 460", "32%, 25") + info("notifications", "32%, 25")
    if kind == "media":
        result = card("340, 360", "-32%, -135") + info("media", "-32%, -155")
        result += block(
            "image",
            path=str(Path.home() / ".local/share/siverteh-ai/branding/sh.png"),
            size=82,
            rounding=14,
            border_size=0,
            position="-32%, -20",
            halign="center",
            valign="center",
            reload_time=10,
            reload_cmd=command + "art",
            zindex=1,
        )
        for x, icon, action in [
            (
                str(round(-0.32 * width)),
                "cmd[update:2000] " + command + "play-icon",
                "toggle",
            ),
            (str(round(-0.32 * width) - 64), "skip_previous", "previous"),
            (str(round(-0.32 * width) + 64), "skip_next", "next"),
        ]:
            result += block(
                "label",
                text=icon,
                position=x + ", -280",
                halign="center",
                valign="center",
                color=primary,
                font_size=25,
                font_family="Material Symbols Rounded",
                onclick=command + action,
                zindex=2,
            )
        return result
    return ""


def output_width(monitor):
    # Native Hyprlock widgets use framebuffer pixels, including at fractional scale.
    dimension = (
        monitor.get("height", 1080)
        if monitor.get("transform", 0) % 2
        else monitor.get("width", 1920)
    )
    return round(dimension)


def render(colors, wallpaper, preferences, helper, monitors=None):
    if any(c in wallpaper for c in "\n\r"):
        raise ValueError("Unsupported wallpaper path")
    template = (
        Path(__file__)
        .with_name("hyprlock.conf.in")
        .read_text()
        .replace("{{wallpaper}}", wallpaper)
    )
    for key, value in colors.items():
        template = template.replace("{{" + key + "}}", value.lstrip("#"))
    template = template.replace("{{helper}}", "python3 " + shlex.quote(str(helper)))
    for kind in ("weather", "media", "notifications"):
        key = {
            "weather": "lockWeather",
            "media": "lockMedia",
            "notifications": "lockNotifications",
        }[kind]
        template = template.replace(
            "{{" + kind + "_widgets}}",
            "".join(
                widgets(
                    kind,
                    {k: v.lstrip("#") for k, v in colors.items()},
                    helper,
                    monitor.get("name", ""),
                    output_width(monitor),
                )
                for monitor in (monitors or [{"name": "", "width": 1920}])
            )
            if preferences.get(key, True)
            else "",
        )
    return template


def publish(home=Path.home()):
    state = home / ".local/state/siverteh_shell"
    scheme = json.loads((state / "scheme.json").read_text())
    colors = scheme["colours"]
    try:
        preferences = json.loads(
            (home / ".config/siverteh-shell/desktop.json").read_text()
        )
    except (OSError, ValueError):
        preferences = {}
    wallpaper = (
        (state / "wallpaper/last.txt").read_text().strip()
        if (state / "wallpaper/last.txt").exists()
        else ""
    )
    target = home / ".config/hypr/hyprlock.conf"
    target.parent.mkdir(parents=True, exist_ok=True)
    monitors = json.loads(
        subprocess.check_output(["hyprctl", "-j", "monitors"], text=True, timeout=2)
    )
    body = render(
        colors,
        wallpaper,
        preferences,
        home / ".local/share/siverteh-ai/siverteh-shell/tools/lock-info.py",
        monitors,
    )
    temp = target.with_suffix(".next")
    temp.write_text(body)
    temp.chmod(0o600)
    temp.replace(target)


if __name__ == "__main__":
    publish()
