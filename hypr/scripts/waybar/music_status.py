#!/usr/bin/env python3

import json
import math
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

WAYBAR_SIGNAL = "RTMIN+13"
SETTINGS_CACHE = {"mtime": None, "data": None}


def run(*args):
    return subprocess.run(
        args,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )


def cache_dir():
    directory = Path.home() / ".cache" / "siverteh"
    directory.mkdir(parents=True, exist_ok=True)
    return directory


def music_cache_path():
    return cache_dir() / "music-waybar.json"


def daemon_pid_path():
    return cache_dir() / "music-waybar.pid"


def write_cache_payload(payload):
    target = music_cache_path()
    temporary = target.with_suffix(".tmp")
    temporary.write_text(json.dumps(payload))
    temporary.replace(target)


def read_cache_payload():
    target = music_cache_path()
    if not target.exists():
        return {
            "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
            "class": "idle",
            "tooltip": "No active media player",
        }

    try:
        payload = json.loads(target.read_text())
    except (OSError, json.JSONDecodeError):
        return {
            "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
            "class": "idle",
            "tooltip": "No active media player",
        }
    if not isinstance(payload, dict):
        return {
            "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
            "class": "idle",
            "tooltip": "No active media player",
        }
    return payload


def daemon_running():
    pid_path = daemon_pid_path()
    if not pid_path.exists():
        return False

    try:
        pid = int(pid_path.read_text().strip())
    except (OSError, ValueError):
        return False

    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def signal_waybar_refresh():
    subprocess.run(
        ["pkill", f"-{WAYBAR_SIGNAL}", "waybar"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )


def ensure_visualizer_daemon():
    if shutil.which("cava") is None or daemon_running():
        return

    subprocess.Popen(
        [sys.executable, str(Path(__file__).resolve()), "--cava-daemon"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
        start_new_session=True,
        env={**os.environ, "TERM": "dumb"},
    )


def sink_inputs_active():
    output = run("pactl", "list", "short", "sink-inputs").stdout.strip()
    return bool(output)


def load_siverteh_settings():
    settings_path = Path.home() / ".config" / "siverteh" / "settings.json"
    try:
        stat = settings_path.stat()
    except OSError:
        SETTINGS_CACHE["mtime"] = None
        SETTINGS_CACHE["data"] = {}
        return {}

    if SETTINGS_CACHE["mtime"] == stat.st_mtime and SETTINGS_CACHE["data"] is not None:
        return SETTINGS_CACHE["data"]

    try:
        data = json.loads(settings_path.read_text())
    except (OSError, json.JSONDecodeError):
        data = {}

    SETTINGS_CACHE["mtime"] = stat.st_mtime
    SETTINGS_CACHE["data"] = data
    return data


def updates_pill_width():
    visibility = load_siverteh_settings().get("bar", {}).get("updates_visibility", "always")
    return 0 if visibility == "pending_only" else 50


def connectivity_pill_width():
    width = 224
    sink_name = run("pactl", "get-default-sink").stdout.strip().lower()

    if "bluez_output" in sink_name:
        width += 16
    elif "headset" in sink_name or "headphone" in sink_name:
        width += 8

    if "hdmi" in sink_name:
        width += 4

    return width


def first_player():
    players = run("playerctl", "-l").stdout.strip().splitlines()
    cleaned = [player.strip() for player in players if player.strip()]
    if not cleaned:
        return ""

    for wanted_status in ("Playing", "Paused"):
        for player in cleaned:
            if player_status(player) == wanted_status:
                return player

    return cleaned[0]


def player_status(player):
    return run("playerctl", "-p", player, "status").stdout.strip()


def player_position(player):
    output = run("playerctl", "-p", player, "position").stdout.strip()
    try:
        return float(output)
    except ValueError:
        return 0.0


def player_length(player):
    output = run("playerctl", "-p", player, "metadata", "mpris:length").stdout.strip()
    try:
        return float(output) / 1_000_000.0
    except ValueError:
        return 0.0


def metadata(player, field):
    return run("playerctl", "-p", player, "metadata", field).stdout.strip()


def cava_config_path():
    return cache_dir() / "cava-waybar.conf"


def pulse_sources():
    output = run("pactl", "list", "short", "sources").stdout.strip().splitlines()
    sources = set()
    for line in output:
        parts = line.split("\t")
        if len(parts) >= 2 and parts[1].strip():
            sources.add(parts[1].strip())
    return sources


def default_pulse_monitor_source():
    sink = run("pactl", "get-default-sink").stdout.strip()
    if sink:
        monitor = f"{sink}.monitor"
        if monitor in pulse_sources():
            return monitor
    return "auto"


def current_visualizer_source():
    return default_pulse_monitor_source()


def ensure_cava_config(source=None):
    config_path = cava_config_path()
    if source is None:
        source = current_visualizer_source()
    config_path.write_text(
        "\n".join(
            [
                "[general]",
                "framerate = 48",
                "bars = 14",
                "sleep_timer = 0",
                "",
                "[input]",
                "method = pulse",
                f"source = {source}",
                "",
                "[output]",
                "method = raw",
                "raw_target = /dev/stdout",
                "data_format = ascii",
                "ascii_max_range = 7",
                "bar_delimiter = 59",
                "frame_delimiter = 10",
                "",
            ]
        )
    )
    return config_path


def progress_payload():
    player = first_player()
    if not player:
        return {
            "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
            "class": "idle",
            "tooltip": "No active media player",
        }

    status = player_status(player) or "Stopped"
    bars = "▁▂▃▄▅▆▇█"
    low_bar = "▁" * 14

    if status.lower() == "playing":
        tick = time.time() * 7.5
        pattern = []
        for index in range(14):
            wave_primary = (math.sin(tick + index * 0.55) + 1.0) / 2.0
            wave_secondary = (math.sin(tick * 1.6 - index * 0.92) + 1.0) / 2.0
            wave_tertiary = (math.sin(tick * 0.8 + index * 0.28) + 1.0) / 2.0
            level = int(
                round(
                    (
                        wave_primary * 0.5
                        + wave_secondary * 0.35
                        + wave_tertiary * 0.15
                    )
                    * (len(bars) - 1)
                )
            )
            level = max(0, min(level, len(bars) - 1))
            pattern.append(bars[level])
        bar = "".join(pattern)
    elif status.lower() == "paused":
        bar = "▁▁▂▂▃▃▂▂▁▁▂▂▃▃"
    else:
        bar = low_bar
    title = metadata(player, "xesam:title")
    artist = metadata(player, "xesam:artist")
    tooltip = "Nothing is playing"
    if title or artist:
        tooltip = " - ".join([part for part in [artist, title] if part])

    return {
        "text": bar,
        "class": status.lower(),
        "tooltip": tooltip,
    }


def remote_playback_payload():
    status, tooltip = current_player_metadata()
    if status != "playing":
        return {
            "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
            "class": status,
            "tooltip": tooltip,
        }

    bars = "▁▂▃▄▅▆▇█"
    tick = time.time() * 5.2
    pattern = []
    for index in range(14):
        wave_primary = (math.sin(tick + index * 0.65) + 1.0) / 2.0
        wave_secondary = (math.sin(tick * 1.35 - index * 0.9) + 1.0) / 2.0
        level = int(round((wave_primary * 0.62 + wave_secondary * 0.38) * (len(bars) - 1)))
        level = max(0, min(level, len(bars) - 1))
        pattern.append(bars[level])

    return {
        "text": "".join(pattern),
        "class": status,
        "tooltip": tooltip,
    }


def play_icon_payload():
    player = first_player()
    if not player:
        return {"text": "", "class": "idle", "tooltip": "No active media player"}

    status = (player_status(player) or "Stopped").lower()
    _, track_tooltip = current_player_metadata()
    icon = ""
    tooltip = track_tooltip
    if status == "playing":
        icon = ""
        if track_tooltip and track_tooltip != "No active media player":
            tooltip = f"{track_tooltip}\nClick: Pause"
        else:
            tooltip = "Pause"
    elif status == "paused":
        icon = ""
        if track_tooltip and track_tooltip != "No active media player":
            tooltip = f"{track_tooltip}\nClick: Resume"
        else:
            tooltip = "Resume"

    return {
        "text": icon,
        "class": status,
        "tooltip": tooltip,
    }


def compact_track_text(text, limit=22):
    compact = " ".join(text.split())
    if limit <= 0:
        return ""
    if len(compact) <= limit:
        return compact
    return compact[: max(0, limit - 1)].rstrip() + "…"


def marquee_track_text(text, limit=22, step_duration=0.34, edge_pause_steps=4):
    compact = " ".join(text.split())
    if limit <= 0:
        return ""
    if len(compact) <= limit:
        return compact

    max_offset = max(0, len(compact) - limit)
    if max_offset == 0:
        return compact

    frames = [0] * edge_pause_steps
    frames.extend(range(1, max_offset + 1))
    frames.extend([max_offset] * edge_pause_steps)
    if max_offset > 1:
        frames.extend(range(max_offset - 1, 0, -1))

    frame_index = int(time.time() / step_duration) % len(frames)
    offset = frames[frame_index]
    return compact[offset : offset + limit]


def pad_to_visual_width(text, limit):
    if limit <= 0:
        return ""
    if len(text) >= limit:
        return text
    return text + (" " * (limit - len(text)))


def focused_monitor():
    try:
        monitors_json = json.loads(run("hyprctl", "-j", "monitors").stdout.strip() or "[]")
    except json.JSONDecodeError:
        return None

    for monitor in monitors_json:
        if monitor.get("focused"):
            return monitor

    return monitors_json[0] if monitors_json else None


def visible_clients_on_focused_monitor():
    try:
        clients = run("hyprctl", "-j", "clients").stdout.strip()
        clients_json = json.loads(clients or "[]")
    except json.JSONDecodeError:
        return []

    monitor = focused_monitor()
    focused_monitor_id = monitor.get("id") if monitor else None

    ignored_classes = {"alacritty", "kitty", "foot"}

    visible = []
    for client in clients_json:
        if not client.get("mapped") or client.get("hidden"):
            continue
        if client.get("workspace", {}).get("id", -1) <= 0:
            continue
        if focused_monitor_id is not None and client.get("monitor") != focused_monitor_id:
            continue
        client_class = str(client.get("class", "")).lower()
        if client_class in ignored_classes:
            continue
        visible.append(client)

    return visible


def visible_client_count():
    return len(visible_clients_on_focused_monitor())


def grouped_app_count():
    grouped = set()
    for client in visible_clients_on_focused_monitor():
        key = (client.get("class") or client.get("initialClass") or client.get("title") or "").strip().lower()
        if key:
            grouped.add(key)
    return len(grouped)


def logical_monitor_width():
    monitor = focused_monitor()
    if not monitor:
        return 1920

    try:
        width = float(monitor.get("width", 1920))
        scale = float(monitor.get("scale", 1.0)) or 1.0
    except (TypeError, ValueError):
        return 1920

    return max(1024, int(width / scale))



def adaptive_label_limit():
    monitor_width = logical_monitor_width()
    # Music sits at the left edge of the right cluster and should flex to fill
    # the gap from the center clock to the fixed right-side pills. The other
    # right-side pills always keep priority and stay fully visible.
    half_bar_budget = int(monitor_width / 2)
    center_clock_half = 92
    center_gap = 22

    music_progress_width = 96
    music_buttons_width = 50
    updates_width = updates_pill_width()
    stats_width = 138
    connectivity_width = connectivity_pill_width()
    session_width = 104
    right_spacing = 16

    fixed_right_width = (
        music_progress_width
        + music_buttons_width
        + updates_width
        + stats_width
        + connectivity_width
        + session_width
        + right_spacing
    )

    remaining = half_bar_budget - center_clock_half - center_gap - fixed_right_width
    if remaining <= 0:
        return 0

    character_width = 8.2
    limit = int(remaining / character_width)
    return max(0, min(limit, 44))


def current_player_metadata():
    player = first_player()
    if not player:
        return "idle", "No active media player"

    status = (player_status(player) or "Stopped").lower()
    title = metadata(player, "xesam:title")
    artist = metadata(player, "xesam:artist")
    tooltip = "Nothing is playing"
    if title or artist:
        tooltip = " - ".join([part for part in [artist, title] if part])
    return status, tooltip


def label_payload():
    status, tooltip = current_player_metadata()
    if status == "idle":
        return {"text": "", "class": "idle", "tooltip": tooltip}
    return {
        "text": " ".join(tooltip.split()),
        "class": status,
        "tooltip": tooltip,
    }


def progress_cache_payload():
    ensure_visualizer_daemon()
    payload = read_cache_payload()
    if payload.get("class") == "playing" and not sink_inputs_active():
        return remote_playback_payload()
    return payload


def map_cava_levels(line):
    bars = "▁▂▃▄▅▆▇█"
    parts = [part for part in line.strip().split(";") if part != ""]
    if not parts:
        return ""

    mapped = []
    for part in parts:
        try:
            level = int(part)
        except ValueError:
            level = 0
        level = max(0, min(level, len(bars) - 1))
        mapped.append(bars[level])
    return "".join(mapped)


def cava_daemon():
    daemon_pid_path().write_text(str(os.getpid()))

    try:
        while True:
            visualizer_source = current_visualizer_source()
            config_path = ensure_cava_config(visualizer_source)
            process = subprocess.Popen(
                ["cava", "-p", str(config_path)],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                env={**os.environ, "TERM": "dumb"},
            )

            last_meta_refresh = 0.0
            last_signal = 0.0
            last_source_refresh = 0.0
            current_class = "idle"
            current_tooltip = "No active media player"

            try:
                while True:
                    line = process.stdout.readline()
                    if not line:
                        break

                    now = time.time()
                    if now - last_meta_refresh > 0.35:
                        current_class, current_tooltip = current_player_metadata()
                        last_meta_refresh = now

                    if now - last_source_refresh > 1.0:
                        if current_visualizer_source() != visualizer_source:
                            break
                        last_source_refresh = now

                    payload = {
                        "text": map_cava_levels(line) or "▁▁▁▁▁▁▁▁▁▁▁▁▁▁",
                        "class": current_class,
                        "tooltip": current_tooltip,
                    }
                    write_cache_payload(payload)

                    if now - last_signal > 0.12:
                        signal_waybar_refresh()
                        last_signal = now
            finally:
                process.terminate()
                try:
                    process.wait(timeout=1)
                except subprocess.TimeoutExpired:
                    process.kill()

            time.sleep(0.5)
    finally:
        try:
            daemon_pid_path().unlink(missing_ok=True)
        except OSError:
            pass


def main():
    mode = "progress"
    follow = False
    for arg in sys.argv[1:]:
        if arg == "play-icon":
            mode = "play-icon"
        elif arg == "label":
            mode = "label"
        elif arg == "progress-cache":
            mode = "progress-cache"
        elif arg == "--label-follow":
            mode = "label-follow"
        elif arg == "--cava-daemon":
            mode = "cava-daemon"
        elif arg == "--follow":
            follow = True

    def payload_for_mode():
        if shutil.which("playerctl") is None:
            return {
                "text": "▁▁▁▁▁▁▁▁▁▁▁▁▁▁" if mode != "play-icon" else "",
                "class": "idle",
                "tooltip": "playerctl is not installed",
            }
        if mode == "play-icon":
            return play_icon_payload()
        if mode == "label":
            return label_payload()
        if mode == "progress-cache":
            return progress_cache_payload()
        if mode == "label-follow":
            return label_payload()
        return progress_payload()

    if mode == "cava-daemon":
        if shutil.which("cava") is None:
            return
        cava_daemon()
        return

    if mode == "label-follow":
        while True:
            try:
                print(json.dumps(label_payload()), flush=True)
                time.sleep(0.12)
            except BrokenPipeError:
                return

    if follow:
        delay = 0.12 if mode != "play-icon" else 0.25
        while True:
            try:
                print(json.dumps(payload_for_mode()), flush=True)
                time.sleep(delay)
            except BrokenPipeError:
                return
    else:
        try:
            print(json.dumps(payload_for_mode()))
        except BrokenPipeError:
            return


if __name__ == "__main__":
    main()
