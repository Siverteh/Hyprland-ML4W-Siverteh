#!/usr/bin/env python3

import json
import random
import re
import subprocess
import sys
from pathlib import Path

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")

from gi.repository import Gdk, Gio, GLib, Gtk


SYMBOLS = "01<>[]{}()/\\|+-=*&#@!?%$ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


def read_color_from_rasi(name, fallback):
    colors_file = Path.home() / ".config" / "rofi" / "colors.rasi"
    if not colors_file.exists():
        return fallback

    try:
        content = colors_file.read_text()
    except OSError:
        return fallback

    match = re.search(rf"{re.escape(name)}:\s*([^;]+);", content)
    if not match:
        return fallback

    return match.group(1).strip()


def read_color_file(name, fallback):
    path = Path.home() / ".config" / "ml4w" / "colors" / name
    if not path.exists():
        return fallback

    try:
        value = path.read_text().strip()
    except OSError:
        return fallback

    return value or fallback


def hex_to_rgba(value, alpha=1.0):
    hex_value = value.strip().lstrip("#")
    if len(hex_value) != 6:
        return 1.0, 1.0, 1.0, alpha
    return (
        int(hex_value[0:2], 16) / 255.0,
        int(hex_value[2:4], 16) / 255.0,
        int(hex_value[4:6], 16) / 255.0,
        alpha,
    )


def luminance(rgb):
    r, g, b = rgb[:3]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def darken_rgba(rgba, factor, alpha=None):
    darkened = (
        max(0.0, min(1.0, rgba[0] * factor)),
        max(0.0, min(1.0, rgba[1] * factor)),
        max(0.0, min(1.0, rgba[2] * factor)),
        rgba[3] if alpha is None else alpha,
    )
    return darkened


def mix_rgba(left, right, balance, alpha=None):
    inverse = 1.0 - balance
    mixed = (
        max(0.0, min(1.0, left[0] * inverse + right[0] * balance)),
        max(0.0, min(1.0, left[1] * inverse + right[1] * balance)),
        max(0.0, min(1.0, left[2] * inverse + right[2] * balance)),
        left[3] if alpha is None else alpha,
    )
    return mixed


def load_palette():
    primary = read_color_file("primary", read_color_from_rasi("primary", "#6effa0"))
    secondary = read_color_file("secondary", read_color_from_rasi("secondary", "#b0ffd2"))
    on_surface = read_color_file("onsurface", read_color_from_rasi("on-surface", "#e8f3ec"))
    surface = read_color_from_rasi("surface", "#08110c")
    background = read_color_from_rasi("background", "#050705")

    return {
        "primary": primary,
        "secondary": secondary,
        "on_surface": on_surface,
        "surface": surface,
        "background": background,
    }


def get_focused_monitor_geometry():
    try:
        monitors = json.loads(subprocess.check_output(["hyprctl", "-j", "monitors"], text=True))
    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
        monitors = []

    focused = next((monitor for monitor in monitors if monitor.get("focused")), None)
    if focused is not None:
        return {
            "x": int(focused.get("x", 0)),
            "y": int(focused.get("y", 0)),
            "width": int(focused.get("width", 1920)),
            "height": int(focused.get("height", 1080)),
        }

    display = Gdk.Display.get_default()
    if display is None:
        return {"x": 0, "y": 0, "width": 1920, "height": 1080}

    monitor = display.get_monitors().get_item(0)
    if monitor is None:
        return {"x": 0, "y": 0, "width": 1920, "height": 1080}

    geometry = monitor.get_geometry()
    return {
        "x": geometry.x,
        "y": geometry.y,
        "width": geometry.width,
        "height": geometry.height,
    }


class MatrixWindow(Gtk.ApplicationWindow):
    def __init__(self, app, geometry, palette):
        super().__init__(application=app, title="Siverteh Matrix Sleep")
        self.app = app
        self.geometry = geometry
        self.palette = palette
        self.width = 0
        self.height = 0
        self.cell_width = 22
        self.cell_height = 28
        self.font_size = 22
        self.columns = []

        self.set_decorated(False)
        self.set_resizable(False)
        self.set_can_focus(True)
        self.set_default_size(geometry["width"], geometry["height"])
        self.set_size_request(geometry["width"], geometry["height"])

        drawing = Gtk.DrawingArea()
        drawing.set_hexpand(True)
        drawing.set_vexpand(True)
        drawing.set_content_width(geometry["width"])
        drawing.set_content_height(geometry["height"])
        drawing.set_draw_func(self.on_draw)
        self.set_child(drawing)
        self.drawing = drawing

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.add_controller(key_controller)

        click = Gtk.GestureClick()
        click.connect("pressed", self.on_click)
        self.add_controller(click)

        GLib.timeout_add(40, self.on_tick)
        GLib.idle_add(self.enter_fullscreen)

    def enter_fullscreen(self):
        self.fullscreen()
        return GLib.SOURCE_REMOVE

    def configure_grid(self, width, height):
        if width == self.width and height == self.height and self.columns:
            return

        self.width = max(width, 1)
        self.height = max(height, 1)
        self.font_size = max(18, min(28, self.height // 34))
        self.cell_width = max(16, int(self.font_size * 0.72))
        self.cell_height = max(20, int(self.font_size * 1.12))
        column_count = max(1, self.width // self.cell_width)
        row_count = max(1, self.height // self.cell_height)

        self.columns = []
        for index in range(column_count):
            self.columns.append(
                {
                    "x": index * self.cell_width,
                    "head": random.uniform(-row_count, row_count),
                    "speed": random.uniform(0.35, 1.15),
                    "trail": random.randint(8, 18),
                }
            )

    def reset_stream(self, stream):
        row_count = max(1, self.height // self.cell_height)
        stream["head"] = random.uniform(-row_count * 0.8, 0)
        stream["speed"] = random.uniform(0.35, 1.15)
        stream["trail"] = random.randint(8, 18)

    def on_tick(self):
        if not self.columns:
            self.drawing.queue_draw()
            return GLib.SOURCE_CONTINUE

        row_count = max(1, self.height // self.cell_height)
        for stream in self.columns:
            stream["head"] += stream["speed"]
            if random.random() < 0.025:
                stream["speed"] = max(0.25, min(1.35, stream["speed"] + random.uniform(-0.1, 0.1)))
            if stream["head"] - stream["trail"] > row_count and random.random() > 0.35:
                self.reset_stream(stream)

        self.drawing.queue_draw()
        return GLib.SOURCE_CONTINUE

    def on_draw(self, _area, cr, width, height):
        self.configure_grid(width, height)

        background = hex_to_rgba(self.palette["background"], 1.0)
        surface = hex_to_rgba(self.palette["surface"], 1.0)
        primary = hex_to_rgba(self.palette["primary"], 1.0)
        secondary = hex_to_rgba(self.palette["secondary"], 1.0)
        highlight = hex_to_rgba(self.palette["on_surface"], 1.0)

        darker_base = background if luminance(background) <= luminance(surface) else surface
        bg = darken_rgba(mix_rgba(darker_base, primary, 0.06), 0.22, 0.992)
        primary = mix_rgba(darken_rgba(primary, 0.72), highlight, 0.12, 1.0)
        secondary = mix_rgba(darken_rgba(secondary, 0.58), bg, 0.18, 1.0)
        highlight = mix_rgba(highlight, primary, 0.22, 1.0)

        cr.set_source_rgba(*bg)
        cr.paint()

        cr.select_font_face("JetBrainsMono Nerd Font", 0, 1)
        cr.set_font_size(self.font_size)

        baseline = self.font_size
        row_count = max(1, height // self.cell_height)

        for stream in self.columns:
            head_row = int(stream["head"])
            for offset in range(stream["trail"]):
                row = head_row - offset
                if row < 0 or row >= row_count:
                    continue

                alpha = max(0.08, 1.0 - (offset / max(stream["trail"], 1)))
                if offset == 0:
                    color = (*highlight[:3], 0.82)
                elif offset < 3:
                    color = (*primary[:3], 0.54 * alpha)
                else:
                    color = (*secondary[:3], 0.26 * alpha)

                cr.set_source_rgba(*color)
                cr.move_to(stream["x"] + 2, row * self.cell_height + baseline)
                cr.show_text(random.choice(SYMBOLS))

    def on_key_pressed(self, _controller, _keyval, _keycode, _state):
        self.app.quit()
        return True

    def on_click(self, *_args):
        self.app.quit()


class MatrixRestApp(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id="com.siverteh.matrixrest",
            flags=Gio.ApplicationFlags.NON_UNIQUE,
        )
        self.windows = []
        self.palette = load_palette()

    def do_activate(self):
        if self.windows:
            for window in self.windows:
                window.present()
            return

        geometry = get_focused_monitor_geometry()
        window = MatrixWindow(self, geometry, self.palette)
        self.windows.append(window)
        window.present()


if __name__ == "__main__":
    app = MatrixRestApp()
    sys.exit(app.run(None))
