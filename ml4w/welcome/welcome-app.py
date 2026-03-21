#!/usr/bin/env python3
"""
Siverteh OS
"""

import json
import re
import subprocess
from pathlib import Path

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")

from gi.repository import Adw, Gdk, Gio, GLib, Gtk, Pango

from settings_backend import SivertehSettingsBackend


class HubWindow(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Siverteh OS")

        self.set_default_size(940, 790)
        self.connect("close-request", self.on_close_request)

        style_manager = Adw.StyleManager.get_default()
        style_manager.set_color_scheme(Adw.ColorScheme.FORCE_DARK)

        self.repo_root = Path(__file__).resolve().parents[2]
        self.settings_dir = Path.home() / ".config" / "ml4w" / "settings"
        self.settings_backend = SivertehSettingsBackend(self.repo_root)
        self.settings_state = self.settings_backend.ensure_state()
        self.css_provider = Gtk.CssProvider()
        self.css_provider_added = False
        self.color_monitors = []
        self.theme_refresh_source = None
        self.color_signature = ""
        self.settings_signal_block = False
        self.pending_display_change = None
        self.display_revert_source = None
        self.display_dialog = None
        self.display_widgets = {}
        self.colors = self.load_colors()
        self.system_info = self.load_system_info()
        self.defaults = self.load_defaults()
        self.apply_css()
        self.build_interface()
        self.setup_color_watchers()
        self.color_signature = self.compute_color_signature()
        GLib.timeout_add(900, self.poll_for_theme_changes)

    def on_close_request(self, *_args):
        if self.pending_display_change is not None:
            self.cancel_pending_display_change(rebuild=False)
        app = self.get_application()
        if app is not None:
            GLib.idle_add(app.quit)
        return False

    def parse_waybar_colors(self, colors):
        colors_file = Path.home() / ".config" / "waybar" / "colors.css"
        if not colors_file.exists():
            return colors

        try:
            content = colors_file.read_text()
        except OSError:
            return colors

        token_map = {
            "background": "background",
            "surface": "surface",
            "surface_container": "surface_container",
            "surface_container_high": "surface_container_high",
            "primary": "primary",
            "primary_fixed": "primary_fixed",
            "primary_container": "primary_container",
            "secondary": "secondary",
            "tertiary": "tertiary",
            "on_primary": "on_primary",
            "on_surface": "on_surface",
            "on_surface_variant": "on_surface_variant",
            "outline": "outline",
        }

        for source_name, key in token_map.items():
            match = re.search(rf"@define-color\s+{re.escape(source_name)}\s+([^;]+);", content)
            if match:
                colors[key] = match.group(1).strip()

        return colors

    def load_colors(self):
        colors = {
            "background": "#110f18",
            "surface": "#161320",
            "surface_container": "#201b2b",
            "surface_container_high": "#2a2237",
            "primary": "#d0a7ff",
            "primary_fixed": "#f2d8ff",
            "primary_container": "#6f5091",
            "secondary": "#c6b2dd",
            "tertiary": "#ff8ab5",
            "on_primary": "#231332",
            "on_surface": "#f4eefb",
            "on_surface_variant": "#c8bdd8",
            "outline": "#7d7090",
        }

        colors = self.parse_waybar_colors(colors)

        colors_file = Path.home() / ".config" / "rofi" / "colors.rasi"
        if not colors_file.exists():
            return self.load_direct_colors(colors)

        try:
            content = colors_file.read_text()
        except OSError:
            return self.load_direct_colors(colors)

        token_map = {
            "background": "background",
            "surface": "surface",
            "surface-container": "surface_container",
            "surface-container-high": "surface_container_high",
            "primary": "primary",
            "primary-fixed": "primary_fixed",
            "primary-container": "primary_container",
            "secondary": "secondary",
            "tertiary": "tertiary",
            "on-primary": "on_primary",
            "on-surface": "on_surface",
            "on-surface-variant": "on_surface_variant",
            "outline": "outline",
        }

        for source_name, key in token_map.items():
            match = re.search(rf"{re.escape(source_name)}:\s*([^;]+);", content)
            if match:
                colors[key] = match.group(1).strip()

        return self.load_direct_colors(colors)

    def load_direct_colors(self, colors):
        direct_color_files = {
            "primary": "primary",
            "secondary": "secondary",
            "onsurface": "on_surface",
        }

        for filename, key in direct_color_files.items():
            path = Path.home() / ".config" / "ml4w" / "colors" / filename
            if not path.exists():
                continue
            try:
                value = path.read_text().strip()
            except OSError:
                continue
            if value:
                colors[key] = value

        return colors

    def setup_color_watchers(self):
        watched_paths = [
            Path.home() / ".config" / "waybar",
            Path.home() / ".config" / "rofi",
            Path.home() / ".config" / "ml4w" / "colors",
        ]

        for path in watched_paths:
            if not path.exists():
                continue
            try:
                monitor = Gio.File.new_for_path(str(path)).monitor_directory(Gio.FileMonitorFlags.NONE, None)
            except Exception:
                continue
            monitor.connect("changed", self.on_color_file_changed)
            self.color_monitors.append(monitor)

    def on_color_file_changed(self, *_args):
        if self.theme_refresh_source is not None:
            return
        self.theme_refresh_source = GLib.timeout_add(150, self.refresh_theme)

    def compute_color_signature(self):
        watched_files = [
            Path.home() / ".config" / "waybar" / "colors.css",
            Path.home() / ".config" / "rofi" / "colors.rasi",
            Path.home() / ".config" / "ml4w" / "colors" / "primary",
            Path.home() / ".config" / "ml4w" / "colors" / "secondary",
            Path.home() / ".config" / "ml4w" / "colors" / "onsurface",
        ]

        signature_parts = []
        for path in watched_files:
            try:
                signature_parts.append(path.read_text())
            except OSError:
                signature_parts.append("")
        return "|".join(signature_parts)

    def poll_for_theme_changes(self):
        current_signature = self.compute_color_signature()
        if current_signature != self.color_signature:
            self.color_signature = current_signature
            self.refresh_theme()
        return GLib.SOURCE_CONTINUE

    def refresh_theme(self):
        self.theme_refresh_source = None
        updated = self.load_colors()
        self.color_signature = self.compute_color_signature()
        if updated == self.colors:
            return GLib.SOURCE_REMOVE

        current_page = None
        if hasattr(self, "stack") and self.stack is not None:
            current_page = self.stack.get_visible_child_name()

        self.colors = updated
        self.apply_css()
        self.build_interface(current_page)
        self.queue_draw()
        return GLib.SOURCE_REMOVE

    def load_system_info(self):
        distro = "Linux"
        os_release = Path("/etc/os-release")
        if os_release.exists():
            for line in os_release.read_text().splitlines():
                if line.startswith("PRETTY_NAME="):
                    distro = line.split("=", 1)[1].strip().strip('"')
                    break

        return {
            "brand": "Siverteh OS",
            "host": subprocess.getoutput("hostname"),
            "user": Path.home().name,
            "distro": distro,
            "session": "Hyprland Dynamic Glass",
            "repo": str(self.repo_root),
        }

    def read_setting(self, name, fallback):
        path = self.settings_dir / name
        if not path.exists():
            return fallback

        try:
            value = path.read_text().strip()
        except OSError:
            return fallback

        return value or fallback

    def pretty_command(self, command):
        mapping = {
            "google-chrome-stable": "Google Chrome",
            "kitty": "Kitty",
            "nautilus --new-window": "Nautilus",
            "evolution": "Evolution",
            "code": "VS Code",
            "cursor": "Cursor",
        }
        return mapping.get(command, command)

    def load_defaults(self):
        return {
            "Browser": self.pretty_command(self.read_setting("browser.sh", "google-chrome-stable")),
            "Terminal": self.pretty_command(self.read_setting("terminal.sh", "kitty")),
            "File Manager": self.pretty_command(self.read_setting("filemanager.sh", "nautilus --new-window")),
            "Mail": self.pretty_command(self.read_setting("email.sh", "evolution")),
            "Editor": self.pretty_command(self.read_setting("editor.sh", "code")),
        }

    def apply_css(self):
        css = f"""
        window {{
            background:
                radial-gradient(circle at top, alpha({self.colors['primary']}, 0.28), transparent 36%),
                linear-gradient(180deg, alpha({self.colors['background']}, 0.98), alpha({self.colors['surface']}, 0.98));
        }}

        .hub-header {{
            margin-top: 24px;
            margin-bottom: 10px;
        }}

        .logo-box {{
            background: transparent;
            min-width: 0;
            min-height: 0;
            border-radius: 0;
            border: none;
            box-shadow: none;
        }}

        .logo-text {{
            font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
            line-height: 0.9;
            margin-bottom: -6px;
        }}

        .title-text {{
            color: {self.colors['on_surface']};
            font-size: 29px;
            font-weight: 800;
            letter-spacing: 0.04em;
        }}

        .subtitle-text {{
            color: {self.colors['on_surface_variant']};
            font-size: 13px;
        }}

        stackswitcher button {{
            color: {self.colors['on_surface_variant']};
            background: alpha({self.colors['surface_container']}, 0.72);
            border-radius: 999px;
            padding: 8px 16px;
            margin: 0 4px;
            border: 1px solid alpha({self.colors['outline']}, 0.35);
        }}

        stackswitcher button:checked {{
            color: {self.colors['on_primary']};
            background: linear-gradient(135deg, alpha({self.colors['primary']}, 0.92), alpha({self.colors['tertiary']}, 0.72));
        }}

        .page {{
            margin: 0 22px 22px 22px;
        }}

        .card {{
            background:
                radial-gradient(circle at top left, alpha({self.colors['primary']}, 0.2), alpha({self.colors['surface_container_high']}, 0.94) 56%, alpha({self.colors['surface']}, 0.96));
            border: 1px solid alpha({self.colors['primary_fixed']}, 0.24);
            border-radius: 24px;
            padding: 20px;
            box-shadow: 0 14px 30px alpha(black, 0.18);
        }}

        .card-title {{
            color: {self.colors['primary_fixed']};
            font-size: 13px;
            font-weight: 800;
            letter-spacing: 0.06em;
        }}

        .card-value {{
            color: {self.colors['on_surface']};
            font-size: 18px;
            font-weight: 700;
            margin-top: 8px;
        }}

        .card-muted {{
            color: {self.colors['on_surface_variant']};
            font-size: 12px;
            margin-top: 4px;
        }}

        .workspace-card {{
            min-width: 250px;
            min-height: 120px;
        }}

        .workspace-number {{
            color: {self.colors['primary_fixed']};
            font-size: 28px;
            font-weight: 900;
        }}

        .workspace-name {{
            color: {self.colors['on_surface']};
            font-size: 17px;
            font-weight: 700;
        }}

        .workspace-desc,
        .workspace-hint,
        .section-subtle {{
            color: {self.colors['on_surface_variant']};
            font-size: 12px;
        }}

        .section-heading {{
            color: {self.colors['primary_fixed']};
            font-size: 16px;
            font-weight: 800;
            margin-bottom: 10px;
        }}

        .keybind-item {{
            background: alpha({self.colors['surface_container']}, 0.72);
            border-radius: 18px;
            padding: 12px 14px;
            margin-bottom: 8px;
        }}

        .keybind-key {{
            background: alpha({self.colors['primary_container']}, 0.56);
            color: {self.colors['primary_fixed']};
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 800;
        }}

        .keybind-action {{
            color: {self.colors['on_surface']};
            font-size: 12px;
        }}

        .action-button {{
            background: alpha({self.colors['surface_container_high']}, 0.9);
            border-radius: 22px;
            border: 1px solid alpha({self.colors['primary_fixed']}, 0.22);
            padding: 18px;
        }}

        .action-button:hover {{
            background: alpha({self.colors['primary_container']}, 0.7);
        }}

        .action-title {{
            color: {self.colors['on_surface']};
            font-size: 15px;
            font-weight: 700;
        }}

        .action-subtitle {{
            color: {self.colors['on_surface_variant']};
            font-size: 11px;
        }}
        """

        self.css_provider.load_from_data(css.encode())
        if not self.css_provider_added:
            Gtk.StyleContext.add_provider_for_display(
                Gdk.Display.get_default(),
                self.css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
            )
            self.css_provider_added = True

    def build_interface(self, current_page=None):
        self.settings_state = self.settings_backend.load_state()
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.set_content(root)

        root.append(self.create_header())

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
        self.stack.set_transition_duration(220)

        switcher = Gtk.StackSwitcher()
        switcher.set_stack(self.stack)
        switcher.set_halign(Gtk.Align.CENTER)
        switcher.set_margin_top(4)
        switcher.set_margin_bottom(12)
        switcher.add_css_class("hub-switcher")

        root.append(switcher)
        root.append(self.stack)

        self.add_overview_page()
        self.add_workspaces_page()
        self.add_keybindings_page()
        self.add_actions_page()
        self.add_settings_page()

        if current_page:
            self.stack.set_visible_child_name(current_page)

    def create_header(self):
        header = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        header.add_css_class("hub-header")
        header.set_halign(Gtk.Align.CENTER)

        logo_box = Gtk.CenterBox()
        logo_box.add_css_class("logo-box")
        logo_box.set_halign(Gtk.Align.CENTER)
        logo_box.set_valign(Gtk.Align.CENTER)

        logo = Gtk.Label()
        logo.add_css_class("logo-text")
        logo.set_use_markup(True)
        logo.set_justify(Gtk.Justification.CENTER)
        logo.set_markup(self.build_logo_markup())
        self.logo_label = logo
        logo_box.set_center_widget(logo)

        title = Gtk.Label(label="Siverteh OS")
        title.add_css_class("title-text")

        subtitle = Gtk.Label(
            label=f"{self.system_info['distro']} • {self.system_info['session']}"
        )
        subtitle.add_css_class("subtitle-text")

        header.append(logo_box)
        header.append(title)
        header.append(subtitle)
        return header

    def build_logo_markup(self):
        primary = self.colors["primary"]
        secondary = self.colors["secondary"]

        lines = [
            ("████████╗  ", "██╗  ██╗"),
            ("██╔═════╝  ", "██║  ██║"),
            ("██║        ", "██║  ██║"),
            ("██║        ", "██║  ██║"),
            ("███████╗   ", "███████║"),
            ("╚════██║   ", "██╔══██║"),
            ("     ██║   ", "██║  ██║"),
            ("     ██║   ", "██║  ██║"),
            ("███████║   ", "██║  ██║"),
            ("╚══════╝   ", "╚═╝  ╚═╝"),
        ]

        return "\n".join(
            f'<span font_family="JetBrainsMono Nerd Font" weight="900" size="12600" foreground="{primary}">{left}</span>'
            f'<span font_family="JetBrainsMono Nerd Font" weight="900" size="12600" foreground="{secondary}">{right}</span>'
            for left, right in lines
        )

    def create_scrolled_page(self):
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        box.add_css_class("page")
        scroll.set_child(box)
        return scroll, box

    def create_card(self, title, value, subtitle):
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        card.add_css_class("card")

        title_label = Gtk.Label(label=title)
        title_label.add_css_class("card-title")
        title_label.set_halign(Gtk.Align.START)

        value_label = Gtk.Label(label=value)
        value_label.add_css_class("card-value")
        value_label.set_halign(Gtk.Align.START)
        value_label.set_wrap(True)

        subtitle_label = Gtk.Label(label=subtitle)
        subtitle_label.add_css_class("card-muted")
        subtitle_label.set_halign(Gtk.Align.START)
        subtitle_label.set_wrap(True)

        card.append(title_label)
        card.append(value_label)
        card.append(subtitle_label)
        return card

    def add_overview_page(self):
        scroll, page = self.create_scrolled_page()

        hero = self.create_card(
            "SESSION",
            self.system_info["session"],
            "A personal Hyprland environment tuned for browser, code, chat, music, and mail.",
        )
        page.append(hero)

        system_grid = Gtk.FlowBox()
        system_grid.set_selection_mode(Gtk.SelectionMode.NONE)
        system_grid.set_column_spacing(14)
        system_grid.set_row_spacing(14)
        system_grid.set_max_children_per_line(2)
        system_grid.set_homogeneous(True)

        system_grid.append(
            self.create_card("HOST", self.system_info["host"], "Local machine hostname")
        )
        system_grid.append(
            self.create_card("DISTRO", self.system_info["distro"], "Wallpaper-reactive dynamic glass palette")
        )
        system_grid.append(
            self.create_card("DOTFILES", "Siverteh Dynamic Glass", self.system_info["repo"])
        )
        system_grid.append(
            self.create_card("PROFILE", "Daily Workspace Flow", "Workspace 1 browser, 2 code, 3 Discord, 4 Spotify, 5 mail")
        )

        page.append(system_grid)

        defaults_heading = Gtk.Label(label="Current Defaults")
        defaults_heading.add_css_class("section-heading")
        defaults_heading.set_halign(Gtk.Align.START)
        page.append(defaults_heading)

        defaults_grid = Gtk.FlowBox()
        defaults_grid.set_selection_mode(Gtk.SelectionMode.NONE)
        defaults_grid.set_column_spacing(14)
        defaults_grid.set_row_spacing(14)
        defaults_grid.set_max_children_per_line(2)
        defaults_grid.set_homogeneous(True)

        for label, value in self.defaults.items():
            defaults_grid.append(self.create_card(label, value, "Loaded from your personal command defaults"))

        page.append(defaults_grid)
        self.stack.add_titled(scroll, "overview", "Overview")

    def add_workspaces_page(self):
        scroll, page = self.create_scrolled_page()

        info = Gtk.Label(label="The bar shows six fixed workspace pills. The daily profile fills 1-5 and leaves 6 open for misc or system tools.")
        info.add_css_class("section-subtle")
        info.set_halign(Gtk.Align.START)
        info.set_wrap(True)
        page.append(info)

        workspaces = [
            ("1", "Browser", "Research, docs, and general web work", "Launches your browser default"),
            ("2", "Code", "VS Code or Cursor for the main development flow", "Daily profile returns here"),
            ("3", "Discord", "Community, chat, and collaboration", "Pinned to its own workspace"),
            ("4", "Spotify", "Music and ambient playback", "Keeps media separate from work"),
            ("5", "Mail", "Evolution for personal and system mail", "Dedicated inbox workspace"),
            ("6", "Misc / System", "Mission Center and overflow apps", "Reserved for tools and one-offs"),
        ]

        flow = Gtk.FlowBox()
        flow.set_selection_mode(Gtk.SelectionMode.NONE)
        flow.set_column_spacing(16)
        flow.set_row_spacing(16)
        flow.set_max_children_per_line(2)

        for number, name, description, hint in workspaces:
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
            card.add_css_class("card")
            card.add_css_class("workspace-card")

            top = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            num = Gtk.Label(label=number)
            num.add_css_class("workspace-number")
            label = Gtk.Label(label=name)
            label.add_css_class("workspace-name")
            label.set_halign(Gtk.Align.START)
            top.append(num)
            top.append(label)

            desc = Gtk.Label(label=description)
            desc.add_css_class("workspace-desc")
            desc.set_wrap(True)
            desc.set_halign(Gtk.Align.START)

            hint_label = Gtk.Label(label=hint)
            hint_label.add_css_class("workspace-hint")
            hint_label.set_wrap(True)
            hint_label.set_halign(Gtk.Align.START)

            card.append(top)
            card.append(desc)
            card.append(hint_label)
            flow.append(card)

        page.append(flow)
        self.stack.add_titled(scroll, "workspaces", "Workspaces")

    def create_keybind_item(self, keys, action):
        item = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        item.add_css_class("keybind-item")

        keys_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        keys_box.set_size_request(220, -1)

        for key in keys:
            chip = Gtk.Label(label=key)
            chip.add_css_class("keybind-key")
            keys_box.append(chip)

        action_label = Gtk.Label(label=action)
        action_label.add_css_class("keybind-action")
        action_label.set_hexpand(True)
        action_label.set_halign(Gtk.Align.START)
        action_label.set_ellipsize(Pango.EllipsizeMode.END)

        item.append(keys_box)
        item.append(action_label)
        return item

    def add_keybindings_page(self):
        scroll, page = self.create_scrolled_page()
        keybindings_file = Path.home() / ".config" / "ml4w" / "welcome" / "keybindings.json"

        if not keybindings_file.exists():
            page.append(self.create_card("KEYBINDINGS", "No keybinding export found", "Run the hub launcher again to regenerate it."))
            self.stack.add_titled(scroll, "keybindings", "Keybindings")
            return

        data = json.loads(keybindings_file.read_text())
        for section in data.get("sections", []):
            heading = Gtk.Label(label=section["name"])
            heading.add_css_class("section-heading")
            heading.set_halign(Gtk.Align.START)
            page.append(heading)

            for binding in section.get("bindings", []):
                page.append(self.create_keybind_item(binding["keys"], binding["action"]))

        self.stack.add_titled(scroll, "keybindings", "Keybindings")

    def build_actions(self):
        file_manager = self.read_setting("filemanager.sh", "nautilus --new-window")
        return [
            ("Wallpaper", "Pick a new wallpaper or effect", "waypaper"),
            ("Matrix Sleep", "Wallpaper-reactive falling glyph rest screen", "~/.config/hypr/scripts/matrix-rest.sh"),
            ("Reload Hyprland", "Apply config changes immediately", "hyprctl reload"),
            ("Relaunch Waybar", "Refresh the top bar and theme", "~/.config/waybar/launch.sh"),
            ("Open Dotfiles", "Jump into your dotfiles repo", f"{file_manager} '{self.repo_root}'"),
            ("System Monitor", "Open Mission Center or btop", self.read_setting("system-monitor.sh", "kitty --class dotfiles-floating -e btop")),
            ("Mail", "Launch your inbox workspace app", self.read_setting("email.sh", "evolution")),
            ("Browser", "Launch your main browser", self.read_setting("browser.sh", "google-chrome-stable")),
        ]

    def run_command(self, _button, command):
        subprocess.Popen(["bash", "-lc", command], start_new_session=True)

    def create_action_button(self, title, subtitle, command):
        button = Gtk.Button()
        button.add_css_class("action-button")
        button.connect("clicked", self.run_command, command)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        box.set_halign(Gtk.Align.START)

        title_label = Gtk.Label(label=title)
        title_label.add_css_class("action-title")
        title_label.set_halign(Gtk.Align.START)

        subtitle_label = Gtk.Label(label=subtitle)
        subtitle_label.add_css_class("action-subtitle")
        subtitle_label.set_halign(Gtk.Align.START)
        subtitle_label.set_wrap(True)

        box.append(title_label)
        box.append(subtitle_label)
        button.set_child(box)
        return button

    def add_actions_page(self):
        scroll, page = self.create_scrolled_page()

        intro = Gtk.Label(label="Quick actions for the surfaces you actually use day to day. The hub is manual-only, so nothing pops up on login.")
        intro.add_css_class("section-subtle")
        intro.set_halign(Gtk.Align.START)
        intro.set_wrap(True)
        page.append(intro)

        flow = Gtk.FlowBox()
        flow.set_selection_mode(Gtk.SelectionMode.NONE)
        flow.set_column_spacing(16)
        flow.set_row_spacing(16)
        flow.set_max_children_per_line(2)
        flow.set_homogeneous(True)

        for title, subtitle, command in self.build_actions():
            flow.append(self.create_action_button(title, subtitle, command))

        page.append(flow)
        self.stack.add_titled(scroll, "actions", "Actions")

    def show_error_dialog(self, title, body):
        dialog = Adw.MessageDialog.new(self, title, body)
        dialog.add_response("ok", "OK")
        dialog.set_default_response("ok")
        dialog.set_close_response("ok")
        dialog.present()

    def create_preferences_page(self):
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)

        page = Adw.PreferencesPage()
        page.set_margin_top(10)
        page.set_margin_bottom(22)
        page.set_margin_start(22)
        page.set_margin_end(22)
        scroll.set_child(page)
        return scroll, page

    def create_combo_row(self, title, subtitle, options, selected_value, callback):
        row = Adw.ComboRow(title=title)
        row.set_subtitle(subtitle)
        model = Gtk.StringList.new(options)
        row.set_model(model)
        row._options = options
        try:
            selected_index = options.index(selected_value)
        except ValueError:
            selected_index = 0
        row.set_selected(selected_index)
        row.connect("notify::selected", callback)
        return row

    def create_switch_row(self, title, subtitle, active, callback):
        row = Adw.SwitchRow(title=title)
        row.set_subtitle(subtitle)
        row.set_active(active)
        row.connect("notify::active", callback)
        return row

    def create_spin_row(self, title, subtitle, value, lower, upper, step, digits, callback):
        row = Adw.ActionRow(title=title)
        row.set_subtitle(subtitle)

        adjustment = Gtk.Adjustment(
            value=value,
            lower=lower,
            upper=upper,
            step_increment=step,
            page_increment=step * 2,
            page_size=0,
        )
        spin = Gtk.SpinButton(adjustment=adjustment, climb_rate=1, digits=digits)
        spin.set_value(value)
        spin.connect("value-changed", callback)
        row.add_suffix(spin)
        row.set_activatable_widget(spin)
        row._spin = spin
        return row

    def on_bar_workspace_display_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        value = "icons" if row._options[row.get_selected()] == "Icons" else "numbers"
        if value == self.settings_state["bar"]["workspace_display"]:
            return
        self.settings_backend.set_bar_setting("workspace_display", value)
        self.settings_state = self.settings_backend.load_state()

    def on_bar_outline_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        value = row.get_active()
        if value == self.settings_state["bar"]["pill_outline"]:
            return
        self.settings_backend.set_bar_setting("pill_outline", value)
        self.settings_state = self.settings_backend.load_state()

    def on_bar_updates_visibility_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        label = row._options[row.get_selected()]
        value = "always" if label == "Always" else "pending_only"
        if value == self.settings_state["bar"]["updates_visibility"]:
            return
        self.settings_backend.set_bar_setting("updates_visibility", value)
        self.settings_state = self.settings_backend.load_state()

    def on_bar_density_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        label = row._options[row.get_selected()]
        value = "compact" if label == "Compact" else "balanced"
        if value == self.settings_state["bar"]["density"]:
            return
        self.settings_backend.set_bar_setting("density", value)
        self.settings_state = self.settings_backend.load_state()

    def on_hyprland_spin_changed(self, spin, key, digits=0):
        if self.settings_signal_block:
            return
        value = spin.get_value()
        if digits == 0:
            value = int(round(value))
        else:
            value = round(value, digits)
        if value == self.settings_state["hyprland"][key]:
            return
        self.settings_backend.set_hyprland_setting(key, value)
        self.settings_state = self.settings_backend.load_state()

    def on_hyprland_blur_enabled_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        value = row.get_active()
        if value == self.settings_state["hyprland"]["blur_enabled"]:
            return
        self.settings_backend.set_hyprland_setting("blur_enabled", value)
        self.settings_state = self.settings_backend.load_state()

    def on_hyprland_animation_changed(self, row, _pspec):
        if self.settings_signal_block:
            return
        label = row._options[row.get_selected()]
        value = label.lower()
        if value == self.settings_state["hyprland"]["animation_preset"]:
            return
        self.settings_backend.set_hyprland_setting("animation_preset", value)
        self.settings_state = self.settings_backend.load_state()

    def get_monitor_state(self, monitor_name, fallback_mode, fallback_scale):
        return self.settings_state.get("display", {}).get(
            monitor_name,
            {"mode": fallback_mode, "scale": fallback_scale},
        )

    def on_display_setting_changed(self, monitor_name):
        if self.settings_signal_block:
            return

        widgets = self.display_widgets.get(monitor_name)
        if not widgets:
            return

        mode = widgets["mode_options"][widgets["mode_row"].get_selected()]
        scale_label = widgets["scale_options"][widgets["scale_row"].get_selected()]
        scale = float(scale_label)
        current = self.get_monitor_state(
            monitor_name, widgets["current_mode"], widgets["current_scale"]
        )

        if mode == current["mode"] and abs(scale - float(current["scale"])) < 0.001:
            return

        if self.pending_display_change is not None:
            self.cancel_pending_display_change(rebuild=True)
            return

        try:
            self.settings_backend.apply_display_preview(monitor_name, mode, scale)
        except subprocess.CalledProcessError:
            self.show_error_dialog(
                "Display change failed",
                "Hyprland rejected that display mode. The current resolution has been kept.",
            )
            self.build_interface("settings")
            return

        self.pending_display_change = {
            "monitor_name": monitor_name,
            "old_mode": current["mode"],
            "old_scale": float(current["scale"]),
            "new_mode": mode,
            "new_scale": scale,
            "seconds_left": 15,
        }
        self.present_display_confirm_dialog()

    def format_display_dialog_body(self):
        if self.pending_display_change is None:
            return ""
        change = self.pending_display_change
        return (
            f"{change['monitor_name']} is now using {change['new_mode']} at scale "
            f"{change['new_scale']}. Reverting in {change['seconds_left']} seconds "
            "unless you keep it."
        )

    def present_display_confirm_dialog(self):
        if self.pending_display_change is None:
            return

        if self.display_dialog is not None:
            self.display_dialog.close()

        dialog = Adw.MessageDialog.new(
            self,
            "Keep display settings?",
            self.format_display_dialog_body(),
        )
        dialog.add_response("revert", "Revert")
        dialog.add_response("keep", "Keep")
        dialog.set_response_appearance("keep", Adw.ResponseAppearance.SUGGESTED)
        dialog.set_default_response("keep")
        dialog.set_close_response("revert")
        dialog.connect("response", self.on_display_dialog_response)
        dialog.present()
        self.display_dialog = dialog

        if self.display_revert_source is not None:
            GLib.source_remove(self.display_revert_source)
        self.display_revert_source = GLib.timeout_add_seconds(
            1, self.on_display_confirm_tick
        )

    def on_display_confirm_tick(self):
        if self.pending_display_change is None:
            self.display_revert_source = None
            return GLib.SOURCE_REMOVE

        self.pending_display_change["seconds_left"] -= 1
        if self.pending_display_change["seconds_left"] <= 0:
            self.cancel_pending_display_change(rebuild=True)
            return GLib.SOURCE_REMOVE

        if self.display_dialog is not None:
            self.display_dialog.set_body(self.format_display_dialog_body())
        return GLib.SOURCE_CONTINUE

    def on_display_dialog_response(self, dialog, response):
        if response == "keep":
            self.confirm_pending_display_change()
        else:
            self.cancel_pending_display_change(rebuild=True)
        dialog.close()

    def confirm_pending_display_change(self):
        if self.pending_display_change is None:
            return

        change = self.pending_display_change
        self.settings_backend.persist_display_setting(
            change["monitor_name"], change["new_mode"], change["new_scale"]
        )
        self.settings_state = self.settings_backend.load_state()
        self.clear_display_confirmation_state()
        self.build_interface("settings")

    def cancel_pending_display_change(self, rebuild=False):
        if self.pending_display_change is not None:
            change = self.pending_display_change
            try:
                self.settings_backend.revert_display_preview(
                    change["monitor_name"], change["old_mode"], change["old_scale"]
                )
            except subprocess.CalledProcessError:
                pass
        self.clear_display_confirmation_state()
        if rebuild:
            self.settings_state = self.settings_backend.load_state()
            self.build_interface("settings")

    def clear_display_confirmation_state(self):
        if self.display_revert_source is not None:
            GLib.source_remove(self.display_revert_source)
            self.display_revert_source = None
        if self.display_dialog is not None:
            self.display_dialog.close()
            self.display_dialog = None
        self.pending_display_change = None

    def create_display_group(self, monitor):
        monitor_name = monitor["name"]
        current_state = self.get_monitor_state(
            monitor_name, monitor["current_mode"], monitor["scale"]
        )
        available_modes = monitor["available_modes"] or [monitor["current_mode"]]
        scale_values = ["1.0", "1.25", "1.5", "1.75", "2.0"]
        current_scale_label = str(current_state["scale"])
        if current_scale_label not in scale_values:
            scale_values.append(current_scale_label)
            scale_values = sorted(scale_values, key=float)

        group = Adw.PreferencesGroup(
            title=monitor_name,
            description=(
                f"{monitor.get('description') or 'Detected display'} • "
                f"Current {current_state['mode']} at scale {current_state['scale']}"
            ),
        )

        mode_row = self.create_combo_row(
            "Resolution and refresh",
            "Applies live and asks for confirmation before it is saved.",
            available_modes,
            current_state["mode"],
            lambda row, pspec, name=monitor_name: self.on_display_setting_changed(name),
        )
        scale_row = self.create_combo_row(
            "Scale",
            "Choose the UI scaling factor for this monitor.",
            scale_values,
            current_scale_label,
            lambda row, pspec, name=monitor_name: self.on_display_setting_changed(name),
        )

        group.add(mode_row)
        group.add(scale_row)

        self.display_widgets[monitor_name] = {
            "mode_row": mode_row,
            "mode_options": available_modes,
            "scale_row": scale_row,
            "scale_options": scale_values,
            "current_mode": current_state["mode"],
            "current_scale": float(current_state["scale"]),
        }
        return group

    def add_settings_page(self):
        scroll, page = self.create_preferences_page()
        self.display_widgets = {}

        bar_group = Adw.PreferencesGroup(
            title="Bar",
            description="Live Waybar presentation controls for the Siverteh glass theme.",
        )
        bar_group.add(
            self.create_combo_row(
                "Workspace style",
                "Choose semantic icons or plain workspace numbers.",
                ["Icons", "Numbers"],
                "Icons"
                if self.settings_state["bar"]["workspace_display"] == "icons"
                else "Numbers",
                self.on_bar_workspace_display_changed,
            )
        )
        bar_group.add(
            self.create_switch_row(
                "Pill outline",
                "Keep the colored border around the glass pills.",
                self.settings_state["bar"]["pill_outline"],
                self.on_bar_outline_changed,
            )
        )
        bar_group.add(
            self.create_combo_row(
                "Updates pill",
                "Show it all the time or only when updates are available.",
                ["Always", "Pending only"],
                "Always"
                if self.settings_state["bar"]["updates_visibility"] == "always"
                else "Pending only",
                self.on_bar_updates_visibility_changed,
            )
        )
        bar_group.add(
            self.create_combo_row(
                "Bar density",
                "Compact keeps the current tight look. Balanced adds a little more breathing room.",
                ["Compact", "Balanced"],
                "Compact"
                if self.settings_state["bar"]["density"] == "compact"
                else "Balanced",
                self.on_bar_density_changed,
            )
        )
        page.add(bar_group)

        layout_group = Adw.PreferencesGroup(
            title="Layout",
            description="Core Hyprland tiling layout controls.",
        )
        gaps_in_row = self.create_spin_row(
            "Inner gaps",
            "Space between tiled windows.",
            self.settings_state["hyprland"]["gaps_in"],
            0,
            32,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "gaps_in"),
        )
        gaps_out_row = self.create_spin_row(
            "Outer gaps",
            "Space between windows and the screen edge.",
            self.settings_state["hyprland"]["gaps_out"],
            0,
            48,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "gaps_out"),
        )
        border_row = self.create_spin_row(
            "Border size",
            "Thickness of the active and inactive window border.",
            self.settings_state["hyprland"]["border_size"],
            0,
            8,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "border_size"),
        )
        rounding_row = self.create_spin_row(
            "Rounding",
            "Corner roundness for windows and surfaces.",
            self.settings_state["hyprland"]["rounding"],
            0,
            32,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "rounding"),
        )
        for row in (gaps_in_row, gaps_out_row, border_row, rounding_row):
            layout_group.add(row)
        page.add(layout_group)

        effects_group = Adw.PreferencesGroup(
            title="Effects",
            description="Blur, opacity, and animation tuning. These settings reload Hyprland immediately.",
        )
        effects_group.add(
            self.create_switch_row(
                "Blur",
                "Enable or disable Hyprland blur for glass surfaces.",
                self.settings_state["hyprland"]["blur_enabled"],
                self.on_hyprland_blur_enabled_changed,
            )
        )
        blur_size_row = self.create_spin_row(
            "Blur size",
            "How wide the blur samples are.",
            self.settings_state["hyprland"]["blur_size"],
            1,
            16,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "blur_size"),
        )
        blur_passes_row = self.create_spin_row(
            "Blur passes",
            "More passes look smoother but cost more performance.",
            self.settings_state["hyprland"]["blur_passes"],
            1,
            8,
            1,
            0,
            lambda spin: self.on_hyprland_spin_changed(spin, "blur_passes"),
        )
        inactive_opacity_row = self.create_spin_row(
            "Inactive opacity",
            "Opacity used for unfocused windows.",
            self.settings_state["hyprland"]["inactive_opacity"],
            0.50,
            1.00,
            0.05,
            2,
            lambda spin: self.on_hyprland_spin_changed(spin, "inactive_opacity", digits=2),
        )
        animation_row = self.create_combo_row(
            "Animation preset",
            "Off removes animations entirely. Balanced matches the current feel.",
            ["Off", "Minimal", "Balanced", "Lively"],
            self.settings_state["hyprland"]["animation_preset"].capitalize(),
            self.on_hyprland_animation_changed,
        )
        for row in (blur_size_row, blur_passes_row, inactive_opacity_row, animation_row):
            effects_group.add(row)
        page.add(effects_group)

        display_intro = Adw.PreferencesGroup(
            title="Displays",
            description="Mode changes apply live, then revert automatically after 15 seconds unless you keep them.",
        )
        page.add(display_intro)

        monitors = self.settings_backend.list_monitors()
        if monitors:
            for monitor in monitors:
                page.add(self.create_display_group(monitor))
        else:
            unavailable = Adw.PreferencesGroup(
                title="Displays unavailable",
                description="Hyprland monitor data was not available, so resolution controls could not be loaded.",
            )
            page.add(unavailable)

        self.stack.add_titled(scroll, "settings", "Settings")


class HubApp(Adw.Application):
    def __init__(self):
        super().__init__(application_id="com.siverteh.hub", flags=Gio.ApplicationFlags.NON_UNIQUE)

    def do_activate(self):
        window = self.props.active_window
        if window is None:
            window = HubWindow(self)
        window.refresh_theme()
        window.present()


if __name__ == "__main__":
    app = HubApp()
    app.run(None)
