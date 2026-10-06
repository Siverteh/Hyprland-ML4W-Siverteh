#!/usr/bin/env python3
"""Read-only lock widgets and an allowlist of media actions. No authentication data."""

import argparse, fcntl, html, json, os, subprocess, time, textwrap, urllib.request, urllib.parse, io
from PIL import Image
from pathlib import Path

HOME = Path.home()
CACHE = HOME / ".cache/siverteh-os/lock-widgets.json"


def ipc(target, action):
    result = subprocess.run(
        [
            str(HOME / ".local/share/siverteh-ai/siverteh-shell/bin/qs"),
            "-c",
            "siverteh_shell",
            "ipc",
            "call",
            target,
            action,
        ],
        capture_output=True,
        text=True,
        timeout=2,
    )
    if result.returncode:
        raise RuntimeError("Desktop data unavailable")
    return result.stdout


def snapshot():
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    with CACHE.with_suffix(".lock").open("w") as guard:
        os.chmod(guard.name, 0o600)
        fcntl.flock(guard, fcntl.LOCK_EX)
        try:
            cached = json.loads(CACHE.read_text())
            if time.time() - cached.get("time", 0) < 2:
                return cached["data"]
        except (OSError, ValueError):
            pass
        try:
            data = json.loads(ipc("lockWidgets", "state"))
        except Exception:
            return {}  # Never display indefinitely stale notification contents.
        temp = CACHE.with_suffix(".tmp")
        temp.write_text(json.dumps(dict(time=time.time(), data=data)))
        temp.chmod(0o600)
        temp.replace(CACHE)
        return data


def plain(value, width=34, lines=2):
    text = " ".join(str(value or "").split())
    return html.escape("\n".join(textwrap.wrap(text, width=width)[:lines]))


def label(kind, data, settings):
    if kind == "weather":
        if not settings.get("lockWeather", True):
            return ""
        w = data.get("weather", {})
        desc = w.get("description")
        return (
            "<b>"
            + plain(w.get("location") or "Weather")
            + "</b>\n\n"
            + plain(w.get("temperature", "") if desc else "")
            + "\n"
            + plain(desc or w.get("error") or "Weather unavailable")
        )
    if kind == "media":
        if not settings.get("lockMedia", True):
            return ""
        m = data.get("media")
        if not m:
            return "<b>Media</b>\n\nNothing playing"
        return (
            "<b>"
            + plain(m.get("title") or "Untitled track")
            + "</b>\n"
            + plain(m.get("artist"))
            + "\n\n"
            + ("Playing" if m.get("playing") else "Paused")
        )
    if kind == "notifications":
        if not settings.get("lockNotifications", True):
            return ""
        rows = data.get("notifications", [])
        count = data.get("count", len(rows))
        output = ["<b>Notifications · " + str(count) + "</b>"]
        if not rows:
            return output[0] + "\n\nYou are all caught up"
        if settings.get("lockNotificationContents", False):
            for n in rows[:3]:
                output += [
                    "",
                    "<b>" + plain(n.get("app") or "Notification", lines=1) + "</b>",
                    plain(n.get("summary")),
                    plain(n.get("body"), lines=1),
                ]
        else:
            counts = {}
            for n in rows:
                counts[n.get("app") or "Notification"] = (
                    counts.get(n.get("app") or "Notification", 0) + 1
                )
            output += ["", "Message previews hidden", ""] + [
                plain(app, lines=1) for app in list(counts)[:5]
            ]
        return "\n".join(output)
    if kind == "status":
        batteries = []
        for path in Path("/sys/class/power_supply").glob("*/capacity"):
            try:
                batteries.append(path.read_text().strip() + "% battery")
            except OSError:
                pass
        return html.escape(" · ".join(batteries) or "Siverteh OS")
    if kind == "play-icon":
        return "pause" if (data.get("media") or {}).get("playing") else "play_arrow"
    return ""


def artwork(data):
    fallback = HOME / ".local/share/siverteh-ai/branding/sh.png"
    url = (data.get("media") or {}).get("art", "")
    output = CACHE.with_name("lock-art.png")
    metadata = CACHE.with_name("lock-art-source.json")
    try:
        saved = json.loads(metadata.read_text())
        if saved.get("url") == url and time.time() - saved.get("checked", 0) < 120:
            return str(output if saved.get("ok") and output.exists() else fallback)
    except (OSError, ValueError):
        pass
    ok = False
    try:
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme == "file":
            raw = Path(urllib.parse.unquote(parsed.path)).read_bytes()
        elif parsed.scheme == "https":
            with urllib.request.urlopen(url, timeout=4) as response:
                if urllib.parse.urlparse(response.url).scheme != "https":
                    raise ValueError("Unsupported artwork redirect")
                raw = response.read(4000001)
        else:
            raise ValueError("No artwork")
        if len(raw) > 4000000:
            raise ValueError("Artwork too large")
        with Image.open(io.BytesIO(raw)) as picture:
            if picture.width * picture.height > 20000000:
                raise ValueError("Artwork dimensions too large")
            picture.thumbnail((512, 512))
            picture.convert("RGB").save(output, format="PNG")
            output.chmod(0o600)
            ok = True
    except Exception:
        pass
    metadata.write_text(json.dumps(dict(url=url, checked=time.time(), ok=ok)))
    metadata.chmod(0o600)
    return str(output if ok else fallback)


def main():
    p = argparse.ArgumentParser()
    p.add_argument(
        "kind",
        choices=[
            "weather",
            "media",
            "notifications",
            "status",
            "art",
            "play-icon",
            "previous",
            "next",
            "toggle",
        ],
    )
    a = p.parse_args()
    try:
        settings = json.loads(
            (HOME / ".config/siverteh-shell/desktop.json").read_text()
        )
    except (OSError, ValueError):
        settings = {}
    if a.kind in ("previous", "next", "toggle"):
        if settings.get("lockMedia", True):
            ipc("mpris", "playPause" if a.kind == "toggle" else a.kind)
        return
    data = snapshot()
    if a.kind == "art":
        print(artwork(data) if settings.get("lockMedia", True) else "")
    else:
        print(label(a.kind, data, settings))


if __name__ == "__main__":
    main()
