#!/usr/bin/env python3

import json
import re
import subprocess
import sys
from pathlib import Path

import gi

gi.require_version("Gdk", "4.0")
gi.require_version("Gtk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")

from gi.repository import Gdk, Gio, GLib, Gtk, Gtk4LayerShell


def read_color(name, fallback):
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


COLORS = {
    "background": read_color("background", "#161320"),
    "surface": read_color("surface", "#1b1624"),
    "surface_container": read_color("surface-container", "#261d31"),
    "surface_container_high": read_color("surface-container-high", "#31243d"),
    "primary": read_color("primary", "#d0a7ff"),
    "primary_fixed": read_color("primary-fixed", "#f2d8ff"),
    "secondary": read_color("secondary", "#c6b2dd"),
    "on_surface": read_color("on-surface", "#f4eefb"),
    "on_surface_variant": read_color("on-surface-variant", "#c8bdd8"),
    "outline": read_color("outline", "#7d7090"),
}


class MiniCalendar(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id="com.siverteh.minicalendar",
            flags=Gio.ApplicationFlags.NON_UNIQUE,
        )
        self.window = None
        self.ready_for_autoclose = False
        self.popup_width = 312
        self.popup_y = 46

    def do_activate(self):
        if self.window is None:
            self.window = Gtk.ApplicationWindow(application=self)
            self.window.set_title("Siverteh Mini Calendar")
            self.window.set_default_size(self.popup_width, 286)
            self.window.set_resizable(False)
            self.window.set_decorated(False)
            self.window.set_hide_on_close(False)
            self.window.connect("close-request", self.on_close_request)
            self.window.connect("notify::is-active", self.on_active_changed)

            controller = Gtk.EventControllerKey()
            controller.connect("key-pressed", self.on_key_pressed)
            self.window.add_controller(controller)

            Gtk4LayerShell.init_for_window(self.window)
            Gtk4LayerShell.set_namespace(self.window, "siverteh-mini-calendar")
            Gtk4LayerShell.set_layer(self.window, Gtk4LayerShell.Layer.OVERLAY)
            Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.TOP, True)
            Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.TOP, 46)
            Gtk4LayerShell.set_keyboard_mode(self.window, Gtk4LayerShell.KeyboardMode.ON_DEMAND)

            self.apply_css()
            self.window.set_child(self.build_content())

        self.window.present()
        GLib.timeout_add(120, self.position_window)
        self.ready_for_autoclose = False
        GLib.timeout_add(450, self.enable_autoclose)

    def compute_position(self):
        try:
            monitors = json.loads(subprocess.check_output(["hyprctl", "-j", "monitors"], text=True))
        except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
            return 804, self.popup_y

        if not monitors:
            return 804, self.popup_y

        focused = next((monitor for monitor in monitors if monitor.get("focused")), monitors[0])
        scale = float(focused.get("scale", 1.0) or 1.0)
        logical_x = int(round(float(focused.get("x", 0)) / scale))
        logical_y = int(round(float(focused.get("y", 0)) / scale))
        logical_width = int(round(float(focused.get("width", 1920)) / scale))
        popup_x = max(logical_x + ((logical_width - self.popup_width) // 2), 0)
        popup_y = max(logical_y + self.popup_y, 0)
        return popup_x, popup_y

    def position_window(self):
        popup_x, popup_y = self.compute_position()
        try:
            subprocess.run(
                [
                    "hyprctl",
                    "dispatch",
                    "movewindowpixel",
                    f"exact {popup_x} {popup_y},title:^(Siverteh Mini Calendar)$",
                ],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except FileNotFoundError:
            pass
        return GLib.SOURCE_REMOVE

    def build_content(self):
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.add_css_class("popup-shell")

        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        card.add_css_class("popup-card")
        card.set_margin_top(12)
        card.set_margin_bottom(12)
        card.set_margin_start(12)
        card.set_margin_end(12)

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

        card.append(title)
        card.append(subtitle)
        card.append(calendar)
        outer.append(card)
        return outer

    def apply_css(self):
        css = f"""
        window {{
            background: transparent;
        }}

        .popup-shell {{
            background: transparent;
        }}

        .popup-card {{
            background:
                radial-gradient(circle at top, alpha({COLORS['primary']}, 0.18), transparent 45%),
                linear-gradient(180deg, alpha({COLORS['surface_container_high']}, 0.92), alpha({COLORS['surface']}, 0.96));
            border-radius: 20px;
            border: 1px solid alpha({COLORS['primary_fixed']}, 0.22);
            box-shadow: 0 18px 40px alpha(black, 0.28);
            padding: 14px 14px 12px 14px;
        }}

        .popup-title {{
            color: {COLORS['on_surface']};
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 0.08em;
        }}

        .popup-subtitle {{
            color: {COLORS['on_surface_variant']};
            font-size: 11px;
            margin-bottom: 4px;
        }}

        calendar.popup-calendar {{
            color: {COLORS['on_surface']};
            background: alpha({COLORS['surface_container']}, 0.64);
            border-radius: 16px;
            border: 1px solid alpha({COLORS['outline']}, 0.28);
            padding: 8px;
        }}

        calendar.popup-calendar header {{
            background: transparent;
            color: {COLORS['primary_fixed']};
            border: none;
        }}

        calendar.popup-calendar button {{
            color: {COLORS['on_surface']};
            background: transparent;
            border-radius: 10px;
        }}

        calendar.popup-calendar button:hover {{
            background: alpha({COLORS['primary']}, 0.16);
        }}

        calendar.popup-calendar > grid > label {{
            color: {COLORS['on_surface']};
            min-width: 22px;
            min-height: 22px;
            border-radius: 999px;
        }}

        calendar.popup-calendar > grid > label.today {{
            background: alpha({COLORS['primary']}, 0.22);
            color: {COLORS['primary_fixed']};
            font-weight: 800;
        }}

        calendar.popup-calendar > grid > label:selected {{
            background: linear-gradient(135deg, alpha({COLORS['primary']}, 0.9), alpha({COLORS['secondary']}, 0.82));
            color: {COLORS['background']};
            font-weight: 800;
        }}
        """

        provider = Gtk.CssProvider()
        provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    def on_key_pressed(self, _controller, keyval, _keycode, _state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True
        return False

    def on_active_changed(self, window, _pspec):
        if not self.ready_for_autoclose:
            return
        GLib.timeout_add(150, self.close_if_inactive, window)

    def enable_autoclose(self):
        self.ready_for_autoclose = True
        return GLib.SOURCE_REMOVE

    def close_if_inactive(self, window):
        if window is None:
            return GLib.SOURCE_REMOVE
        if not window.is_active():
            self.quit()
        return GLib.SOURCE_REMOVE

    def on_close_request(self, *_args):
        self.quit()
        return False


if __name__ == "__main__":
    app = MiniCalendar()
    sys.exit(app.run([]))
