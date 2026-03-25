#!/usr/bin/env python3

import copy
import json
import re
import subprocess
from pathlib import Path


WORKSPACE_ICON_MAP = {
    "1": "",
    "2": "",
    "3": "",
    "4": "",
    "5": "",
    "6": "",
    "7": "",
    "8": "",
    "9": "",
    "10": "",
    "urgent": "",
    "default": "",
}

WORKSPACE_NUMBER_MAP = {
    "1": "1",
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
    "6": "6",
    "7": "",
    "8": "",
    "9": "",
    "10": "",
    "urgent": "",
    "default": "",
}

DEFAULT_STATE = {
    "version": 1,
    "bar": {
        "workspace_display": "icons",
        "pill_outline": True,
        "updates_visibility": "always",
        "density": "compact",
        "show_open_apps": True,
        "show_music": True,
        "music_display": "compact",
        "show_stats": True,
        "show_clock": True,
    },
    "display_setup": {
        "mode": "extend",
        "workspace_layout": "split",
    },
    "hyprland": {
        "gaps_in": 5,
        "gaps_out": 5,
        "border_size": 1,
        "rounding": 10,
        "blur_enabled": True,
        "blur_size": 4,
        "blur_passes": 4,
        "inactive_opacity": 0.9,
        "animation_preset": "balanced",
    },
    "display": {},
}


class SivertehSettingsBackend:
    def __init__(self, repo_root):
        self.repo_root = Path(repo_root)
        self.state_path = Path.home() / ".config" / "siverteh" / "settings.json"
        self.modules_path = self.repo_root / "waybar" / "modules.json"
        self.config_path = self.repo_root / "waybar" / "themes" / "siverteh-glass" / "config"
        self.style_override_path = (
            self.repo_root / "waybar" / "themes" / "siverteh-glass" / "settings-generated.css"
        )
        self.window_conf_path = self.repo_root / "hypr" / "conf" / "window.conf"
        self.decoration_conf_path = self.repo_root / "hypr" / "conf" / "decoration.conf"
        self.animation_conf_path = self.repo_root / "hypr" / "conf" / "animation.conf"
        self.animation_presets_dir = self.repo_root / "hypr" / "conf" / "animation-presets"
        self.monitor_conf_path = self.repo_root / "hypr" / "conf" / "monitor.conf"
        self.display_profile_script = self.repo_root / "hypr" / "scripts" / "apply-display-profile.sh"

    def ensure_state(self):
        self.state_path.parent.mkdir(parents=True, exist_ok=True)
        if not self.state_path.exists():
            state = self.build_initial_state()
            self.save_state(state)
            return state

        state = self.load_state()
        normalized = self.merge_with_defaults(state)
        if normalized != state:
            self.save_state(normalized)
        return normalized

    def load_state(self):
        self.ensure_parent_directory()
        if not self.state_path.exists():
            return self.ensure_state()
        try:
            loaded = json.loads(self.state_path.read_text())
        except (OSError, json.JSONDecodeError):
            loaded = {}
        return self.merge_with_defaults(loaded)

    def save_state(self, state):
        self.ensure_parent_directory()
        self.state_path.write_text(json.dumps(state, indent=2) + "\n")

    def ensure_parent_directory(self):
        self.state_path.parent.mkdir(parents=True, exist_ok=True)

    def merge_with_defaults(self, state):
        merged = copy.deepcopy(DEFAULT_STATE)
        self.deep_merge(merged, state)
        return merged

    def deep_merge(self, base, override):
        for key, value in override.items():
            if (
                key in base
                and isinstance(base[key], dict)
                and isinstance(value, dict)
            ):
                self.deep_merge(base[key], value)
            else:
                base[key] = value

    def build_initial_state(self):
        state = copy.deepcopy(DEFAULT_STATE)
        state["bar"] = self.read_bar_state()
        state["display_setup"] = self.read_display_setup_state()
        state["hyprland"] = self.read_hyprland_state()
        state["display"] = self.read_display_state()
        return state

    def strip_jsonc(self, text):
        output = []
        in_string = False
        escape = False
        i = 0
        while i < len(text):
            char = text[i]
            nxt = text[i + 1] if i + 1 < len(text) else ""
            if in_string:
                output.append(char)
                if escape:
                    escape = False
                elif char == "\\":
                    escape = True
                elif char == '"':
                    in_string = False
                i += 1
                continue

            if char == '"':
                in_string = True
                output.append(char)
                i += 1
                continue

            if char == "/" and nxt == "/":
                while i < len(text) and text[i] != "\n":
                    i += 1
                continue

            output.append(char)
            i += 1
        return "".join(output)

    def load_modules(self):
        content = self.modules_path.read_text()
        stripped = self.strip_jsonc(content)
        stripped = re.sub(r",(\s*[}\]])", r"\1", stripped)
        return json.loads(stripped)

    def save_modules(self, modules):
        self.modules_path.write_text(json.dumps(modules, indent=2) + "\n")

    def load_waybar_config(self):
        try:
            return json.loads(self.config_path.read_text())
        except (OSError, json.JSONDecodeError):
            return {
                "layer": "top",
                "position": "top",
                "margin-top": 0,
                "margin-bottom": 0,
                "margin-left": 0,
                "margin-right": 0,
                "spacing": 0,
                "fixed-center": False,
                "expand-right": False,
                "include": ["~/.config/waybar/modules.json"],
                "modules-left": [
                    "custom/appmenu",
                    "hyprland/workspaces",
                    "wlr/taskbar",
                    "custom/music-progress",
                    "custom/music-label",
                    "custom/player-prev",
                    "custom/player-play",
                    "custom/player-next",
                ],
                "modules-center": [],
                "modules-right": [
                    "custom/updates",
                    "group/stats",
                    "group/connectivity",
                    "group/session",
                ],
            }

    def save_waybar_config(self, config):
        self.config_path.write_text(json.dumps(config, indent=4) + "\n")

    def read_bar_state(self):
        state = copy.deepcopy(DEFAULT_STATE["bar"])
        try:
            modules = self.load_modules()
        except (OSError, json.JSONDecodeError):
            modules = {}

        config = self.load_waybar_config()

        workspace_icons = (
            modules.get("hyprland/workspaces", {}).get("format-icons", {})
        )
        if workspace_icons.get("1") == WORKSPACE_NUMBER_MAP["1"]:
            state["workspace_display"] = "numbers"
        else:
            state["workspace_display"] = "icons"

        override = self.style_override_path
        if override.exists():
            try:
                content = override.read_text()
            except OSError:
                content = ""
            if "siverteh-density: balanced" in content:
                state["density"] = "balanced"
            if "border: 1px solid transparent;" in content:
                state["pill_outline"] = False

        modules_left = config.get("modules-left", [])
        modules_center = config.get("modules-center", [])
        modules_right = config.get("modules-right", [])
        music_modules = modules.get("group/music", {}).get("modules", [])
        flat_music_modules = {
            "custom/music-progress",
            "custom/music-label",
            "custom/player-prev",
            "custom/player-play",
            "custom/player-next",
        }

        state["show_open_apps"] = "wlr/taskbar" in modules_left
        state["show_music"] = (
            "group/music" in modules_left
            or "group/music" in modules_right
            or any(module in modules_left for module in flat_music_modules)
            or any(module in modules_right for module in flat_music_modules)
        )
        state["music_display"] = (
            "full"
            if (
                "custom/music-label" in music_modules
                or "custom/music-label" in modules_left
                or "custom/music-label" in modules_right
            )
            else "compact"
        )
        session_modules = modules.get("group/session", {}).get("modules", [])
        state["show_clock"] = (
            "custom/status-pill" in session_modules
            or "custom/status-pill" in modules_right
            or "custom/clock-center" in modules_center
            or "clock" in modules_center
        )
        state["show_stats"] = "group/stats" in modules_right

        return state

    def read_hyprland_state(self):
        state = copy.deepcopy(DEFAULT_STATE["hyprland"])
        try:
            window_conf = self.window_conf_path.read_text()
            decoration_conf = self.decoration_conf_path.read_text()
        except OSError:
            return state

        int_patterns = {
            "gaps_in": r"gaps_in\s*=\s*(\d+)",
            "gaps_out": r"gaps_out\s*=\s*(\d+)",
            "border_size": r"border_size\s*=\s*(\d+)",
            "rounding": r"rounding\s*=\s*(\d+)",
            "blur_size": r"size\s*=\s*(\d+)",
            "blur_passes": r"passes\s*=\s*(\d+)",
        }

        for key, pattern in int_patterns.items():
            source = decoration_conf if key.startswith("blur") or key == "rounding" else window_conf
            match = re.search(pattern, source)
            if match:
                state[key] = int(match.group(1))

        float_match = re.search(r"inactive_opacity\s*=\s*([0-9.]+)", decoration_conf)
        if float_match:
            state["inactive_opacity"] = float(float_match.group(1))

        blur_enabled = re.search(r"enabled\s*=\s*(true|false|on|off)", decoration_conf)
        if blur_enabled:
            state["blur_enabled"] = blur_enabled.group(1) in {"true", "on"}

        state["animation_preset"] = self.detect_animation_preset()
        return state

    def read_display_setup_state(self):
        state = copy.deepcopy(DEFAULT_STATE["display_setup"])
        monitors = self.list_monitors()
        if not monitors:
            return state

        active_monitors = [monitor for monitor in monitors if not monitor.get("disabled", False)]
        internal = [
            monitor
            for monitor in active_monitors
            if self.is_internal_monitor(monitor["name"], monitor.get("description", ""))
        ]
        external = [monitor for monitor in active_monitors if monitor not in internal]

        if len(active_monitors) <= 1:
            if internal:
                state["mode"] = "laptop_only"
            else:
                state["mode"] = "external_only"
            state["workspace_layout"] = "unified"
            return state

        if any(monitor.get("mirror_of") not in {"", "none", None} for monitor in active_monitors):
            state["mode"] = "mirror"
        else:
            state["mode"] = "extend"

        if len(active_monitors) > 1 and internal and external:
            state["workspace_layout"] = "split"
        else:
            state["workspace_layout"] = "sequential"
        return state

    def detect_animation_preset(self):
        try:
            current = self.animation_conf_path.read_text().strip()
        except OSError:
            return DEFAULT_STATE["hyprland"]["animation_preset"]

        for preset in ("off", "minimal", "balanced", "lively"):
            preset_path = self.animation_presets_dir / f"{preset}.conf"
            if not preset_path.exists():
                continue
            if current == preset_path.read_text().strip():
                return preset
        return "balanced"

    def read_display_state(self):
        state = {}
        live_monitors = {item["name"]: item for item in self.list_monitors()}
        if live_monitors:
            for name, monitor in live_monitors.items():
                state[name] = {
                    "mode": monitor["current_mode"],
                    "scale": monitor["scale"],
                }
            return state

        for entry in self.parse_monitor_conf():
            state[entry["name"]] = {
                "mode": entry["mode"],
                "scale": entry["scale"],
            }
        return state

    def parse_monitor_conf(self):
        entries = []
        try:
            content = self.monitor_conf_path.read_text().splitlines()
        except OSError:
            return entries

        for line in content:
            stripped = line.strip()
            if not stripped.startswith("monitor="):
                continue
            payload = stripped.split("=", 1)[1]
            parts = [part.strip() for part in payload.split(",")]
            if len(parts) < 4:
                continue
            entries.append(
                {
                    "raw": line,
                    "name": parts[0],
                    "mode": parts[1],
                    "position": parts[2],
                    "scale": self.parse_scale(parts[3]),
                }
            )
        return entries

    def is_internal_monitor(self, name, description=""):
        prefixes = ("eDP", "LVDS", "DSI")
        if name.startswith(prefixes):
            return True
        lowered = description.lower()
        return "built-in" in lowered or "panel" in lowered

    def list_monitors(self):
        try:
            output = subprocess.check_output(
                ["hyprctl", "-j", "monitors", "all"], text=True
            )
            monitors_json = json.loads(output)
        except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
            return []

        monitors = []
        for item in monitors_json:
            refresh = item.get("refreshRate", 0)
            if refresh:
                current_mode = self.format_mode_label(
                    f"{item.get('width', 0)}x{item.get('height', 0)}",
                    refresh,
                )
            else:
                current_mode = ""

            available_modes = item.get("availableModes") or []
            if current_mode and current_mode not in available_modes:
                available_modes.insert(0, current_mode)

            monitors.append(
                {
                    "name": item.get("name", ""),
                    "current_mode": current_mode,
                    "available_modes": available_modes,
                    "scale": self.parse_scale(item.get("scale", 1.0)),
                    "focused": bool(item.get("focused", False)),
                    "description": item.get("description", ""),
                    "disabled": bool(item.get("disabled", False)),
                    "mirror_of": item.get("mirrorOf", "none"),
                }
            )

        return monitors

    def format_mode_label(self, resolution, refresh_text):
        refresh = self.clean_refresh(refresh_text)
        return f"{resolution}@{refresh}Hz"

    def clean_refresh(self, refresh_text):
        try:
            refresh = float(str(refresh_text).replace("Hz", ""))
        except ValueError:
            return str(refresh_text).replace("Hz", "")
        return f"{refresh:.2f}".rstrip("0").rstrip(".") if refresh % 1 else f"{refresh:.2f}"

    def parse_scale(self, value):
        try:
            return float(str(value).strip())
        except ValueError:
            return 1.0

    def normalize_mode_for_hypr(self, mode):
        if mode.startswith("preferred"):
            return mode
        match = re.match(r"(\d+x\d+)@([0-9.]+)(?:Hz)?", mode)
        if not match:
            return mode
        try:
            refresh_value = float(match.group(2))
            refresh = f"{refresh_value:.2f}".rstrip("0").rstrip(".")
        except ValueError:
            refresh = match.group(2).replace("Hz", "")
        return f"{match.group(1)}@{refresh}"

    def format_scale_for_hypr(self, scale):
        return f"{float(scale):.2f}".rstrip("0").rstrip(".")

    def detect_preferred_network_interface(self):
        try:
            output = subprocess.check_output(
                ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device", "status"],
                text=True,
            )
        except (subprocess.CalledProcessError, FileNotFoundError):
            return ""

        lines = [line.strip() for line in output.splitlines() if line.strip()]
        connected_wifi = []
        connected_ethernet = []
        for line in lines:
            parts = line.split(":")
            if len(parts) < 3:
                continue
            device, device_type, state = parts[:3]
            if state.startswith("connected"):
                if device_type == "wifi":
                    connected_wifi.append(device)
                elif device_type == "ethernet":
                    connected_ethernet.append(device)

        if connected_wifi:
            return connected_wifi[0]
        if connected_ethernet:
            return connected_ethernet[0]
        return ""

    def collect_monitor_inventory(self, state=None):
        if state is None:
            state = self.load_state()

        display_state = state.get("display", {})
        parsed_entries = self.parse_monitor_conf()
        live_monitors = {item["name"]: item for item in self.list_monitors()}

        order = []
        inventory = {}

        def ensure_monitor(name):
            if name not in inventory:
                inventory[name] = {
                    "name": name,
                    "position": "auto",
                    "description": "",
                    "mode": "preferred",
                    "scale": 1.0,
                    "disabled": False,
                    "mirror_of": "none",
                }
                order.append(name)
            return inventory[name]

        for entry in parsed_entries:
            monitor = ensure_monitor(entry["name"])
            monitor["position"] = entry["position"]
            monitor["mode"] = entry["mode"]
            monitor["scale"] = entry["scale"]

        for name, live in live_monitors.items():
            monitor = ensure_monitor(name)
            monitor["description"] = live.get("description", "")
            if live.get("current_mode"):
                monitor["mode"] = live["current_mode"]
            monitor["scale"] = live.get("scale", monitor["scale"])
            monitor["disabled"] = live.get("disabled", False)
            monitor["mirror_of"] = live.get("mirror_of", "none")

        for name, display in display_state.items():
            monitor = ensure_monitor(name)
            monitor["mode"] = display.get("mode", monitor["mode"])
            monitor["scale"] = display.get("scale", monitor["scale"])

        connected_names = [name for name in order if name in live_monitors] or order[:]
        return {"order": order, "inventory": inventory, "connected": connected_names}

    def determine_display_plan(self, state=None):
        if state is None:
            state = self.load_state()

        data = self.collect_monitor_inventory(state)
        order = data["order"]
        inventory = data["inventory"]
        connected = data["connected"]
        settings = state.get("display_setup", DEFAULT_STATE["display_setup"])

        internal = [
            name for name in connected if self.is_internal_monitor(name, inventory[name].get("description", ""))
        ]
        external = [name for name in connected if name not in internal]

        mode = settings.get("mode", "extend")
        if mode == "laptop_only":
            active = internal[:] or connected[:1]
            primary = active[0] if active else None
        elif mode == "external_only":
            active = external[:] or internal[:] or connected[:1]
            primary = active[0] if active else None
        elif mode == "mirror":
            active = connected[:] or order[:1]
            # Hyprland's native mirror uses one display as the render source.
            # Prefer the internal panel on mixed-resolution laptop setups so the
            # built-in screen keeps its native mode instead of inheriting the
            # external monitor's rendered output size.
            primary = internal[0] if internal else (external[0] if external else (active[0] if active else None))
        else:
            active = connected[:] or order[:1]
            primary = external[0] if external else (active[0] if active else None)

        secondary = [name for name in active if name != primary]
        return {
            "mode": mode,
            "layout": settings.get("workspace_layout", "split"),
            "order": order,
            "inventory": inventory,
            "connected": connected,
            "active": active,
            "primary": primary,
            "secondary": secondary,
            "internal": internal,
            "external": external,
        }

    def set_bar_setting(self, key, value):
        state = self.load_state()
        state["bar"][key] = value
        self.save_state(state)
        self.apply_bar_settings(state)

    def set_display_setup_setting(self, key, value):
        state = self.load_state()
        state["display_setup"][key] = value
        self.save_state(state)
        self.apply_display_setup(state)

    def set_hyprland_setting(self, key, value):
        state = self.load_state()
        state["hyprland"][key] = value
        self.save_state(state)
        self.apply_hyprland_settings(state)

    def persist_display_setting(self, monitor_name, mode, scale):
        state = self.load_state()
        state["display"][monitor_name] = {
            "mode": mode,
            "scale": scale,
        }
        self.save_state(state)
        self.write_monitor_conf(state)
        self.write_display_profile_script(state)

    def apply_display_setup(self, state=None):
        if state is None:
            state = self.load_state()
        self.write_monitor_conf(state)
        self.write_display_profile_script(state)
        self.run_command(["hyprctl", "reload"])
        self.run_shell_command(
            "sleep 1.6 && ~/.config/hypr/scripts/apply-display-profile.sh && sleep 0.5 && ~/.config/waybar/launch.sh"
        )

    def apply_bar_settings(self, state=None):
        if state is None:
            state = self.load_state()

        bar_settings = state["bar"]
        modules = self.load_modules()
        config = self.load_waybar_config()
        workspace_format = (
            WORKSPACE_ICON_MAP
            if bar_settings["workspace_display"] == "icons"
            else WORKSPACE_NUMBER_MAP
        )
        modules.setdefault("hyprland/workspaces", {})
        modules["hyprland/workspaces"]["format"] = "{icon}"
        modules["hyprland/workspaces"]["format-icons"] = workspace_format
        modules["hyprland/workspaces"]["all-outputs"] = False
        modules["hyprland/workspaces"]["on-scroll-up"] = "hyprctl dispatch focusworkspaceoncurrentmonitor r-1"
        modules["hyprland/workspaces"]["on-scroll-down"] = "hyprctl dispatch focusworkspaceoncurrentmonitor r+1"

        modules.setdefault("custom/updates", {})
        modules["custom/updates"]["exec"] = "~/.config/hypr/scripts/waybar/updates_status.sh"
        modules["custom/updates"]["hide-empty-text"] = (
            bar_settings.get("updates_visibility", "always") != "always"
        )
        modules.setdefault("custom/clock-center", {})
        modules["custom/clock-center"] = {
            "exec": "~/.config/hypr/scripts/waybar/clock_status.py",
            "format": "{}",
            "return-type": "json",
            "interval": 1,
            "tooltip": True,
            "escape": False,
            "on-click": "~/.config/hypr/scripts/waybar/calendar-popup.sh",
        }
        modules.setdefault("custom/status-pill", {})
        modules["custom/status-pill"] = {
            "exec": "~/.config/hypr/scripts/waybar/status_pill.py",
            "format": "{}",
            "return-type": "json",
            "interval": 1,
            "tooltip": True,
            "escape": False,
            "on-click": "~/.config/hypr/scripts/waybar/calendar-popup.sh",
            "hide-empty-text": True,
        }
        modules.setdefault("custom/music-progress", {})
        modules["custom/music-progress"] = {
            "exec": "~/.config/hypr/scripts/waybar/music_status.py progress-cache",
            "return-type": "json",
            "signal": 13,
            "escape": True,
            "on-click": "~/.config/hypr/scripts/waybar/music-control.sh play-pause",
            "tooltip": True,
        }
        modules.setdefault("custom/music-label", {})
        modules["custom/music-label"] = {
            "exec": "~/.config/hypr/scripts/waybar/music_status.py --label-follow",
            "return-type": "json",
            "restart-interval": 1,
            "expand": False,
            "align": 0,
            "justify": "left",
            "escape": True,
            "hide-empty-text": True,
            "tooltip": True,
            "on-click": "~/.config/hypr/scripts/waybar/music-control.sh play-pause",
        }
        modules.setdefault("custom/player-play", {})
        modules["custom/player-play"]["exec"] = "~/.config/hypr/scripts/waybar/music_status.py play-icon"
        modules["custom/player-play"]["return-type"] = "json"
        modules["custom/player-play"]["interval"] = 1
        modules["custom/player-play"]["escape"] = True
        modules["custom/player-play"]["tooltip"] = True
        modules["custom/player-play"]["on-click"] = "~/.config/hypr/scripts/waybar/music-control.sh play-pause"
        modules.setdefault("network", {})
        preferred_interface = self.detect_preferred_network_interface()
        if preferred_interface:
            modules["network"]["interface"] = preferred_interface
        elif "interface" in modules["network"]:
            modules["network"].pop("interface", None)
        modules["network"]["format"] = " {signalStrength}%"
        modules["network"]["format-wifi"] = " {signalStrength}%"
        modules["network"]["format-ethernet"] = "󰈀"
        modules["network"]["format-disconnected"] = "󰖪"
        modules.setdefault("group/session", {})
        modules["group/session"]["orientation"] = "horizontal"
        session_modules = [
            "custom/notification",
            "custom/siverteh",
            "custom/exit",
        ]
        if bar_settings["show_clock"]:
            session_modules.append("custom/status-pill")
        modules["group/session"]["modules"] = session_modules

        modules_left = ["custom/appmenu", "hyprland/workspaces"]
        if bar_settings["show_open_apps"]:
            modules_left.append("wlr/taskbar")
        if bar_settings["show_music"]:
            modules_left.append("custom/music-progress")
            if bar_settings.get("music_display") == "full":
                modules_left.append("custom/music-label")
            modules_left.extend(
                [
                    "custom/player-prev",
                    "custom/player-play",
                    "custom/player-next",
                ]
            )

        modules_center = []

        modules_right = []
        modules_right.append("custom/updates")
        if bar_settings["show_stats"]:
            modules_right.append("group/stats")
        modules_right.append("group/connectivity")
        modules_right.append("group/session")

        config["modules-left"] = modules_left
        config["modules-center"] = modules_center
        config["modules-right"] = modules_right
        config["fixed-center"] = False
        config["expand-right"] = False

        self.save_modules(modules)
        self.save_waybar_config(config)
        self.style_override_path.parent.mkdir(parents=True, exist_ok=True)
        self.style_override_path.write_text(
            self.render_waybar_override_css(bar_settings)
        )
        self.run_shell_command("~/.config/waybar/launch.sh")

    def render_waybar_override_css(self, bar_settings):
        density = bar_settings["density"]
        pill_outline = bar_settings["pill_outline"]
        border_color = "alpha(@primary, 0.62)" if pill_outline else "transparent"

        if density == "balanced":
            shell_padding = "3px 6px"
            shell_height = "28px"
            shell_radius = "13px"
            app_padding = ("9px", "9px")
            inner_padding = "3px 7px"
            inner_height = "20px"
            workspace_size = ("26px", "22px", "0 6px")
            taskbar_size = ("22px", "20px", "6px", "6px")
            clock_padding = "3px 9px"
        else:
            shell_padding = "2px 5px"
            shell_height = "24px"
            shell_radius = "12px"
            app_padding = ("8px", "8px")
            inner_padding = "2px 6px"
            inner_height = "18px"
            workspace_size = ("24px", "20px", "0 5px")
            taskbar_size = ("20px", "18px", "5px", "5px")
            clock_padding = "2px 8px"

        return f"""/* Auto-generated by Siverteh OS Settings */
/* siverteh-density: {density} */

#custom-appmenu,
#custom-updates,
#workspaces,
#taskbar,
#clock,
#custom-clock-center,
.modules-right > widget > box {{
    background: alpha(@surface_container_high, 0.05);
    border: 1px solid {border_color};
    border-radius: {shell_radius};
    margin: 6px 4px 0 4px;
    padding: {shell_padding};
    min-height: {shell_height};
    box-shadow: 0 2px 8px alpha(@shadow, 0.05), inset 0 1px 0 alpha(@on_surface, 0.03);
}}

#custom-appmenu {{
    padding-left: {app_padding[0]};
    padding-right: {app_padding[1]};
    min-height: {shell_height};
}}

#clock {{
    padding: {clock_padding};
}}

#custom-clock-center {{
    color: @on_surface;
    font-family: "JetBrainsMono Nerd Font", "Fira Sans Semibold", "Font Awesome 7 Free", "Font Awesome 6 Free", FontAwesome, sans-serif;
    padding: {clock_padding};
}}

#custom-siverteh,
#custom-status-pill,
#custom-music-progress,
#custom-music-label,
#custom-player-prev,
#custom-player-play,
#custom-player-next,
#cpu,
#memory,
#disk,
#custom-notification,
#pulseaudio,
#bluetooth,
#network,
#battery,
#tray,
#custom-exit,
#taskbar button {{
    padding: {inner_padding};
    min-height: {inner_height};
}}

#custom-updates,
#cpu,
#memory,
#disk,
#network,
#bluetooth,
#custom-status-pill {{
    font-family: "JetBrainsMono Nerd Font", "Fira Sans Semibold", "Font Awesome 7 Free", "Font Awesome 6 Free", FontAwesome, sans-serif;
}}

#custom-status-pill {{
    font-size: 10px;
    font-weight: 800;
    min-width: 0;
    padding-left: 8px;
    padding-right: 8px;
}}

#custom-updates {{
    min-width: 44px;
}}

#workspaces button {{
    min-width: {workspace_size[0]};
    min-height: {workspace_size[1]};
    padding: {workspace_size[2]};
}}

#taskbar button {{
    min-width: {taskbar_size[0]};
    min-height: {taskbar_size[1]};
    padding-left: {taskbar_size[2]};
    padding-right: {taskbar_size[3]};
}}


#custom-music-progress,
#custom-music-label,
#custom-player-prev,
#custom-player-play,
#custom-player-next {{
    min-height: {inner_height};
    background: alpha(@surface_container_high, 0.05);
    border-top: 1px solid {border_color};
    border-bottom: 1px solid {border_color};
    box-shadow: inset 0 1px 0 alpha(@on_surface, 0.03);
    margin-top: 6px;
    margin-bottom: 0;
    margin-left: 0;
    margin-right: 0;
    border-radius: 0;
}}

#custom-music-progress {{
    padding: 8px 3px 0 6px;
    min-height: {inner_height};
    min-width: 92px;
    font-size: 12px;
    border-left: 1px solid {border_color};
    border-top-left-radius: {shell_radius};
    border-bottom-left-radius: {shell_radius};
    margin-left: 4px;
}}

#custom-music-label {{
    padding: 8px 4px 0 4px;
    min-height: {inner_height};
    min-width: 0;
    font-size: 10px;
    margin-left: 0;
    margin-right: 0;
    border-left: none;
    border-right: none;
}}

#custom-player-prev,
#custom-player-play {{
    border-left: none;
    border-right: none;
}}

#custom-player-next {{
    border-right: 1px solid {border_color};
    border-top-right-radius: {shell_radius};
    border-bottom-right-radius: {shell_radius};
    margin-right: 4px;
}}

#custom-player-prev,
#custom-player-play,
#custom-player-next {{
    padding: 8px 3px 0 3px;
    min-height: {inner_height};
    font-size: 9px;
}}
"""

    def apply_hyprland_settings(self, state=None):
        if state is None:
            state = self.load_state()

        hyprland = state["hyprland"]
        self.update_window_conf(hyprland)
        self.update_decoration_conf(hyprland)
        self.write_animation_preset(hyprland["animation_preset"])
        self.run_command(["hyprctl", "reload"])

    def update_window_conf(self, hyprland):
        content = self.window_conf_path.read_text()
        content = self.replace_assignment(content, "gaps_in", hyprland["gaps_in"])
        content = self.replace_assignment(content, "gaps_out", hyprland["gaps_out"])
        content = self.replace_assignment(content, "border_size", hyprland["border_size"])
        self.window_conf_path.write_text(content)

    def update_decoration_conf(self, hyprland):
        content = self.decoration_conf_path.read_text()
        content = self.replace_assignment(content, "rounding", hyprland["rounding"])
        content = self.replace_assignment(
            content,
            "inactive_opacity",
            f"{float(hyprland['inactive_opacity']):.2f}".rstrip("0").rstrip("."),
        )
        content = self.replace_assignment(
            content,
            "enabled",
            "true" if hyprland["blur_enabled"] else "false",
            first_match_after="blur {",
        )
        content = self.replace_assignment(
            content, "size", hyprland["blur_size"], first_match_after="blur {"
        )
        content = self.replace_assignment(
            content, "passes", hyprland["blur_passes"], first_match_after="blur {"
        )
        self.decoration_conf_path.write_text(content)

    def write_animation_preset(self, preset_name):
        preset_path = self.animation_presets_dir / f"{preset_name}.conf"
        if not preset_path.exists():
            preset_path = self.animation_presets_dir / "balanced.conf"
        self.animation_conf_path.write_text(preset_path.read_text())

    def replace_assignment(self, content, key, value, first_match_after=None):
        flags = re.MULTILINE
        string_value = str(value)

        if first_match_after is not None:
            start = content.find(first_match_after)
            if start != -1:
                prefix = content[:start]
                suffix = content[start:]
                suffix = re.sub(
                    rf"(^\s*{re.escape(key)}\s*=\s*).*$",
                    lambda match: match.group(1) + string_value,
                    suffix,
                    count=1,
                    flags=flags,
                )
                return prefix + suffix

        return re.sub(
            rf"(^\s*{re.escape(key)}\s*=\s*).*$",
            lambda match: match.group(1) + string_value,
            content,
            count=1,
            flags=flags,
        )

    def apply_display_preview(self, monitor_name, mode, scale):
        command = (
            f"{monitor_name},{self.normalize_mode_for_hypr(mode)},auto,"
            f"{self.format_scale_for_hypr(scale)}"
        )
        self.run_command(["hyprctl", "keyword", "monitor", command])

    def revert_display_preview(self, monitor_name, old_mode, old_scale):
        self.apply_display_preview(monitor_name, old_mode, old_scale)

    def write_monitor_conf(self, state=None):
        if state is None:
            state = self.load_state()

        plan = self.determine_display_plan(state)
        inventory = plan["inventory"]
        active = set(plan["active"])
        primary = plan["primary"]

        header = [
            "# -----------------------------------------------------",
            "# Monitor Setup",
            "# Generated by Siverteh OS",
            "# -----------------------------------------------------",
        ]
        lines = header[:]

        ordered_names = plan["order"][:]
        if plan["mode"] == "mirror" and primary in ordered_names:
            ordered_names = [primary] + [name for name in ordered_names if name != primary]

        for name in ordered_names:
            monitor = inventory[name]
            if name not in active:
                lines.append(f"monitor={name},disable")
                continue

            mode = self.normalize_mode_for_hypr(monitor["mode"])
            position = monitor.get("position", "auto") or "auto"
            scale = self.format_scale_for_hypr(monitor["scale"])

            if plan["mode"] == "mirror" and primary and name != primary:
                lines.append(
                    f"monitor={name},{mode},{position},{scale},mirror,{primary}"
                )
            else:
                lines.append(f"monitor={name},{mode},{position},{scale}")

        self.monitor_conf_path.write_text("\n".join(lines) + "\n")

    def write_display_profile_script(self, state=None):
        if state is None:
            state = self.load_state()

        self.display_profile_script.parent.mkdir(parents=True, exist_ok=True)
        self.display_profile_script.write_text(
            """#!/usr/bin/env bash
set -euo pipefail

settings_file="$HOME/.config/siverteh/settings.json"

if ! command -v hyprctl >/dev/null 2>&1; then
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    exit 0
fi

if [ ! -f "$settings_file" ]; then
    exit 0
fi

mapfile -t monitor_lines < <(hyprctl -j monitors | jq -r '.[] | select(.disabled == false) | [.name, .description] | @tsv')

if [ ${#monitor_lines[@]} -eq 0 ]; then
    exit 0
fi

active_monitors=()
internal_monitors=()
external_monitors=()

for line in "${monitor_lines[@]}"; do
    name=${line%%$'\\t'*}
    description=${line#*$'\\t'}
    active_monitors+=("$name")
    if [[ "$name" == eDP* || "$name" == LVDS* || "$name" == DSI* ]] || [[ "${description,,}" == *"built-in"* ]] || [[ "${description,,}" == *"panel"* ]]; then
        internal_monitors+=("$name")
    else
        external_monitors+=("$name")
    fi
done

mode=$(jq -r '.display_setup.mode // "extend"' "$settings_file")
layout=$(jq -r '.display_setup.workspace_layout // "split"' "$settings_file")

choose_primary() {
    if [ "$mode" = "mirror" ] && [ ${#internal_monitors[@]} -gt 0 ]; then
        printf '%s' "${internal_monitors[0]}"
    elif [ ${#external_monitors[@]} -gt 0 ]; then
        printf '%s' "${external_monitors[0]}"
    elif [ ${#active_monitors[@]} -gt 0 ]; then
        printf '%s' "${active_monitors[0]}"
    elif [ ${#internal_monitors[@]} -gt 0 ]; then
        printf '%s' "${internal_monitors[0]}"
    fi
}

primary=$(choose_primary)

if [ -z "$primary" ]; then
    exit 0
fi

move_ws() {
    local workspace="$1"
    local monitor="$2"
    [ -n "$monitor" ] || return 0
    hyprctl dispatch moveworkspacetomonitor "$workspace $monitor" >/dev/null 2>&1 || true
}

if [ "$mode" = "laptop_only" ] || [ "$mode" = "external_only" ] || [ "$mode" = "mirror" ] || [ ${#active_monitors[@]} -le 1 ]; then
    for ws in 1 2 3 4 5 6; do
        move_ws "$ws" "$primary"
    done
    exit 0
fi

if [ "$layout" = "unified" ]; then
    for ws in 1 2 3 4 5 6; do
        move_ws "$ws" "$primary"
    done
elif [ "$layout" = "split" ]; then
    secondary=""
    for mon in "${active_monitors[@]}"; do
        if [ "$mon" != "$primary" ]; then
            secondary="$mon"
            break
        fi
    done

    if [ -z "$secondary" ]; then
        for ws in 1 2 3 4 5 6; do
            move_ws "$ws" "$primary"
        done
    else
        for ws in 1 2 6; do
            move_ws "$ws" "$primary"
        done
        for ws in 3 4 5; do
            move_ws "$ws" "$secondary"
        done
    fi
else
    index=0
    count=${#active_monitors[@]}
    for ws in 1 2 3 4 5 6; do
        target=${active_monitors[$((index % count))]}
        move_ws "$ws" "$target"
        index=$((index + 1))
    done
fi
"""
        )
        self.display_profile_script.chmod(0o755)

    def run_shell_command(self, command):
        subprocess.Popen(
            ["bash", "-lc", command],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def run_command(self, command):
        subprocess.run(
            command,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
