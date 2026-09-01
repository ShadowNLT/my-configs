# Teaching Standard

Canonical teaching doctrine for all agent commands (corporate, personal, and curriculum sessions).

## Files

| File | Role |
|---|---|
| `Teaching-Standard.md` | Source of truth — §Procedure P1–P6 and rules TS-1…TS-7 |

## Where it lives on disk

**Not in a knowledge/work vault.** The Teaching Standard is harness-local agent config — the same
class of thing as `layman-terms/denylist.txt` or `concept-viz/template/`. It stays with the agent
harness so personal and corporate profiles can both use it without coupling to a corporate vault.

```
$CONFIG_DIR/teaching-standard/Teaching-Standard.md
```

`CONFIG_DIR` is **user-given at seed time** — ask where the harness lives; never assume or bake a
machine path into this repo.

## Install

Ask the user for `CONFIG_DIR` (harness config root) before copying. Echo the resolved path and
get confirmation, then:

```bash
mkdir -p "$CONFIG_DIR/teaching-standard"
cp protocols/teaching-standard/Teaching-Standard.md "$CONFIG_DIR/teaching-standard/"
```

**Corporate seed:** also add to the harness variable map (resolved in command templates at seed):

| Variable | Resolves to |
|---|---|
| `{{TEACHING_STANDARD_PATH}}` | `$CONFIG_DIR/teaching-standard/Teaching-Standard.md` |

**Personal seed:** same sidecar install; same variable if teaching commands are seeded.

**Knowledge vault** (optional, separate concern): corporate work harnesses that run `/learn`,
`/start-work`, etc. also need a configured knowledge vault root for P3 graph reconcile — that is
**not** where this file goes. Resolve it via a distinct seed variable (e.g.
`{{KNOWLEDGE_VAULT_ROOT}}`) in those commands only.

## Commands

Teaching commands do **not** copy this file into `$COMMANDS_DIR`. They reference
`{{TEACHING_STANDARD_PATH}}` (after seed) or the repo copy during development. When the standard
changes, re-install the sidecar and update command inline triggers in the same commit.

## Related protocols

| Protocol | Relationship |
|---|---|
| `explain-first-principles` | Command form of §Procedure P2+P5 (TS-1) |
| `layman-terms` | §Procedure P6 clarity pass only — not a substitute for teaching |
| `concept-viz` | Optional visual layer after P5 |

Teaching commands (`start-work`, `learn`, `new-session`, etc.) live in `corporate/commands/` and reference `{{TEACHING_STANDARD_PATH}}`.
