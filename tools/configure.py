#!/usr/bin/env python3
"""Deploy reviewed configuration copies, detect drift and retain private rollback."""

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile

ROOT = Path(__file__).resolve().parent.parent
ACTIVE_DIRS = (
    "uwsm",
    "hypr",
    "kitty",
    "fastfetch",
    "fish",
    "gtk-3.0",
    "gtk-4.0",
    "rofi",
)
RETIRED_DIRS = (
    "waybar",
    "swaync",
    "waypaper",
    "wlogout",
    "matugen",
    "nwg-dock-hyprland",
    "kanshi",
)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None


def files(root=ROOT):
    result = {}
    for folder in ("hypr", "kitty", "fastfetch", "fish", "uwsm"):
        for source in (root / folder).rglob("*"):
            if source.is_file():
                result[Path(".config") / source.relative_to(root)] = source
    for name in ("siverteh-os-app", "xdg-open"):
        result[Path(".local/bin") / name] = root / "bin" / name
    return result


def atomic(path, data, mode=0o644):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(dir=path.parent, prefix="." + path.name)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
        os.chmod(temp, mode)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)


IDLE_WRAPPER = "# Host locking policy is private; installation seeds it only once.\nsource = ~/.config/siverteh-shell/hypridle.local.conf\n"


POWER_TAIL = '\n-- Local manual power-button and display-wake preference.\nrequire("conf.manual-power")\n'


def power_policy(home, root, migrate_idle):
    if not migrate_idle:
        return None
    current = home / ".config/hypr/hyprland.lua"
    source = root / "hypr/hyprland.lua"
    if not current.exists() or not source.exists():
        return None
    # Accept only this recognized historical addition, never arbitrary Lua drift.
    old_base = source.read_text().split("\n-- Optional private host behavior.")[0]
    if current.read_text() != old_base + POWER_TAIL:
        return None
    content = (home / ".config/hypr/conf/manual-power.lua").read_bytes()
    private = home / ".config/siverteh-shell/host.lua"
    if private.exists() and private.read_bytes() != content:
        raise RuntimeError("Private host policy differs; reconcile it before migration")
    return content


def idle_policy(home, root, migrate_idle):
    source = root / "hypr/hypridle.conf"
    if not source.exists() or source.read_text() != IDLE_WRAPPER:
        return None
    private = home / ".config/siverteh-shell/hypridle.local.conf"
    current = home / ".config/hypr/hypridle.conf"
    if migrate_idle and current.exists() and current.read_text() != IDLE_WRAPPER:
        content = current.read_bytes()
        if private.exists() and private.read_bytes() != content:
            raise RuntimeError(
                "Private idle policy differs; reconcile it before migration"
            )
        return content
    if not private.exists():
        return (root / "tools/defaults/hypridle.conf").read_bytes()
    return None


def plan(home, root=ROOT, migrate=False, app_routes_only=False, migrate_idle=False):
    if not app_routes_only:
        idle_policy(home, root, migrate_idle)
        power_policy(home, root, migrate_idle)
    manifest = home / ".local/state/siverteh-os/configuration.json"
    known = json.loads(manifest.read_text()) if manifest.exists() else {}
    desired = files(root)
    if app_routes_only:
        desired = {
            path: source
            for path, source in desired.items()
            if path.parent == Path(".local/bin")
        }
    links = {}
    for name in (*ACTIVE_DIRS, *RETIRED_DIRS):
        if app_routes_only:
            continue
        path = home / ".config" / name
        if path.is_symlink():
            target = path.resolve()
            managed = {
                relative: value
                for relative, value in known.items()
                if Path(relative).is_relative_to(Path(".config") / name)
            }
            managed_fish = (
                name == "fish"
                and bool(managed)
                and all(
                    digest(home / relative) == value
                    for relative, value in managed.items()
                )
            )
            source_tree = (target.parent / ".git").exists()
            if (
                not migrate
                or target.name != name
                or not target.is_dir()
                or not (source_tree or managed_fish)
            ):
                raise RuntimeError(
                    f"Refusing to replace configuration symlink: {path}; review --migrate-owned"
                )
            links[path] = target
    changed = []
    for relative, source in desired.items():
        dest = home / relative
        current, wanted = digest(dest), digest(source)
        if current == wanted and not any(dest.is_relative_to(p) for p in links):
            continue
        owned_link = any(dest.is_relative_to(p) for p in links)
        if dest.is_symlink():
            owned_link = owned_link or (
                migrate
                and dest.resolve().name == source.name
                and (dest.resolve().parent.parent / ".git").exists()
            )
        if (
            current is not None
            and not owned_link
            and current != known.get(str(relative))
            and not (
                relative == Path(".config/hypr/hyprland.lua")
                and power_policy(home, root, migrate_idle) is not None
            )
            and not (
                migrate_idle
                and relative == Path(".config/hypr/hypridle.conf")
                and source.read_text() == IDLE_WRAPPER
            )
        ):
            raise RuntimeError(f"Local edit preserved: {dest}")
        changed.append((relative, source))
    for relative, previous in known.items():
        if app_routes_only and Path(relative).name not in (
            "siverteh-os-app",
            "xdg-open",
        ):
            continue
        if Path(relative) in desired:
            continue
        dest = home / relative
        if not dest.exists():
            continue
        if digest(dest) != previous:
            raise RuntimeError(f"Local edit preserved: {dest}")
        changed.append((Path(relative), None))
    return changed, links, known


def apply(home, root=ROOT, migrate=False, app_routes_only=False, migrate_idle=False):
    changed, links, known = plan(home, root, migrate, app_routes_only, migrate_idle)
    host_policy = None if app_routes_only else power_policy(home, root, migrate_idle)
    if host_policy is not None:
        atomic(home / ".config/siverteh-shell/host.lua", host_policy, 0o600)
    policy = None if app_routes_only else idle_policy(home, root, migrate_idle)
    if policy is not None:
        atomic(home / ".config/siverteh-shell/hypridle.local.conf", policy, 0o600)
    if not changed and not links:
        atomic(
            home / ".local/state/siverteh-os/configuration.json",
            json.dumps(
                (
                    {
                        **known,
                        **{
                            str(p): digest(home / p)
                            for p in files(root)
                            if p.parent == Path(".local/bin")
                        },
                    }
                    if app_routes_only
                    else {str(p): digest(home / p) for p in files(root)}
                ),
                indent=2,
            ).encode(),
            0o600,
        )
        return None
    backup = (
        home
        / ".local/state/siverteh-os/backups"
        / dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    )
    backup.mkdir(parents=True, mode=0o700)
    entries = []
    # Capture every directory before unlinking it. Generated files remain private.
    for dest, target in links.items():
        saved = backup / dest.relative_to(home)
        shutil.copytree(target, saved, symlinks=True)
        entries.append(dict(path=str(dest), backup=str(saved), link=str(target)))
    monitor = home / ".config/hypr/conf/monitor.lua"
    private_monitor = home / ".config/siverteh-shell/monitor.lua"
    if (
        home / ".config/hypr" in links
        and monitor.exists()
        and not private_monitor.exists()
    ):
        atomic(private_monitor, monitor.read_bytes())
    for dest, target in links.items():
        saved = backup / dest.relative_to(home)
        dest.unlink()
        if dest.name in RETIRED_DIRS:
            continue
        if dest.name == "fish":
            shutil.copytree(saved, dest, symlinks=True)
            continue
        dest.mkdir()
        # Preserve explicit user overrides and the current lock appearance.
        for rel in ("custom.conf", "hyprlock.conf", "settings.ini", "config.rasi"):
            if (saved / rel).is_file():
                shutil.copy2(saved / rel, dest / rel)
    for relative, source in changed:
        dest = home / relative
        if dest.exists() or dest.is_symlink():
            saved = backup / relative
            saved.parent.mkdir(parents=True, exist_ok=True)
            if not saved.exists():
                shutil.copy2(dest, saved)
            entries.append(dict(path=str(dest), backup=str(saved)))
        else:
            entries.append(dict(path=str(dest), backup=None))
        if source is None:
            dest.unlink(missing_ok=True)
            known.pop(str(relative), None)
        else:
            atomic(
                dest,
                source.read_bytes(),
                0o755 if os.access(source, os.X_OK) else 0o644,
            )
            known[str(relative)] = digest(dest)
    atomic(
        home / ".local/state/siverteh-os/configuration.json",
        json.dumps(known, indent=2).encode(),
        0o600,
    )
    atomic(backup / "manifest.json", json.dumps(entries, indent=2).encode(), 0o600)
    return backup


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--apply", action="store_true")
    p.add_argument("--migrate-owned", action="store_true")
    p.add_argument(
        "--app-routes-only",
        action="store_true",
        help="deploy native app launch routes without touching compositor config",
    )
    p.add_argument(
        "--migrate-idle-override",
        action="store_true",
        help="preserve the current full idle policy as a private override",
    )
    args = p.parse_args()
    changed, links, _ = plan(
        Path.home(),
        migrate=args.migrate_owned,
        app_routes_only=args.app_routes_only,
        migrate_idle=args.migrate_idle_override,
    )
    print(
        f"{len(changed)} configuration files to deploy; {len(links)} source symlinks to migrate"
    )
    if args.apply:
        print(
            "Private configuration backup:",
            apply(
                Path.home(),
                migrate=args.migrate_owned,
                app_routes_only=args.app_routes_only,
                migrate_idle=args.migrate_idle_override,
            )
            or "no changes",
        )


if __name__ == "__main__":
    main()
