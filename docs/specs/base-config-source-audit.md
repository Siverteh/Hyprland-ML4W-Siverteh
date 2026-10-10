# Final source review of replaced base defaults

Audit spec ready, 2026-10-09 local / 2026-10-10 UTC. Consolidate current SHA-bound
reviews for the already independently rewritten area in config-defaults.md:
kitty/kitty.conf, fastfetch/config.jsonc, fastfetch/system-age.sh,
hypr/conf/{misc,decoration,nacre}.lua and tools/tests/test_config_defaults.py.
Trace replacement 3bf8870 and acceptance/corrections 00fbe78 plus later current-file
changes. Do not rewrite verified independent implementations merely because their
final review records have not yet been consolidated.

Inspect these own current bodies against the existing behavior spec, recorded
replacement boundary and authoring changes. Original inherited bodies were deleted
before fresh implementation; retain honest earlier public declaration/source
exposure record. Mechanical historical comparison can supplement evidence, not
replace it or serve as a legal clean-room/whole-license conclusion. No upstream
body consulted while writing any necessary replacement.

Preserve current private palette/host override precedence, Kitty effective
non-color defaults, Nacre Fastfetch layout and validated filesystem-age helper.
Retired ML4W rules/templates must stay retired. Logo/generator/private assets and
other runtime/terminal helper dependencies remain separate audits; this review
cannot certify them by association. Correctly licensed native applications/APIs
remain dependencies, not prohibited implementation ancestry.

Acceptance: trace exact sources/tests, current installed bytes and real native
Kitty/Fastfetch/compositor contracts without closing user windows or changing
preferences. Reuse scoped owned fixtures only where additional runtime evidence
is needed; do not apply bound power/package/AI actions. Full tests/native Hyprland
and reviewed install plan. If runtime unchanged, compare active source and retain
its good release instead of restarting it for a documentation-only audit. If
runtime corrections needed, spec first, deletion/reimplementation for inherited
portions, appropriate config/shell plan/apply/strict/live gates. Exact-main CI,
private worker/state preservation and registry integrity required. Notices and
complete originality goal remain until whole-tree requirements are proven.
