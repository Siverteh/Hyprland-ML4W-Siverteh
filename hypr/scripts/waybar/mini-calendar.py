#!/usr/bin/env python3

import atexit
import json
import os
import re
import signal
import subprocess
import sys
from pathlib import Path

import gi

gi.require_version("Gtk4LayerShell", "1.0")
gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")

from gi.repository import Gtk4LayerShell, Gtk, Gdk, Gio, GLib


PID_FILE = Path.home() / ".cache" / "siverteh" / "mini-calendar.pid"


def read_color_from_css(path, name):
    if not path.exists():
        return ""

    try:
        content = path.read_text()
    except OSError:
        return ""

    define_match = re.search(
        rf"@define-color\s+{re.escape(name)}\s+([^;]+);",
        content,
    )
    if define_match:
        return define_match.group(1).strip()

    rofi_name = name.replace("_", "-")
    rofi_match = re.search(
        rf"{re.escape(rofi_name)}:\s*([^;]+);",
        content,
    )
    if rofi_match:
        return rofi_match.group(1).strip()

    return ""


def read_color(name, fallback):
    sources = [
        Path.home() / ".config" / "waybar" / "colors.css",
        Path.home() / ".config" / "gtk-4.0" / "colors.css",
        Path.home() / ".config" / "rofi" / "colors.rasi",
    ]
    for source in sources:
        value = read_color_from_css(source, name)
        if value:
            return value
    return fallback


def load_colors():
    return {
        "background": read_color("background", "#161320"),
        "surface": read_color("surface", "#1b1624"),
        "surface_container": read_color("surface_container", "#261d31"),
        "surface_container_high": read_color("surface_container_high", "#31243d"),
        "secondary_container": read_color("secondary_container", "#334b4f"),
        "primary": read_color("primary", "#d0a7ff"),
        "primary_fixed": read_color("primary_fixed", "#f2d8ff"),
        "secondary": read_color("secondary", "#c6b2dd"),
        "on_surface": read_color("on_surface", "#f4eefb"),
        "on_surface_variant": read_color("on_surface_variant", "#c8bdd8"),
        "outline": read_color("outline", "#7d7090"),
    }


class MiniCalendar(Gtk.Application):
    def __init__(self, daemon_mode=False):
        super().__init__(
            application_id="com.siverteh.minicalendar",
            flags=Gio.ApplicationFlags.NON_UNIQUE,
        )
        self.daemon_mode = daemon_mode
        self.window = None
        self.popup_width = 312
        self.popup_y = 0
        self.popup_right_margin = 8
        self.colors = load_colors()
        self.provider = Gtk.CssProvider()
        self.provider_installed = False
        self.hold()

        PID_FILE.parent.mkdir(parents=True, exist_ok=True)
        PID_FILE.write_text(str(os.getpid()))
        atexit.register(self.cleanup_pid)
        signal.signal(signal.SIGUSR1, self.on_toggle_signal)

    def cleanup_pid(self):
        try:
            if PID_FILE.exists() and PID_FILE.read_text().strip() == str(os.getpid()):
                PID_FILE.unlink()
        except OSError:
            pass

    def do_activate(self):
        self.ensure_window()
        if not self.daemon_mode:
            self.toggle_visibility(force_show=True)

    def ensure_window(self):
        self.colors = load_colors()
        if self.window is not None:
            self.apply_css()
            self.window.set_child(self.build_content())
            return

        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("Siverteh Mini Calendar")
        self.window.set_default_size(self.popup_width, 286)
        self.window.set_resizable(False)
        self.window.set_decorated(False)
        self.window.set_hide_on_close(False)
        self.window.set_focusable(True)
        self.window.add_css_class("popup-window")
        self.window.connect("close-request", self.on_close_request)

        controller = Gtk.EventControllerKey()
        controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(controller)

        Gtk4LayerShell.init_for_window(self.window)
        Gtk4LayerShell.set_namespace(self.window, "siverteh-mini-calendar")
        Gtk4LayerShell.set_layer(self.window, Gtk4LayerShell.Layer.OVERLAY)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.TOP, True)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.LEFT, True)
        Gtk4LayerShell.set_keyboard_mode(
            self.window, Gtk4LayerShell.KeyboardMode.ON_DEMAND
        )

        self.apply_css()
        self.window.set_child(self.build_content())
        self.configure_position()

    def on_toggle_signal(self, *_args):
        GLib.idle_add(self.toggle_visibility)

    def toggle_visibility(self, force_show=False):
        self.ensure_window()
        if self.window.is_visible() and not force_show:
            self.window.hide()
        else:
            self.colors = load_colors()
            self.apply_css()
            self.window.set_child(self.build_content())
            self.configure_position()
            self.window.present()
            self.window.grab_focus()
        return GLib.SOURCE_REMOVE

    def compute_position(self):
        try:
            monitors = json.loads(
                subprocess.check_output(["hyprctl", "-j", "monitors"], text=True)
            )
        except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
            return 804, self.popup_y

        if not monitors:
            return 804, self.popup_y

        focused = next((monitor for monitor in monitors if monitor.get("focused")), monitors[0])
        scale = float(focused.get("scale", 1.0) or 1.0)
        logical_x = int(round(float(focused.get("x", 0)) / scale))
        logical_y = int(round(float(focused.get("y", 0)) / scale))
        logical_width = int(round(float(focused.get("width", 1920)) / scale))
        popup_x = logical_x + logical_width - self.popup_width - self.popup_right_margin
        popup_x = max(logical_x, popup_x)
        popup_y = max(logical_y + self.popup_y, 0)
        return popup_x, popup_y

    def configure_position(self):
        popup_x, popup_y = self.compute_position()
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.LEFT, popup_x)
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.TOP, popup_y)

    def build_content(self):
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.add_css_class("popup-shell")

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        card.add_css_class("popup-card")

        title = Gtk.Label(label="Calendar")
        title.add_css_class("popup-title")
        title.set_halign(Gtk.Align.CENTER)

        subtitle = Gtk.Label(label=GLib.DateTime.new_now_local().format("%A, %d %B %Y"))
        subtitle.add_css_class("popup-subtitle")
        subtitle.set_halign(Gtk.Align.CENTER)

        calendar = Gtk.Calendar()
        calendar.add_css_class("popup-calendar")
        calendar.set_halign(Gtk.Align.CENTER)
        calendar.set_hexpand(False)
        calendar.set_vexpand(False)
        calendar.set_show_week_numbers(False)
        calendar.set_focusable(True)

        shortcuts = Gtk.ShortcutController()
        shortcuts.add_shortcut(
            Gtk.Shortcut.new(
                Gtk.ShortcutTrigger.parse_string("Escape"),
                Gtk.CallbackAction.new(lambda *_args: self.close_shortcut()),
            )
        )
        outer.add_controller(shortcuts)

        card.append(title)
        card.append(subtitle)
        card.append(calendar)
        outer.append(card)
        return outer

    def apply_css(self):
        colors = self.colors
        css = f"""
        window.popup-window,
        window {{
            background: transparent;
            background-color: transparent;
            border: none;
            outline: none;
            box-shadow: none;
        }}

        .popup-shell {{
            background:
                radial-gradient(circle at top, alpha({colors['primary']}, 0.18), transparent 45%),
                linear-gradient(180deg, alpha({colors['secondary_container']}, 0.88), alpha({colors['surface_container_high']}, 0.94));
            border-radius: 20px;
            border: 1px solid alpha({colors['primary_fixed']}, 0.12);
            box-shadow:
                0 6px 14px alpha({colors['primary']}, 0.05),
                inset 0 1px 0 alpha({colors['primary_fixed']}, 0.05);
            padding: 18px 18px 14px 18px;
        }}

        .popup-card {{
            background: transparent;
            border: none;
            box-shadow: none;
            padding: 0;
        }}

        .popup-title {{
            color: {colors['on_surface']};
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 0.08em;
        }}

        .popup-subtitle {{
            color: {colors['on_surface_variant']};
            font-size: 11px;
            margin-bottom: 4px;
        }}

        calendar.popup-calendar {{
            color: {colors['on_surface']};
            background: alpha({colors['surface_container']}, 0.82);
            border-radius: 16px;
            border: 1px solid alpha({colors['outline']}, 0.22);
            outline: none;
            box-shadow: none;
            padding: 8px;
        }}

        calendar.popup-calendar header {{
            background: transparent;
            color: {colors['primary_fixed']};
            border: none;
        }}

        calendar.popup-calendar button {{
            color: {colors['on_surface']};
            background: transparent;
            border-radius: 10px;
        }}

        calendar.popup-calendar button:hover {{
            background: alpha({colors['primary']}, 0.16);
        }}

        calendar.popup-calendar > grid > label {{
            color: {colors['on_surface']};
            min-width: 22px;
            min-height: 22px;
            border-radius: 999px;
        }}

        calendar.popup-calendar > grid > label.today {{
            background: alpha({colors['primary']}, 0.22);
            color: {colors['primary_fixed']};
            font-weight: 800;
        }}

        calendar.popup-calendar > grid > label:selected {{
            background: linear-gradient(135deg, alpha({colors['primary']}, 0.9), alpha({colors['secondary']}, 0.82));
            color: {colors['background']};
            font-weight: 800;
        }}
        """

        self.provider.load_from_data(css.encode())
        if not self.provider_installed:
            Gtk.StyleContext.add_provider_for_display(
                Gdk.Display.get_default(),
                self.provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
            )
            self.provider_installed = True

    def on_key_pressed(self, _controller, keyval, _keycode, _state):
        if keyval == Gdk.KEY_Escape:
            self.window.hide()
            return True
        return False

    def close_shortcut(self):
        if self.window is not None:
            self.window.hide()
        return True

    def on_close_request(self, *_args):
        if self.window is not None:
            self.window.hide()
        return True


if __name__ == "__main__":
    daemon_mode = "--daemon" in sys.argv[1:]
    app = MiniCalendar(daemon_mode=daemon_mode)
    sys.exit(app.run(sys.argv))
