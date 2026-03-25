#!/usr/bin/env python3

import json
import os
import re
import signal
import subprocess
import sys
from pathlib import Path


PAGE_SIZE = 6
SIGNAL_NUMBER = signal.SIGRTMIN + 8
CACHE_DIR = Path.home() / ".cache" / "siverteh"
STATE_PATH = CACHE_DIR / "workspace-apps-pages.json"

ICON_RULES = [
    (r"firefox|chrome|chromium|brave|zen", ""),
    (r"code|cursor|codium", ""),
    (r"discord|vesktop", ""),
    (r"spotify|music", ""),
    (r"evolution|thunderbird|geary|mail", ""),
    (r"nautilus|org\.gnome\.nautilus|files", ""),
    (r"kitty|foot|alacritty|wezterm|ghostty", ""),
    (r"steam|lutris", ""),
    (r"telegram|signal|slack", ""),
]


def run_json(*args):
    try:
        output = subprocess.run(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        ).stdout
        return json.loads(output or "null")
    except json.JSONDecodeError:
        return None


def load_state():
    try:
        return json.loads(STATE_PATH.read_text())
    except (OSError, json.JSONDecodeError):
        return {}


def save_state(state):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state))


def waybar_output_name():
    return (
        os.environ.get("WAYBAR_OUTPUT_NAME")
        or os.environ.get("OUTPUT_NAME")
        or ""
    )


def target_monitor():
    monitors = run_json("hyprctl", "-j", "monitors") or []
    if not monitors:
        return None

    output_name = waybar_output_name()
    if output_name:
        for monitor in monitors:
            if monitor.get("name") == output_name:
                return monitor

    for monitor in monitors:
        if monitor.get("focused"):
            return monitor

    return monitors[0]


def active_window_address():
    active = run_json("hyprctl", "-j", "activewindow") or {}
    return active.get("address", "")


def window_icon(client):
    haystack = f"{client.get('class', '')} {client.get('initialClass', '')} {client.get('title', '')}".lower()
    for pattern, icon in ICON_RULES:
        if re.search(pattern, haystack):
            return icon
    return ""


def visible_clients_for_monitor(monitor):
    clients = run_json("hyprctl", "-j", "clients") or []
    if not monitor:
        return []

    monitor_id = monitor.get("id")
    visible = [
        client
        for client in clients
        if client.get("mapped")
        and not client.get("hidden")
        and client.get("workspace", {}).get("id", -1) > 0
        and client.get("monitor") == monitor_id
    ]

    visible.sort(
        key=lambda client: (
            client.get("workspace", {}).get("id", 999),
            client.get("focusHistoryID", 999999),
            client.get("title", "").lower(),
        )
    )
    return visible


def page_key(monitor):
    if not monitor:
        return "focused"
    return monitor.get("name", "focused")


def page_count(clients):
    return max(1, (len(clients) + PAGE_SIZE - 1) // PAGE_SIZE)


def current_page_for_clients(monitor, clients):
    state = load_state()
    key = page_key(monitor)
    page = int(state.get(key, 0))
    max_page = page_count(clients) - 1
    page = max(0, min(page, max_page))

    active_address = active_window_address()
    if active_address:
        for index, client in enumerate(clients):
            if client.get("address") == active_address:
                active_page = index // PAGE_SIZE
                if active_page != page:
                    page = active_page
                    state[key] = page
                    save_state(state)
                break

    return page


def tooltip_for_page(clients, page):
    if not clients:
        return "No open applications"

    total = page_count(clients)
    start = page * PAGE_SIZE
    end = start + PAGE_SIZE
    page_clients = clients[start:end]
    lines = [f"Apps page {page + 1}/{total}", "Scroll to browse more", ""]
    for client in page_clients:
        workspace = client.get("workspace", {}).get("id", "?")
        title = client.get("title", "") or client.get("class", "Window")
        lines.append(f"{workspace}: {title}")
    return "\n".join(lines)


def payload():
    monitor = target_monitor()
    clients = visible_clients_for_monitor(monitor)
    if not clients:
        return {"text": "", "class": "empty", "tooltip": "No open applications"}

    page = current_page_for_clients(monitor, clients)
    start = page * PAGE_SIZE
    end = start + PAGE_SIZE
    page_clients = clients[start:end]
    icons = [window_icon(client) for client in page_clients]
    text = "  ".join(icons)

    return {
        "text": text,
        "class": "paged" if len(clients) > PAGE_SIZE else "normal",
        "tooltip": tooltip_for_page(clients, page),
    }


def signal_waybar():
    subprocess.run(["pkill", f"-{int(SIGNAL_NUMBER)}", "waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)


def update_page(direction):
    monitor = target_monitor()
    clients = visible_clients_for_monitor(monitor)
    total = page_count(clients)
    state = load_state()
    key = page_key(monitor)
    page = int(state.get(key, 0))

    if direction == "next":
        page = (page + 1) % total
    elif direction == "prev":
        page = (page - 1) % total
    else:
        page = 0

    state[key] = page
    save_state(state)
    signal_waybar()


def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--page":
        update_page(sys.argv[2])
        return

    print(json.dumps(payload()))


if __name__ == "__main__":
    main()
