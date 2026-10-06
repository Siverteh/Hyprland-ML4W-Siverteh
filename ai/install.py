#!/usr/bin/env python3
"""Install the user-level AI workflow without changing existing credentials."""

import argparse
import datetime as dt
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--remote",
        action="store_true",
        help="Install host helpers and guidance without replacing its Codex binary",
    )
    parser.add_argument(
        "--repo", type=Path, default=Path(__file__).resolve().parent.parent
    )
    parser.add_argument(
        "--codex-home",
        type=Path,
        help="Also install guidance in an isolated Codex home",
    )
    args = parser.parse_args()
    repo = args.repo.resolve()
    home = Path.home()
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    backup = home / ".local/state/siverteh-ai/backups" / stamp

    def save(path):
        backup.mkdir(parents=True, exist_ok=True, mode=0o700)
        dest = backup / path.relative_to(home)
        dest.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if path.is_symlink():
            dest.symlink_to(os.readlink(path))
        elif path.is_dir():
            shutil.copytree(path, dest, symlinks=True)
        else:
            shutil.copy2(path, dest)

    def link(source, target):
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.is_symlink() and target.resolve() == source.resolve():
            return
        if target.exists() or target.is_symlink():
            save(target)
            if target.is_dir() and not target.is_symlink():
                raise RuntimeError(f"Refusing to replace existing directory: {target}")
            target.unlink()
        target.symlink_to(source)

    binaries = (
        ["siverteh-brain", "siverteh-ai-remote"]
        if args.remote
        else ["codex", "siverteh-ai", "siverteh-brain", "siverteh-ai-remote"]
    )
    binaries.extend(
        [
            "siverteh-brain-maintain",
            "siverteh-ai-tools",
            "siverteh-ai-skills",
            "siverteh-ai-account",
            "siverteh-brain-sync",
            "siverteh-ai-chat",
            "siverteh-ai-claude",
            "siverteh-ai-context",
            "siverteh-ai-memory",
            "siverteh-ai-usage",
        ]
    )
    if (
        not args.remote
        and (
            home / ".local/share/siverteh-ai/obsidian/1.13.7/squashfs-root/AppRun"
        ).exists()
    ):
        binaries.append("obsidian")
    if not args.remote:
        for name in (
            "siverteh-brain-sync.service",
            "siverteh-brain-sync.timer",
            "siverteh-brain-check.service",
            "siverteh-brain-check.timer",
        ):
            link(repo / "ai/systemd" / name, home / ".config/systemd/user" / name)
        secret_service = (
            home / ".local/share/dbus-1/services/org.freedesktop.secrets.service"
        )
        if (
            Path("/usr/bin/ksecretd").exists()
            and not Path(
                "/usr/share/dbus-1/services/org.freedesktop.secrets.service"
            ).exists()
            and not secret_service.exists()
        ):
            link(repo / "ai/dbus/org.freedesktop.secrets.service", secret_service)
    for name in binaries:
        link(repo / "bin" / name, home / ".local/bin" / name)
    for skill in (repo / "ai/skills").iterdir():
        if skill.is_dir():
            shared = home / ".agents/skills" / skill.name
            previous = shared.resolve() if shared.is_symlink() else None
            link(skill, shared)
            # Migrate only aliases proven to point at our previous shared skill.
            if previous and previous != shared.resolve():
                profiles = [home / ".codex", home / ".claude"]
                for group in ("accounts", "claude-accounts"):
                    profiles.extend(
                        (home / ".local/share/siverteh-ai" / group).glob("*")
                    )
                for profile in profiles:
                    alias = profile / "skills" / skill.name
                    if alias.is_symlink() and alias.resolve() == previous:
                        link(shared, alias)
    subprocess.run([str(home / ".local/bin/siverteh-ai-skills")], check=True)
    guidance = home / ".codex/AGENTS.md"
    guidance.parent.mkdir(parents=True, exist_ok=True)
    if not guidance.exists():
        link(repo / "ai/AGENTS.md", guidance)
    elif (
        guidance.is_symlink()
        and guidance.resolve() == (repo / "ai/AGENTS.md").resolve()
    ):
        pass
    else:
        marker = "<!-- siverteh-ai-guidance -->"
        current = guidance.read_text()
        block = (
            marker
            + "\nFor personal knowledge and cross-project context, read `"
            + str(repo / "ai/AGENTS.md")
            + "`.\n<!-- /siverteh-ai-guidance -->"
        )
        if marker in current:
            updated, count = re.subn(
                re.escape(marker)
                + r"\nFor personal knowledge and cross-project context, read `[^\n]+`\.\n(?:<!-- /siverteh-ai-guidance -->)?",
                lambda _: block,
                current,
                count=1,
            )
            if count != 1:
                raise RuntimeError(
                    "Existing personal guidance marker needs manual integration"
                )
        else:
            updated = current.rstrip() + "\n\n" + block + "\n"
        if updated != current:
            save(guidance)
            # A foreign symlink may point into another repository; never edit its target.
            if guidance.is_symlink():
                guidance.unlink()
            guidance.write_text(updated)
    if args.codex_home:
        isolated = args.codex_home.expanduser().resolve()
        isolated.mkdir(parents=True, exist_ok=True, mode=0o700)
        target = isolated / "AGENTS.md"
        if target.exists() and target.resolve() != (repo / "ai/AGENTS.md").resolve():
            raise RuntimeError(
                f"Existing isolated guidance needs manual integration: {target}"
            )
        link(repo / "ai/AGENTS.md", target)
    title_env = dict(os.environ, CODEX_HOME=str(home / ".codex"))
    if args.codex_home:
        title_env["CODEX_HOME"] = str(args.codex_home.expanduser().resolve())
    subprocess.run(
        [str(home / ".local/bin/siverteh-ai-chat"), "configure"],
        env=title_env,
        check=True,
    )
    config = home / ".config/siverteh-ai/projects.json"
    if not config.exists():
        config.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        config.write_text(
            json.dumps(
                {"projects": [{"id": "os", "label": "Siverteh OS", "path": str(repo)}]},
                indent=2,
            )
            + "\n"
        )
        config.chmod(0o600)
    subprocess.run([str(home / ".local/bin/siverteh-brain"), "init"], check=True)
    subprocess.run(
        [str(home / ".local/bin/siverteh-brain-maintain"), "setup"], check=True
    )
    print("Personal workflow installed. Existing account credentials were not changed.")
    print("Project registry:", config)
    if backup.exists():
        print("Replaced-file backup:", backup)


if __name__ == "__main__":
    main()
