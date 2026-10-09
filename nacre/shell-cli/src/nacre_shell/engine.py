"""Image palette generation with versioned read-only-to-desktop cache behavior."""

import hashlib
from pathlib import Path

from . import ENGINE_ID
from .colour import clean, lch
from .extract import analyze
from .palette import DEFAULT_SEED, generate, validate
from .storage import cache_key, read, roots, write_json


def palette_options(analysis, mode, variant, flavour, harmony=False):
    candidates = [c["hex"] for c in analysis["candidates"]]
    result = []
    for index, seed in enumerate(candidates):
        colors = generate(seed, mode, variant, flavour, analysis["candidates"], harmony=harmony)
        _, chroma, hue = lch(seed)
        if chroma < 0.012:
            name = "Neutral"
        else:
            names = (
                (25, "Rose"),
                (55, "Copper"),
                (95, "Gold"),
                (130, "Olive"),
                (170, "Green"),
                (205, "Teal"),
                (245, "Blue"),
                (285, "Indigo"),
                (325, "Lilac"),
                (360, "Rose"),
            )
            name = next(label for end, label in names if hue < end)
        if any(item["name"] == name for item in result):
            name += " tone"
        result.append(
            {
                "accent": seed,
                "name": name,
                "swatches": [colors[k] for k in ("primary", "secondary", "tertiary")],
                "surface": colors["frame"],
                "recommended": index == 0,
            }
        )
    return result


def from_image(path, mode="dark", variant="tonalspot", flavour="default", accent=None, smart=False, harmony=False):
    path = Path(path).expanduser().resolve(strict=True)
    settings = {
        "mode": mode,
        "variant": variant,
        "flavour": flavour,
        "accent": clean(accent) if accent else None,
        "smart": smart,
        "harmony": bool(harmony),
    }
    identity = cache_key(path, settings)
    cache = roots()[2] / "orient" / (identity + ".json")
    try:
        cached = read(cache, {})
        if not isinstance(cached, dict):
            raise ValueError("Invalid palette cache record")
        if (
            cached.get("engine") == ENGINE_ID
            and cached.get("input") == settings
            and cached.get("name") == "dynamic"
            and cached.get("mode") in ("light", "dark")
            and (smart or cached.get("mode") == mode)
            and cached.get("variant") == variant
            and cached.get("flavour") == flavour
        ):
            validate(cached["colours"])
            source = cached.get("source", {})
            if not isinstance(source, dict):
                raise ValueError("Invalid palette cache source")
            digest = source.get("digest", "")
            clean(source.get("selected", ""))
            if len(digest) == 64 and all(c in "0123456789abcdef" for c in digest):
                return cached
    except (OSError, ValueError, KeyError, TypeError):
        pass
    analysis = analyze(path)
    if smart:
        mode = "light" if analysis["meanLightness"] >= 0.68 else "dark"
    seed = settings["accent"] or analysis["seed"]
    neutral = analysis["neutral"] and not accent
    effective_variant = "neutral" if neutral and variant not in ("monochrome", "neutral") else variant
    colors = generate(seed, mode, effective_variant, flavour, analysis["candidates"], harmony=harmony)
    hasher = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(block)
    digest = hasher.hexdigest()
    if cache_key(path, settings) != identity:
        raise ValueError("Wallpaper changed during extraction; select it again")
    data = {
        "name": "dynamic",
        "mode": mode,
        "variant": variant,
        "flavour": flavour,
        "colours": colors,
        "engine": ENGINE_ID,
        "input": settings,
        "source": {
            **analysis,
            "selected": seed,
            "digest": digest,
            "options": palette_options(analysis, mode, effective_variant, flavour, harmony),
        },
    }
    # An unwritable cache must not prevent a valid read-only palette result.
    try:
        write_json(cache, data)
    except OSError:
        pass
    return data


def default_palette(mode="dark", variant="tonalspot", flavour="default"):
    return {
        "name": "default",
        "mode": mode,
        "variant": variant,
        "flavour": flavour,
        "colours": generate(DEFAULT_SEED, mode, variant, flavour),
        "engine": ENGINE_ID,
    }
