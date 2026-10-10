"""Pure role rendering with Matugen color-token compatibility; no code execution."""

import colorsys
import re

TOKEN = re.compile(r"(\\)?\{\{([^{}]*?)\}\}")
COLOR = re.compile(r"[0-9a-fA-F]{6}")


def role_name(name, values):
    if name == "source_color":
        return "overtone"
    if name in values:
        return name
    parts = name.split("_")
    return parts[0] + "".join(part[:1].upper() + part[1:] for part in parts[1:])


def format_color(value, format_name):
    if not isinstance(value, str) or not COLOR.fullmatch(value):
        raise ValueError("Missing or invalid template color")
    value = value.lower()
    red, green, blue = (int(value[i : i + 2], 16) for i in (0, 2, 4))
    hue, lightness, saturation = colorsys.rgb_to_hls(red / 255, green / 255, blue / 255)

    def number(n):
        return f"{n:.3f}".rstrip("0").rstrip(".")

    formats = {
        "hex": "#" + value,
        "hex_stripped": value,
        "rgb": f"rgb({red}, {green}, {blue})",
        "rgba": f"rgba({red}, {green}, {blue}, 1.0)",
        "red": str(red),
        "green": str(green),
        "blue": str(blue),
        "alpha": "255",
        "hsl": f"hsl({number(hue * 360)}, {number(saturation * 100)}%, {number(lightness * 100)}%)",
        "hsla": f"hsla({number(hue * 360)}, {number(saturation * 100)}%, {number(lightness * 100)}%, 1.0)",
        "hue": number(hue * 360),
        "saturation": number(saturation * 100),
        "lightness": number(lightness * 100),
    }
    if format_name not in formats:
        raise ValueError("Unsupported Matugen color format: " + format_name)
    return formats[format_name]


def render_values(template, values, schemes=None, image=None, custom=None):
    """Render documented color expressions, rejecting unsupported template logic.

    Explicit schemes must be provided; a light token never silently uses dark
    values. Original Orient {{role}} tokens remain unprefixed six-digit hex.
    """
    if "<*" in template or "{%" in template:
        raise ValueError("Matugen blocks/includes/loops are not supported; use plain color expressions")
    mode = values.get("mode")
    contexts = dict(schemes or {})
    if mode in ("dark", "light"):
        contexts[mode] = values
    contexts["default"] = values

    def replacement(match):
        if match[1]:
            return "{{" + match[2] + "}}"
        expression = match[2].strip()
        if "|" in expression or "{{" in expression:
            raise ValueError("Matugen filters/nested expressions are not supported: " + expression)
        if expression == "mode" and mode in ("dark", "light"):
            return mode
        if expression == "is_dark_mode" and mode in ("dark", "light"):
            return "true" if mode == "dark" else "false"
        if expression == "image":
            if not isinstance(image, str) or "\0" in image:
                raise ValueError("Template requests image but no source image was supplied")
            return image
        if expression.startswith("custom."):
            name = expression[7:]
            value = (custom or {}).get(name)
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name) or not isinstance(value, (str, int, float, bool)):
                raise ValueError("Missing or unsupported custom keyword: " + name)
            return str(value).lower() if isinstance(value, bool) else str(value)
        if expression.startswith("colors."):
            parts = expression.split(".")
            if len(parts) == 3:  # Older active-scheme shorthand.
                parts.insert(2, "default")
            if len(parts) != 4 or parts[2] not in ("default", "dark", "light"):
                raise ValueError("Expected colors.ROLE.default|dark|light.FORMAT: " + expression)
            context = contexts.get(parts[2])
            if context is None:
                raise ValueError("Template requires the " + parts[2] + " palette; supply a companion palette")
            role = role_name(parts[1], context)
            try:
                return format_color(context.get(role), parts[3])
            except ValueError as error:
                raise ValueError(str(error) + ": " + expression) from error
        if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", expression):
            raise ValueError("Unsupported template expression: " + expression)
        value = values.get(expression)
        if not isinstance(value, str) or not COLOR.fullmatch(value):
            raise ValueError("Missing or invalid color template token: " + expression)
        return value.lower()

    output, position = [], 0
    for match in TOKEN.finditer(template):
        plain = template[position : match.start()]
        if "{{" in plain:
            raise ValueError("Malformed or nested template expression")
        output += [plain, replacement(match)]
        position = match.end()
    tail = template[position:]
    if "{{" in tail:
        raise ValueError("Malformed or nested template expression")
    return "".join(output) + tail
