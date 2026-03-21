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
        self.style_override_path = (
            self.repo_root / "waybar" / "themes" / "siverteh-glass" / "settings-generated.css"
        )
        self.window_conf_path = self.repo_root / "hypr" / "conf" / "window.conf"
        self.decoration_conf_path = self.repo_root / "hypr" / "conf" / "decoration.conf"
        self.animation_conf_path = self.repo_root / "hypr" / "conf" / "animation.conf"
        self.animation_presets_dir = self.repo_root / "hypr" / "conf" / "animation-presets"
        self.monitor_conf_path = self.repo_root / "hypr" / "conf" / "monitor.conf"

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

    def read_bar_state(self):
        state = copy.deepcopy(DEFAULT_STATE["bar"])
        try:
            modules = self.load_modules()
        except (OSError, json.JSONDecodeError):
            modules = {}

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

    def list_monitors(self):
        try:
            output = subprocess.check_output(
                ["hyprctl", "monitors", "all"], text=True
            )
        except (subprocess.CalledProcessError, FileNotFoundError):
            return []

        monitors = []
        current = None
        for raw_line in output.splitlines():
            line = raw_line.strip()
            if not line:
                continue
            match = re.match(r"Monitor\s+(.+?)\s+\(ID\s+\d+\):", line)
            if match:
                if current:
                    monitors.append(current)
                current = {
                    "name": match.group(1),
                    "current_mode": "",
                    "available_modes": [],
                    "scale": 1.0,
                    "focused": False,
                    "description": "",
                }
                continue
            if current is None:
                continue

            mode_match = re.match(r"(\d+x\d+)@([0-9.]+)\s+at\s+", line)
            if mode_match and not current["current_mode"]:
                current["current_mode"] = self.format_mode_label(
                    mode_match.group(1), mode_match.group(2)
                )
                continue

            if line.startswith("availableModes:"):
                available = line.split(":", 1)[1].strip().split()
                current["available_modes"] = [
                    self.format_mode_label(*mode.split("@", 1))
                    if "@" in mode
                    else mode
                    for mode in available
                ]
                continue

            scale_match = re.match(r"scale:\s*([0-9.]+)", line)
            if scale_match:
                current["scale"] = self.parse_scale(scale_match.group(1))
                continue

            if line.startswith("focused:"):
                current["focused"] = line.endswith("yes")
                continue

            if line.startswith("description:"):
                current["description"] = line.split(":", 1)[1].strip()

        if current:
            monitors.append(current)

        for monitor in monitors:
            if monitor["current_mode"] and monitor["current_mode"] not in monitor["available_modes"]:
                monitor["available_modes"].insert(0, monitor["current_mode"])

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

    def set_bar_setting(self, key, value):
        state = self.load_state()
        state["bar"][key] = value
        self.save_state(state)
        self.apply_bar_settings(state)

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

    def apply_bar_settings(self, state=None):
        if state is None:
            state = self.load_state()

        modules = self.load_modules()
        workspace_format = (
            WORKSPACE_ICON_MAP
            if state["bar"]["workspace_display"] == "icons"
            else WORKSPACE_NUMBER_MAP
        )
        modules.setdefault("hyprland/workspaces", {})
        modules["hyprland/workspaces"]["format"] = "{icon}"
        modules["hyprland/workspaces"]["format-icons"] = workspace_format

        modules.setdefault("custom/updates", {})
        modules["custom/updates"]["hide-empty-text"] = True

        self.save_modules(modules)
        self.style_override_path.parent.mkdir(parents=True, exist_ok=True)
        self.style_override_path.write_text(
            self.render_waybar_override_css(state["bar"])
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

#custom-siverteh,
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

        display_state = state.get("display", {})
        lines = []
        try:
            lines = self.monitor_conf_path.read_text().splitlines()
        except OSError:
            lines = []

        existing = set()
        updated_lines = []
        for line in lines:
            stripped = line.strip()
            if not stripped.startswith("monitor="):
                updated_lines.append(line)
                continue

            payload = stripped.split("=", 1)[1]
            parts = [part.strip() for part in payload.split(",")]
            if len(parts) < 4:
                updated_lines.append(line)
                continue

            name = parts[0]
            existing.add(name)
            if name not in display_state:
                updated_lines.append(line)
                continue

            position = parts[2]
            new_line = (
                f"monitor={name},"
                f"{self.normalize_mode_for_hypr(display_state[name]['mode'])},"
                f"{position},"
                f"{self.format_scale_for_hypr(display_state[name]['scale'])}"
            )
            updated_lines.append(new_line)

        for name, display in display_state.items():
            if name in existing:
                continue
            updated_lines.append(
                "monitor="
                f"{name},{self.normalize_mode_for_hypr(display['mode'])},auto,"
                f"{self.format_scale_for_hypr(display['scale'])}"
            )

        self.monitor_conf_path.write_text("\n".join(updated_lines) + "\n")

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
