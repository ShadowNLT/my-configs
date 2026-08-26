---
description: Verify an onboarding curriculum against the latest vivenu-core, and surface new material
argument-hint: [optional: "web3" | "checkout" — defaults to the active track]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> ~/.claude|~/.cursor|~/.codex|~/.config/opencode, {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Sync Core

Keeps an onboarding curriculum honest against `vivenu-core`, which keeps moving underneath it. See that track's own `Engine/Sync-Core.md` in the vault for the full rationale — this file is the executable steps, shared across tracks.

## Resolve the track

If `$ARGUMENTS` names a track (see `Vivenu/Track-State.md`'s Tracks table for the current list), use it. Otherwise use `Vivenu/Track-State.md`'s `current-track` — and when you resolve it this way (no explicit argument), **say which track you resolved to before doing anything else**, not just in the final report — a bare `/sync-core` defaulting to whatever `current-track` currently is (which may not be the track you were just discussing) is easy to miss otherwise, especially right after a one-off module override in `/new-session` that didn't change `current-track`. Each track has:

| Track | Module glob | Scan pathspec (step 4) | Keyword list (step 4) |
|---|---|---|---|
| `checkout` | `Modules/M*.md` | whole repo | `checkout, transaction, ticket, payment, pricing, fee, voucher, reservation, discount, distributor` |
| `web3` | `Modules/W*.md` | `-- apps/web3` | `web3, seating, seatmap, checkout, feature flag, a11y, accessibility, payment, cart, selection` |

Curriculum root for each track (`Vivenu/Onboarding/` for checkout, `Vivenu/Onboarding-Web3/` for web3) comes from `Vivenu/Track-State.md`'s own Tracks table, not restated here — if a new track is ever added, add it to *that* table first, then add its row here for the sync-specific columns (glob/pathspec/keywords) that table doesn't carry. Both keyword lists are authoritative, not illustrative — edit this table directly as either domain's vocabulary grows. The web3 track's scan is deliberately narrowed to `apps/web3` (rather than the whole repo) because that track's own scope explicitly excludes the shared backend — see `Vivenu/Onboarding-Web3/Engine/00-How-This-Works.md`'s Scope section.

## Golden rule

**Never touch the working tree of `~/Developer/vivenu-core`.** Read remote/historical content only via `git show origin/develop:<path>`, `git ls-tree origin/develop`, `git log`, `git cat-file -e`. The local checkout may be on any branch with any uncommitted state — do not run `git checkout`, `git pull`, `git stash`, or anything else that mutates it. (This command exists partly because an earlier session ran `git checkout develop -- .` on a branch with unrelated changes and staged 4 files that had to be reverted. Remote-read only, no exceptions.)

## Preconditions

Before anything else: confirm `~/Developer/vivenu-core` exists and is a git repo (`git -C ~/Developer/vivenu-core rev-parse --git-dir`). If it doesn't, stop and tell the user — there's nothing to sync against.

## Steps

1. `cd ~/Developer/vivenu-core && git fetch origin`. If this fails (network, auth, `origin/develop` doesn't resolve), **stop and report the failure** — do not proceed on stale data.
2. Read `last_synced_commit` from the frontmatter of the resolved track's `Curriculum-Map.md`.
   - **If it's present and resolves:** run `git log --oneline <last_synced_commit>..origin/develop`. If the range is empty, report "already in sync as of `origin/develop`" and stop.
   - **If it's absent, unparseable, or doesn't resolve as an ancestor of `origin/develop`:** treat this as a first sync. Still run step 3, but skip step 4 and say so explicitly — "first sync: baseline established, re-run after `develop` moves for a real diff."
3. For each Module note matching the resolved track's Module glob, read its "Key Files & Entry Points" section.
   - **If the section is missing or empty:** skip that module and note it in the report.
   - **Extraction rule:** each bullet's path is the *first* backtick-delimited span on the line.
   - Check each extracted path exists at `origin/develop` (`git cat-file -e origin/develop:<path>`).
     - Still exists: no action.
     - Missing: run `git log --follow --oneline -- <old-path>` on `origin/develop` to look for a rename. **Never auto-apply this** — propose the candidate(s) instead: one plausible successor → propose old → new; more than one → list all; none → flag as broken with no candidate. Leave the Module note untouched either way.
4. Scan the commit range from step 2 (messages and touched paths, restricted to the resolved track's scan pathspec, skip if step 2 detected a first sync) for that track's keyword list. Summarize anything substantial enough to be new module content as a **proposal**, never write it into a Module note directly.
5. Update the resolved track's `Curriculum-Map.md` frontmatter: `last_synced_commit` to the current `origin/develop` SHA, `last_synced_at` to today's date — get the real date via `date +%F`, don't rely on ambient knowledge of what day it is.
6. Report to the user in this shape. This command touches only that track's `Curriculum-Map.md` frontmatter and (on confirmed path fixes) Module note bodies — it never writes `Progress-Dashboard.md`. The report itself is chat-only; the persisted audit trail is the frontmatter updated in step 5.
   - Which track this ran against, if it wasn't obvious from the request.
   - Commits pulled since last sync (count + one-line range summary, not the full log unless asked), or "first sync" per step 2.
   - Paths verified to still exist (existence only, not pedagogical accuracy).
   - Any proposed path fix (old → new, or multiple candidates) — needs the user's call.
   - Anything flagged as broken with no successor candidate — needs the user's call.
   - Any new-material candidates worth a future module — needs the user's call.
