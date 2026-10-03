#!/usr/bin/env python3

import atexit
import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import threading
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

import gi

gi.require_version("Gtk4LayerShell", "1.0")
gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
gi.require_version("GLibUnix", "2.0")
gi.require_version("Pango", "1.0")

from gi.repository import Gtk4LayerShell, Gdk, Gio, GLib, GLibUnix, Gtk, Pango

from settings_backend import VIBE_LABELS, VIBE_OPTIONS, SivertehSettingsBackend, normalize_vibe


PID_FILE = Path.home() / ".cache" / "siverteh" / "shell-overlay.pid"
READY_FILE = Path.home() / ".cache" / "siverteh" / "shell-overlay.ready"
STATE_FILE = Path.home() / ".cache" / "siverteh" / "shell-overlay.state"
REQUEST_FILE = Path.home() / ".cache" / "siverteh" / "shell-overlay.request"
DEBUG_FILE = Path("/tmp/siverteh-shell-debug.log")
DEBUG_ENABLED = os.environ.get("SIVERTEH_SHELL_DEBUG") == "1"


def debug(message):
    if not DEBUG_ENABLED:
        return
    try:
        with DEBUG_FILE.open("a", encoding="utf-8") as handle:
            handle.write(f"{GLib.get_monotonic_time()} {message}\n")
    except OSError:
        pass


def read_color_from_css(path, name):
    if not path.exists():
        return ""

    try:
        content = path.read_text()
    except OSError:
        return ""

    define_match = re.search(rf"@define-color\s+{re.escape(name)}\s+([^;]+);", content)
    if define_match:
        return define_match.group(1).strip()

    rofi_name = name.replace("_", "-")
    rofi_match = re.search(rf"{re.escape(rofi_name)}:\s*([^;]+);", content)
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
        "background": read_color("background", "#110f18"),
        "surface": read_color("surface", "#161320"),
        "surface_container": read_color("surface_container", "#201b2b"),
        "surface_container_high": read_color("surface_container_high", "#2a2237"),
        "surface_container_highest": read_color("surface_container_highest", "#342b43"),
        "primary": read_color("primary", "#d0a7ff"),
        "primary_fixed": read_color("primary_fixed", "#f2d8ff"),
        "primary_container": read_color("primary_container", "#6f5091"),
        "secondary": read_color("secondary", "#c6b2dd"),
        "secondary_container": read_color("secondary_container", "#4c405f"),
        "tertiary": read_color("tertiary", "#ff8ab5"),
        "on_primary": read_color("on_primary", "#231332"),
        "on_surface": read_color("on_surface", "#f4eefb"),
        "on_surface_variant": read_color("on_surface_variant", "#c8bdd8"),
        "outline": read_color("outline", "#7d7090"),
        "shadow": read_color("shadow", "#000000"),
    }


SHELL_VIBE_STYLE = {
    "glass": {
        "accent": "primary_fixed",
        "accent_2": "secondary",
        "panel_top": "0.46",
        "panel_bottom": "0.30",
        "panel_halo": "0.22",
        "panel_glow": "0.10",
        "panel_shadow": "0.08",
        "panel_border": "0.24",
        "panel_radius": 30,
        "rail_alpha": "0.24",
        "rail_border": "0.20",
        "card_top": "0.20",
        "card_bottom": "0.11",
        "card_border": "0.11",
        "card_radius": 13,
        "hero_halo": "0.10",
        "button_alpha": "0.48",
        "button_border": "0.22",
        "selected_alpha": "0.92",
        "selected_alpha_2": "0.74",
        "hover_border": "0.38",
        "signal_alpha": "0.42",
    },
    "minimal": {
        "accent": "secondary",
        "accent_2": "primary_fixed",
        "panel_top": "0.78",
        "panel_bottom": "0.68",
        "panel_halo": "0.10",
        "panel_glow": "0.04",
        "panel_shadow": "0.08",
        "panel_border": "0.14",
        "panel_radius": 22,
        "rail_alpha": "0.34",
        "rail_border": "0.12",
        "card_top": "0.32",
        "card_bottom": "0.20",
        "card_border": "0.06",
        "card_radius": 12,
        "hero_halo": "0.08",
        "button_alpha": "0.32",
        "button_border": "0.14",
        "selected_alpha": "0.72",
        "selected_alpha_2": "0.48",
        "hover_border": "0.22",
        "signal_alpha": "0.30",
    },
    "neon": {
        "accent": "tertiary",
        "accent_2": "primary",
        "panel_top": "0.93",
        "panel_bottom": "0.86",
        "panel_halo": "0.38",
        "panel_glow": "0.28",
        "panel_shadow": "0.18",
        "panel_border": "0.36",
        "panel_radius": 32,
        "rail_alpha": "0.58",
        "rail_border": "0.30",
        "card_top": "0.52",
        "card_bottom": "0.36",
        "card_border": "0.14",
        "card_radius": 16,
        "hero_halo": "0.28",
        "button_alpha": "0.54",
        "button_border": "0.30",
        "selected_alpha": "0.96",
        "selected_alpha_2": "0.82",
        "hover_border": "0.50",
        "signal_alpha": "0.50",
    },
    "nordic": {
        "accent": "secondary",
        "accent_2": "primary",
        "panel_top": "0.84",
        "panel_bottom": "0.76",
        "panel_halo": "0.18",
        "panel_glow": "0.08",
        "panel_shadow": "0.10",
        "panel_border": "0.18",
        "panel_radius": 24,
        "rail_alpha": "0.44",
        "rail_border": "0.18",
        "card_top": "0.40",
        "card_bottom": "0.27",
        "card_border": "0.08",
        "card_radius": 13,
        "hero_halo": "0.12",
        "button_alpha": "0.42",
        "button_border": "0.20",
        "selected_alpha": "0.82",
        "selected_alpha_2": "0.62",
        "hover_border": "0.30",
        "signal_alpha": "0.38",
    },
    "custom": {
        "accent": "primary_fixed",
        "accent_2": "tertiary",
        "panel_top": "0.95",
        "panel_bottom": "0.88",
        "panel_halo": "0.44",
        "panel_glow": "0.32",
        "panel_shadow": "0.20",
        "panel_border": "0.42",
        "panel_radius": 36,
        "rail_alpha": "0.62",
        "rail_border": "0.36",
        "card_top": "0.56",
        "card_bottom": "0.38",
        "card_border": "0.16",
        "card_radius": 18,
        "hero_halo": "0.34",
        "button_alpha": "0.58",
        "button_border": "0.34",
        "selected_alpha": "0.98",
        "selected_alpha_2": "0.88",
        "hover_border": "0.56",
        "signal_alpha": "0.54",
    },
}


def run(*args, timeout=None):
    try:
        return subprocess.run(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
            timeout=timeout,
        )
    except (OSError, subprocess.SubprocessError):
        return subprocess.CompletedProcess(args, 1, stdout="")


VALID_TABS = {"dashboard", "media", "actions", "settings"}
TAB_ALIASES = {"now": "dashboard"}
TAB_ORDER = ("dashboard", "media", "actions", "settings")

TAB_CHROME = {
    "dashboard": ("󰎆", "Dashboard", "calendar · system · desktop pulse"),
    "media": ("", "Media", "MPRIS · transport · now playing"),
    "actions": ("󰣇", "Tools", "surfaces · commands · session flow"),
    "settings": ("󰒓", "Settings", "vibe matrix · wallpaper-reactive"),
}


def normalize_tab_name(tab, fallback="dashboard"):
    tab = TAB_ALIASES.get(tab, tab)
    return tab if tab in VALID_TABS else fallback


def parse_initial_tab(argv):
    requested = os.environ.get("SIVERTEH_SHELL_INITIAL_TAB")
    args = argv[1:]
    for index, arg in enumerate(args):
        if arg == "--tab" and index + 1 < len(args):
            requested = args[index + 1]
            break
        if arg.startswith("--tab="):
            requested = arg.split("=", 1)[1]
            break
    return normalize_tab_name(requested)


class SivertehShell(Gtk.Application):
    def __init__(self, daemon_mode=False, initial_tab="dashboard"):
        super().__init__(
            application_id="com.siverteh.shell",
            flags=Gio.ApplicationFlags.NON_UNIQUE,
        )
        self.daemon_mode = daemon_mode
        self.initial_tab = normalize_tab_name(initial_tab)
        self.repo_root = Path(__file__).resolve().parents[2]
        self.backend = SivertehSettingsBackend(self.repo_root)
        self.colors = load_colors()
        self.provider = Gtk.CssProvider()
        self.provider_installed = False
        self.window = None
        self.panel = None
        self.hide_source = None
        self.animation_source = None
        self.shape_source = None
        self.map_source = None
        self.runtime_source = None
        self.runtime_pending = False
        self.open_state = False
        self.show_generation = 0
        self.position_cache = None
        self.panel_width = 560
        self.current_tab = self.initial_tab
        self.panel_heights = {
            "dashboard": 660,
            "media": 480,
            "actions": 520,
            "settings": 720,
        }
        self.transition_ms = 210
        self.widgets = {}
        self.chrome_details = {}
        self.tab_buttons = {}
        self.vibe_buttons = {}
        self.setting_buttons = {}
        self.hypr_buttons = {}
        self.display_buttons = {}
        self.shell_root = None
        self.parking_root = None
        self.content_revealer = None
        self.header_revealer = None
        self.page_scroller = None
        self.hold()

        PID_FILE.parent.mkdir(parents=True, exist_ok=True)
        PID_FILE.write_text(str(os.getpid()))
        READY_FILE.unlink(missing_ok=True)
        atexit.register(self.cleanup_pid)
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, self.on_toggle_signal)
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR2, self.on_request_signal)
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, self.on_shutdown_signal)
        GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, self.on_shutdown_signal)

    def cleanup_pid(self):
        try:
            self.write_shell_state(False, notify=False)
            if PID_FILE.exists() and PID_FILE.read_text().strip() == str(os.getpid()):
                PID_FILE.unlink()
            if READY_FILE.exists() and READY_FILE.read_text().strip() == str(os.getpid()):
                READY_FILE.unlink()
        except OSError:
            pass

    def do_activate(self):
        self.ensure_window()
        if self.daemon_mode:
            self.park_window()
        READY_FILE.write_text(str(os.getpid()))
        debug(f"activate daemon={self.daemon_mode} pid={os.getpid()}")
        if not self.daemon_mode:
            GLib.timeout_add(120, self.show_on_start)

    def show_on_start(self):
        self.toggle_visibility(force_show=True)
        return GLib.SOURCE_REMOVE

    def ensure_window(self):
        self.colors = load_colors()
        if self.window is not None:
            self.apply_css()
            if self.open_state:
                self.configure_position()
            else:
                self.configure_position(1, 1)
            return

        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("Siverteh Shell")
        self.window.set_decorated(False)
        self.window.set_resizable(True)
        self.window.set_hide_on_close(False)
        self.window.set_focusable(False)
        self.window.add_css_class("shell-window")
        self.window.connect("close-request", self.on_close_request)

        controller = Gtk.EventControllerKey()
        controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(controller)

        Gtk4LayerShell.init_for_window(self.window)
        Gtk4LayerShell.set_namespace(self.window, "siverteh-shell")
        Gtk4LayerShell.set_layer(self.window, Gtk4LayerShell.Layer.OVERLAY)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.TOP, True)
        Gtk4LayerShell.set_anchor(self.window, Gtk4LayerShell.Edge.LEFT, True)
        Gtk4LayerShell.set_keyboard_mode(
            self.window, Gtk4LayerShell.KeyboardMode.NONE
        )

        self.panel = self.build_panel()
        self.panel.set_halign(Gtk.Align.CENTER)
        self.panel.set_valign(Gtk.Align.START)
        self.panel.set_hexpand(False)
        self.panel.set_vexpand(False)
        self.panel.set_size_request(self.panel_width, -1)

        shell = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        shell.add_css_class("shell-root")
        shell.set_halign(Gtk.Align.FILL)
        shell.set_valign(Gtk.Align.START)
        shell.set_size_request(self.panel_width, -1)
        shell.append(self.panel)
        self.shell_root = shell

        parking = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        parking.add_css_class("shell-parking")
        parking.set_size_request(1, 1)
        self.parking_root = parking

        self.apply_css()
        self.window.set_child(shell)
        self.configure_position()

    def write_shell_state(self, open_state=None, notify=True):
        state_open = self.open_state if open_state is None else bool(open_state)
        try:
            STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
            STATE_FILE.write_text(
                json.dumps(
                    {
                        "open": state_open,
                        "tab": self.current_tab,
                        "pid": os.getpid(),
                    }
                )
                + "\n"
            )
        except OSError:
            pass
        if notify:
            self.notify_waybar_shell_state()

    def notify_waybar_shell_state(self):
        try:
            subprocess.Popen(
                ["pkill", "-RTMIN+9", "waybar"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        except OSError:
            pass

    def read_monitor_geometry(self):
        try:
            monitors = json.loads(
                run("hyprctl", "-j", "monitors", timeout=0.25).stdout.strip() or "[]"
            )
        except json.JSONDecodeError:
            monitors = []

        if not monitors:
            return {
                "x": 0,
                "y": 0,
                "width": 1920,
                "height": 1080,
            }

        focused = next((monitor for monitor in monitors if monitor.get("focused")), monitors[0])
        try:
            scale = float(focused.get("scale", 1.0) or 1.0)
            logical_x = int(round(float(focused.get("x", 0)) / scale))
            logical_y = int(round(float(focused.get("y", 0)) / scale))
            logical_width = int(round(float(focused.get("width", 1920)) / scale))
            logical_height = int(round(float(focused.get("height", 1080)) / scale))
        except (TypeError, ValueError):
            logical_x = 0
            logical_y = 0
            logical_width = 1920
            logical_height = 1080

        return {
            "x": logical_x,
            "y": logical_y,
            "width": logical_width,
            "height": logical_height,
        }

    def compute_position(self, width_override=None, geometry=None):
        geometry = geometry or self.position_cache or self.read_monitor_geometry()
        logical_x = geometry["x"]
        logical_y = geometry["y"]
        logical_width = geometry["width"]

        target_width = min(492, max(420, logical_width - 96))
        if width_override is None:
            width = target_width
        else:
            width = min(target_width, max(1, int(width_override)))
        x = logical_x + max(18, int((logical_width - width) / 2))
        return x, logical_y, width

    def current_panel_height(self):
        geometry = self.position_cache or self.read_monitor_geometry()
        max_height = max(320, geometry["height"] - 72)
        return min(self.panel_heights.get(normalize_tab_name(self.current_tab), 616), max_height)

    def compact_panel_width(self, target_width):
        return min(target_width, 204)

    def compact_panel_height(self):
        return 32

    def configure_position(self, width_override=None, height_override=None, surface_width=None):
        if height_override is None:
            height_override = self.current_panel_height() if self.open_state else -1
        surface_override = surface_width if surface_width is not None else width_override
        popup_x, popup_y, surface_width = self.compute_position(surface_override)
        if width_override is None:
            panel_width = surface_width
        else:
            panel_width = min(surface_width, max(1, int(width_override)))
        debug(
            f"configure surface={surface_width} panel={panel_width} "
            f"height={height_override} x={popup_x} y={popup_y}"
        )
        self.panel_width = panel_width
        self.window.set_default_size(surface_width, height_override)
        self.window.set_size_request(surface_width, height_override)
        child_height = height_override if height_override > 0 else -1
        content_height = max(1, height_override - 128) if height_override > 0 else -1
        if self.shell_root is not None:
            self.shell_root.set_size_request(surface_width, child_height)
        if self.panel is not None:
            self.panel.set_size_request(panel_width, child_height)
        if self.page_scroller is not None:
            self.page_scroller.set_size_request(-1, content_height)
            if content_height > 0:
                self.page_scroller.set_min_content_height(-1)
                self.page_scroller.set_max_content_height(content_height)
                self.page_scroller.set_min_content_height(content_height)
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.LEFT, popup_x)
        Gtk4LayerShell.set_margin(self.window, Gtk4LayerShell.Edge.TOP, popup_y)
        self.window.queue_resize()

    def on_toggle_signal(self):
        visible = self.window.is_visible() if self.window is not None else False
        debug(f"signal visible={visible}")
        self.toggle_visibility()
        return GLib.SOURCE_CONTINUE

    def on_request_signal(self):
        requested_tab = "dashboard"
        try:
            payload = json.loads(REQUEST_FILE.read_text())
            requested_tab = payload.get("tab", "dashboard")
        except (OSError, json.JSONDecodeError):
            pass
        self.show_tab(requested_tab)
        return GLib.SOURCE_CONTINUE

    def on_shutdown_signal(self):
        debug("shutdown")
        self.open_state = False
        if self.hide_source is not None:
            GLib.source_remove(self.hide_source)
            self.hide_source = None
        if self.animation_source is not None:
            GLib.source_remove(self.animation_source)
            self.animation_source = None
        if self.shape_source is not None:
            GLib.source_remove(self.shape_source)
            self.shape_source = None
        if self.map_source is not None:
            GLib.source_remove(self.map_source)
            self.map_source = None
        self.write_shell_state(False)
        if self.window is not None:
            self.window.set_opacity(1.0)
            self.window.set_visible(False)
        self.release()
        self.quit()
        return GLib.SOURCE_REMOVE

    def show_tab(self, tab):
        self.ensure_window()
        self.set_tab(tab)
        if self.open_state:
            self.write_shell_state(True)
            return
        self.toggle_visibility(force_show=True)

    def toggle_visibility(self, force_show=False):
        self.ensure_window()
        visible = self.window.is_visible()
        debug(f"toggle force={force_show} visible={visible}")
        if self.hide_source is not None:
            GLib.source_remove(self.hide_source)
            self.hide_source = None
        if self.animation_source is not None:
            GLib.source_remove(self.animation_source)
            self.animation_source = None
        if self.shape_source is not None:
            GLib.source_remove(self.shape_source)
            self.shape_source = None
        if self.map_source is not None:
            GLib.source_remove(self.map_source)
            self.map_source = None

        if self.open_state and not force_show:
            self.open_state = False
            debug("hide-start")
            self.hide_window(animated=True)
            return GLib.SOURCE_REMOVE

        self.open_state = True
        self.show_generation += 1
        debug("show-start")
        self.attach_shell()
        self.colors = load_colors()
        self.apply_css()
        self.prime_runtime_labels()
        self.position_cache = self.read_monitor_geometry()
        _popup_x, _popup_y, target_width = self.compute_position(geometry=self.position_cache)
        target_height = self.current_panel_height()
        start_width = self.compact_panel_width(target_width)
        start_height = self.compact_panel_height()
        self.write_shell_state(True)
        if self.content_revealer is not None:
            self.content_revealer.set_transition_duration(180)
            self.content_revealer.set_reveal_child(False)
            self.content_revealer.set_visible(False)
        if self.header_revealer is not None:
            self.header_revealer.set_transition_duration(120)
            self.header_revealer.set_reveal_child(False)
            self.header_revealer.set_visible(False)
        self.configure_position(start_width, start_height, surface_width=target_width)
        Gtk4LayerShell.set_keyboard_mode(
            self.window, Gtk4LayerShell.KeyboardMode.NONE
        )
        self.window.set_opacity(1.0)
        self.window.set_visible(True)
        self.window.set_opacity(1.0)
        self.animate_shape(
            start_width,
            target_width,
            start_height,
            target_height,
            require_open=True,
            surface_width=target_width,
            on_done=self.reveal_content,
        )
        self.map_source = GLib.timeout_add(220, self.ensure_open_mapped, 1)
        GLib.timeout_add(320, self.refresh_runtime_once)
        GLib.timeout_add(1400, self.refresh_runtime_once)
        if self.runtime_source is None:
            self.runtime_source = GLib.timeout_add_seconds(2, self.update_runtime)
        return GLib.SOURCE_REMOVE

    def reveal_content(self):
        if self.open_state and self.content_revealer is not None:
            if self.header_revealer is not None:
                self.header_revealer.set_visible(True)
                self.header_revealer.set_transition_duration(160)
                self.header_revealer.set_reveal_child(True)
            self.content_revealer.set_visible(True)
            self.content_revealer.set_transition_duration(250)
            self.content_revealer.set_reveal_child(True)
        return GLib.SOURCE_REMOVE

    def attach_shell(self):
        if self.window is None or self.shell_root is None:
            return
        if self.window.get_child() is not self.shell_root:
            self.window.set_child(self.shell_root)

    def park_window(self, notify_closed=False):
        if self.window is None:
            return
        if notify_closed and self.open_state:
            return
        debug("park")
        if self.shape_source is not None:
            GLib.source_remove(self.shape_source)
            self.shape_source = None
        if self.animation_source is not None:
            GLib.source_remove(self.animation_source)
            self.animation_source = None
        if self.content_revealer is not None:
            self.content_revealer.set_reveal_child(False)
            self.content_revealer.set_visible(False)
        if self.header_revealer is not None:
            self.header_revealer.set_reveal_child(False)
            self.header_revealer.set_visible(False)
        if self.parking_root is not None and self.window.get_child() is not self.parking_root:
            self.window.set_child(self.parking_root)
        Gtk4LayerShell.set_keyboard_mode(self.window, Gtk4LayerShell.KeyboardMode.NONE)
        geometry = self.position_cache or self.read_monitor_geometry()
        self.position_cache = geometry
        self.configure_position(1, 1)
        Gtk4LayerShell.set_margin(
            self.window,
            Gtk4LayerShell.Edge.TOP,
            geometry["height"] + 100000,
        )
        if self.parking_root is not None:
            self.parking_root.set_size_request(1, 1)
        self.window.set_opacity(0.0)
        self.window.set_visible(False)
        if notify_closed and not self.open_state:
            self.write_shell_state(False)

    def refresh_runtime_once(self):
        self.update_runtime()
        return GLib.SOURCE_REMOVE

    def prime_runtime_labels(self):
        if not self.widgets:
            return
        now = GLib.DateTime.new_now_local()
        if "time" in self.widgets:
            self.widgets["time"].set_text(now.format("%H:%M  %a %d"))
        if "dash_time" in self.widgets:
            self.widgets["dash_time"].set_text(now.format("%H:%M"))
        if "dash_date" in self.widgets:
            self.widgets["dash_date"].set_text(now.format("%A · %d %B"))
        if "dash_track" in self.widgets:
            self.widgets["dash_track"].set_text("Syncing player...")
        if "dash_artist" in self.widgets:
            self.widgets["dash_artist"].set_text("MPRIS bridge")
        if "dash_media_state" in self.widgets:
            self.widgets["dash_media_state"].set_text("media")
        if "track" in self.widgets:
            self.widgets["track"].set_text("Syncing player...")
        if "system" in self.widgets:
            self.widgets["system"].set_text("syncing pulse...")
        if "workspace_radar" in self.widgets:
            self.widgets["workspace_radar"].set_text("1○  2○  3○  4○  5○  6○")
        if "focus" in self.widgets:
            self.widgets["focus"].set_text("desktop radar syncing...")
        self.update_chrome()

    def ensure_open_mapped(self, pass_number):
        self.map_source = None
        if not self.open_state or self.window is None:
            return GLib.SOURCE_REMOVE

        debug(f"map-pass {pass_number}")
        self.window.set_opacity(1.0)
        self.configure_position()
        if not self.window.is_visible():
            self.window.set_visible(True)
            self.window.set_opacity(1.0)

        if pass_number < 3:
            self.map_source = GLib.timeout_add(260, self.ensure_open_mapped, pass_number + 1)

        return GLib.SOURCE_REMOVE

    def animate_opacity(self, start, end, on_done=None):
        steps = 12
        frame_ms = max(12, int(self.transition_ms / steps))
        current_step = 0
        self.window.set_opacity(start)

        def tick():
            nonlocal current_step
            current_step += 1
            progress = current_step / steps
            eased = 1 - pow(1 - progress, 3)
            self.window.set_opacity(start + ((end - start) * eased))
            if current_step >= steps:
                self.window.set_opacity(end)
                self.animation_source = None
                if on_done is not None:
                    on_done()
                return GLib.SOURCE_REMOVE
            return GLib.SOURCE_CONTINUE

        self.animation_source = GLib.timeout_add(frame_ms, tick)

    def animate_shape(
        self,
        start_width,
        end_width,
        start_height=None,
        end_height=None,
        require_open=True,
        surface_width=None,
        on_done=None,
    ):
        steps = 13
        frame_ms = max(12, int(self.transition_ms / steps))
        current_step = 0
        if start_height is None:
            start_height = self.current_panel_height()
        if end_height is None:
            end_height = start_height

        def tick():
            nonlocal current_step
            if require_open and not self.open_state:
                self.shape_source = None
                return GLib.SOURCE_REMOVE
            current_step += 1
            progress = current_step / steps
            eased = 1 - pow(1 - progress, 3)
            width = int(start_width + ((end_width - start_width) * eased))
            height = int(start_height + ((end_height - start_height) * eased))
            self.configure_position(width, height, surface_width=surface_width)
            if current_step >= steps:
                debug(f"shape-final width={end_width} height={end_height}")
                self.configure_position(end_width, end_height, surface_width=surface_width)
                self.shape_source = None
                if on_done is not None:
                    on_done()
                return GLib.SOURCE_REMOVE
            return GLib.SOURCE_CONTINUE

        self.shape_source = GLib.timeout_add(frame_ms, tick)

    def hide_window(self, animated=False):
        if self.window is not None:
            debug("hide-finish")
            self.show_generation += 1
            if animated:
                Gtk4LayerShell.set_keyboard_mode(self.window, Gtk4LayerShell.KeyboardMode.NONE)
                if self.header_revealer is not None:
                    self.header_revealer.set_transition_duration(100)
                    self.header_revealer.set_reveal_child(False)
                if self.content_revealer is not None:
                    self.content_revealer.set_transition_duration(140)
                    self.content_revealer.set_reveal_child(False)
                geometry = self.position_cache or self.read_monitor_geometry()
                self.position_cache = geometry
                _popup_x, _popup_y, target_width = self.compute_position(geometry=geometry)
                compact_width = self.compact_panel_width(target_width)
                compact_height = self.compact_panel_height()
                current_width = target_width
                current_height = self.current_panel_height()
                self.configure_position(current_width, current_height, surface_width=target_width)
                self.animate_shape(
                    current_width,
                    compact_width,
                    current_height,
                    compact_height,
                    require_open=False,
                    surface_width=target_width,
                    on_done=self.finish_hide_if_needed,
                )
                self.hide_source = GLib.timeout_add(360, self.finish_hide_if_needed)
                return GLib.SOURCE_REMOVE
            self.park_window()
        self.open_state = False
        self.hide_source = None
        return GLib.SOURCE_REMOVE

    def finish_hide_if_needed(self):
        self.hide_source = None
        if not self.open_state and self.window is not None:
            self.park_window(True)
        return GLib.SOURCE_REMOVE

    def on_close_request(self, *_args):
        self.toggle_visibility()
        return True

    def on_key_pressed(self, _controller, keyval, _keycode, _state):
        if keyval == Gdk.KEY_Escape:
            self.toggle_visibility()
            return True
        if keyval in (Gdk.KEY_1, Gdk.KEY_KP_1):
            self.set_tab("dashboard")
            return True
        if keyval in (Gdk.KEY_2, Gdk.KEY_KP_2):
            self.set_tab("media")
            return True
        if keyval in (Gdk.KEY_3, Gdk.KEY_KP_3):
            self.set_tab("actions")
            return True
        if keyval in (Gdk.KEY_4, Gdk.KEY_KP_4):
            self.set_tab("settings")
            return True
        if keyval in (Gdk.KEY_Right, Gdk.KEY_Down, Gdk.KEY_Tab):
            self.cycle_tab(1)
            return True
        if keyval in (Gdk.KEY_Left, Gdk.KEY_Up, Gdk.KEY_ISO_Left_Tab):
            self.cycle_tab(-1)
            return True
        return False

    def build_panel(self):
        panel = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        panel.add_css_class("shell-panel")

        header = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        header.add_css_class("shell-header")
        header.set_halign(Gtk.Align.CENTER)
        panel.append(header)

        bridge = Gtk.Label(label="")
        bridge.add_css_class("waybar-bridge")
        bridge.set_halign(Gtk.Align.CENTER)
        header.append(bridge)

        header_chrome = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        header_chrome.add_css_class("header-chrome")
        header_chrome.set_halign(Gtk.Align.CENTER)

        tabs = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        tabs.add_css_class("tab-rail")
        tabs.set_halign(Gtk.Align.CENTER)
        header_chrome.append(tabs)

        for key, label, tooltip in (
            ("dashboard", "󰎆", "Dashboard"),
            ("media", "", "Media"),
            ("actions", "󰣇", "Tools"),
            ("settings", "󰒓", "Settings"),
        ):
            button = Gtk.Button(label=label)
            button.add_css_class("tab-chip")
            button.set_tooltip_text(tooltip)
            button.connect("clicked", self.on_tab_clicked, key)
            tabs.append(button)
            self.tab_buttons[key] = button

        capsule = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        capsule.add_css_class("chrome-capsule")
        capsule.set_halign(Gtk.Align.CENTER)
        capsule.set_valign(Gtk.Align.CENTER)

        self.widgets["chrome_icon"] = Gtk.Label(label="󰎆")
        self.widgets["chrome_icon"].add_css_class("chrome-icon")
        capsule.append(self.widgets["chrome_icon"])

        chrome_copy = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        chrome_copy.add_css_class("chrome-copy")
        chrome_copy.set_valign(Gtk.Align.CENTER)

        self.widgets["chrome_title"] = Gtk.Label(label="Dashboard")
        self.widgets["chrome_title"].add_css_class("chrome-title")
        self.widgets["chrome_title"].set_halign(Gtk.Align.START)
        chrome_copy.append(self.widgets["chrome_title"])

        self.widgets["chrome_detail"] = Gtk.Label(label="media · calendar · desktop pulse")
        self.widgets["chrome_detail"].add_css_class("chrome-detail")
        self.widgets["chrome_detail"].set_halign(Gtk.Align.START)
        self.widgets["chrome_detail"].set_ellipsize(Pango.EllipsizeMode.END)
        self.widgets["chrome_detail"].set_max_width_chars(34)
        chrome_copy.append(self.widgets["chrome_detail"])

        capsule.append(chrome_copy)
        header_chrome.append(capsule)

        self.header_revealer = Gtk.Revealer()
        self.header_revealer.set_transition_type(Gtk.RevealerTransitionType.CROSSFADE)
        self.header_revealer.set_transition_duration(160)
        self.header_revealer.set_child(header_chrome)
        header.append(self.header_revealer)

        self.page_stack = Gtk.Stack()
        self.page_stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.page_stack.set_transition_duration(140)
        self.page_stack.set_hhomogeneous(False)
        self.page_stack.set_vhomogeneous(False)
        self.page_stack.set_vexpand(False)
        self.page_stack.add_named(self.create_dashboard_page(), "dashboard")
        self.page_stack.add_named(self.create_media_page(), "media")
        self.page_stack.add_named(self.create_actions_page(), "actions")
        self.page_stack.add_named(self.create_settings_page(), "settings")
        self.page_scroller = Gtk.ScrolledWindow()
        self.page_scroller.add_css_class("shell-scroller")
        self.page_scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self.page_scroller.set_propagate_natural_height(False)
        self.page_scroller.set_child(self.page_stack)
        self.content_revealer = Gtk.Revealer()
        self.content_revealer.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN)
        self.content_revealer.set_transition_duration(280)
        self.content_revealer.set_child(self.page_scroller)
        panel.append(self.content_revealer)
        self.set_tab(self.initial_tab)

        grip = Gtk.Label(label="━━━━")
        grip.add_css_class("shell-grip")
        grip.set_halign(Gtk.Align.CENTER)
        panel.append(grip)
        return panel

    def create_dashboard_page(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        page.add_css_class("shell-page")
        page.add_css_class("dashboard-page")
        page.set_size_request(470, -1)

        page.append(self.create_dashboard_hero_card())
        page.append(self.create_dashboard_media_card())

        content = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        content.add_css_class("dashboard-grid")
        page.append(content)

        status = self.create_status_card()
        status.add_css_class("dashboard-status-card")
        status.set_hexpand(True)
        content.append(status)

        signal = self.create_signal_card()
        signal.add_css_class("dashboard-signal-card")
        signal.set_hexpand(True)
        content.append(signal)

        return page

    def create_dashboard_hero_card(self):
        card = self.create_card("SIVERTEH LIVE")
        card.add_css_class("dashboard-hero-card")

        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        row.add_css_class("dashboard-hero-row")
        row.set_halign(Gtk.Align.FILL)

        time_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        time_box.set_hexpand(True)
        self.widgets["dash_time"] = Gtk.Label(label="--:--")
        self.widgets["dash_time"].add_css_class("dash-time")
        self.widgets["dash_time"].set_halign(Gtk.Align.START)
        time_box.append(self.widgets["dash_time"])

        self.widgets["dash_date"] = Gtk.Label(label="syncing date")
        self.widgets["dash_date"].add_css_class("dash-date")
        self.widgets["dash_date"].set_halign(Gtk.Align.START)
        time_box.append(self.widgets["dash_date"])
        row.append(time_box)

        signal_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        signal_box.add_css_class("dash-signal-box")
        signal_box.set_halign(Gtk.Align.END)
        self.widgets["dash_vibe"] = self.create_signal_chip("dash-vibe", "Glass / Cyber")
        signal_box.append(self.widgets["dash_vibe"])
        self.widgets["dash_workspace"] = Gtk.Label(label="1○  2○  3○")
        self.widgets["dash_workspace"].add_css_class("dash-workspace")
        self.widgets["dash_workspace"].set_halign(Gtk.Align.CENTER)
        signal_box.append(self.widgets["dash_workspace"])
        row.append(signal_box)

        card.append(row)
        return card

    def create_dashboard_media_card(self):
        card = self.create_card("ON AIR")
        card.add_css_class("dashboard-media-card")

        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        row.set_halign(Gtk.Align.FILL)

        orb = Gtk.Label(label="")
        orb.add_css_class("dash-media-orb")
        row.append(orb)

        copy = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        copy.set_hexpand(True)
        copy.set_valign(Gtk.Align.CENTER)

        self.widgets["dash_media_state"] = Gtk.Label(label="media")
        self.widgets["dash_media_state"].add_css_class("media-state")
        self.widgets["dash_media_state"].set_halign(Gtk.Align.START)
        copy.append(self.widgets["dash_media_state"])

        self.widgets["dash_track"] = Gtk.Label(label="No active media player")
        self.widgets["dash_track"].add_css_class("dash-track")
        self.widgets["dash_track"].set_halign(Gtk.Align.START)
        self.widgets["dash_track"].set_ellipsize(Pango.EllipsizeMode.END)
        self.widgets["dash_track"].set_max_width_chars(28)
        copy.append(self.widgets["dash_track"])

        self.widgets["dash_artist"] = Gtk.Label(label="MPRIS idle")
        self.widgets["dash_artist"].add_css_class("dash-artist")
        self.widgets["dash_artist"].set_halign(Gtk.Align.START)
        self.widgets["dash_artist"].set_ellipsize(Pango.EllipsizeMode.END)
        self.widgets["dash_artist"].set_max_width_chars(30)
        copy.append(self.widgets["dash_artist"])
        row.append(copy)

        controls = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        controls.set_halign(Gtk.Align.END)
        controls.set_valign(Gtk.Align.CENTER)
        controls.append(self.create_dashboard_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh previous"))
        self.widgets["dash_play"] = self.create_dashboard_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh play-pause")
        controls.append(self.widgets["dash_play"])
        controls.append(self.create_dashboard_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh next"))
        row.append(controls)

        card.append(row)

        self.widgets["dash_media_progress"] = Gtk.ProgressBar()
        self.widgets["dash_media_progress"].add_css_class("dash-media-progress")
        self.widgets["dash_media_progress"].set_fraction(0.0)
        card.append(self.widgets["dash_media_progress"])
        return card

    def create_media_page(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        page.add_css_class("shell-page")
        page.add_css_class("media-page")
        page.set_hexpand(True)
        page.set_size_request(470, 350)

        music = self.create_music_card()
        music.add_css_class("media-card")
        music.set_hexpand(True)
        page.append(music)
        return page

    def create_actions_page(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        page.add_css_class("shell-page")
        action_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        action_row.append(self.create_quick_actions_card())
        action_row.append(self.create_session_card())
        page.append(action_row)
        page.append(self.create_command_dock_card())
        return page

    def create_settings_page(self):
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        page.add_css_class("shell-page")
        page.add_css_class("settings-page")
        page.append(self.create_settings_overview_card())
        page.append(self.create_vibe_card())
        page.append(self.create_hyprland_settings_card())
        page.append(self.create_display_settings_card())
        page.append(self.create_bar_settings_card())
        page.append(self.create_system_settings_card())
        page.append(self.create_palette_card())
        return page

    def create_settings_overview_card(self):
        card = self.create_card("CONTROL CENTER")
        card.add_css_class("settings-overview-card")

        grid = Gtk.Grid()
        grid.add_css_class("settings-status-grid")
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        for index, (key, icon, title) in enumerate(
            (
                ("vibe", "󰔎", "Vibe"),
                ("bar", "󰌧", "Waybar"),
                ("hypr", "󰖯", "Hyprland"),
                ("display", "󰍹", "Display"),
            )
        ):
            tile = self.create_settings_status_tile(key, icon, title)
            grid.attach(tile, index % 2, index // 2, 1, 1)
        card.append(grid)

        dock = Gtk.Grid()
        dock.add_css_class("settings-command-grid")
        dock.set_column_spacing(8)
        dock.set_row_spacing(8)
        for index, (icon, label, command) in enumerate(
            (
                ("󱂬", "Full Hub", "~/.config/hypr/scripts/siverteh-hub.sh --page=settings"),
                ("󰸉", "Wallpaper", "~/.config/hypr/scripts/waypaper.sh"),
                ("󰍹", "Displays", "~/.config/hypr/scripts/monitor-rules.sh"),
                ("󰑐", "Reload", "hyprctl reload && ~/.config/waybar/launch.sh"),
            )
        ):
            button = self.create_action_tile(icon, label, command)
            button.add_css_class("overview-action-tile")
            dock.attach(button, index, 0, 1, 1)
        dock.set_halign(Gtk.Align.CENTER)
        card.append(dock)

        self.refresh_settings_overview()
        return card

    def create_settings_status_tile(self, key, icon, title):
        tile = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        tile.add_css_class("settings-status-tile")

        icon_label = Gtk.Label(label=icon)
        icon_label.add_css_class("settings-status-icon")
        icon_label.set_halign(Gtk.Align.CENTER)
        icon_label.set_valign(Gtk.Align.CENTER)
        tile.append(icon_label)

        copy = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=1)
        copy.set_valign(Gtk.Align.CENTER)
        copy.set_hexpand(True)

        title_label = Gtk.Label(label=title)
        title_label.add_css_class("settings-status-title")
        title_label.set_halign(Gtk.Align.START)
        copy.append(title_label)

        detail_label = Gtk.Label(label="syncing")
        detail_label.add_css_class("settings-status-detail")
        detail_label.set_halign(Gtk.Align.START)
        detail_label.set_ellipsize(Pango.EllipsizeMode.END)
        detail_label.set_max_width_chars(24)
        copy.append(detail_label)

        tile.append(copy)
        self.widgets[f"settings_{key}_detail"] = detail_label
        return tile

    def refresh_settings_overview(self):
        state = self.backend.load_state()
        appearance = state.get("appearance", {})
        bar = state.get("bar", {})
        hypr = state.get("hyprland", {})
        display = state.get("display_setup", {})

        vibe = normalize_vibe(appearance.get("vibe", "glass"))
        details = {
            "vibe": VIBE_LABELS.get(vibe, "Glass / Cyber"),
            "bar": (
                f"{bar.get('density', 'compact')} · "
                f"apps {'on' if bar.get('show_open_apps') else 'off'} · "
                f"stats {'on' if bar.get('show_stats') else 'off'}"
            ),
            "hypr": (
                f"{hypr.get('animation_preset', 'balanced')} · "
                f"blur {'on' if hypr.get('blur_enabled') else 'off'} · "
                f"gaps {hypr.get('gaps_in', '--')}/{hypr.get('gaps_out', '--')}"
            ),
            "display": (
                f"{display.get('mode', 'extend')} · "
                f"{display.get('workspace_layout', 'split')}"
            ),
        }

        for key, detail in details.items():
            widget = self.widgets.get(f"settings_{key}_detail")
            if widget is not None:
                widget.set_text(detail)

    def create_signal_card(self):
        card = self.create_card("SIGNAL")
        chip_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        chip_row.set_halign(Gtk.Align.CENTER)
        chip_row.append(self.create_signal_chip("shell", "⌬"))

        self.widgets["vibe"] = self.create_signal_chip("vibe", "Glass / Cyber")
        chip_row.append(self.widgets["vibe"])
        card.append(chip_row)

        self.widgets["time"] = Gtk.Label(label="")
        self.widgets["time"].add_css_class("shell-clock")
        self.widgets["time"].set_halign(Gtk.Align.CENTER)
        card.append(self.widgets["time"])

        self.widgets["workspace_radar"] = Gtk.Label(label="1○  2○  3○  4○  5○  6○")
        self.widgets["workspace_radar"].add_css_class("workspace-radar")
        self.widgets["workspace_radar"].set_halign(Gtk.Align.CENTER)
        card.append(self.widgets["workspace_radar"])

        self.widgets["focus"] = Gtk.Label(label="desktop radar syncing...")
        self.widgets["focus"].add_css_class("focus-line")
        self.widgets["focus"].set_halign(Gtk.Align.CENTER)
        self.widgets["focus"].set_wrap(True)
        self.widgets["focus"].set_justify(Gtk.Justification.CENTER)
        card.append(self.widgets["focus"])

        hint = Gtk.Label(label="wallpaper colors · glass blur · live shell")
        hint.add_css_class("status-line")
        hint.set_halign(Gtk.Align.CENTER)
        hint.set_wrap(True)
        card.append(hint)
        return card

    def create_signal_chip(self, name, label):
        chip = Gtk.Label(label=label)
        chip.add_css_class("signal-chip")
        chip.add_css_class(f"signal-{name}")
        chip.set_halign(Gtk.Align.CENTER)
        return chip

    def set_tab(self, tab):
        if not hasattr(self, "page_stack"):
            return
        self.current_tab = normalize_tab_name(tab)
        self.page_stack.set_visible_child_name(self.current_tab)
        for key, button in self.tab_buttons.items():
            if key == self.current_tab:
                button.add_css_class("selected")
            else:
                button.remove_css_class("selected")
        self.update_chrome()
        if self.window is not None and self.open_state:
            self.configure_position()
            self.write_shell_state(True)

    def on_tab_clicked(self, _button, tab):
        self.set_tab(tab)

    def cycle_tab(self, direction):
        try:
            current_index = TAB_ORDER.index(normalize_tab_name(self.current_tab))
        except ValueError:
            current_index = 0
        self.set_tab(TAB_ORDER[(current_index + direction) % len(TAB_ORDER)])

    def current_vibe_label(self):
        state = self.backend.load_state()
        current = normalize_vibe(state.get("appearance", {}).get("vibe", "glass"))
        return VIBE_LABELS.get(current, "Glass / Cyber")

    def default_chrome_detail(self, tab=None):
        tab = normalize_tab_name(tab or self.current_tab)
        if tab == "settings":
            return f"{self.current_vibe_label()} · wallpaper-reactive"
        return TAB_CHROME.get(tab, TAB_CHROME["dashboard"])[2]

    def update_chrome(self, detail=None):
        if not self.widgets:
            return
        tab = normalize_tab_name(self.current_tab)
        icon, title, _fallback = TAB_CHROME.get(tab, TAB_CHROME["dashboard"])
        detail = detail or self.chrome_details.get(tab) or self.default_chrome_detail(tab)

        if "chrome_icon" in self.widgets:
            self.widgets["chrome_icon"].set_text(icon)
        if "chrome_title" in self.widgets:
            self.widgets["chrome_title"].set_text(title)
        if "chrome_detail" in self.widgets:
            self.widgets["chrome_detail"].set_text(detail)

    def create_card(self, title_text):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        card.add_css_class("shell-card")
        title = Gtk.Label(label=title_text)
        title.add_css_class("card-title")
        title.set_halign(Gtk.Align.START)
        card.append(title)
        return card

    def create_music_card(self):
        card = self.create_card("NOW PLAYING")
        card.add_css_class("media-console")
        card.set_size_request(450, 330)

        hero = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=14)
        hero.add_css_class("media-hero")
        hero.set_halign(Gtk.Align.FILL)

        art_stack = Gtk.Stack()
        art_stack.add_css_class("media-art-stack")
        art_stack.set_size_request(82, 82)

        self.widgets["media_orb"] = Gtk.Label(label="")
        self.widgets["media_orb"].add_css_class("media-orb")
        self.widgets["media_orb"].set_halign(Gtk.Align.CENTER)
        self.widgets["media_orb"].set_valign(Gtk.Align.CENTER)
        art_stack.add_named(self.widgets["media_orb"], "fallback")

        self.widgets["media_art"] = Gtk.Picture()
        self.widgets["media_art"].add_css_class("media-art")
        self.widgets["media_art"].set_size_request(82, 82)
        art_stack.add_named(self.widgets["media_art"], "art")
        art_stack.set_visible_child_name("fallback")
        self.widgets["media_art_stack"] = art_stack
        hero.append(art_stack)

        media_copy = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        media_copy.add_css_class("media-copy")
        media_copy.set_hexpand(True)
        media_copy.set_valign(Gtk.Align.CENTER)

        self.widgets["media_state"] = Gtk.Label(label="MPRIS IDLE")
        self.widgets["media_state"].add_css_class("media-state")
        self.widgets["media_state"].set_halign(Gtk.Align.START)
        media_copy.append(self.widgets["media_state"])

        self.widgets["track"] = Gtk.Label(label="No active player")
        self.widgets["track"].add_css_class("music-title")
        self.widgets["track"].set_halign(Gtk.Align.START)
        self.widgets["track"].set_ellipsize(Pango.EllipsizeMode.END)
        self.widgets["track"].set_max_width_chars(34)
        media_copy.append(self.widgets["track"])

        self.widgets["artist"] = Gtk.Label(label="No active media source")
        self.widgets["artist"].add_css_class("media-artist")
        self.widgets["artist"].set_halign(Gtk.Align.START)
        self.widgets["artist"].set_ellipsize(Pango.EllipsizeMode.END)
        self.widgets["artist"].set_max_width_chars(38)
        media_copy.append(self.widgets["artist"])

        hero.append(media_copy)
        card.append(hero)

        self.widgets["media_progress"] = Gtk.ProgressBar()
        self.widgets["media_progress"].add_css_class("media-progress")
        self.widgets["media_progress"].set_fraction(0.0)
        card.append(self.widgets["media_progress"])

        timeline = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        timeline.add_css_class("media-timeline")
        self.widgets["elapsed"] = Gtk.Label(label="0:00")
        self.widgets["elapsed"].add_css_class("media-time")
        self.widgets["elapsed"].set_halign(Gtk.Align.START)
        timeline.append(self.widgets["elapsed"])

        self.widgets["duration"] = Gtk.Label(label="--:--")
        self.widgets["duration"].add_css_class("media-time")
        self.widgets["duration"].set_halign(Gtk.Align.END)
        self.widgets["duration"].set_hexpand(True)
        timeline.append(self.widgets["duration"])
        card.append(timeline)

        self.widgets["bars"] = Gtk.Label(label="▁▁▁▁▁▁▁▁▁▁▁▁▁▁")
        self.widgets["bars"].add_css_class("music-bars")
        self.widgets["bars"].set_halign(Gtk.Align.CENTER)
        card.append(self.widgets["bars"])

        meta = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        meta.add_css_class("media-meta-row")
        meta.set_halign(Gtk.Align.CENTER)
        for key, label in (
            ("media_player", "player --"),
            ("album", "album --"),
            ("volume", "vol --"),
        ):
            chip = Gtk.Label(label=label)
            chip.add_css_class("media-meta-chip")
            chip.set_ellipsize(Pango.EllipsizeMode.END)
            chip.set_max_width_chars(16)
            self.widgets[key] = chip
            meta.append(chip)
        card.append(meta)

        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        row.add_css_class("media-controls")
        row.set_halign(Gtk.Align.CENTER)
        row.append(self.create_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh previous"))
        self.widgets["play"] = self.create_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh play-pause")
        row.append(self.widgets["play"])
        row.append(self.create_icon_button("", "~/.config/hypr/scripts/waybar/music-control.sh next"))
        card.append(row)
        return card

    def create_quick_actions_card(self):
        card = self.create_card("QUICK SURFACES")
        grid = Gtk.Grid()
        grid.set_column_spacing(8)
        grid.set_row_spacing(6)
        actions = [
            ("󰀻", "Apps", "~/.config/hypr/scripts/launcher.sh"),
            ("󰸉", "Wall", "~/.config/hypr/scripts/waypaper.sh"),
            ("󰔎", "Shade", "~/.config/hypr/scripts/hyprshade.sh"),
            ("󰉋", "Files", self.read_setting("filemanager.sh", "nautilus --new-window")),
            ("󰒓", "Settings", "~/.config/hypr/scripts/siverteh-hub.sh --page=settings"),
            ("⏻", "Power", "~/.config/siverteh/core/scripts/wlogout.sh"),
        ]
        for index, (icon, label, command) in enumerate(actions):
            button = self.create_action_tile(icon, label, command)
            grid.attach(button, index % 2, index // 2, 1, 1)
        grid.set_halign(Gtk.Align.CENTER)
        card.append(grid)
        return card

    def create_session_card(self):
        card = self.create_card("SESSION FLOW")
        grid = Gtk.Grid()
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        actions = [
            ("󰑐", "Reload", "hyprctl reload"),
            ("󰖲", "Waybar", "~/.config/waybar/launch.sh"),
            ("󱂬", "Hub", "~/.config/hypr/scripts/siverteh-hub.sh --page=settings"),
            ("󰌾", "Lock", "hyprlock"),
            ("󰍹", "Displays", "~/.config/hypr/scripts/monitor-rules.sh"),
            ("󰏘", "Theme", "~/.config/hypr/scripts/waypaper.sh"),
        ]
        for index, (icon, label, command) in enumerate(actions):
            button = self.create_action_tile(icon, label, command)
            grid.attach(button, index % 2, index // 2, 1, 1)
        grid.set_halign(Gtk.Align.CENTER)
        card.append(grid)
        return card

    def create_command_dock_card(self):
        card = self.create_card("COMMAND DOCK")
        grid = Gtk.Grid()
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        actions = [
            ("󰄀", "Shot", "~/.config/hypr/scripts/screenshot.sh"),
            ("󰨞", "OCR", "~/.config/hypr/scripts/text-extractor.sh"),
            ("󰹑", "Float", "~/.config/hypr/scripts/toggleallfloat.sh"),
            ("󰚰", "Motion", "~/.config/hypr/scripts/toggle-animations.sh"),
        ]
        for index, (icon, label, command) in enumerate(actions):
            button = self.create_action_tile(icon, label, command)
            button.add_css_class("dock-tile")
            grid.attach(button, index, 0, 1, 1)
        grid.set_halign(Gtk.Align.CENTER)
        card.append(grid)
        return card

    def create_action_tile(self, icon, label, command):
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        content.set_halign(Gtk.Align.CENTER)
        content.set_valign(Gtk.Align.CENTER)

        icon_label = Gtk.Label(label=icon)
        icon_label.add_css_class("tile-icon")
        icon_label.set_halign(Gtk.Align.CENTER)
        content.append(icon_label)

        text = Gtk.Label(label=label)
        text.add_css_class("tile-label")
        text.set_halign(Gtk.Align.CENTER)
        content.append(text)

        button = Gtk.Button()
        button.set_child(content)
        button.add_css_class("action-tile")
        button.connect("clicked", self.run_shell_command, command)
        return button

    def create_status_card(self):
        card = self.create_card("SYSTEM PULSE")
        self.widgets["system"] = Gtk.Label(label="")
        self.widgets["system"].add_css_class("status-line")
        self.widgets["system"].set_halign(Gtk.Align.START)
        self.widgets["system"].set_wrap(True)
        card.append(self.widgets["system"])

        metric_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        metric_row.add_css_class("metric-row")
        metric_row.set_halign(Gtk.Align.FILL)
        for key, label in (
            ("metric_load", "load --"),
            ("metric_mem", "mem --"),
            ("metric_battery", "bat --"),
        ):
            metric = Gtk.Label(label=label)
            metric.add_css_class("metric-chip")
            metric.set_halign(Gtk.Align.FILL)
            metric.set_hexpand(True)
            self.widgets[key] = metric
            metric_row.append(metric)
        card.append(metric_row)

        calendar = Gtk.Calendar()
        calendar.add_css_class("shell-calendar")
        calendar.set_show_week_numbers(False)
        calendar.set_hexpand(True)
        card.append(calendar)
        return card

    def create_vibe_card(self):
        card = self.create_card("VIBE SWITCH")
        card.add_css_class("segment-card")
        grid = Gtk.Grid()
        grid.add_css_class("segment-grid")
        grid.set_column_spacing(6)
        grid.set_row_spacing(6)

        for index, (value, label) in enumerate(VIBE_OPTIONS):
            button = Gtk.Button(label=label)
            button.add_css_class("vibe-chip")
            button.connect("clicked", self.on_vibe_clicked, value)
            grid.attach(button, index % 3, index // 3, 1, 1)
            self.vibe_buttons[value] = button

        grid.set_halign(Gtk.Align.CENTER)
        card.append(grid)
        self.refresh_vibe_buttons()
        return card

    def create_bar_settings_card(self):
        card = self.create_card("BAR FEEL")
        card.add_css_class("segment-card")
        card.append(
            self.create_setting_row(
                "Density",
                [("Compact", "density", "compact"), ("Balanced", "density", "balanced")],
            )
        )
        card.append(
            self.create_setting_row(
                "Music",
                [("Mini", "music_display", "compact"), ("Full", "music_display", "full")],
            )
        )
        card.append(
            self.create_setting_row(
                "Apps",
                [("On", "show_open_apps", True), ("Off", "show_open_apps", False)],
            )
        )
        card.append(
            self.create_setting_row(
                "Outline",
                [("Glow", "pill_outline", True), ("Clean", "pill_outline", False)],
            )
        )
        card.append(
            self.create_setting_row(
                "Updates",
                [
                    ("Always", "updates_visibility", "always"),
                    ("Quiet", "updates_visibility", "pending"),
                ],
            )
        )
        card.append(
            self.create_setting_row(
                "Workspaces",
                [
                    ("Icons", "workspace_display", "icons"),
                    ("Numbers", "workspace_display", "numbers"),
                ],
            )
        )
        card.append(
            self.create_setting_row(
                "Stats",
                [("On", "show_stats", True), ("Off", "show_stats", False)],
            )
        )
        card.append(
            self.create_setting_row(
                "Clock",
                [("On", "show_clock", True), ("Off", "show_clock", False)],
            )
        )
        self.refresh_setting_buttons()
        return card

    def create_display_settings_card(self):
        card = self.create_card("DISPLAY FLOW")
        card.add_css_class("segment-card")
        card.append(
            self.create_display_setting_row(
                "Mode",
                [
                    ("Extend", "mode", "extend"),
                    ("Mirror", "mode", "mirror"),
                    ("Laptop", "mode", "laptop_only"),
                    ("External", "mode", "external_only"),
                ],
            )
        )
        card.append(
            self.create_display_setting_row(
                "Workspaces",
                [
                    ("Split", "workspace_layout", "split"),
                    ("Unified", "workspace_layout", "unified"),
                    ("Seq", "workspace_layout", "sequential"),
                ],
            )
        )
        self.refresh_display_buttons()
        return card

    def create_hyprland_settings_card(self):
        card = self.create_card("HYPRLAND FEEL")
        card.add_css_class("segment-card")
        card.append(
            self.create_hypr_setting_row(
                "Blur",
                [("On", "blur_enabled", True), ("Off", "blur_enabled", False)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Motion",
                [
                    ("Balanced", "animation_preset", "balanced"),
                    ("Lively", "animation_preset", "lively"),
                    ("Off", "animation_preset", "off"),
                ],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Corners",
                [("Sharp", "rounding", 4), ("Soft", "rounding", 14), ("Orb", "rounding", 26)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Gaps In",
                [("Tight", "gaps_in", 3), ("Air", "gaps_in", 7), ("Luxe", "gaps_in", 12)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Gaps Out",
                [("Tight", "gaps_out", 3), ("Float", "gaps_out", 8), ("Gallery", "gaps_out", 14)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Border",
                [("Hair", "border_size", 1), ("Glow", "border_size", 2), ("Frame", "border_size", 3)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Opacity",
                [
                    ("Deep", "inactive_opacity", 0.82),
                    ("Glass", "inactive_opacity", 0.90),
                    ("Solid", "inactive_opacity", 1.0),
                ],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Blur Size",
                [("Soft", "blur_size", 3), ("Glass", "blur_size", 5), ("Frost", "blur_size", 8)],
            )
        )
        card.append(
            self.create_hypr_setting_row(
                "Blur Pass",
                [("Lite", "blur_passes", 2), ("Smooth", "blur_passes", 4), ("Deep", "blur_passes", 6)],
            )
        )
        self.refresh_hypr_buttons()
        return card

    def create_system_settings_card(self):
        card = self.create_card("SYSTEM SURFACES")
        card.add_css_class("segment-card")
        grid = Gtk.Grid()
        grid.add_css_class("surface-grid")
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        actions = [
            ("󰸉", "Wallpaper", "~/.config/hypr/scripts/waypaper.sh"),
            ("󰍹", "Displays", "~/.config/hypr/scripts/monitor-rules.sh"),
            ("󰖲", "Waybar", "~/.config/waybar/launch.sh"),
            ("󰑐", "Hypr", "hyprctl reload"),
            ("󰉋", "Files", self.read_setting("filemanager.sh", "nautilus --new-window")),
            ("⏻", "Power", "~/.config/siverteh/core/scripts/wlogout.sh"),
        ]
        for index, (icon, label, command) in enumerate(actions):
            button = self.create_action_tile(icon, label, command)
            button.add_css_class("surface-tile")
            grid.attach(button, index % 3, index // 3, 1, 1)
        grid.set_halign(Gtk.Align.CENTER)
        card.append(grid)
        return card

    def create_palette_card(self):
        card = self.create_card("LIVE PALETTE")
        grid = Gtk.Grid()
        grid.set_column_spacing(8)
        grid.set_row_spacing(8)
        swatches = [
            ("Primary", "primary"),
            ("Secondary", "secondary"),
            ("Tertiary", "tertiary"),
            ("Surface", "surface"),
        ]
        for index, (label, class_name) in enumerate(swatches):
            swatch = Gtk.Label(label=label)
            swatch.add_css_class("palette-swatch")
            swatch.add_css_class(f"palette-{class_name}")
            swatch.set_halign(Gtk.Align.FILL)
            swatch.set_hexpand(True)
            grid.attach(swatch, index % 2, index // 2, 1, 1)
        card.append(grid)
        return card

    def create_setting_row(self, label, options):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        row.add_css_class("setting-row")

        row_label = Gtk.Label(label=label)
        row_label.add_css_class("setting-label")
        row_label.set_halign(Gtk.Align.START)
        row_label.set_hexpand(True)
        row.append(row_label)

        segments = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        segments.add_css_class("setting-segments")
        for option_label, key, value in options:
            button = Gtk.Button(label=option_label)
            button.add_css_class("setting-chip")
            button.connect("clicked", self.on_bar_setting_clicked, key, value)
            self.setting_buttons[(key, value)] = button
            segments.append(button)

        row.append(segments)
        return row

    def create_hypr_setting_row(self, label, options):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        row.add_css_class("setting-row")

        row_label = Gtk.Label(label=label)
        row_label.add_css_class("setting-label")
        row_label.set_halign(Gtk.Align.START)
        row_label.set_hexpand(True)
        row.append(row_label)

        segments = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        segments.add_css_class("setting-segments")
        for option_label, key, value in options:
            button = Gtk.Button(label=option_label)
            button.add_css_class("setting-chip")
            button.connect("clicked", self.on_hypr_setting_clicked, key, value)
            self.hypr_buttons[(key, value)] = button
            segments.append(button)

        row.append(segments)
        return row

    def create_display_setting_row(self, label, options):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        row.add_css_class("setting-row")

        row_label = Gtk.Label(label=label)
        row_label.add_css_class("setting-label")
        row_label.set_halign(Gtk.Align.START)
        row_label.set_hexpand(True)
        row.append(row_label)

        segments = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        segments.add_css_class("setting-segments")
        for option_label, key, value in options:
            button = Gtk.Button(label=option_label)
            button.add_css_class("setting-chip")
            button.connect("clicked", self.on_display_setting_clicked, key, value)
            self.display_buttons[(key, value)] = button
            segments.append(button)

        row.append(segments)
        return row

    def on_bar_setting_clicked(self, _button, key, value):
        self.backend.set_bar_setting(key, value)
        self.refresh_setting_buttons()
        self.refresh_settings_overview()
        self.chrome_details["settings"] = "Waybar surface applied"
        self.update_chrome()

    def on_hypr_setting_clicked(self, _button, key, value):
        self.backend.set_hyprland_setting(key, value)
        self.refresh_hypr_buttons()
        self.refresh_settings_overview()
        self.chrome_details["settings"] = "Hyprland feel applied"
        self.update_chrome()

    def on_display_setting_clicked(self, _button, key, value):
        self.backend.set_display_setup_setting(key, value)
        self.refresh_display_buttons()
        self.refresh_settings_overview()
        self.chrome_details["settings"] = "Display profile applied"
        self.update_chrome()

    def refresh_setting_buttons(self):
        state = self.backend.load_state().get("bar", {})
        for (key, value), button in self.setting_buttons.items():
            if state.get(key) == value:
                button.add_css_class("selected")
            else:
                button.remove_css_class("selected")

    def refresh_hypr_buttons(self):
        state = self.backend.load_state().get("hyprland", {})
        for (key, value), button in self.hypr_buttons.items():
            if state.get(key) == value:
                button.add_css_class("selected")
            else:
                button.remove_css_class("selected")

    def refresh_display_buttons(self):
        state = self.backend.load_state().get("display_setup", {})
        for (key, value), button in self.display_buttons.items():
            if state.get(key) == value:
                button.add_css_class("selected")
            else:
                button.remove_css_class("selected")

    def create_icon_button(self, label, command):
        button = Gtk.Button(label=label)
        button.add_css_class("transport-chip")
        button.connect("clicked", self.run_shell_command, command)
        return button

    def create_dashboard_icon_button(self, label, command):
        button = Gtk.Button(label=label)
        button.add_css_class("dash-transport-chip")
        button.connect("clicked", self.run_shell_command, command)
        return button

    def read_setting(self, name, fallback):
        path = Path.home() / ".config" / "siverteh" / "core" / "settings" / name
        try:
            value = path.read_text().strip()
        except OSError:
            return fallback
        return value or fallback

    def run_shell_command(self, _button, command):
        subprocess.Popen(["bash", "-lc", command], start_new_session=True)
        if command.endswith("launcher.sh") or "wlogout" in command:
            self.toggle_visibility()

    def on_vibe_clicked(self, _button, vibe):
        self.backend.set_appearance_setting("vibe", vibe)
        self.refresh_vibe_buttons()
        self.refresh_settings_overview()
        self.chrome_details["settings"] = f"{VIBE_LABELS.get(vibe, 'Glass / Cyber')} · applied"
        self.update_chrome()
        self.colors = load_colors()
        self.apply_css()
        self.write_shell_state(self.open_state)

    def refresh_vibe_buttons(self):
        state = self.backend.load_state()
        current = normalize_vibe(state.get("appearance", {}).get("vibe", "glass"))
        if "vibe" in self.widgets:
            self.widgets["vibe"].set_text(VIBE_LABELS.get(current, "Glass / Cyber"))
        for vibe, button in self.vibe_buttons.items():
            if vibe == current:
                button.add_css_class("selected")
            else:
                button.remove_css_class("selected")

    def query_music_payload(self, mode):
        script = self.repo_root / "hypr" / "scripts" / "waybar" / "music_status.py"
        try:
            output = subprocess.check_output(
                ["python3", str(script), mode],
                text=True,
                stderr=subprocess.DEVNULL,
                timeout=0.35,
            )
            payload = json.loads(output)
        except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
            payload = {}

        return {
            "text": payload.get("text") or "",
            "class": payload.get("class") or "idle",
            "tooltip": payload.get("tooltip") or "No active media player",
        }

    def active_player(self):
        players = [
            player.strip()
            for player in run("playerctl", "-l", timeout=0.25).stdout.splitlines()
            if player.strip()
        ]
        for wanted_status in ("Playing", "Paused"):
            for player in players:
                status = run(
                    "playerctl",
                    "-p",
                    player,
                    "status",
                    timeout=0.2,
                ).stdout.strip()
                if status == wanted_status:
                    return player, status.lower()
        if players:
            status = run(
                "playerctl",
                "-p",
                players[0],
                "status",
                timeout=0.2,
            ).stdout.strip()
            return players[0], (status or "stopped").lower()
        return "", "idle"

    def player_metadata(self, player, field):
        if not player:
            return ""
        return run(
            "playerctl",
            "-p",
            player,
            "metadata",
            field,
            timeout=0.25,
        ).stdout.strip()

    def format_seconds(self, seconds):
        try:
            seconds = max(0, int(float(seconds)))
        except (TypeError, ValueError):
            seconds = 0
        return f"{seconds // 60}:{seconds % 60:02d}"

    def audio_volume_text(self):
        output = run("wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@", timeout=0.25).stdout
        match = re.search(r"([0-9]*\.?[0-9]+)", output)
        if match:
            volume = round(float(match.group(1)) * 100)
            muted = " muted" if "MUTED" in output.upper() else ""
            return f"vol {volume}%{muted}"

        output = run("pactl", "get-sink-volume", "@DEFAULT_SINK@", timeout=0.25).stdout
        match = re.search(r"(\d+)%", output)
        if match:
            return f"vol {match.group(1)}%"
        return "vol --"

    def cache_artwork(self, art_url):
        if not art_url:
            return ""

        parsed = urllib.parse.urlparse(art_url)
        if parsed.scheme == "file":
            path = Path(urllib.parse.unquote(parsed.path))
            return str(path) if path.exists() else ""
        if parsed.scheme not in {"http", "https"}:
            path = Path(art_url)
            return str(path) if path.exists() else ""

        cache_dir = Path.home() / ".cache" / "siverteh" / "media-art"
        suffix = Path(parsed.path).suffix
        if suffix.lower() not in {".jpg", ".jpeg", ".png", ".webp"}:
            suffix = ".jpg"
        target = cache_dir / f"{hashlib.sha256(art_url.encode()).hexdigest()}{suffix}"
        if target.exists() and target.stat().st_size > 0:
            return str(target)

        try:
            cache_dir.mkdir(parents=True, exist_ok=True)
            with urllib.request.urlopen(art_url, timeout=0.8) as response:
                target.write_bytes(response.read(2_500_000))
            return str(target) if target.exists() and target.stat().st_size > 0 else ""
        except (OSError, ValueError):
            return ""

    def collect_media_detail(self, progress_payload):
        player, status = self.active_player()
        if not player:
            return {
                "media_state": "MPRIS IDLE",
                "track": "No active media player",
                "artist": "Open Spotify, browser media, or any MPRIS player",
                "album": "album --",
                "media_player": "player --",
                "volume": self.audio_volume_text(),
                "elapsed": "0:00",
                "duration": "--:--",
                "media_fraction": 0.0,
                "art_path": "",
            }

        title = self.player_metadata(player, "xesam:title")
        artist = self.player_metadata(player, "xesam:artist")
        album = self.player_metadata(player, "xesam:album")
        art_path = self.cache_artwork(self.player_metadata(player, "mpris:artUrl"))
        if not title:
            tooltip = progress_payload.get("tooltip", "")
            if " - " in tooltip:
                artist_hint, title_hint = tooltip.split(" - ", 1)
                artist = artist or artist_hint
                title = title_hint
            else:
                title = tooltip or "Unknown track"

        position_output = run("playerctl", "-p", player, "position", timeout=0.25).stdout.strip()
        length_output = self.player_metadata(player, "mpris:length")
        try:
            position = max(0.0, float(position_output or 0))
        except ValueError:
            position = 0.0
        try:
            length = max(0.0, float(length_output or 0) / 1_000_000)
        except ValueError:
            length = 0.0
        fraction = 0.0 if length <= 0 else max(0.0, min(1.0, position / length))

        status_label = status.upper() if status else "MPRIS"
        player_label = re.sub(r"\.instance\d+$", "", player)
        return {
            "media_state": f"{status_label} VIA MPRIS",
            "track": self.truncate_label(title, 48),
            "artist": self.truncate_label(artist or player_label, 48),
            "album": self.truncate_label(f"album {album}" if album else "album --", 22),
            "media_player": self.truncate_label(f"player {player_label}", 20),
            "volume": self.audio_volume_text(),
            "elapsed": self.format_seconds(position),
            "duration": self.format_seconds(length) if length > 0 else "--:--",
            "media_fraction": fraction,
            "art_path": art_path,
        }

    def battery_text(self):
        batteries = sorted(Path("/sys/class/power_supply").glob("BAT*"))
        if not batteries:
            return "battery n/a"
        battery = batteries[0]
        try:
            capacity = (battery / "capacity").read_text().strip()
            status = (battery / "status").read_text().strip().lower()
        except OSError:
            return "battery n/a"
        return f"{capacity}% {status}"

    def memory_text(self):
        try:
            data = {}
            for line in Path("/proc/meminfo").read_text().splitlines():
                key, value = line.split(":", 1)
                data[key] = int(value.strip().split()[0])
            total = data.get("MemTotal", 1)
            available = data.get("MemAvailable", 0)
            used = max(0, total - available)
            return f"mem {round((used / total) * 100)}%"
        except (OSError, ValueError, ZeroDivisionError):
            return "mem n/a"

    def network_text(self):
        output = run(
            "nmcli",
            "-t",
            "-f",
            "TYPE,STATE,CONNECTION",
            "device",
            "status",
            timeout=0.35,
        ).stdout
        for line in output.splitlines():
            parts = line.split(":")
            if len(parts) >= 3 and parts[1].startswith("connected"):
                label = "wifi" if parts[0] == "wifi" else parts[0]
                return f"{label} {parts[2] or 'connected'}"
        return "network offline"

    def truncate_label(self, value, limit=42):
        compact = re.sub(r"\s+", " ", value or "").strip()
        if len(compact) <= limit:
            return compact
        return compact[: max(0, limit - 1)].rstrip() + "…"

    def safe_int(self, value, fallback=0):
        try:
            return int(value)
        except (TypeError, ValueError):
            return fallback

    def desktop_radar_payload(self):
        try:
            workspace = json.loads(
                run("hyprctl", "-j", "activeworkspace", timeout=0.35).stdout.strip()
                or "{}"
            )
        except json.JSONDecodeError:
            workspace = {}

        try:
            active_window = json.loads(
                run("hyprctl", "-j", "activewindow", timeout=0.35).stdout.strip()
                or "{}"
            )
        except json.JSONDecodeError:
            active_window = {}

        try:
            clients = json.loads(
                run("hyprctl", "-j", "clients", timeout=0.5).stdout.strip() or "[]"
            )
        except json.JSONDecodeError:
            clients = []

        active_id = self.safe_int(workspace.get("id"), 0)
        counts = {index: 0 for index in range(1, 7)}
        total_clients = 0

        for client in clients if isinstance(clients, list) else []:
            workspace_id = self.safe_int(client.get("workspace", {}).get("id"), -1)
            if (
                not client.get("mapped")
                or client.get("hidden")
                or workspace_id <= 0
            ):
                continue
            total_clients += 1
            if workspace_id in counts:
                counts[workspace_id] += 1

        tokens = []
        for index in range(1, 7):
            count = counts.get(index, 0)
            if index == active_id:
                marker = "◉" if count else "◎"
            elif count >= 3:
                marker = "◆"
            elif count:
                marker = "●"
            else:
                marker = "○"
            tokens.append(f"{index}{marker}")

        title = (
            active_window.get("title")
            or active_window.get("class")
            or active_window.get("initialClass")
            or ""
        )
        active_label = self.truncate_label(title, 30)
        if active_label:
            focus = f"ws {active_id or '-'} · {total_clients} clients\n{active_label}"
        else:
            focus = f"ws {active_id or '-'} · {total_clients} clients\ndesktop"

        return {
            "workspace_radar": "  ".join(tokens),
            "focus": focus,
        }

    def update_runtime(self):
        if not self.widgets or not self.open_state or self.runtime_pending:
            return GLib.SOURCE_CONTINUE
        self.runtime_pending = True
        threading.Thread(
            target=self.collect_runtime_payload,
            args=(self.show_generation,),
            daemon=True,
        ).start()
        return GLib.SOURCE_CONTINUE

    def collect_runtime_payload(self, generation):
        try:
            progress = self.query_music_payload("progress-cache")
            play_icon = self.query_music_payload("play-icon")
            media = self.collect_media_detail(progress)
            track = media["track"]

            load = os.getloadavg()[0] if hasattr(os, "getloadavg") else 0.0
            load_text = f"load {load:.2f}"
            memory_text = self.memory_text()
            battery_text = self.battery_text()
            network_text = self.network_text()
            desktop = self.desktop_radar_payload()
            focus_line = self.truncate_label(desktop["focus"].replace("\n", " · "), 42)
            if track == "No active media player":
                media_chrome = "media idle · transport ready"
            else:
                media_chrome = self.truncate_label(f"{media['artist']} · {track}", 42)
            payload = {
                "time": datetime.now().strftime("%H:%M  %a %d"),
                "dash_time": datetime.now().strftime("%H:%M"),
                "dash_date": datetime.now().strftime("%A · %d %B"),
                "track": track,
                "artist": media["artist"],
                "media_state": media["media_state"],
                "bars": progress["text"] or "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
                "play": play_icon["text"] or "",
                "album": media["album"],
                "media_player": media["media_player"],
                "volume": media["volume"],
                "elapsed": media["elapsed"],
                "duration": media["duration"],
                "media_fraction": media["media_fraction"],
                "art_path": media["art_path"],
                "system": network_text,
                "metric_load": load_text,
                "metric_mem": memory_text,
                "metric_battery": battery_text,
                "workspace_radar": desktop["workspace_radar"],
                "focus": desktop["focus"],
                "chrome_details": {
                    "dashboard": focus_line,
                    "media": media_chrome,
                    "actions": focus_line,
                    "settings": f"{self.current_vibe_label()} · live Matugen",
                },
            }
        except Exception:
            payload = {
                "time": datetime.now().strftime("%H:%M  %a %d"),
                "dash_time": datetime.now().strftime("%H:%M"),
                "dash_date": datetime.now().strftime("%A · %d %B"),
                "track": "No active media player",
                "artist": "media bridge unavailable",
                "media_state": "MPRIS UNAVAILABLE",
                "bars": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
                "play": "",
                "album": "album --",
                "media_player": "player --",
                "volume": "vol --",
                "elapsed": "0:00",
                "duration": "--:--",
                "media_fraction": 0.0,
                "art_path": "",
                "system": "pulse unavailable",
                "metric_load": "load --",
                "metric_mem": "mem --",
                "metric_battery": "bat --",
                "workspace_radar": "1○  2○  3○  4○  5○  6○",
                "focus": "desktop radar unavailable",
                "chrome_details": {
                    "dashboard": "desktop radar unavailable",
                    "media": "media idle · transport ready",
                    "actions": "desktop radar unavailable",
                    "settings": "wallpaper-reactive vibes",
                },
            }
        GLib.idle_add(self.apply_runtime_payload, payload, generation)

    def apply_runtime_payload(self, payload, generation):
        self.runtime_pending = False
        if not self.widgets or generation != self.show_generation or not self.open_state:
            return GLib.SOURCE_REMOVE
        self.widgets["time"].set_text(payload["time"])
        self.widgets["track"].set_text(payload["track"])
        self.widgets["bars"].set_text(payload["bars"])
        self.widgets["play"].set_label(payload["play"])
        for key in ("dash_time", "dash_date", "dash_track", "dash_artist", "dash_media_state"):
            if key in self.widgets:
                source_key = {
                    "dash_track": "track",
                    "dash_artist": "artist",
                    "dash_media_state": "media_state",
                }.get(key, key)
                self.widgets[key].set_text(payload.get(source_key, ""))
        if "dash_play" in self.widgets:
            self.widgets["dash_play"].set_label(payload["play"])
        for key in ("artist", "media_state", "album", "media_player", "volume", "elapsed", "duration"):
            if key in self.widgets:
                self.widgets[key].set_text(payload.get(key, ""))
        if "media_progress" in self.widgets:
            self.widgets["media_progress"].set_fraction(
                max(0.0, min(1.0, float(payload.get("media_fraction", 0.0))))
            )
        if "dash_media_progress" in self.widgets:
            self.widgets["dash_media_progress"].set_fraction(
                max(0.0, min(1.0, float(payload.get("media_fraction", 0.0))))
            )
        if "media_art_stack" in self.widgets:
            art_path = payload.get("art_path", "")
            if art_path and Path(art_path).exists():
                self.widgets["media_art"].set_filename(art_path)
                self.widgets["media_art_stack"].set_visible_child_name("art")
            else:
                self.widgets["media_art_stack"].set_visible_child_name("fallback")
        self.widgets["system"].set_text(payload["system"])
        for key in ("metric_load", "metric_mem", "metric_battery"):
            if key in self.widgets:
                self.widgets[key].set_text(payload.get(key, "--"))
        if "workspace_radar" in self.widgets:
            self.widgets["workspace_radar"].set_text(payload["workspace_radar"])
        if "dash_workspace" in self.widgets:
            self.widgets["dash_workspace"].set_text(payload["workspace_radar"])
        if "dash_vibe" in self.widgets:
            self.widgets["dash_vibe"].set_text(self.current_vibe_label())
        if "focus" in self.widgets:
            self.widgets["focus"].set_text(payload["focus"])
        self.chrome_details.update(payload.get("chrome_details", {}))
        self.update_chrome()
        return GLib.SOURCE_REMOVE

    def render_shell_vibe_css(self, vibe, c, accent, accent_2, style):
        if vibe == "minimal":
            return f"""
            .shell-panel {{
                background: alpha({c['surface']}, 0.88);
                border-radius: 10px;
                border-color: alpha({c['outline']}, 0.18);
                box-shadow: none;
            }}

            .tab-rail {{
                background: alpha({c['surface_container_highest']}, 0.28);
                border-color: alpha({c['outline']}, 0.16);
                border-radius: 8px;
                padding: 3px;
                box-shadow: none;
            }}

            .tab-chip,
            .tab-chip.selected,
            .tab-rail,
            .chrome-capsule,
            .shell-card,
            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card,
            .settings-status-tile,
            .settings-status-icon,
            .transport-chip,
            .action-tile,
            .overview-action-tile,
            .vibe-chip,
            .setting-chip,
            .media-meta-chip,
            .metric-chip,
            .signal-chip,
            .workspace-radar,
            .setting-segments,
            .palette-swatch {{
                border-radius: 8px;
                box-shadow: none;
            }}

            .tab-chip.selected,
            .vibe-chip.selected,
            .setting-chip.selected,
            .transport-chip:hover,
            .action-tile:hover {{
                color: {c['on_primary']};
                background: alpha({accent}, 0.78);
                border-color: alpha({accent}, 0.36);
            }}

            .chrome-capsule,
            .shell-card {{
                background: alpha({c['surface_container']}, 0.34);
                border-color: alpha({c['outline']}, 0.10);
            }}

            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card {{
                background: alpha({c['surface_container_high']}, 0.28);
            }}

            progressbar.media-progress progress {{
                background: alpha({accent}, 0.82);
                box-shadow: none;
            }}
            """
        if vibe == "neon":
            return f"""
            .shell-panel {{
                background:
                    radial-gradient(circle at 16% 0%, alpha({accent}, 0.38), transparent 36%),
                    radial-gradient(circle at 84% 4%, alpha({accent_2}, 0.30), transparent 32%),
                    alpha({c['background']}, 0.92);
                border-radius: 34px;
                border-color: alpha({accent}, 0.62);
                box-shadow:
                    0 0 0 1px alpha({accent_2}, 0.28),
                    0 0 38px alpha({accent}, 0.36),
                    0 18px 44px alpha({c['shadow']}, 0.26);
            }}

            .tab-rail,
            .chrome-capsule,
            .shell-card,
            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card,
            .settings-status-tile {{
                background:
                    radial-gradient(circle at 18% 0%, alpha({accent_2}, 0.20), transparent 42%),
                    alpha({c['background']}, 0.58);
                border-color: alpha({accent}, 0.36);
                box-shadow:
                    0 0 20px alpha({accent}, 0.18),
                    inset 0 1px 0 alpha({c['on_surface']}, 0.08);
            }}

            .tab-rail {{
                padding: 5px;
                border-radius: 999px;
                box-shadow:
                    0 0 0 1px alpha({accent_2}, 0.18),
                    0 0 26px alpha({accent}, 0.22);
            }}

            .tab-chip,
            .settings-status-icon,
            .transport-chip,
            .action-tile,
            .overview-action-tile,
            .vibe-chip,
            .setting-chip,
            .media-meta-chip,
            .metric-chip,
            .signal-chip,
            .workspace-radar {{
                background: alpha({c['background']}, 0.44);
                border-color: alpha({accent}, 0.30);
                box-shadow: 0 0 14px alpha({accent}, 0.16);
            }}

            .tab-chip.selected,
            .vibe-chip.selected,
            .setting-chip.selected {{
                color: {c['on_surface']};
                background:
                    radial-gradient(circle at 35% 20%, alpha({c['on_surface']}, 0.22), transparent 28%),
                    linear-gradient(135deg, alpha({accent_2}, 0.86), alpha({accent}, 0.96));
                box-shadow:
                    0 0 18px alpha({accent}, 0.42),
                    0 0 34px alpha({accent_2}, 0.22);
            }}

            .card-title,
            .media-state,
            .tile-icon {{
                text-shadow: 0 0 12px alpha({accent}, 0.55);
            }}

            progressbar.media-progress trough {{
                background: alpha({c['background']}, 0.60);
                border-color: alpha({accent}, 0.40);
            }}

            progressbar.media-progress progress {{
                background: linear-gradient(90deg, alpha({accent_2}, 0.98), alpha({accent}, 0.98));
                box-shadow: 0 0 20px alpha({accent}, 0.58);
            }}
            """
        if vibe == "nordic":
            return f"""
            .shell-panel {{
                background: alpha({c['surface_container_highest']}, 0.86);
                border-radius: 3px;
                border-color: alpha({accent}, 0.36);
                box-shadow:
                    0 10px 22px alpha({c['shadow']}, 0.12),
                    inset 0 0 0 1px alpha({c['on_surface']}, 0.04),
                    inset 0 -2px 0 alpha({accent}, 0.58);
            }}

            .tab-chip,
            .tab-rail,
            .chrome-capsule,
            .shell-card,
            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card,
            .settings-status-tile,
            .settings-status-icon,
            .transport-chip,
            .action-tile,
            .overview-action-tile,
            .vibe-chip,
            .setting-chip,
            .media-meta-chip,
            .metric-chip,
            .signal-chip,
            .workspace-radar,
            .setting-segments,
            .palette-swatch {{
                border-radius: 2px;
                box-shadow: none;
            }}

            .shell-card,
            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card,
            .settings-status-tile,
            .chrome-capsule,
            .tab-rail {{
                background: alpha({c['surface_container']}, 0.46);
                border-color: alpha({accent}, 0.22);
            }}

            .tab-chip.selected,
            .vibe-chip.selected,
            .setting-chip.selected,
            .transport-chip:hover,
            .action-tile:hover {{
                color: {c['on_surface']};
                background: alpha({accent}, 0.34);
                border-color: alpha({accent}, 0.72);
            }}

            .card-title,
            .media-state,
            .metric-chip,
            .workspace-radar,
            .chrome-title,
            .chrome-detail,
            .tile-label,
            .setting-label {{
                font-family: "JetBrainsMono Nerd Font", monospace;
            }}

            progressbar.media-progress trough {{
                border-radius: 2px;
            }}

            progressbar.media-progress progress {{
                border-radius: 2px;
                background: alpha({accent}, 0.82);
                box-shadow: none;
            }}
            """
        if vibe == "custom":
            return f"""
            .shell-panel {{
                background:
                    radial-gradient(circle at 11% 8%, alpha({accent}, 0.48), transparent 30%),
                    radial-gradient(circle at 90% 16%, alpha({accent_2}, 0.40), transparent 34%),
                    radial-gradient(circle at 50% 116%, alpha({c['tertiary']}, 0.34), transparent 44%),
                    linear-gradient(160deg, alpha({c['surface_container_highest']}, 0.78), alpha({c['background']}, 0.62));
                border-radius: 38px 16px 38px 22px;
                border-color: alpha({accent}, 0.64);
                box-shadow:
                    0 0 0 1px alpha({accent_2}, 0.22),
                    0 0 42px alpha({accent}, 0.34),
                    0 26px 60px alpha({c['shadow']}, 0.28);
            }}

            .tab-rail {{
                padding: 6px;
                border-radius: 26px 10px 26px 10px;
                background:
                    radial-gradient(circle at 20% 0%, alpha({accent}, 0.32), transparent 38%),
                    linear-gradient(90deg, alpha({c['surface_container_highest']}, 0.46), alpha({c['surface_container']}, 0.26));
                border-color: alpha({accent}, 0.46);
                box-shadow: 0 0 28px alpha({accent}, 0.28);
            }}

            .tab-chip,
            .chrome-capsule,
            .shell-card,
            .dashboard-hero-card,
            .dashboard-media-card,
            .media-card,
            .settings-overview-card,
            .settings-status-tile,
            .settings-status-icon,
            .transport-chip,
            .action-tile,
            .overview-action-tile,
            .vibe-chip,
            .setting-chip,
            .media-meta-chip,
            .metric-chip,
            .signal-chip,
            .workspace-radar,
            .setting-segments,
            .palette-swatch {{
                border-color: alpha({accent}, 0.34);
                box-shadow:
                    0 0 18px alpha({accent}, 0.18),
                    inset 0 1px 0 alpha({c['on_surface']}, 0.08);
            }}

            .tab-chip,
            .transport-chip,
            .vibe-chip,
            .setting-chip {{
                border-radius: 20px 8px 20px 8px;
            }}

            .action-tile,
            .shell-card {{
                border-radius: 22px 9px 22px 12px;
            }}

            .dashboard-hero-card {{
                background:
                    radial-gradient(circle at 12% 0%, alpha({accent}, 0.42), transparent 44%),
                    radial-gradient(circle at 92% 20%, alpha({accent_2}, 0.32), transparent 38%),
                    alpha({c['surface_container_highest']}, 0.34);
            }}

            .dashboard-media-card,
            .media-card,
            .settings-overview-card {{
                background:
                    radial-gradient(circle at 20% 18%, alpha({accent_2}, 0.26), transparent 40%),
                    radial-gradient(circle at 82% 92%, alpha({c['tertiary']}, 0.24), transparent 42%),
                    alpha({c['surface_container']}, 0.28);
            }}

            .tab-chip.selected,
            .vibe-chip.selected,
            .setting-chip.selected {{
                color: {c['on_surface']};
                background:
                    radial-gradient(circle at 26% 18%, alpha({c['on_surface']}, 0.22), transparent 26%),
                    linear-gradient(135deg, alpha({accent}, 0.92), alpha({accent_2}, 0.82));
                box-shadow:
                    0 0 26px alpha({accent}, 0.40),
                    0 0 42px alpha({accent_2}, 0.24);
            }}

            progressbar.media-progress progress {{
                background:
                    linear-gradient(90deg, alpha({accent}, 0.98), alpha({accent_2}, 0.90), alpha({c['tertiary']}, 0.82));
                box-shadow: 0 0 22px alpha({accent}, 0.42);
            }}
            """
        return f"""
            .shell-panel {{
                background:
                    radial-gradient(circle at 50% 0%, alpha({accent}, 0.10), transparent 42%),
                    linear-gradient(180deg, alpha({c['surface_container_highest']}, {style['panel_top']}), alpha({c['surface_container_high']}, {style['panel_bottom']}));
            }}

        """

    def apply_css(self):
        c = self.colors
        state = self.backend.load_state()
        vibe = normalize_vibe(state.get("appearance", {}).get("vibe", "glass"))
        style = SHELL_VIBE_STYLE.get(vibe, SHELL_VIBE_STYLE["glass"])
        accent = c.get(style["accent"], c["primary_fixed"])
        accent_2 = c.get(style["accent_2"], c["secondary"])
        vibe_css = self.render_shell_vibe_css(vibe, c, accent, accent_2, style)
        panel_radius = style["panel_radius"]
        card_radius = style["card_radius"]
        css = f"""
        window.shell-window,
        window.shell-window.background,
        .shell-window,
        .shell-window.background,
        window.shell-window > contents,
        window.shell-window.background > contents,
        window.shell-window contents,
        window.shell-window > contents > box,
        window.shell-window box.shell-root,
        window.shell-window .shell-root,
        window.shell-window .shell-parking,
        window {{
            background: transparent;
            background-color: transparent;
            background-image: none;
            border: none;
            box-shadow: none;
            outline: none;
        }}

        .shell-root {{
            background: transparent;
            padding: 0;
        }}

        .shell-parking,
        window.shell-window > contents,
        window.shell-window.background > contents,
        window.shell-window contents,
        window.shell-window > contents > box,
        window.shell-window revealer,
        window.shell-window revealer > box,
        window.shell-window viewport,
        window.shell-window viewport.frame,
        window.shell-window viewport > box,
        window.shell-window stack,
        window.shell-window stack > box,
        window.shell-window scrolledwindow,
        window.shell-window .background {{
            background: transparent;
            background-color: transparent;
            background-image: none;
        }}

        .shell-panel {{
            background: linear-gradient(180deg, alpha({c['surface_container_highest']}, {style['panel_top']}), alpha({c['surface_container_high']}, {style['panel_bottom']}));
            border: 1px solid alpha({accent}, {style['panel_border']});
            border-radius: 24px 24px {panel_radius}px {panel_radius}px;
            box-shadow:
                0 12px 24px alpha({c['shadow']}, {style['panel_shadow']}),
                0 0 24px alpha({accent}, {style['panel_glow']}),
                inset 0 -1px 0 alpha({accent}, 0.10);
            border-top-color: transparent;
            margin-top: -1px;
            padding: 7px 11px 8px 11px;
        }}

        .shell-header {{
            min-height: 0;
        }}

        .header-chrome {{
            background: transparent;
        }}

        .waybar-bridge {{
            background: transparent;
            border-radius: 999px;
            min-width: 0;
            min-height: 0;
            margin: 0;
            box-shadow: none;
        }}

        .shell-page {{
            background: transparent;
        }}

        .dashboard-page,
        .media-page {{
            padding-top: 1px;
        }}

        .dashboard-grid {{
            background: transparent;
        }}

        .dashboard-grid .shell-card {{
            min-width: 0;
            padding: 8px;
        }}

        .dashboard-hero-card {{
            min-height: 86px;
            background:
                radial-gradient(circle at 18% 0%, alpha({accent}, {style['hero_halo']}), transparent 42%),
                radial-gradient(circle at 90% 10%, alpha({accent_2}, 0.16), transparent 36%),
                linear-gradient(135deg, alpha({c['surface_container_highest']}, {style['card_top']}), alpha({c['surface']}, {style['card_bottom']}));
        }}

        .dashboard-hero-row {{
            margin-top: -2px;
        }}

        .dash-time {{
            color: {c['on_surface']};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 30px;
            font-weight: 900;
        }}

        .dash-date {{
            color: {c['on_surface_variant']};
            font-size: 10px;
            font-weight: 900;
        }}

        .dash-signal-box {{
            background: alpha({c['surface_container']}, {style['signal_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 16px;
            padding: 6px;
            min-width: 138px;
        }}

        .dash-workspace {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 9px;
            font-weight: 900;
        }}

        .dashboard-media-card {{
            min-height: 108px;
            background:
                radial-gradient(circle at 12% 20%, alpha({accent_2}, 0.18), transparent 38%),
                linear-gradient(180deg, alpha({c['surface_container_high']}, {style['card_top']}), alpha({c['surface']}, {style['card_bottom']}));
        }}

        .dash-media-orb {{
            color: {c['on_primary']};
            background:
                radial-gradient(circle at 35% 30%, alpha({c['on_primary']}, 0.68), transparent 18%),
                radial-gradient(circle at 50% 50%, alpha({accent_2}, 0.36), alpha({accent}, 0.84) 72%);
            border: 1px solid alpha({accent}, {style['hover_border']});
            border-radius: 999px;
            min-width: 46px;
            min-height: 46px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 18px;
            font-weight: 900;
            box-shadow: 0 0 18px alpha({accent}, {style['panel_glow']});
        }}

        .dash-track {{
            color: {c['on_surface']};
            font-size: 13px;
            font-weight: 900;
        }}

        .dash-artist {{
            color: {c['on_surface_variant']};
            font-size: 9px;
            font-weight: 800;
        }}

        .dash-transport-chip {{
            color: {c['on_surface']};
            background: alpha({c['surface_container_highest']}, {style['button_alpha']});
            border: 1px solid alpha({c['outline']}, {style['button_border']});
            border-radius: 999px;
            min-width: 28px;
            min-height: 28px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 10px;
            font-weight: 900;
        }}

        .dash-transport-chip:hover {{
            color: {c['on_primary']};
            background: linear-gradient(135deg, alpha({accent}, {style['selected_alpha']}), alpha({accent_2}, {style['selected_alpha_2']}));
            border-color: alpha({accent}, {style['hover_border']});
        }}

        progressbar.dash-media-progress {{
            min-height: 5px;
            padding: 0;
            margin-top: 6px;
        }}

        progressbar.dash-media-progress trough {{
            background: alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            min-height: 4px;
        }}

        progressbar.dash-media-progress progress {{
            background: linear-gradient(90deg, alpha({accent}, 0.94), alpha({accent_2}, 0.72));
            border-radius: 999px;
            min-height: 4px;
            box-shadow: 0 0 14px alpha({accent}, {style['panel_glow']});
        }}

        scrolledwindow.shell-scroller {{
            background: transparent;
            border: 0;
        }}

        scrolledwindow.shell-scroller viewport,
        scrolledwindow.shell-scroller viewport.frame,
        scrolledwindow.shell-scroller undershoot,
        scrolledwindow.shell-scroller overshoot,
        scrolledwindow.shell-scroller contents {{
            background: transparent;
            background-color: transparent;
            background-image: none;
            border: 0;
            box-shadow: none;
        }}

        scrolledwindow.shell-scroller scrollbar {{
            opacity: 0.0;
            min-width: 0;
            min-height: 0;
        }}

        .tab-rail {{
            background: alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 4px;
            min-height: 28px;
        }}

        .tab-chip {{
            color: {c['on_surface_variant']};
            background: transparent;
            border: 0;
            border-radius: 999px;
            min-width: 42px;
            min-height: 26px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 13px;
            font-weight: 900;
        }}

        .tab-chip:hover,
        .tab-chip.selected {{
            color: {c['on_primary']};
            background: linear-gradient(135deg, alpha({accent}, {style['selected_alpha']}), alpha({accent_2}, {style['selected_alpha_2']}));
        }}

        .chrome-capsule {{
            background:
                radial-gradient(circle at 15% 50%, alpha({accent}, {style['hero_halo']}), transparent 46%),
                alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 4px 12px;
            min-width: 244px;
            min-height: 28px;
            box-shadow:
                0 8px 20px alpha({accent}, {style['panel_glow']}),
                inset 0 1px 0 alpha({c['on_surface']}, 0.05);
        }}

        .chrome-icon {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 13px;
            font-weight: 900;
            min-width: 22px;
        }}

        .chrome-copy {{
            min-width: 0;
        }}

        .chrome-title {{
            color: {c['on_surface']};
            font-size: 9px;
            font-weight: 900;
        }}

        .chrome-detail {{
            color: {c['on_surface_variant']};
            font-size: 8px;
            font-weight: 800;
        }}

        .palette-rail {{
            padding: 1px 2px;
        }}

        .palette-rail-swatch {{
            border-radius: 999px;
            min-width: 34px;
            min-height: 4px;
            box-shadow: 0 0 10px alpha({accent}, {style['panel_glow']});
        }}

        .rail-primary {{
            background: linear-gradient(90deg, alpha({c['primary']}, 0.95), alpha({c['primary_fixed']}, 0.76));
        }}

        .rail-secondary {{
            background: linear-gradient(90deg, alpha({c['secondary']}, 0.92), alpha({c['secondary_container']}, 0.70));
        }}

        .rail-tertiary {{
            background: linear-gradient(90deg, alpha({c['tertiary']}, 0.88), alpha({c['primary_container']}, 0.68));
        }}

        .rail-surface {{
            background: linear-gradient(90deg, alpha({c['surface_container_highest']}, 0.86), alpha({c['surface_container']}, 0.62));
            border: 1px solid alpha({accent}, {style['rail_border']});
        }}

        .shell-title {{
            color: {c['on_surface']};
            font-size: 18px;
            font-weight: 900;
        }}

        .shell-subtitle,
        .status-line {{
            color: {c['on_surface_variant']};
            font-size: 11px;
            font-weight: 700;
        }}

        .metric-row {{
            margin-top: 1px;
            margin-bottom: 1px;
        }}

        .metric-chip {{
            color: {accent};
            background: alpha({c['surface_container']}, {style['signal_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 5px 6px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 9px;
            font-weight: 900;
        }}

        .shell-clock {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 14px;
            font-weight: 900;
            padding: 7px 12px;
            border-radius: 999px;
            background: alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
        }}

        .shell-card {{
            background:
                linear-gradient(180deg, alpha({c['surface_container']}, {style['card_top']}), alpha({c['surface']}, {style['card_bottom']}));
            border: 1px solid alpha({c['outline']}, {style['card_border']});
            border-radius: {card_radius}px;
            padding: 10px;
            min-height: 92px;
        }}

        .segment-card {{
            background:
                linear-gradient(180deg, alpha({c['surface_container']}, {style['card_top']}), alpha({c['surface']}, {style['card_bottom']}));
        }}

        .media-card {{
            min-width: 450px;
            min-height: 318px;
            background:
                radial-gradient(circle at 50% 0%, alpha({accent}, {style['hero_halo']}), transparent 52%),
                linear-gradient(180deg, alpha({c['surface_container_high']}, {style['panel_bottom']}), alpha({c['surface']}, {style['card_top']}));
        }}

        .media-console {{
            padding: 14px;
        }}

        .media-hero {{
            margin-bottom: 8px;
        }}

        .media-art-stack,
        .media-orb,
        .media-art {{
            border-radius: 999px;
            min-width: 82px;
            min-height: 82px;
        }}

        .media-art-stack {{
            background: alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['hover_border']});
            box-shadow:
                0 0 24px alpha({accent}, {style['panel_glow']}),
                inset 0 1px 0 alpha({c['on_surface']}, 0.12);
        }}

        .media-orb {{
            color: {c['on_primary']};
            background:
                radial-gradient(circle at 35% 28%, alpha({c['on_primary']}, 0.70), transparent 18%),
                radial-gradient(circle at 50% 50%, alpha({accent_2}, 0.45), alpha({accent}, 0.92) 72%);
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 27px;
            font-weight: 900;
        }}

        .media-art {{
            background: alpha({c['surface_container_highest']}, {style['button_alpha']});
        }}

        .media-copy {{
            min-width: 0;
        }}

        .media-state {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 10px;
            font-weight: 900;
        }}

        .card-title {{
            color: {accent};
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 0.08em;
        }}

        .music-title {{
            color: {c['on_surface']};
            font-size: 17px;
            font-weight: 900;
        }}

        .media-artist {{
            color: {c['on_surface_variant']};
            font-size: 12px;
            font-weight: 800;
        }}

        progressbar.media-progress {{
            min-height: 8px;
            padding: 0;
        }}

        progressbar.media-progress trough {{
            background: alpha({c['surface_container']}, {style['rail_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            min-height: 7px;
        }}

        progressbar.media-progress progress {{
            background: linear-gradient(90deg, alpha({accent}, 0.96), alpha({accent_2}, 0.76));
            border-radius: 999px;
            min-height: 7px;
            box-shadow: 0 0 18px alpha({accent}, {style['panel_glow']});
        }}

        .media-timeline {{
            margin-top: -4px;
            margin-bottom: -2px;
        }}

        .media-time {{
            color: {c['on_surface_variant']};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 9px;
            font-weight: 900;
        }}

        .music-bars {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 18px;
            font-weight: 900;
            margin-top: 4px;
        }}

        .media-meta-row {{
            margin-top: 2px;
        }}

        .media-meta-chip {{
            color: {c['on_surface_variant']};
            background: alpha({c['surface_container']}, {style['signal_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 4px 7px;
            font-size: 9px;
            font-weight: 900;
        }}

        .transport-chip,
        .action-chip,
        .action-tile,
        .vibe-chip,
        .setting-chip {{
            color: {c['on_surface']};
            background: alpha({c['surface_container_highest']}, {style['button_alpha']});
            border: 1px solid alpha({c['outline']}, {style['button_border']});
            border-radius: {card_radius + 2}px;
            min-height: 34px;
            font-weight: 800;
        }}

        .transport-chip {{
            border-radius: 999px;
            min-width: 72px;
            min-height: 42px;
            font-size: 15px;
        }}

        .media-controls {{
            margin-top: 4px;
        }}

        .action-tile {{
            min-width: 64px;
            min-height: 56px;
            padding: 6px;
        }}

        .dock-tile {{
            min-width: 92px;
        }}

        .surface-tile {{
            min-width: 94px;
            min-height: 58px;
        }}

        .vibe-chip,
        .setting-chip {{
            border-radius: 999px;
            min-width: 84px;
            min-height: 30px;
        }}

        .settings-page .vibe-chip {{
            min-width: 76px;
            min-height: 28px;
            padding-left: 8px;
            padding-right: 8px;
            font-size: 10px;
        }}

        .settings-page .setting-chip {{
            min-width: 64px;
            min-height: 28px;
            padding-left: 7px;
            padding-right: 7px;
            font-size: 10px;
        }}

        .tile-icon {{
            color: {accent};
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 20px;
            font-weight: 900;
        }}

        .tile-label,
        .setting-label {{
            color: {c['on_surface_variant']};
            font-size: 10px;
            font-weight: 900;
        }}

        .setting-row {{
            padding: 2px 1px;
        }}

        .setting-segments {{
            background: alpha({c['surface_container']}, {style['card_bottom']});
            border: 1px solid alpha({c['outline']}, {style['card_border']});
            border-radius: 999px;
            padding: 2px;
        }}

        .settings-page .setting-row {{
            padding: 2px 0;
        }}

        .settings-page .setting-label {{
            min-width: 58px;
            font-size: 9px;
        }}

        .settings-page .setting-segments {{
            padding: 2px;
        }}

        .settings-overview-card {{
            min-height: 142px;
            background:
                radial-gradient(circle at 18% 0%, alpha({accent}, {style['hero_halo']}), transparent 44%),
                radial-gradient(circle at 86% 14%, alpha({accent_2}, 0.15), transparent 38%),
                linear-gradient(180deg, alpha({c['surface_container_high']}, {style['card_top']}), alpha({c['surface']}, {style['card_bottom']}));
        }}

        .settings-status-grid,
        .settings-command-grid {{
            background: transparent;
        }}

        .settings-status-tile {{
            background: alpha({c['surface_container']}, {style['signal_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: {max(8, card_radius)}px;
            padding: 7px;
            min-width: 198px;
            min-height: 44px;
        }}

        .settings-status-icon {{
            color: {accent};
            background: alpha({c['surface_container_highest']}, {style['button_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            min-width: 30px;
            min-height: 30px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 15px;
            font-weight: 900;
        }}

        .settings-status-title {{
            color: {c['on_surface']};
            font-size: 10px;
            font-weight: 900;
        }}

        .settings-status-detail {{
            color: {c['on_surface_variant']};
            font-size: 9px;
            font-weight: 800;
        }}

        .overview-action-tile {{
            min-width: 88px;
            min-height: 48px;
        }}

        .palette-swatch {{
            color: {c['on_primary']};
            border-radius: 14px;
            min-height: 32px;
            min-width: 170px;
            padding: 6px;
            font-weight: 900;
            border: 1px solid alpha({accent}, {style['panel_border']});
        }}

        .palette-primary {{
            background: linear-gradient(135deg, alpha({c['primary']}, 0.96), alpha({c['primary_fixed']}, 0.76));
        }}

        .palette-secondary {{
            background: linear-gradient(135deg, alpha({c['secondary']}, 0.92), alpha({c['secondary_container']}, 0.78));
        }}

        .palette-tertiary {{
            background: linear-gradient(135deg, alpha({c['tertiary']}, 0.88), alpha({c['primary_container']}, 0.76));
        }}

        .palette-surface {{
            color: {c['on_surface']};
            background: linear-gradient(135deg, alpha({c['surface_container_highest']}, 0.86), alpha({c['surface_container']}, 0.72));
        }}

        .transport-chip:hover,
        .action-chip:hover,
        .action-tile:hover,
        .vibe-chip:hover,
        .vibe-chip.selected,
        .setting-chip:hover,
        .setting-chip.selected {{
            color: {c['on_primary']};
            background: linear-gradient(135deg, alpha({accent}, {style['selected_alpha']}), alpha({accent_2}, {style['selected_alpha_2']}));
            border-color: alpha({accent}, {style['hover_border']});
        }}

        .signal-chip {{
            color: {accent};
            background: alpha({c['surface_container']}, {style['signal_alpha']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 6px 10px;
            font-weight: 900;
        }}

        .signal-shell {{
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 18px;
            min-width: 24px;
        }}

        .signal-vibe {{
            font-size: 11px;
        }}

        .workspace-radar {{
            color: {accent};
            background: alpha({c['surface_container']}, {style['card_bottom']});
            border: 1px solid alpha({accent}, {style['rail_border']});
            border-radius: 999px;
            padding: 7px 11px;
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 12px;
            font-weight: 900;
        }}

        .focus-line {{
            color: {c['on_surface_variant']};
            font-size: 10px;
            font-weight: 800;
        }}

        .now-symbol {{
            color: {accent};
            font-size: 24px;
            font-weight: 900;
            padding-top: 8px;
        }}

        calendar.shell-calendar {{
            color: {c['on_surface']};
            background: alpha({c['surface_container_high']}, {style['card_top']});
            border: 1px solid alpha({c['outline']}, {style['card_border']});
            border-radius: {card_radius}px;
            padding: 8px;
        }}

        calendar.shell-calendar header {{
            color: {accent};
            background: transparent;
        }}

        calendar.shell-calendar button {{
            color: {c['on_surface']};
            background: transparent;
            border-radius: 10px;
        }}

        calendar.shell-calendar button:hover {{
            background: alpha({accent}, {style['hero_halo']});
        }}

        {vibe_css}

        .waybar-bridge {{
            background: transparent;
            min-width: 0;
            min-height: 0;
            margin: 0;
            box-shadow: none;
        }}

        .shell-grip {{
            color: alpha({accent}, {style['selected_alpha_2']});
            font-size: 10px;
        }}
        """

        self.provider.load_from_data(css.encode())
        if not self.provider_installed:
            Gtk.StyleContext.add_provider_for_display(
                Gdk.Display.get_default(),
                self.provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER,
            )
            self.provider_installed = True


if __name__ == "__main__":
    daemon_mode = "--daemon" in sys.argv[1:]
    app = SivertehShell(daemon_mode=daemon_mode, initial_tab=parse_initial_tab(sys.argv))
    sys.exit(app.run([sys.argv[0]]))
