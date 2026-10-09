"""Nacre's role policy, independent from Material dynamic scheme generation."""

from .colour import clean, color, contrast, foreground, lch, readable

DEFAULT_SEED = "47a99a"
VARIANTS = (
    "tonalspot",
    "vibrant",
    "expressive",
    "fidelity",
    "fruitsalad",
    "monochrome",
    "neutral",
    "rainbow",
    "content",
)


def generate(seed, mode="dark", variant="tonalspot", flavour="default", companions=()):
    seed = clean(seed)
    if mode not in ("light", "dark") or variant not in VARIANTS or flavour not in ("default", "hard"):
        raise ValueError("Unsupported palette mode, variant or flavour")
    dark = mode == "dark"
    _, chroma, hue = lch(seed)
    soft = variant in ("neutral", "content")
    if variant == "monochrome":
        chroma = 0.0
    elif soft:
        chroma = min(chroma * 0.55, 0.10)
    # Body tint stays modest: color belongs in accents, not a global cast.
    tint = min(chroma * 0.10, 0.016)
    if flavour == "hard":
        tint *= 0.5
    levels = {
        "surface": 0.15 if dark else 0.975,
        "surfaceDim": 0.15 if dark else 0.87,
        "surfaceBright": 0.27 if dark else 0.985,
        "surfaceContainerLowest": 0.115 if dark else 0.995,
        "surfaceContainerLow": 0.19 if dark else 0.955,
        "surfaceContainer": 0.215 if dark else 0.935,
        "surfaceContainerHigh": 0.24 if dark else 0.91,
        "surfaceContainerHighest": 0.255 if dark else 0.885,
    }
    colors = {role: color(light, tint, hue) for role, light in levels.items()}
    backgrounds = [
        colors["surface"],
        colors["surfaceContainerHighest"],
        colors["surfaceBright" if dark else "surfaceDim"],
    ]
    colors.update(
        background=colors["surface"],
        surfaceVariant=colors["surfaceContainerHighest"],
        onSurface=readable(color(0.94 if dark else 0.20, tint, hue), backgrounds),
        onSurfaceVariant=readable(color(0.76 if dark else 0.40, tint, hue), backgrounds),
        shadow="000000",
        scrim="000000",
    )
    colors["onBackground"] = colors["onSurface"]
    colors["outline"] = readable(color(0.58 if dark else 0.54, tint, hue), backgrounds, 3.0)
    colors["outlineVariant"] = color(0.37 if dark else 0.79, tint, hue)
    colors["inverseSurface"] = color(0.96 if dark else 0.15, tint, hue)
    colors["inverseOnSurface"] = readable(color(0.25 if dark else 0.92, tint, hue), [colors["inverseSurface"]])

    def family(role, source, strength=1.0):
        light, c, h = lch(source)
        c = c * strength
        if role == "primary":
            c = chroma
        # Lift dark pigments without turning the same saturation into a gray tint.
        # Relative OKLCH strength grows with lightness, bounded by sRGB gamut.
        lifted = max(light, 0.60) if dark and not soft and c >= 0.035 else light
        lifted_chroma = c * min(1.8, lifted / max(light, 0.12))
        accent = readable(color(lifted, lifted_chroma, h), backgrounds)
        container = color(0.35 if dark else 0.88, min(c * 0.42, 0.085), h)
        colors[role] = accent
        colors["on" + role.title()] = foreground(accent)
        colors[role + "Dim"] = readable(color(lch(accent)[0] + (-0.025 if dark else 0.025), c, h), backgrounds)
        colors[role + "Container"] = container
        colors["on" + role.title() + "Container"] = readable(
            color(0.93 if dark else 0.22, min(c * 0.3, 0.05), h), [container]
        )
        if role in ("primary", "secondary", "tertiary"):
            fixed = color(0.87, min(c, 0.14), h)
            fixed_dim = color(0.78, min(c, 0.14), h)
            colors[role + "Fixed"] = fixed
            colors[role + "FixedDim"] = fixed_dim
            colors["on" + role.title() + "Fixed"] = readable(color(0.20, min(c, 0.07), h), [fixed, fixed_dim])
            colors["on" + role.title() + "FixedVariant"] = readable(color(0.35, min(c, 0.07), h), [fixed, fixed_dim])
            colors[role + "PaletteKeyColor"] = color(light, c, h)
            colors[role + "_paletteKeyColor"] = colors[role + "PaletteKeyColor"]

    sources = [clean(c) for c in companions if clean(c) != seed]
    secondary = sources[0] if sources else color(lch(seed)[0], chroma * 0.70, hue)
    tertiary = sources[1] if len(sources) > 1 else color(lch(seed)[0], chroma * 0.45, hue)
    family("primary", seed)
    family("secondary", secondary, 0.85 if not soft else 0.5)
    family("tertiary", tertiary, 0.85 if not soft else 0.5)
    family("error", "df303e")
    family("success", "289563")
    colors["surfaceTint"] = colors["primary"]
    # Rich accents for decoration can retain the source even when text must brighten.
    colors["overtone"] = color(lch(seed)[0], chroma, hue)
    colors["orient1"] = colors["overtone"]
    colors["orient2"] = clean(secondary)
    colors["orient3"] = clean(tertiary)
    colors["inversePrimary"] = readable(colors["overtone"], [colors["inverseSurface"]])
    colors["neutralPaletteKeyColor"] = color(0.55, tint, hue)
    colors["neutralVariantPaletteKeyColor"] = color(0.55, min(tint * 2, 0.03), hue)
    colors["neutral_paletteKeyColor"] = colors["neutralPaletteKeyColor"]
    colors["neutral_variant_paletteKeyColor"] = colors["neutralVariantPaletteKeyColor"]
    colors["errorPaletteKeyColor"] = "df303e"

    # Legacy adapters are role names only; named ANSI colors keep their meaning.
    semantic = {
        "rosewater": "d8ada7",
        "flamingo": "dd8d81",
        "pink": "d965aa",
        "mauve": "a86fd0",
        "red": "df303e",
        "maroon": "b64b60",
        "peach": "e68d50",
        "yellow": "d4b14b",
        "green": "289563",
        "teal": "309f95",
        "sky": "55accc",
        "sapphire": "398ab7",
        "blue": "477fe0",
        "lavender": "8f84d5",
    }
    for role, value in semantic.items():
        colors[role] = readable(value, backgrounds)
    for role, value in {
        "text": "onSurface",
        "subtext1": "onSurfaceVariant",
        "subtext0": "onSurfaceVariant",
        "overlay2": "outline",
        "overlay1": "outline",
        "overlay0": "outlineVariant",
        "surface2": "surfaceContainerHighest",
        "surface1": "surfaceContainerHigh",
        "surface0": "surfaceContainer",
        "base": "surface",
        "mantle": "surfaceContainerLowest",
        "crust": "surfaceContainerLowest",
        "klink": "blue",
        "kvisited": "mauve",
        "knegative": "error",
        "kneutral": "yellow",
        "kpositive": "success",
    }.items():
        colors[role] = colors[value]
    for role in ("klink", "kvisited", "knegative", "kneutral", "kpositive"):
        colors[role + "Selection"] = readable(colors[role], [colors["primary"]], 4.5)
    ansi = ("surface", "red", "green", "yellow", "blue", "mauve", "teal", "onSurface")
    for i, role in enumerate(ansi):
        colors[f"term{i}"] = colors[role]
        colors[f"term{i + 8}"] = colors["onSurfaceVariant"] if i == 0 else colors[role]
    validate(colors)
    return colors


def validate(colors):
    pairs = [
        ("onSurface", "surface"),
        ("onSurfaceVariant", "surfaceContainerHighest"),
        ("inverseOnSurface", "inverseSurface"),
    ]
    for role in ("primary", "secondary", "tertiary", "error", "success"):
        pairs.extend(
            (
                ("on" + role.title(), role),
                ("on" + role.title() + "Container", role + "Container"),
                (role, "surfaceContainerHighest"),
            )
        )
    for fg, bg in pairs:
        if contrast(colors[fg], colors[bg]) < 4.5:
            raise ValueError(f"Unreadable generated roles: {fg}/{bg}")
    if not REQUIRED_ROLES <= colors.keys():
        raise ValueError("Incomplete palette roles")
    for value in colors.values():
        clean(value)


# Compatibility vocabulary captured from the installed CLI output.
REQUIRED_ROLES = frozenset(
    (
        "background",
        "base",
        "blue",
        "crust",
        "error",
        "errorContainer",
        "errorDim",
        "errorPaletteKeyColor",
        "flamingo",
        "green",
        "inverseOnSurface",
        "inversePrimary",
        "inverseSurface",
        "klink",
        "klinkSelection",
        "knegative",
        "knegativeSelection",
        "kneutral",
        "kneutralSelection",
        "kpositive",
        "kpositiveSelection",
        "kvisited",
        "kvisitedSelection",
        "lavender",
        "mantle",
        "maroon",
        "mauve",
        "neutralPaletteKeyColor",
        "neutralVariantPaletteKeyColor",
        "neutral_paletteKeyColor",
        "neutral_variant_paletteKeyColor",
        "onBackground",
        "onError",
        "onErrorContainer",
        "onPrimary",
        "onPrimaryContainer",
        "onPrimaryFixed",
        "onPrimaryFixedVariant",
        "onSecondary",
        "onSecondaryContainer",
        "onSecondaryFixed",
        "onSecondaryFixedVariant",
        "onSuccess",
        "onSuccessContainer",
        "onSurface",
        "onSurfaceVariant",
        "onTertiary",
        "onTertiaryContainer",
        "onTertiaryFixed",
        "onTertiaryFixedVariant",
        "outline",
        "outlineVariant",
        "overlay0",
        "overlay1",
        "overlay2",
        "peach",
        "pink",
        "primary",
        "primaryContainer",
        "primaryDim",
        "primaryFixed",
        "primaryFixedDim",
        "primaryPaletteKeyColor",
        "primary_paletteKeyColor",
        "red",
        "rosewater",
        "sapphire",
        "scrim",
        "secondary",
        "secondaryContainer",
        "secondaryDim",
        "secondaryFixed",
        "secondaryFixedDim",
        "secondaryPaletteKeyColor",
        "secondary_paletteKeyColor",
        "shadow",
        "sky",
        "subtext0",
        "subtext1",
        "success",
        "successContainer",
        "surface",
        "surface0",
        "surface1",
        "surface2",
        "surfaceBright",
        "surfaceContainer",
        "surfaceContainerHigh",
        "surfaceContainerHighest",
        "surfaceContainerLow",
        "surfaceContainerLowest",
        "surfaceDim",
        "surfaceTint",
        "surfaceVariant",
        "teal",
        "term0",
        "term1",
        "term10",
        "term11",
        "term12",
        "term13",
        "term14",
        "term15",
        "term2",
        "term3",
        "term4",
        "term5",
        "term6",
        "term7",
        "term8",
        "term9",
        "tertiary",
        "tertiaryContainer",
        "tertiaryDim",
        "tertiaryFixed",
        "tertiaryFixedDim",
        "tertiaryPaletteKeyColor",
        "tertiary_paletteKeyColor",
        "text",
        "yellow",
    )
)
