#!/usr/bin/env python3
"""Local wallpaper catalog, video posters, private picker preferences and selection."""

import argparse, fcntl, hashlib, json, os, re, shutil, subprocess, sys, tempfile, urllib.parse, time
from pathlib import Path
from PIL import Image, ImageOps

HOME = Path.home()
LIBRARY = HOME / "Pictures/Wallpapers"
CACHE = HOME / ".cache/nacre/wallpaper-media"
STATE = HOME / ".local/state/nacre/wallpaper"
PREFS = HOME / ".config/nacre/wallpaper-picker.json"
IMAGES = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".tif", ".tiff"}
VIDEOS = {".mp4", ".webm", ".mkv", ".mov", ".avi", ".m4v"}


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(data, stream)
        os.chmod(name, 0o600)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def read(path, default):
    try:
        return json.loads(path.read_text())
    except FileNotFoundError:
        return default


def settings():
    result = dict(
        {
            "kind": "static",
            "layout": "carousel",
            "paused": False,
            "motionMode": "full",
            "pauseCovered": True,
            "rotationEnabled": False,
            "rotationMinutes": 30,
            "rotationKind": "all",
            "rotationShuffle": True,
            "palettePreset": "wallpaper",
            "paletteMode": "dark",
            "paletteHarmony": False,
        },
        **read(PREFS, {}),
    )

    if result["rotationEnabled"] and not result.get("rotationAnchorMs"):
        result["rotationAnchorMs"] = (
            int(PREFS.stat().st_mtime * 1000) if PREFS.exists() else 0
        )
    return result


def media_state():
    path = STATE / "media.json"
    result = read(path, {})
    if result and not result.get("appliedAtMs"):
        result["appliedAtMs"] = int(path.stat().st_mtime * 1000)
    return result


def palette_presets():
    return read(Path(__file__).with_name("palette-presets.json"), [])


def theme(value):
    if (
        not isinstance(value, dict)
        or not value
        or set(value)
        - {"palettePreset", "paletteMode", "paletteAccent", "paletteHarmony"}
    ):
        raise ValueError("Unknown appearance preference")
    accent = value.get("paletteAccent")
    if accent is not None and (
        not isinstance(accent, str) or not re.fullmatch(r"auto|[0-9a-fA-F]{6}", accent)
    ):
        raise ValueError("Choose a valid wallpaper accent")
    previous = settings()
    changes = {key: item for key, item in value.items() if key != "paletteAccent"}
    if accent is not None:
        changes["palettePreset"] = "wallpaper"
    poster = read(STATE / "media.json", {}).get("poster")
    if not poster:
        path = STATE / "last.txt"
        poster = path.read_text().strip() if path.exists() else ""
    if not poster or not Path(poster).is_file():
        raise ValueError("Choose a wallpaper before changing its palette")
    result = preference(changes)
    try:
        cli = HOME / ".local/share/nacre/shell/bin/nacre_shell"
        if accent is not None:
            args = [str(cli), "scheme", "set", "-n", "dynamic"]
            if "paletteMode" in value:
                args += ["-m", value["paletteMode"]]
            args += ["--auto-accent"] if accent == "auto" else ["--accent", accent]
            subprocess.run(args, check=True, capture_output=True, timeout=60)
        elif "paletteMode" in value:
            # A mode change generates and publishes once, with the saved harmony.
            subprocess.run(
                [str(cli), "scheme", "set", "-m", value["paletteMode"]],
                check=True,
                capture_output=True,
                timeout=60,
            )
        else:
            subprocess.run(
                [str(cli), "wallpaper", "-f", poster, "--no-smart"],
                check=True,
                capture_output=True,
                timeout=60,
            )
    except Exception:
        preference({key: previous[key] for key in changes})
        raise
    return result


def preference(value):
    allowed = {
        "kind": ("static", "dynamic"),
        "motionMode": ("full", "battery", "still"),
        "layout": ("carousel", "spotlight", "hexagons"),
        "rotationKind": ("all", "static", "dynamic"),
        "paletteMode": ("dark", "light"),
        "palettePreset": ("wallpaper", *[item["id"] for item in palette_presets()]),
    }
    boolean_keys = (
        "paused",
        "pauseCovered",
        "rotationEnabled",
        "rotationShuffle",
        "paletteHarmony",
    )
    if not isinstance(value, dict) or any(
        k not in (*allowed, *boolean_keys, "rotationMinutes") for k in value
    ):
        raise ValueError("Unknown picker preference")
    for k, v in value.items():
        if k in allowed and v not in allowed[k]:
            raise ValueError("Invalid picker preference")
        if k in boolean_keys and type(v) is not bool:
            raise ValueError("Expected a boolean preference")
        if k == "rotationMinutes" and (type(v) is not int or not 5 <= v <= 1440):
            raise ValueError("Choose a wallpaper interval between 5 and 1440 minutes")
    PREFS.parent.mkdir(parents=True, exist_ok=True)
    with PREFS.with_suffix(".lock").open("w") as lock:
        os.chmod(lock.name, 0o600)
        fcntl.flock(lock, fcntl.LOCK_EX)
        result = settings()
        previous = dict(result)
        result.update(value)
        if (result["rotationEnabled"] and not previous["rotationEnabled"]) or any(
            key in value and value[key] != previous[key]
            for key in ("rotationMinutes", "rotationKind")
        ):
            result["rotationAnchorMs"] = int(time.time() * 1000)
        atomic(PREFS, result)
        return result


def previews(poster):
    stat = poster.stat()
    key = hashlib.sha256(
        (
            str(poster) + str(stat.st_size) + str(stat.st_mtime_ns) + "preview-v1"
        ).encode()
    ).hexdigest()
    CACHE.mkdir(parents=True, exist_ok=True)
    files = {
        name: CACHE / (key + "-" + name + ".jpg") for name in ("thumbnail", "preview")
    }
    if any(not path.exists() for path in files.values()):
        with Image.open(poster) as image:
            image = ImageOps.exif_transpose(image).convert("RGB")
            for name, size in [("thumbnail", (640, 400)), ("preview", (1600, 1000))]:
                if files[name].exists():
                    continue
                resized = image.copy()
                resized.thumbnail(size, Image.Resampling.LANCZOS)
                fd, temp = tempfile.mkstemp(dir=CACHE, suffix=".jpg")
                os.close(fd)
                try:
                    resized.save(temp, quality=88, optimize=False)
                    os.chmod(temp, 0o600)
                    os.replace(temp, files[name])
                finally:
                    Path(temp).unlink(missing_ok=True)
    return {name: str(path) for name, path in files.items()}


def describe(path):
    path = Path(path).expanduser().resolve()
    if not path.is_file() or path.suffix.lower() not in IMAGES | VIDEOS:
        raise ValueError("Select a local image, GIF or video")
    animated = False
    if path.suffix.lower() == ".gif":
        with Image.open(path) as image:
            animated = getattr(image, "n_frames", 1) > 1
    dynamic = path.suffix.lower() in VIDEOS or animated
    poster = path
    if dynamic:
        stat = path.stat()
        key = hashlib.sha256(
            (str(path) + str(stat.st_size) + str(stat.st_mtime_ns)).encode()
        ).hexdigest()
        CACHE.mkdir(parents=True, exist_ok=True)
        poster = CACHE / (key + ".png")
        if not poster.exists():
            fd, name = tempfile.mkstemp(dir=CACHE, suffix=".png")
            os.close(fd)
            temporary = Path(name)
            try:
                if animated:
                    with Image.open(path) as image:
                        image.seek(0)
                        image = image.convert("RGB")
                        image.thumbnail((1920, 1080))
                        image.save(temporary)
                else:
                    subprocess.run(
                        [
                            "ffmpeg",
                            "-nostdin",
                            "-v",
                            "error",
                            "-threads",
                            "2",
                            "-i",
                            str(path),
                            "-frames:v",
                            "1",
                            "-vf",
                            "scale=1920:1080:force_original_aspect_ratio=decrease",
                            "-y",
                            str(temporary),
                        ],
                        capture_output=True,
                        timeout=30,
                        check=True,
                    )
                with Image.open(temporary) as image:
                    image.verify()
                temporary.chmod(0o600)
                temporary.replace(poster)
            finally:
                temporary.unlink(missing_ok=True)
    return dict(
        path=str(path),
        name=path.stem.replace("_", " "),
        poster=str(poster),
        dynamic=dynamic,
        animated=animated,
        **previews(poster),
    )


def catalog():
    LIBRARY.mkdir(parents=True, exist_ok=True)
    (LIBRARY / "Dynamic").mkdir(exist_ok=True)
    rows = []
    errors = []
    for path in sorted(LIBRARY.rglob("*"), key=lambda p: str(p).casefold()):
        if path.is_file() and path.suffix.lower() in IMAGES | VIDEOS:
            try:
                rows.append(describe(path))
            except Exception:
                errors.append(path.name)
    return dict(
        entries=rows,
        preferences=settings(),
        media=media_state(),
        errors=errors,
        palettes=[
            dict(
                {key: item[key] for key in ("id", "name", "seed", "group")},
                swatches=[
                    item["modes"]["dark"][key]
                    for key in ("primary", "secondary", "tertiary")
                ],
                surface=item["modes"]["dark"]["surface"],
            )
            for item in palette_presets()
        ],
    )


def palette_marker(poster, flavour):
    poster = Path(poster)
    stat = poster.stat()
    cli = HOME / ".local/share/nacre/palette-runtime/venv/bin/nacre_shell"
    marker = cli.parents[2] / "orient-build.json"
    engine = (
        marker.read_text()
        if marker.exists()
        else str(cli.stat().st_mtime_ns)
        if cli.exists()
        else "uninstalled"
    )
    scheme = read(HOME / ".local/state/nacre/scheme.json", {})
    config = read(HOME / ".config/nacre/cli.json", {})
    generation = json.dumps(
        {
            "mode": scheme.get("mode", "dark"),
            "variant": scheme.get("variant", "tonalspot"),
            "orient": config.get("orient", {}),
            "harmony": settings().get("paletteHarmony", False),
        },
        sort_keys=True,
    )
    key = hashlib.sha256(
        (
            str(poster)
            + str(stat.st_size)
            + str(stat.st_mtime_ns)
            + str(stat.st_ctime_ns)
            + str(stat.st_ino)
            + str(flavour)
            + engine
            + generation
            + "palette-warm-orient-v3"
        ).encode()
    ).hexdigest()
    return CACHE / (key + ".palette.json")


def warm():
    # Read-only preparation never publishes a wallpaper, palette or login theme.
    # One low-priority worker survives overlapping startup requests via a lock.
    CACHE.mkdir(parents=True, exist_ok=True)
    with (CACHE / "warm.lock").open("w") as lock:
        os.chmod(lock.name, 0o600)
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return {"busy": True}
        cli = HOME / ".local/share/nacre/palette-runtime/venv/bin/nacre_shell"
        import importlib.util

        spec = importlib.util.spec_from_file_location(
            "login", Path(__file__).with_name("login-appearance.py")
        )
        login = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(login)
        # The selected wallpaper gets both supporting-color treatments first.
        # These query calls only fill private caches; no palette is published.
        current_poster = media_state().get("poster")
        if current_poster and cli.exists() and Path(current_poster).is_file():
            brand_spec = importlib.util.spec_from_file_location(
                "branding", Path(__file__).with_name("branding.py")
            )
            brand = importlib.util.module_from_spec(brand_spec)
            brand_spec.loader.exec_module(brand)
            for treatment in ("--no-harmony", "--harmony"):
                try:
                    result = subprocess.run(
                        [str(cli), "wallpaper", "-p", current_poster, treatment],
                        capture_output=True,
                        text=True,
                        check=True,
                        timeout=30,
                    )
                    brand.prepare(json.loads(result.stdout)["colours"], HOME)
                except (OSError, ValueError, KeyError, subprocess.SubprocessError):
                    continue
        prepared = 0
        computed = 0
        flavour = read(HOME / ".local/state/nacre/scheme.json", {}).get(
            "flavour", "default"
        )
        for item in catalog()["entries"]:
            try:
                poster = Path(item["poster"])
                marker = palette_marker(poster, flavour)
                if cli.exists() and not marker.exists():
                    result = subprocess.run(
                        [str(cli), "wallpaper", "-p", str(poster)],
                        capture_output=True,
                        text=True,
                        check=True,
                        timeout=30,
                    )
                    atomic(marker, json.loads(result.stdout))
                    computed += 1
                login.prepare(item["poster"])
                prepared += 1
            except (OSError, ValueError, subprocess.SubprocessError):
                continue
        return {"prepared": prepared, "computed": computed}


def select(path):
    item = describe(path)
    # Prepared colors still pass through the single publisher and its shared lock.
    # Missing/stale/invalid cache or custom CLI hooks use the normal CLI pipeline.
    prepared = False
    scheme = read(HOME / ".local/state/nacre/scheme.json", {})
    marker = palette_marker(item["poster"], scheme.get("flavour", "default"))
    if marker.exists():
        try:
            data = read(marker, {})
            digest = hashlib.sha256(Path(item["poster"]).read_bytes()).hexdigest()
            thumbnail = HOME / ".cache/nacre/wallpapers" / digest / "thumbnail.jpg"
            import importlib.util

            spec = importlib.util.spec_from_file_location(
                "palette", Path(__file__).with_name("classic-state.py")
            )
            palette = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(palette)
            prepared = palette.commit_prepared(HOME, item["poster"], data, thumbnail)
        except (OSError, ValueError, KeyError):
            prepared = False
    if not prepared:
        subprocess.run(
            [
                str(HOME / ".local/bin/nacre-shell"),
                "wallpaper-image",
                item["poster"],
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            timeout=60,
        )
    item["appliedAtMs"] = int(time.time() * 1000)
    atomic(STATE / "media.json", item)
    return item


def import_files(paths):
    copied = []
    for value in paths:
        source = (
            Path(
                urllib.parse.unquote(urllib.parse.urlparse(value).path)
                if str(value).startswith("file:")
                else value
            )
            .expanduser()
            .resolve()
        )
        item = describe(source)
        if source.is_relative_to(LIBRARY.resolve()):
            copied.append(str(source))
            continue
        folder = LIBRARY / ("Dynamic" if item["dynamic"] else "Static")
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / source.name
        index = 1
        while target.exists():
            target = folder / (source.stem + "-" + str(index) + source.suffix)
            index += 1
        temporary = target.with_name(target.name + ".importing")
        try:
            shutil.copy2(source, temporary)
            temporary.chmod(0o600)
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)
        copied.append(str(target))
    return copied


def main():
    p = argparse.ArgumentParser()
    p.add_argument(
        "action",
        choices=[
            "catalog",
            "select",
            "preferences",
            "theme",
            "import",
            "pick",
            "session",
            "warm",
        ],
    )
    p.add_argument("path", nargs="?")
    a = p.parse_args()
    try:
        if a.action == "session":
            display = subprocess.check_output(
                [
                    "loginctl",
                    "show-user",
                    str(os.getuid()),
                    "--property=Display",
                    "--value",
                ],
                text=True,
                timeout=3,
            ).strip()
            if not display:
                result = {"locked": False, "path": ""}
            else:
                locked = (
                    subprocess.check_output(
                        [
                            "loginctl",
                            "show-session",
                            display,
                            "--property=LockedHint",
                            "--value",
                        ],
                        text=True,
                        timeout=3,
                    ).strip()
                    == "yes"
                )
                raw = subprocess.check_output(
                    [
                        "busctl",
                        "--system",
                        "call",
                        "org.freedesktop.login1",
                        "/org/freedesktop/login1",
                        "org.freedesktop.login1.Manager",
                        "GetSession",
                        "s",
                        display,
                    ],
                    text=True,
                    timeout=3,
                ).strip()
                result = {"locked": locked, "path": raw.split(" ", 1)[1].strip('"')}
        elif a.action == "catalog":
            result = catalog()
        elif a.action == "warm":
            result = warm()
        elif a.action == "select":
            result = select(a.path)
        elif a.action in ("preferences", "theme"):
            value = json.loads(sys.stdin.readline())
            result = theme(value) if a.action == "theme" else preference(value)
        else:
            if a.action == "pick":
                picker = subprocess.run(
                    [
                        "zenity",
                        "--file-selection",
                        "--multiple",
                        "--separator=\n",
                        "--title=Add wallpapers",
                        "--file-filter=Wallpapers | *.png *.jpg *.jpeg *.webp *.gif *.mp4 *.webm *.mkv *.mov *.m4v",
                    ],
                    capture_output=True,
                    text=True,
                )
                if picker.returncode:
                    print(json.dumps({"cancelled": True}))
                    return
                paths = picker.stdout.strip().splitlines()
            else:
                paths = json.loads(sys.stdin.readline())
            result = {"imported": import_files(paths)}
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()
