#!/usr/bin/env python3

import os
import random
import re
import select
import shutil
import signal
import sys
import termios
import time
import tty
from pathlib import Path


SYMBOLS = "01<>[]{}()/\\|+-=*&#@!?%$ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
FRAME_DELAY = 0.1


def normalize_color(value, fallback):
    value = value.strip()

    if re.fullmatch(r"#[0-9a-fA-F]{6}", value):
        return value

    match = re.fullmatch(
        r"rgba\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*[0-9.]+\s*\)",
        value,
    )
    if match:
        return "#{:02x}{:02x}{:02x}".format(
            max(0, min(255, int(match.group(1)))),
            max(0, min(255, int(match.group(2)))),
            max(0, min(255, int(match.group(3)))),
        )

    return fallback


def read_color_from_rasi(name, fallback):
    colors_file = Path.home() / ".config" / "rofi" / "colors.rasi"
    if not colors_file.exists():
        return fallback

    try:
        content = colors_file.read_text()
    except OSError:
        return fallback

    match = re.search(rf"{re.escape(name)}:\s*([^;]+);", content)
    if not match:
        return fallback

    return normalize_color(match.group(1), fallback)


def read_color_file(name, fallback):
    path = Path.home() / ".config" / "siverteh" / "colors" / name
    if not path.exists():
        return fallback

    try:
        value = path.read_text().strip()
    except OSError:
        return fallback

    return normalize_color(value, fallback) if value else fallback


def hex_to_rgb(value):
    value = value.strip().lstrip("#")
    if len(value) != 6:
        return 255, 255, 255

    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def luminance(rgb):
    r, g, b = [channel / 255.0 for channel in rgb]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def mix_rgb(left, right, balance):
    inverse = 1.0 - balance
    return tuple(
        max(0, min(255, round(left[index] * inverse + right[index] * balance)))
        for index in range(3)
    )


def darken_rgb(rgb, factor):
    return tuple(max(0, min(255, round(channel * factor))) for channel in rgb)


def ansi_fg(rgb):
    return f"\033[38;2;{rgb[0]};{rgb[1]};{rgb[2]}m"


def ansi_bg(rgb):
    return f"\033[48;2;{rgb[0]};{rgb[1]};{rgb[2]}m"


def load_palette():
    primary = hex_to_rgb(read_color_file("primary", read_color_from_rasi("primary", "#6effa0")))
    secondary = hex_to_rgb(read_color_file("secondary", read_color_from_rasi("secondary", "#b0ffd2")))
    on_surface = hex_to_rgb(read_color_file("onsurface", read_color_from_rasi("on-surface", "#e8f3ec")))
    surface = hex_to_rgb(read_color_from_rasi("surface", "#08110c"))
    background = hex_to_rgb(read_color_from_rasi("background", "#050705"))

    base = background if luminance(background) <= luminance(surface) else surface
    bg = darken_rgb(mix_rgb(base, primary, 0.06), 0.22)
    primary = mix_rgb(darken_rgb(primary, 0.72), on_surface, 0.12)
    secondary = mix_rgb(darken_rgb(secondary, 0.58), bg, 0.18)
    highlight = mix_rgb(on_surface, primary, 0.22)

    return {
        "background": bg,
        "primary": primary,
        "secondary": secondary,
        "highlight": highlight,
    }


class MatrixRain:
    def __init__(self):
        self.columns = []
        self.size = (0, 0)

    def configure(self, rows, cols):
        if self.size == (rows, cols) and self.columns:
            return

        self.size = (rows, cols)
        self.columns = []
        spacing = 2 if cols >= 100 else 1
        symbol_count = rows + 48

        for x in range(0, cols, spacing):
            self.columns.append(
                {
                    "x": x,
                    "head": random.uniform(-rows * 0.25, rows * 1.2),
                    "speed": random.uniform(0.65, 1.8),
                    "trail": random.randint(max(6, rows // 7), max(12, rows // 3)),
                    "symbols": [random.choice(SYMBOLS) for _ in range(symbol_count)],
                }
            )

    def reset_stream(self, stream, rows):
        stream["head"] = random.uniform(-rows * 0.5, 0)
        stream["speed"] = random.uniform(0.65, 1.8)
        stream["trail"] = random.randint(max(6, rows // 7), max(12, rows // 3))

    def tick(self):
        rows, _cols = self.size
        if rows <= 0:
            return

        for stream in self.columns:
            stream["head"] += stream["speed"]

            if random.random() < 0.12:
                stream["symbols"][random.randrange(len(stream["symbols"]))] = random.choice(SYMBOLS)

            if random.random() < 0.018:
                stream["speed"] = max(0.45, min(2.1, stream["speed"] + random.uniform(-0.12, 0.12)))

            if stream["head"] - stream["trail"] > rows:
                self.reset_stream(stream, rows)

    def draw(self, palette):
        rows, cols = shutil.get_terminal_size((120, 40))[1], shutil.get_terminal_size((120, 40))[0]
        rows = max(rows, 1)
        cols = max(cols, 1)
        self.configure(rows, cols)

        bg = palette["background"]
        output = [ansi_bg(bg), "\033[2J"]

        for stream in self.columns:
            head = int(stream["head"])
            trail = stream["trail"]
            x = stream["x"]

            if x >= cols:
                continue

            for offset in range(trail):
                y = head - offset
                if y < 0 or y >= rows:
                    continue

                if offset == 0:
                    color = palette["highlight"]
                elif offset < 3:
                    color = palette["primary"]
                else:
                    fade = max(0.0, 1.0 - (offset / max(trail, 1)))
                    color = mix_rgb(palette["background"], palette["secondary"], 0.25 + fade * 0.55)

                symbol = stream["symbols"][(y + offset) % len(stream["symbols"])]
                output.append(f"\033[{y + 1};{x + 1}H{ansi_fg(color)}{symbol}")

        sys.stdout.write("".join(output))
        sys.stdout.flush()


def run():
    palette = load_palette()
    rain = MatrixRain()
    original_termios = termios.tcgetattr(sys.stdin)
    stop = False

    def stop_now(_signum=None, _frame=None):
        nonlocal stop
        stop = True

    signal.signal(signal.SIGTERM, stop_now)
    signal.signal(signal.SIGINT, stop_now)

    try:
        tty.setcbreak(sys.stdin.fileno())
        sys.stdout.write("\033[?25l\033[?1000h\033[?1006h\033[2J")
        sys.stdout.flush()
        close_after = time.monotonic() + 0.35

        while not stop:
            ready, _, _ = select.select([sys.stdin], [], [], 0)
            if ready:
                try:
                    data = os.read(sys.stdin.fileno(), 128)
                except (BlockingIOError, OSError):
                    data = b""

                if data and time.monotonic() >= close_after:
                    break

            rain.tick()
            rain.draw(palette)
            time.sleep(FRAME_DELAY)
    finally:
        sys.stdout.write("\033[0m\033[2J\033[H\033[?1006l\033[?1000l\033[?25h")
        sys.stdout.flush()
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, original_termios)


if __name__ == "__main__":
    run()
