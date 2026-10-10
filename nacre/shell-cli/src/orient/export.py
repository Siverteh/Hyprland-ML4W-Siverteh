"""Safe plain-text theme templates. Export never edits installed applications."""

from pathlib import Path
import json
import re
import hashlib
from .palette import validate

from .template_engine import render_values, TOKEN


def render(template, palette, schemes=None, custom=None):
    validate(palette["colours"])
    contexts = dict(schemes or {})
    # Only a template requesting the opposite mode needs its companion query.
    expressions = [match[2].strip() for match in TOKEN.finditer(template) if not match[1]]
    needed = {
        m for m in ("dark", "light") if any(re.match(r"colors\.[A-Za-z_]+\." + m + r"\.", text) for text in expressions)
    }
    for mode in needed - {palette["mode"]} - set(contexts):
        source = palette.get("source", {}).get("path")
        if source and Path(source).is_file() and palette.get("name") == "dynamic":
            from . import ENGINE_ID

            if palette.get("engine") != ENGINE_ID:
                raise ValueError("Palette engine changed; supply an explicit companion palette")
            digest = hashlib.sha256()
            with Path(source).open("rb") as stream:
                for block in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(block)
            if digest.hexdigest() != palette.get("source", {}).get("digest"):
                raise ValueError("Source image changed; supply an explicit companion palette")
            from .engine import from_image

            options = dict(palette.get("input", {}), mode=mode, smart=False)
            contexts[mode] = from_image(source, **options)["colours"]
    for values in contexts.values():
        validate(values)
    return render_values(
        template,
        dict(palette["colours"], mode=palette["mode"]),
        contexts,
        palette.get("source", {}).get("path"),
        custom,
    )


def export(palette, directory, templates=None, schemes=None, custom=None):
    root = (Path(templates) if templates else Path(__file__).with_name("templates")).resolve()
    directory = Path(directory).expanduser().resolve()
    pending = []
    for path in sorted(root.rglob("*.in")):
        if path.is_symlink() or not path.resolve().is_relative_to(root):
            raise ValueError("Theme templates must be regular files inside their folder")
        relative = path.relative_to(root).with_suffix("")
        target = directory / relative
        if target.exists():
            raise ValueError("Export would replace an existing file: " + str(target))
        text = render(path.read_text(), palette, schemes=schemes, custom=custom)
        if target.suffix == ".json":
            json.loads(text)
        pending.append((target, text))
    if not pending:
        raise ValueError("No .in theme templates found")
    directory.mkdir(parents=True, exist_ok=True)
    for target, text in pending:
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.parent.resolve().is_relative_to(directory):
            raise ValueError("Export path escapes the selected directory")
        # Exclusive creation: another export cannot silently replace a file.
        with target.open("x") as stream:
            stream.write(text)
    return [str(target) for target, _ in pending]
