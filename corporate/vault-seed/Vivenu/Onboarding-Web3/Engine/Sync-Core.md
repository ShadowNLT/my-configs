---
type: engine-rule
created: 2026-07-07
verified_last: 2026-07-07
---

# Sync-Core

Why `/sync-core` exists — for exactly what it does, see the harness `/sync-core` command directly rather than a summary here. Same reasoning as [[../../Onboarding/Engine/Sync-Core|the checkout curriculum's copy]] of this file: the command file is the single source of truth for mechanics, this file only carries the rationale, so a future behavior change to the command can't leave this doc quietly wrong.

## Why this exists

`apps/web3` is under active, fast-moving development — the git history that grounded this curriculum (2026-07-07 recon) shows a steady stream of commits, much of it accessibility work and seating features. Module notes point at real file paths in that directory, which keeps moving. Without a check, those pointers go stale silently. `/sync-core` is the fix — run it whenever `develop` has moved since the last check.

## Where the actual rules live

The harness `/sync-core` command — read it directly for: what it fetches and how it never touches `vivenu-core`'s working tree, how it finds what's changed since the last sync, exactly which things get auto-corrected versus proposed (nothing is auto-written into a Module note, ever), and what the report to you looks like. The command is now track-aware — it operates against whichever track's `Curriculum-Map.md` you name (or the active track per [[../../Track-State|Track-State]] if you don't), and uses this track's own keyword list (see the command file) when scanning for new-material candidates: `web3, seating, seatmap, checkout, feature flag, a11y, accessibility, payment, cart, selection` — narrower than the checkout curriculum's list since this track cares about the frontend surface, not every backend entity.
