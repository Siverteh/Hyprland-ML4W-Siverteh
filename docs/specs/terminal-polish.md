# Wallpaper-matched terminal styling

The existing Kitty/Orient publisher remains the single terminal color owner.
Repair the user-reported fixed cyan labels and fixed violet prompt accent without
replacing their font, shell/pearl logo, prompt layout or active terminal sessions.

- Fastfetch labels use ANSI blue, the existing wallpaper-primary terminal slot,
  instead of its default cyan. Separators use muted bright-black ink.
- The normal and bright magenta slots carry the readable wallpaper secondary,
  allowing the existing Oh My Posh marker to follow the chosen wallpaper.
- Keep semantic red, green and yellow. Preserve readable text (4.5:1 against the
  underlying terminal color) and the existing dark inverse roles in light mode.
- Dark terminal background uses the palette's low raised surface, with 92% opacity
  for subtle desktop texture. The static fallback agrees with generated opacity;
  private Kitty overrides retain final precedence.
- Publish through existing atomic writes and in-place Kitty config reloads. Do not
  add polling, another color generator, prompt replacement or worker restart.

Validate actual Fastfetch ANSI output and repeated distinct wallpaper colors in
light/dark publisher tests. Inspect real Kitty/Fastfetch/Oh My Posh rendering in an
owned temporary window. Remove only that window and restore original workspace and
focus. Preview tools must strip their inherited NO_COLOR and TERM=dumb flags;
those belong to automation, not to normal interactive terminal rendering.
