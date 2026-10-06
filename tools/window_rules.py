"""Detect conflicting class-wide Lua window routes and floating rules.

This statically reads literal rule tables; it never executes desktop config.
It compares equal selectors and witnesses overlaps using finite class names,
including case pairs and alternations. Arbitrary PCRE intersection is not assumed.
"""

import ast
import itertools
import re
from pathlib import Path

STRING = r'"(?:[^"\\]|\\.)*"|\x27(?:[^\x27\\]|\\.)*\x27'


def balanced(source, start):
    depth = 0
    quote = None
    escaped = False
    for index in range(start, len(source)):
        char = source[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = None
        elif char in '"\x27':
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index + 1
    raise ValueError("Unclosed window rule table")


def fields(table):
    values = {}
    for match in re.finditer(r"\b(\w+)\s*=\s*(" + STRING + r"|true|false)", table):
        value = match[2]
        values[match[1]] = (
            value == "true" if value in ("true", "false") else ast.literal_eval(value)
        )
    return values


def rules(folder):
    result = []
    for path in sorted(Path(folder).glob("*.lua")):
        source = re.sub(r"--[^\n]*", "", path.read_text())
        for call in re.finditer(r"hl\.window_rule\s*\(\s*\{", source):
            start = source.index("{", call.start())
            block = source[start : balanced(source, start)]
            match = re.search(r"\bmatch\s*=\s*\{", block)
            if not match:
                continue
            begin = block.index("{", match.start())
            end = balanced(block, begin)
            selectors = fields(block[begin:end])
            pattern = selectors.pop("class", None)
            if not pattern:
                continue
            values = fields(block[:begin] + block[end:])
            if "workspace" in values:
                values["workspace"] = values["workspace"].split()[0]
            result.append((path.name, pattern, selectors, values))
    return result


def witnesses(pattern):
    body = pattern.removeprefix("^").removesuffix("$")
    if body.startswith("(") and body.endswith(")"):
        body = body[1:-1]
    values = []
    for branch in body.split("|"):
        pieces = re.split(r"(\[[^\]]+\])", branch)
        options = []
        for piece in pieces:
            if piece.startswith("["):
                chars = piece[1:-1]
                if "-" in chars or "^" in chars:
                    break
                options.append(list(chars))
            elif any(char in piece for char in "*+?(){}\\"):
                break
            else:
                options.append([piece])
        else:
            values.extend("".join(parts) for parts in itertools.product(*options))
    return values


def conflicts(folder):
    found = []
    rows = rules(folder)
    for left, right in itertools.combinations(rows, 2):
        if left[2] != right[2]:
            continue
        overlapping = left[1] == right[1]
        if not overlapping:
            try:
                overlapping = any(
                    re.fullmatch(left[1], name) and re.fullmatch(right[1], name)
                    for name in witnesses(left[1]) + witnesses(right[1])
                )
            except re.error:
                continue  # The compositor validates PCRE-specific syntax.
        if overlapping:
            for field in ("workspace", "float"):
                if (
                    field in left[3]
                    and field in right[3]
                    and left[3][field] != right[3][field]
                ):
                    found.append(
                        f"{left[0]} {left[1]} conflicts with {right[0]} {right[1]}: {field}"
                    )
    return found
