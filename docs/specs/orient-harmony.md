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

## Visual and performance review

Native Quickshell RHI sheets compare the pre-tuning engine, Natural and Harmony
with body backgrounds, three actual Nacre button surfaces and role foregrounds.
Reviewed dark and light sheets for four Nick Nazzaro CC BY-SA 4.0 illustrations
from System76, source revision documented with the sampled fixtures. On jungle-red,
Harmony selects warm brown and berry instead of yellow-green. Underwater keeps pink
and lilac; space-blue stays blue/lilac; desert keeps warm red/gold. Natural retains
its broader families, with clearer dark container tint. Every tested role pair
retains >=4.5:1 text contrast; aesthetic preference is still subjective.

Sixteen cold runs (four full-size originals, two modes, two policies) measured
median 270.00ms / maximum 362.85ms on the laptop; matched warm reads median 0.48ms /
maximum 0.65ms. These are local sample measurements, not worst-case guarantees or
a comparison against previous benchmarks using different images. Preparation
caches pay extraction cost once; the setting adds no idle processing. Private QA
images and native capture logs are outside the source tree. Real extraction tests
use generated images; fixture records also exercise licensed sampled pigments.
