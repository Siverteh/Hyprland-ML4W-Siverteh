#!/usr/bin/env python3
"""Commit one wallpaper palette to the shell, window frame and native choosers."""

import fcntl, json, os, re, signal, subprocess, sys, tempfile, time
from pathlib import Path


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix="." + path.name, dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(text)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


def atomic_symlink(path, target):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent)
    os.close(fd)
    os.unlink(name)
    try:
        Path(name).symlink_to(target)
        os.replace(name, path)
    finally:
        Path(name).unlink(missing_ok=True)


def commit_prepared(home, wallpaper, data, thumbnail, live=True):
    """Use a validated read-only cache through this same palette publisher."""
    home = Path(home)
    state = home / ".local/state/siverteh_shell"
    image = Path(wallpaper).resolve()
    thumbnail = Path(thumbnail).resolve()
    if not image.is_file() or not thumbnail.is_file():
        return False
    if not thumbnail.is_relative_to(
        (home / ".cache/siverteh_shell/wallpapers").resolve()
    ):
        return False
    try:
        roles = json.loads(
            Path(__file__).with_name("reference-style.json").read_text()
        )["colours"]
        colors = data["colours"]
        if data["name"] != "dynamic" or data["mode"] not in ("light", "dark"):
            return False
        if not isinstance(colors, dict) or not roles.keys() <= colors.keys():
            return False
        if any(
            not isinstance(v, str) or not re.fullmatch("#?[0-9a-fA-F]{6}", v)
            for v in colors.values()
        ):
            return False
        if any(
            not isinstance(data[k], str)
            or not re.fullmatch("[a-zA-Z0-9_-]{1,40}", data[k])
            for k in ("flavour", "variant")
        ):
            return False
        config = home / ".config/siverteh_shell/cli.json"
        if config.exists() and json.loads(config.read_text()).get("wallpaper", {}).get(
            "postHook"
        ):
            return False
    except (OSError, ValueError, KeyError, TypeError):
        return False
    state.mkdir(parents=True, exist_ok=True)
    with (state / "palette-commit.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            current = json.loads((state / "scheme.json").read_text())
        except (OSError, ValueError):
            return False
        if (
            current.get("name") != "dynamic"
            or current.get("flavour") != data["flavour"]
        ):
            return False
        atomic_write(state / "scheme.json", json.dumps(data))
        atomic_write(state / "wallpaper/path.txt", str(image))
        atomic_symlink(state / "wallpaper/current", image)
        atomic_symlink(state / "wallpaper/thumbnail.jpg", thumbnail)
        apply_palette(home, str(image), live=live)
    return True


def luminance(value):
    rgb = [int(value.lstrip("#")[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    rgb = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in rgb]
    return sum(v * w for v, w in zip(rgb, (0.2126, 0.7152, 0.0722)))


def readable(value, background, minimum=4.5):
    rgb = [int(value.lstrip("#")[i : i + 2], 16) for i in (0, 2, 4)]
    bg = luminance(background)
    for _ in range(100):
        result = "".join(f"{v:02x}" for v in rgb)
        fg = luminance(result)
        if (max(bg, fg) + 0.05) / (min(bg, fg) + 0.05) >= minimum:
            return result
        rgb = (
            [max(0, int(v * 0.92)) for v in rgb]
            if bg > 0.5
            else [min(255, int(v + max(1, (255 - v) * 0.08))) for v in rgb]
        )
    return "000000" if bg > 0.5 else "ffffff"


def apply_palette(home, wallpaper=None, live=True):
    state = home / ".local/state/siverteh_shell"
    data = json.loads((state / "scheme.json").read_text())
    preferences = home / ".config/siverteh-shell/wallpaper-picker.json"
    options = json.loads(preferences.read_text()) if preferences.exists() else {}
    preset = options.get("palettePreset", "wallpaper")
    if preset != "wallpaper":
        presets = json.loads(
            Path(__file__).with_name("palette-presets.json").read_text()
        )
        chosen = next((item for item in presets if item["id"] == preset), None)
        mode = options.get("paletteMode", "dark")
        if chosen is None or mode not in ("dark", "light"):
            raise ValueError("Invalid fixed palette preference")
        data = dict(data, mode=mode, colours=chosen["modes"][mode])
        # The CLI remains the scheme owner; all publishers resolve this preference.
        atomic_write(state / "scheme.json", json.dumps(data))
    colors = {k: v.lstrip("#") for k, v in data["colours"].items()}
    if any(not re.fullmatch("[0-9a-fA-F]{6}", v) for v in colors.values()):
        raise ValueError("Invalid palette color")
    # Validate required roles before publishing any state.
    primary, secondary, inactive, shadow = (
        colors[k] for k in ("primary", "secondary", "outlineVariant", "shadow")
    )
    selected = (
        str(Path(wallpaper).expanduser().resolve())
        if wallpaper
        else (
            (state / "wallpaper/last.txt").read_text().strip()
            if (state / "wallpaper/last.txt").exists()
            else ""
        )
    )
    if selected:
        presentation = state / "presentation.json"
        previous = json.loads(presentation.read_text()) if presentation.exists() else {}
        changed_at = (
            previous.get("changedAtMs", 0) if previous.get("poster") == selected else 0
        )
        if not changed_at and previous.get("poster") == selected:
            media_path = state / "wallpaper/media.json"
            media = json.loads(media_path.read_text()) if media_path.exists() else {}
            if media.get("poster") == selected:
                changed_at = media.get("appliedAtMs") or int(
                    media_path.stat().st_mtime * 1000
                )
            else:
                changed_at = int(presentation.stat().st_mtime * 1000)
        if not changed_at:
            changed_at = int(time.time() * 1000)
        atomic_write(
            state / "presentation.json",
            json.dumps(
                {
                    "version": 1,
                    "changedAtMs": changed_at,
                    "mode": data["mode"],
                    "colours": colors,
                    "poster": selected,
                }
            ),
        )
    # Publish the native shell palette before slower compatibility/login assets.
    atomic_write(state / "scheme/current-mode.txt", data["mode"])
    atomic_write(
        state / "scheme/current.txt",
        "\n".join(k + " " + v for k, v in colors.items()) + "\n",
    )
    lua = (
        'hl.config({general={col={active_border={colors={"rgba('
        + primary
        + 'ff)","rgba('
        + secondary
        + 'ff)"},angle=45},inactive_border="rgba('
        + inactive
        + 'aa)"}},decoration={shadow={color="rgba('
        + shadow
        + '40)"}}})\n'
    )
    atomic_write(home / ".config/siverteh-shell/palette.lua", lua)
    template = Path(__file__).with_name("rofi.rasi").read_text()
    roles = {
        "bg": "surface",
        "raised": "surfaceContainer",
        "text": "onSurface",
        "muted": "onSurfaceVariant",
        "accent": "primary",
        "border": "outlineVariant",
    }
    for token, role in roles.items():
        template = re.sub(
            r"\b" + token + r": #[0-9a-fA-F]{6};",
            token + ": #" + colors[role] + ";",
            template,
        )
    atomic_write(home / ".config/siverteh-shell/rofi.rasi", template)
    # GTK and qtct use the same committed palette, rather than the old blue files.
    gtk_roles = {
        "accent_color": "primary",
        "accent_bg_color": "primary",
        "accent_fg_color": "onPrimary",
        "window_bg_color": "surface",
        "window_fg_color": "onSurface",
        "headerbar_bg_color": "surfaceContainer",
        "headerbar_fg_color": "onSurface",
        "popover_bg_color": "surfaceContainer",
        "popover_fg_color": "onSurface",
        "view_bg_color": "surface",
        "view_fg_color": "onSurface",
        "sidebar_bg_color": "surfaceContainerLow",
        "sidebar_fg_color": "onSurface",
        "sidebar_backdrop_color": "surfaceContainerLow",
        "secondary_sidebar_bg_color": "surfaceContainer",
        "secondary_sidebar_fg_color": "onSurface",
        "secondary_sidebar_backdrop_color": "surfaceContainer",
        "headerbar_backdrop_color": "surfaceContainer",
        "card_bg_color": "surfaceContainerLow",
        "card_fg_color": "onSurface",
        "theme_bg_color": "surface",
        "theme_fg_color": "onSurface",
        "theme_base_color": "surface",
        "theme_text_color": "onSurface",
        "theme_selected_bg_color": "primary",
        "theme_selected_fg_color": "onPrimary",
    }
    gtk = "".join(
        "@define-color " + name + " #" + colors[role] + ";\n"
        for name, role in gtk_roles.items()
    )
    import importlib.util

    icon_spec = importlib.util.spec_from_file_location(
        "file_icons", Path(__file__).with_name("file-icons.py")
    )
    icon_module = importlib.util.module_from_spec(icon_spec)
    icon_spec.loader.exec_module(icon_module)
    icon_theme = icon_module.theme(home, colors["primary"], data["mode"])
    for version in ("3.0", "4.0"):
        directory = home / (".config/gtk-" + version)
        css = gtk
        if version == "4.0":
            # Libadwaita 1.6+ consumes CSS variables rather than the old names.
            modern = {
                name.replace("_", "-"): role
                for name, role in gtk_roles.items()
                if not name.startswith("theme_")
            }
            css += (
                "\n:root {\n"
                + "".join(
                    "  --" + name + ": #" + colors[role] + ";\n"
                    for name, role in modern.items()
                )
                + "}\n"
            )
        atomic_write(directory / "gtk.css", css)
        settings = directory / "settings.ini"
        if settings.exists():
            text = settings.read_text()
            text = re.sub(
                r"(?m)^gtk-application-prefer-dark-theme\s*=.*$",
                "gtk-application-prefer-dark-theme="
                + ("1" if data["mode"] == "dark" else "0"),
                text,
            )
            text = re.sub(
                r"(?m)^gtk-theme-name\s*=.*$",
                "gtk-theme-name=Adwaita" + ("-dark" if data["mode"] == "dark" else ""),
                text,
            )
            if icon_theme:
                text = re.sub(
                    r"(?m)^gtk-icon-theme-name\s*=.*$",
                    "gtk-icon-theme-name=" + icon_theme,
                    text,
                )
                if not re.search(r"(?m)^gtk-icon-theme-name=", text):
                    text += "\ngtk-icon-theme-name=" + icon_theme + "\n"
            atomic_write(settings, text)
    kde_spec = importlib.util.spec_from_file_location(
        "kde_palette", Path(__file__).with_name("kde-palette.py")
    )
    kde_module = importlib.util.module_from_spec(kde_spec)
    kde_spec.loader.exec_module(kde_module)
    kde_module.publish(home, colors, icon_theme)
    # Numeric order follows Qt QPalette::ColorRole, including Accent in Qt 6.
    qt_roles = [
        "onSurface",
        "surfaceContainer",
        "surfaceBright",
        "surfaceContainerHigh",
        "surfaceDim",
        "outlineVariant",
        "onSurface",
        "onPrimary",
        "onSurface",
        "surface",
        "surface",
        "shadow",
        "primary",
        "onPrimary",
        "primary",
        "tertiary",
        "surfaceContainerLow",
        "onSurface",
        "surfaceContainer",
        "onSurface",
        "onSurfaceVariant",
        "primary",
    ]
    qt = "[ColorScheme]\n" + "".join(
        group + "_colors=" + ", ".join("#ff" + colors[role] for role in qt_roles) + "\n"
        for group in ("active", "inactive", "disabled")
    )
    qt_path = home / ".config/siverteh-shell/qt.conf"
    atomic_write(qt_path, qt)
    for version in (5, 6):
        settings = home / f".config/qt{version}ct/qt{version}ct.conf"
        if settings.exists():
            text = re.sub(
                r"(?m)^color_scheme_path\s*=.*$",
                "color_scheme_path=" + str(qt_path),
                settings.read_text(),
            )
            text = re.sub(r"(?m)^custom_palette\s*=.*$", "custom_palette=true", text)
            if icon_theme:
                text = re.sub(
                    r"(?m)^icon_theme\s*=.*$", "icon_theme=" + icon_theme, text
                )
            atomic_write(settings, text)
    if live:
        # Native KDE apps react in-place; no polling or application restarts.
        for change in (0, 4):
            subprocess.run(
                [
                    "dbus-send",
                    "--session",
                    "--type=signal",
                    "/KGlobalSettings",
                    "org.kde.KGlobalSettings.notifyChange",
                    "int32:" + str(change),
                    "int32:0",
                ],
                capture_output=True,
                timeout=3,
            )
    # Existing updater prompts and terminal apps share the committed colors too.
    for name, role in {
        "primary": "primary",
        "secondary": "secondary",
        "onsurface": "onSurface",
        "onprimary": "onPrimary",
        "surface": "surface",
        "surfacecontainer": "surfaceContainer",
    }.items():
        atomic_write(
            home / (".config/siverteh-shell/colors/" + name), "#" + colors[role]
        )
    # Terminal TUIs often paint dark input panels regardless of the desktop mode.
    # Use the same palette's inverse roles on light wallpapers, preserving its hue.
    term_bg = colors["inverseSurface"] if data["mode"] == "light" else colors["surface"]
    term_fg = (
        colors["inverseOnSurface"] if data["mode"] == "light" else colors["onSurface"]
    )
    term_accent = readable(
        colors["inversePrimary"] if data["mode"] == "light" else colors["primary"],
        term_bg,
    )
    term_muted = readable(colors["onSurfaceVariant"], term_bg)
    terminal_roles = {
        "foreground": term_fg,
        "background": term_bg,
        "cursor": term_accent,
        "cursor_text_color": term_bg,
        "selection_foreground": term_bg,
        "selection_background": term_accent,
        "url_color": readable(colors["tertiary"], term_bg),
        "active_border_color": colors["primary"],
        "inactive_border_color": colors["outlineVariant"],
        "active_tab_foreground": term_bg,
        "active_tab_background": term_accent,
        "inactive_tab_foreground": term_muted,
        "inactive_tab_background": term_bg,
    }
    terminal = (
        "".join(name + " #" + value + "\n" for name, value in terminal_roles.items())
        + "background_opacity 0.98\n"
    )
    ansi = [
        "onSurface",
        "error",
        "green",
        "yellow",
        "blue",
        "mauve",
        "teal",
        "onSurface",
    ]
    for i, role in enumerate(ansi):
        value = (
            term_bg
            if i == 0
            else term_fg
            if i == 7
            else term_accent
            if i == 4
            else readable(colors.get(role, colors["primary"]), term_bg)
        )
        bright = (
            term_muted
            if i == 0
            else readable(colors["secondary"], term_bg)
            if i == 6
            else value
        )
        terminal += f"color{i} #{value}\ncolor{i + 8} #{bright}\n"
    atomic_write(home / ".config/siverteh-shell/kitty-colors.conf", terminal)
    brand = Path(__file__).with_name("branding.py")
    if brand.exists():
        import importlib.util

        spec = importlib.util.spec_from_file_location("brand", brand)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        module.publish(colors, home)
    selected = (
        str(Path(wallpaper).expanduser().resolve())
        if wallpaper
        else (
            (state / "wallpaper/last.txt").read_text().strip()
            if (state / "wallpaper/last.txt").exists()
            else ""
        )
    )
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "lock_config", Path(__file__).with_name("lock-config.py")
    )
    lock_config = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(lock_config)
    try:
        preferences = json.loads(
            (home / ".config/siverteh-shell/desktop.json").read_text()
        )
    except (OSError, ValueError):
        preferences = {}
    atomic_write(
        home / ".config/hypr/hyprlock.conf",
        lock_config.render(
            colors,
            selected,
            preferences,
            home / ".local/share/siverteh-ai/siverteh-shell/tools/lock-info.py",
        ),
    )
    # Login appearance is public wallpaper/color data; authentication remains SDDM-owned.
    publisher = Path(__file__).with_name("login-appearance.py")
    if selected and publisher.exists():
        try:
            import importlib.util

            spec = importlib.util.spec_from_file_location("login_appearance", publisher)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            module.publish(
                colors,
                selected,
                home / ".local/state/siverteh-native-shell/login-preview",
            )
        except (OSError, ValueError, ImportError):
            pass  # A login-theme image failure must not interrupt the desktop palette.

    if wallpaper is not None:
        atomic_write(
            state / "wallpaper/last.txt", str(Path(wallpaper).expanduser().resolve())
        )
    if live:
        # Kitty documents SIGUSR1 as a config reload; it leaves terminal sessions running.
        for proc in Path("/proc").iterdir():
            if not proc.name.isdigit():
                continue
            try:
                if (
                    proc.stat().st_uid == os.getuid()
                    and (proc / "comm").read_text().strip() == "kitty"
                ):
                    os.kill(int(proc.name), signal.SIGUSR1)
            except (OSError, ProcessLookupError):
                pass
        subprocess.run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "cursor-theme",
                "breeze_cursors",
            ],
            capture_output=True,
        )
        subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.interface", "cursor-size", "24"],
            capture_output=True,
        )
        subprocess.run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "color-scheme",
                "prefer-" + data["mode"],
            ],
            capture_output=True,
        )
        subprocess.run(
            [
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "gtk-theme",
                "Adwaita" + ("-dark" if data["mode"] == "dark" else ""),
            ],
            capture_output=True,
        )
        if icon_theme:
            subprocess.run(
                [
                    "gsettings",
                    "set",
                    "org.gnome.desktop.interface",
                    "icon-theme",
                    icon_theme,
                ],
                capture_output=True,
            )
        result = subprocess.run(
            ["hyprctl", "eval", lua], capture_output=True, text=True
        )
        if result.returncode:
            print(
                "Palette saved; live window-border update failed: "
                + result.stderr.strip(),
                file=sys.stderr,
            )


if __name__ == "__main__":
    apply_palette(Path.home(), sys.argv[1] if len(sys.argv) > 1 else None)
