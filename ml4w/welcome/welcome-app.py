#!/usr/bin/env python3
"""
Siverteh's OS Welcome Screen
GTK4 Application
"""

import gi
import json
import re
import os
from pathlib import Path

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, Gdk

class WelcomeWindow(Adw.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="Siverteh's OS")
        
        # Window setup
        self.set_default_size(650, 650)
        
        # Force dark mode
        style_manager = Adw.StyleManager.get_default()
        style_manager.set_color_scheme(Adw.ColorScheme.FORCE_DARK)
        
        # Load colors
        self.colors = self.load_colors()
        
        # Apply custom CSS
        self.apply_custom_css()
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.set_content(main_box)
        
        # Header
        header = self.create_header()
        main_box.append(header)
        
        # Stack switcher (tabs)
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_transition_duration(200)
        
        switcher = Gtk.StackSwitcher()
        switcher.set_stack(self.stack)
        switcher.set_halign(Gtk.Align.CENTER)
        switcher.set_margin_bottom(10)
        
        main_box.append(switcher)
        main_box.append(self.stack)
        
        # Add pages
        self.add_workspaces_page()
        self.add_keybindings_page()
        self.add_settings_page()
    
    def load_colors(self):
        """Load colors from rofi colors.rasi"""
        colors = {
            'primary': '#d9c76f',
            'primary_fixed': '#f6e388',
            'on_primary_fixed': '#211b00',
            'surface': '#15130c',
            'on_surface': '#e8e2d4',
            'on_surface_variant': '#cdc6b4',
            'surface_container': '#222017',
            'surface_container_high': '#2c2a21',
            'primary_container': '#524700',
        }
        
        colors_file = Path.home() / '.config/rofi/colors.rasi'
        if colors_file.exists():
            try:
                content = colors_file.read_text()
                
                def extract_color(pattern):
                    match = re.search(pattern, content, re.MULTILINE)
                    return match.group(1) if match else None
                
                primary = extract_color(r'primary:\s*([#\w]+);')
                if primary:
                    colors['primary'] = primary
                    
                primary_fixed = extract_color(r'primary-fixed:\s*([#\w]+);')
                if primary_fixed:
                    colors['primary_fixed'] = primary_fixed
                    
                on_primary = extract_color(r'on-primary-fixed:\s*([#\w]+);')
                if on_primary:
                    colors['on_primary_fixed'] = on_primary
                    
            except Exception as e:
                print(f"Error loading colors: {e}")
        
        return colors
    
    def apply_custom_css(self):
        """Apply custom CSS styling"""
        css = f"""
        window {{
            background-color: {self.colors['surface']};
        }}
        
        .logo-box {{
            background: linear-gradient(135deg, {self.colors['primary']}, {self.colors['primary_fixed']});
            border-radius: 20px;
            min-width: 110px;
            min-height: 110px;
        }}
        
        .logo-text {{
            font-size: 48px;
            font-weight: 900;
            color: {self.colors['on_primary_fixed']};
            margin: 0;
        }}
        
        .title-text {{
            font-size: 28px;
            font-weight: 800;
            color: {self.colors['primary']};
        }}
        
        .subtitle-text {{
            font-size: 14px;
            color: {self.colors['on_surface_variant']};
            opacity: 0.8;
        }}
        
        .workspace-card {{
            background-color: alpha({self.colors['primary']}, 0.1);
            border: 1px solid alpha({self.colors['primary']}, 0.3);
            border-radius: 12px;
            padding: 18px;
            min-width: 260px;
            min-height: 120px;
        }}
        
        .workspace-card:hover {{
            background-color: alpha({self.colors['primary']}, 0.2);
            border-color: {self.colors['primary']};
        }}
        
        .workspace-number {{
            font-size: 28px;
            font-weight: 800;
            color: {self.colors['primary']};
        }}
        
        .workspace-name {{
            font-size: 16px;
            font-weight: 600;
            color: {self.colors['on_surface']};
        }}
        
        .workspace-desc {{
            font-size: 11px;
            color: {self.colors['on_surface_variant']};
            opacity: 0.7;
        }}
        
        .keybind-item {{
            background-color: alpha({self.colors['primary']}, 0.05);
            border-radius: 8px;
            padding: 10px 14px;
        }}
        
        .keybind-key {{
            background-color: alpha({self.colors['primary']}, 0.2);
            border: 1px solid alpha({self.colors['primary']}, 0.4);
            border-radius: 5px;
            padding: 3px 8px;
            font-family: monospace;
            font-weight: 700;
            font-size: 11px;
            color: {self.colors['primary']};
        }}
        
        .keybind-action {{
            color: {self.colors['on_surface']};
            font-size: 12px;
        }}
        
        .section-title {{
            font-size: 15px;
            font-weight: 700;
            color: {self.colors['primary']};
        }}
        
        .setting-item {{
            background-color: alpha({self.colors['primary']}, 0.05);
            border-radius: 8px;
            padding: 14px;
        }}
        
        .setting-label {{
            color: {self.colors['on_surface']};
            font-size: 13px;
            font-weight: 600;
        }}
        
        .setting-value {{
            color: {self.colors['on_surface_variant']};
            font-size: 12px;
            opacity: 0.8;
        }}
        """
        
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
    def create_header(self):
        """Create the header with logo and title"""
        header_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        header_box.set_halign(Gtk.Align.CENTER)
        header_box.set_margin_top(20)
        header_box.set_margin_bottom(15)
        
        # Logo - use CenterBox for perfect centering
        logo_box = Gtk.CenterBox()
        logo_box.add_css_class('logo-box')
        logo_box.set_halign(Gtk.Align.CENTER)
        logo_box.set_valign(Gtk.Align.CENTER)
        
        # Logo label in center
        logo_label = Gtk.Label(label="SH")
        logo_label.add_css_class('logo-text')
        logo_label.set_halign(Gtk.Align.CENTER)
        logo_label.set_valign(Gtk.Align.CENTER)
        
        logo_box.set_center_widget(logo_label)
        
        header_box.append(logo_box)
        
        # Title
        title = Gtk.Label(label="Siverteh's OS")
        title.add_css_class('title-text')
        header_box.append(title)
        
        # Subtitle
        subtitle = Gtk.Label(label="Hyprland Environment")
        subtitle.add_css_class('subtitle-text')
        header_box.append(subtitle)
        
        return header_box
    
    def add_workspaces_page(self):
        """Add workspaces page"""
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)
        
        # Use FlowBox for automatic wrapping
        flow_box = Gtk.FlowBox()
        flow_box.set_valign(Gtk.Align.START)
        flow_box.set_halign(Gtk.Align.CENTER)
        flow_box.set_max_children_per_line(2)
        flow_box.set_column_spacing(16)
        flow_box.set_row_spacing(16)
        flow_box.set_margin_top(20)
        flow_box.set_margin_bottom(20)
        flow_box.set_margin_start(20)
        flow_box.set_margin_end(20)
        flow_box.set_selection_mode(Gtk.SelectionMode.NONE)
        
        workspaces = [
            ("1", "Browser", "SUPER + 1", "Web browsing, research, and documentation"),
            ("2", "Code", "SUPER + 2", "VS Code, Cursor, and development tools"),
            ("3", "Discord", "SUPER + 3", "Communication and collaboration"),
            ("4", "Music", "SUPER + 4", "Spotify and media playback"),
        ]
        
        for num, name, shortcut, desc in workspaces:
            card = self.create_workspace_card(num, name, shortcut, desc)
            flow_box.append(card)
        
        scroll.set_child(flow_box)
        self.stack.add_titled(scroll, "workspaces", "Workspaces")
    
    def create_workspace_card(self, number, name, shortcut, description):
        """Create a workspace card widget"""
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        card.add_css_class('workspace-card')
        
        # Top row: number and name
        top_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        
        num_label = Gtk.Label(label=number)
        num_label.add_css_class('workspace-number')
        
        name_label = Gtk.Label(label=name)
        name_label.add_css_class('workspace-name')
        name_label.set_halign(Gtk.Align.START)
        
        top_box.append(num_label)
        top_box.append(name_label)
        
        # Description
        desc_label = Gtk.Label(label=description)
        desc_label.add_css_class('workspace-desc')
        desc_label.set_halign(Gtk.Align.START)
        desc_label.set_wrap(True)
        desc_label.set_wrap_mode(2)  # WORD_CHAR
        desc_label.set_max_width_chars(30)
        
        # Shortcut hint
        shortcut_label = Gtk.Label(label=f"Press {shortcut}")
        shortcut_label.add_css_class('workspace-desc')
        shortcut_label.set_halign(Gtk.Align.START)
        shortcut_label.set_margin_top(4)
        
        card.append(top_box)
        card.append(desc_label)
        card.append(shortcut_label)
        
        return card
    
    def add_keybindings_page(self):
        """Add keybindings page"""
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        main_box.set_margin_top(20)
        main_box.set_margin_bottom(20)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        
        # Load keybindings
        keybindings_file = Path.home() / '.config/ml4w/welcome/keybindings.json'
        if keybindings_file.exists():
            try:
                with open(keybindings_file) as f:
                    data = json.load(f)
                    
                for section in data.get('sections', []):
                    # Section title
                    section_label = Gtk.Label(label=section['name'])
                    section_label.add_css_class('section-title')
                    section_label.set_halign(Gtk.Align.START)
                    section_label.set_margin_top(8)
                    section_label.set_margin_bottom(6)
                    main_box.append(section_label)
                    
                    # Bindings
                    for binding in section.get('bindings', []):
                        keybind_box = self.create_keybind_item(
                            binding['keys'],
                            binding['action']
                        )
                        main_box.append(keybind_box)
                        
            except Exception as e:
                error_label = Gtk.Label(label=f"Error loading keybindings: {e}")
                main_box.append(error_label)
        else:
            info_label = Gtk.Label(label="No keybindings found")
            main_box.append(info_label)
        
        scroll.set_child(main_box)
        self.stack.add_titled(scroll, "keybindings", "Keybindings")
    
    def create_keybind_item(self, keys, action):
        """Create a keybinding item widget"""
        item = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        item.add_css_class('keybind-item')
        item.set_margin_top(2)
        item.set_margin_bottom(2)
        
        # Keys box
        keys_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=3)
        keys_box.set_size_request(200, -1)
        
        for key in keys:
            key_label = Gtk.Label(label=key)
            key_label.add_css_class('keybind-key')
            keys_box.append(key_label)
        
        # Action label
        action_label = Gtk.Label(label=action)
        action_label.add_css_class('keybind-action')
        action_label.set_halign(Gtk.Align.END)
        action_label.set_hexpand(True)
        action_label.set_ellipsize(3)  # ELLIPSIZE_END
        
        item.append(keys_box)
        item.append(action_label)
        
        return item
    
    def add_settings_page(self):
        """Add settings page"""
        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scroll.set_vexpand(True)
        
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        main_box.set_margin_top(20)
        main_box.set_margin_bottom(20)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        
        # Environment section
        env_title = Gtk.Label(label="Environment")
        env_title.add_css_class('section-title')
        env_title.set_halign(Gtk.Align.START)
        env_title.set_margin_bottom(6)
        main_box.append(env_title)
        
        settings = [
            ("Terminal", "Kitty"),
            ("Browser", "Google Chrome"),
            ("File Manager", "Nautilus"),
            ("Code Editor", "VS Code / Cursor"),
        ]
        
        for label, value in settings:
            item = self.create_setting_item(label, value)
            main_box.append(item)
        
        # Appearance section
        appear_title = Gtk.Label(label="Appearance")
        appear_title.add_css_class('section-title')
        appear_title.set_halign(Gtk.Align.START)
        appear_title.set_margin_top(12)
        appear_title.set_margin_bottom(6)
        main_box.append(appear_title)
        
        appearance_settings = [
            ("Theme", "Glass"),
            ("Color Scheme", "Material You (Dynamic)"),
            ("Font", "Fira Sans"),
        ]
        
        for label, value in appearance_settings:
            item = self.create_setting_item(label, value)
            main_box.append(item)
        
        scroll.set_child(main_box)
        self.stack.add_titled(scroll, "settings", "Settings")
    
    def create_setting_item(self, label, value):
        """Create a setting item widget"""
        item = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        item.add_css_class('setting-item')
        item.set_margin_top(3)
        item.set_margin_bottom(3)
        
        label_widget = Gtk.Label(label=label)
        label_widget.add_css_class('setting-label')
        label_widget.set_halign(Gtk.Align.START)
        
        value_widget = Gtk.Label(label=value)
        value_widget.add_css_class('setting-value')
        value_widget.set_halign(Gtk.Align.END)
        value_widget.set_hexpand(True)
        
        item.append(label_widget)
        item.append(value_widget)
        
        return item


class WelcomeApp(Adw.Application):
    def __init__(self):
        super().__init__(application_id='com.siverteh.welcome')
        
    def do_activate(self):
        win = WelcomeWindow(self)
        win.present()


if __name__ == '__main__':
    app = WelcomeApp()
    app.run(None)
