"""Dependency-free role substitution shared by exports and desktop adapters."""

import re

TOKEN = re.compile(r"\{\{([A-Za-z][A-Za-z0-9_]*)\}\}")


def render_values(template, values):
    def replacement(match):
        key = match[1]
        value = values.get(key)
        if key == "mode" and value in ("dark", "light"):
            return value
        if not isinstance(value, str) or not re.fullmatch("[0-9a-fA-F]{6}", value):
            raise ValueError("Missing or invalid color template token: " + key)
        return value.lower()

    return TOKEN.sub(replacement, template)
