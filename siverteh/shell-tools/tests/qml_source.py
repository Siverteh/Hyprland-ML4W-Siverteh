"""Formatting-independent adaptation of production QML for plain Qt fixtures."""

import re


def remove_objects(source, pattern):
    while match := re.search(pattern, source):
        start = source.index("{", match.start())
        depth = 0
        quote = None
        escaped = False
        for end in range(start, len(source)):
            char = source[end]
            if quote:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
            elif char in '"\x27`':
                quote = char
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    source = source[: match.start()] + source[end + 1 :]
                    break
        else:
            raise ValueError("Unclosed fixture object")
    return source
