"""Safe plain-text theme templates. Export never edits installed applications."""

from pathlib import Path
import json
from .palette import validate

from .template_engine import render_values


def render(template, palette):
    validate(palette["colours"])
    return render_values(template, dict(palette["colours"], mode=palette["mode"]))


def export(palette, directory, templates=None):
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
        text = render(path.read_text(), palette)
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
