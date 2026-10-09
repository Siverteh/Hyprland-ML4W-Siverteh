# Orient: optional harmony and clearer containers

Date: 2026-10-08. Preserve the user's selected richer accent strength. Natural
remains the default; Harmony is an explicit Appearance preference, default false.
Both keep real wallpaper hue families, manual per-image accents, neutral fallback,
light/dark readability and cached matched wallpaper/palette publication.

Harmony changes supporting-source selection, not a global saturation clamp. Rank
related hues above distant ones; intentional high-coverage contrasts remain valid.
Require supporting colors to cover at least 4% of the sampled image and a useful
fraction of the dominant color. Tiny distant patches remain choices in the picker,
but do not become automatic secondary/tertiary accents. Prefer another candidate
over a dark weak yellow-green; if it must be used (including a manually selected
main hue), lift its lightness while retaining hue. Never label an entire hue family
bad or remove olive choices from the user. Use our OKLCH coverage/ranking policy,
not copied Material You dislike code or HCT thresholds.

Natural preserves supporting selection and existing accent ceilings/strengths.
In both modes dark containers retain more source tint, with bounded chroma and
individually validated foreground contrast >=4.5:1. Neutral/monochrome must stay
neutral. Fixed presets retain identity; regenerate their role values deterministically
with the same independent engine, without changing chosen IDs or seed hues.

The setting lives in the existing wallpaper-picker preferences, one owner. It
invalidates generated/prepared caches and regenerates selected palette, preview
choices and toolkit publication together. Per-image accents are retained. Queries
can use wallpaper --print --harmony/--no-harmony without writing preferences or
desktop state. Fixed palettes ignore the wallpaper Harmony preference. Failed
updates restore the saved preference. No idle sampling, learning, polling or new
background process is introduced.

Test meaningful contrast coverage versus tiny distant colors, dark weak olive,
manual olive, neutral pictures, light/dark roles, cache separation, read-only CLI,
persistent preference across selections and helper rollback. Use generated fixtures
for deterministic tests. Review licensed real illustrations privately and document
source/license; do not add personal artwork or comparison mocks to product assets.
Inspect Natural/Harmony component sheets and the actual deployed shell. Full checks,
Hyprland verification, install plan/apply and live IPC precede publication.
