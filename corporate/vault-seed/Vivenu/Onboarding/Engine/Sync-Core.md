---
type: engine-rule
created: 2026-07-06
verified_last: 2026-07-06
---

# Sync-Core

Why `/sync-core` exists — for exactly what it does, see the harness `/sync-core` command directly rather than a summary here. This file used to restate the command's steps and its auto-fix/propose line in prose; that restatement drifted out of sync with the real command after the command's own adversarial review changed its behavior (renames went from "sometimes auto-applied" to "always proposed"). Two descriptions of one piece of logic is a standing invitation for exactly that kind of silent drift, so this file only carries the rationale now — the command file is the single source of truth for mechanics.

## Why this exists

`vivenu-core` keeps moving — new commits land on `develop` constantly, and the curriculum's Module notes point at real file paths in that repo. Without a check, those pointers go stale silently: a file gets renamed, a module still says to look at the old name, and the next session either wastes time hunting for it or trusts a dead pointer. `/sync-core` is the fix — run it whenever `develop` has moved since the last check.

## Where the actual rules live

The harness `/sync-core` command — read it directly for: what it fetches and how it never touches `vivenu-core`'s working tree, how it finds what's changed since the last sync, exactly which things get auto-corrected versus proposed (as of the last review: nothing is auto-written into a Module note, ever — rename detection and new-material detection are both propose-only), and what the report to you looks like.
