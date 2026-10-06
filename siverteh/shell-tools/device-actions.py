#!/usr/bin/env python3
"""Bounded device actions; authentication stays in the native managers."""

import argparse, json, re, subprocess


def command(action, value=""):
    if action == "wifi-scan":
        return ["nmcli", "device", "wifi", "rescan"]
    if action == "wifi-radio" and value in ("on", "off"):
        return ["nmcli", "radio", "wifi", value]
    if action == "bluetooth-power" and value in ("on", "off"):
        return ["bluetoothctl", "power", value]
    operations = {
        "bluetooth-connect": "connect",
        "bluetooth-disconnect": "disconnect",
        "bluetooth-trust": "trust",
        "bluetooth-untrust": "untrust",
    }
    if action in operations and re.fullmatch(
        r"(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}", value
    ):
        return ["bluetoothctl", operations[action], value]
    if (
        action == "wifi-connect"
        and value
        and len(value) <= 32
        and not any(ord(c) < 32 for c in value)
    ):
        return ["nmcli", "--ask", "device", "wifi", "connect", value]
    raise ValueError("Unsupported device action")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("action")
    p.add_argument("value", nargs="?", default="")
    a = p.parse_args()
    try:
        cmd = command(a.action, a.value)
        if a.action == "wifi-connect":
            subprocess.run(cmd, check=True)
            input("\nPress Enter to close.")
            return
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        # bluetoothctl can return zero for an unsuccessful operation.
        output = result.stdout + result.stderr
        if result.returncode or any(
            word in output.lower() for word in ("failed", "not available", "not ready")
        ):
            raise RuntimeError(output.strip()[:400] or "Device action failed")
        print(json.dumps(dict(message=output.strip()[:400] or "Device updated")))
    except Exception as e:
        print(json.dumps(dict(error=str(e))))


if __name__ == "__main__":
    main()
