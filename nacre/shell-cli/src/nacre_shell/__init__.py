"""Orient palette engine; independently implemented for Nacre."""

__version__ = "2.0.0"
# The fingerprint also invalidates palettes during development or downstream patches.
import hashlib
from pathlib import Path

_PACKAGE = Path(__file__).parent
_FINGERPRINT = hashlib.sha256()
for _name in ("colour.py", "extract.py", "palette.py", "engine.py"):
    _FINGERPRINT.update((_PACKAGE / _name).read_bytes())
ENGINE_ID = "orient-2.0.0-" + _FINGERPRINT.hexdigest()[:12]


def main():
    from .cli import main as run

    return run()
