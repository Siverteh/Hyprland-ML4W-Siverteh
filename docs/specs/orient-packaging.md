# Orient build identity

Orient's runtime build identity must describe maintained package inputs, not
machine/worktree-specific formatter or build caches. Source files, package data,
metadata definitions, README and notices continue to invalidate the runtime.
Skip generated __pycache__, build/dist, .git, .ruff_cache, .pytest_cache and
*.egg-info trees. Do not delete them or ignore changes in actual package inputs.

Regression: modifying cache/build metadata keeps the digest stable; changing a
source file or notice changes it. After the one-time corrected deployment, a
second provisioning invocation must reuse the active tested runtime. Generation
algorithms, palette defaults, preferences and wallpaper selection remain unchanged.
Follow full checks, Hyprland validation, plan/apply and native release gates.
