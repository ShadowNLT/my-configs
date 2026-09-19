---
description: Check ShadowNLT/concept-viz upstream and update local concept-viz command/assets if not byte-identical
argument-hint: [--check-only | --force]
---

# Concept Viz Update

Target: $ARGUMENTS (flags: `--check-only` reports without writing, `--force` overwrites even if bytes identical).

You are the updater for a globally installed `concept-viz` command. Upstream is `https://github.com/ShadowNLT/concept-viz` (skill package at `concept-viz/`). This command is the only writer for the current harness's `concept-viz` install paths.

## What "bytes identical" means

Byte-for-byte equality as `cmp -s` / `sha256sum` reports, not semantic equivalence. Line endings, whitespace, and frontmatter all count. The command file and the skill-form `SKILL.md` are *derived* (upstream `SKILL.md` wrapped with form-specific frontmatter + Asset resolution preamble), so they are never byte-identical to raw `SKILL.md` — compare each derived form to a freshly wrapped candidate, and compare raw `SKILL.md` separately as `$SIDECAR/SKILL.upstream.md`.

## Seeded paths (sync these; skip the rest)

Upstream skill root is the `concept-viz/` subdirectory, not the repo root. Seed the runtime files the skill opens. Flatten that subdirectory into the sidecar (so `$SIDECAR/catalog.py` matches upstream `concept-viz/catalog.py`). Also seed repo-root `LICENSE`, repo-root `examples/`, and the three docs the skill body names.

Do **not** seed repo-root `README.md`, `.gitignore`, `decisions.tsv`, `tests/`, repo-root `evals/`, or the rest of `docs/` (`docs/README.md`, `docs/amendments/`, `docs/concept-viz-adversarial.md`, `docs/concept-viz-skill-outline.md`). Nested skill-package `eval/golden-asks.json` is seeded.

Asset paths (byte-copy):

- `concept-viz/catalog.py`
- `concept-viz/gate.py`
- `concept-viz/render.py`
- `concept-viz/retrieval.py`
- `concept-viz/runstore.py`
- `LICENSE` (repo root)
- `concept-viz/catalog/` (recursive)
- `concept-viz/eval/` (recursive)
- `concept-viz/schemas/` (recursive)
- `concept-viz/scripts/` (recursive)
- `concept-viz/seeds/` (recursive)
- `concept-viz/skeletons/` (recursive)
- `examples/` (repo root, recursive)
- `docs/concept-viz-hardened.md`
- `docs/concept-viz-serve-stop.md`
- `docs/coverage-scorecard.md`
- `concept-viz/SKILL.md` → stored as `$SIDECAR/SKILL.upstream.md` (raw)

Derived paths (regenerate, do not `cp` raw `SKILL.md` over them):

- `$COMMAND_FILE` — command form
- `$SIDECAR/SKILL.md` and `$REPO_PROTOCOL/SKILL.md` — skill form

## Procedure — run every time this command is invoked

Do all steps in order, with observable shell output. Do not skip the temp clone even if the network feels slow.

### 0. Resolve where this install lives — ask, do not assume

Ask which harness install to update if it is not already obvious in this conversation. Get `COMMANDS_DIR` and `CONFIG_DIR` from the user (see `protocols/README.md`). Do not look up a product name in a path table and do not default to a home directory.

Set:

- `SIDECAR="$CONFIG_DIR/concept-viz"`
- `COMMAND_FILE="$COMMANDS_DIR/concept-viz.md"`
- `UPDATE_FILE="$COMMANDS_DIR/concept-viz-update.md"`

If this repo is the workspace, also set `REPO_PROTOCOL` to `protocols/concept-viz/` and keep it in sync with the sidecar when you write. If `concept-viz` is installed and `concept-viz-update` is missing, copy `protocols/concept-viz-update/command.md` to `$UPDATE_FILE` as part of this run.

Echo the resolved paths before continuing.

### 1. Fetch upstream to a fresh temp dir

```bash
rm -rf /tmp/concept-viz-upstream
git clone --depth 1 https://github.com/ShadowNLT/concept-viz.git /tmp/concept-viz-upstream 2>&1
git -C /tmp/concept-viz-upstream rev-parse --short HEAD
git -C /tmp/concept-viz-upstream log --oneline -1
find /tmp/concept-viz-upstream/concept-viz -not -path '*/.git/*' -type f | sort
```

### 2. Snapshot local state

```bash
ls -lh "$COMMAND_FILE" "$SIDECAR"/SKILL.md "$SIDECAR"/SKILL.upstream.md \
  "$SIDECAR"/catalog.py "$SIDECAR"/gate.py "$SIDECAR"/render.py \
  "$SIDECAR"/retrieval.py "$SIDECAR"/runstore.py "$SIDECAR"/LICENSE 2>&1
find "$SIDECAR"/catalog "$SIDECAR"/eval "$SIDECAR"/schemas \
  "$SIDECAR"/scripts "$SIDECAR"/seeds "$SIDECAR"/skeletons \
  "$SIDECAR"/examples "$SIDECAR"/docs -type f 2>/dev/null | wc -l
```

### 3. Byte-compare each seeded path

```bash
UP=/tmp/concept-viz-upstream
SKILL_ROOT="$UP/concept-viz"
for f in catalog.py gate.py render.py retrieval.py runstore.py; do
  cmp -s "$SKILL_ROOT/$f" "$SIDECAR/$f" && echo "$f: IDENTICAL" || echo "$f: DIFFERS"
done
cmp -s "$UP/LICENSE" "$SIDECAR/LICENSE" && echo "LICENSE: IDENTICAL" || echo "LICENSE: DIFFERS"
cmp -s "$SKILL_ROOT/SKILL.md" "$SIDECAR/SKILL.upstream.md" && echo "SKILL.upstream.md: IDENTICAL" || echo "SKILL.upstream.md: DIFFERS"
for f in concept-viz-hardened.md concept-viz-serve-stop.md coverage-scorecard.md; do
  cmp -s "$UP/docs/$f" "$SIDECAR/docs/$f" && echo "docs/$f: IDENTICAL" || echo "docs/$f: DIFFERS"
done
diff -rq "$SKILL_ROOT/catalog" "$SIDECAR"/catalog
diff -rq "$SKILL_ROOT/eval" "$SIDECAR"/eval
diff -rq "$SKILL_ROOT/schemas" "$SIDECAR"/schemas
diff -rq "$SKILL_ROOT/scripts" "$SIDECAR"/scripts
diff -rq "$SKILL_ROOT/seeds" "$SIDECAR"/seeds
diff -rq "$SKILL_ROOT/skeletons" "$SIDECAR"/skeletons
diff -rq "$UP/examples" "$SIDECAR"/examples
```

Summarize recursive dirs as counts, and list every DIFFERS / NEW / GONE path (do not print 70 IDENTICAL rows).

Then build derived candidates and compare those:

1. Read upstream `/tmp/concept-viz-upstream/concept-viz/SKILL.md`, strip its YAML frontmatter (the opening `---` block).
2. Write `/tmp/concept-viz-candidate.md` as the command form in §4.
3. Write `/tmp/concept-viz-skill-candidate.md` as the skill form in §4.
4. Compare:

```bash
cmp -s /tmp/concept-viz-candidate.md "$COMMAND_FILE" && echo "concept-viz.md (derived command): IDENTICAL" || echo "concept-viz.md (derived command): DIFFERS"
cmp -s /tmp/concept-viz-skill-candidate.md "$SIDECAR"/SKILL.md && echo "SKILL.md (derived skill): IDENTICAL" || echo "SKILL.md (derived skill): DIFFERS"
diff -u "$COMMAND_FILE" /tmp/concept-viz-candidate.md | head -n 80
```

Present a table:

| File | Status |
|------|--------|
| catalog.py | IDENTICAL / DIFFERS |
| gate.py | ... |
| render.py | ... |
| retrieval.py | ... |
| runstore.py | ... |
| LICENSE | ... |
| SKILL.upstream.md (raw) | ... |
| docs/concept-viz-hardened.md | ... |
| docs/concept-viz-serve-stop.md | ... |
| docs/coverage-scorecard.md | ... |
| catalog/ | N identical, N differs, N new, N gone |
| eval/ | ... |
| schemas/ | ... |
| scripts/ | ... |
| seeds/ | ... |
| skeletons/ | ... |
| examples/ | ... |
| `<name>.md` in the commands dir (derived) | ... |
| SKILL.md (derived skill) | ... |

If `--check-only` was passed, stop here after the table and clean up `/tmp/concept-viz-upstream` (and candidates). Do not write.

### 4. Update any file that is not bytes identical (default)

Only files marked DIFFERS / NEW / GONE are overwritten. Never touch files marked IDENTICAL unless `--force` is set.

**For asset paths** — direct byte copy into `$SIDECAR` (and `$REPO_PROTOCOL` when set). Use `--delete` on the recursive dirs so removed upstream files disappear locally:

```bash
UP=/tmp/concept-viz-upstream
SKILL_ROOT="$UP/concept-viz"
cp "$SKILL_ROOT/catalog.py" "$SIDECAR"/catalog.py
cp "$SKILL_ROOT/gate.py" "$SIDECAR"/gate.py
cp "$SKILL_ROOT/render.py" "$SIDECAR"/render.py
cp "$SKILL_ROOT/retrieval.py" "$SIDECAR"/retrieval.py
cp "$SKILL_ROOT/runstore.py" "$SIDECAR"/runstore.py
cp "$UP/LICENSE" "$SIDECAR"/LICENSE
cp "$SKILL_ROOT/SKILL.md" "$SIDECAR"/SKILL.upstream.md
mkdir -p "$SIDECAR"/docs
cp "$UP/docs/concept-viz-hardened.md" "$SIDECAR"/docs/concept-viz-hardened.md
cp "$UP/docs/concept-viz-serve-stop.md" "$SIDECAR"/docs/concept-viz-serve-stop.md
cp "$UP/docs/coverage-scorecard.md" "$SIDECAR"/docs/coverage-scorecard.md
rsync -a --delete "$SKILL_ROOT/catalog/" "$SIDECAR"/catalog/
rsync -a --delete "$SKILL_ROOT/eval/" "$SIDECAR"/eval/
rsync -a --delete "$SKILL_ROOT/schemas/" "$SIDECAR"/schemas/
rsync -a --delete "$SKILL_ROOT/scripts/" "$SIDECAR"/scripts/
rsync -a --delete "$SKILL_ROOT/seeds/" "$SIDECAR"/seeds/
rsync -a --delete "$SKILL_ROOT/skeletons/" "$SIDECAR"/skeletons/
rsync -a --delete "$UP/examples/" "$SIDECAR"/examples/
```

If `REPO_PROTOCOL` is set, copy the same bytes into that folder so the repo stays identical to the sidecar.

**For the command file** `$COMMAND_FILE` and **skill-form** `SKILL.md` — regenerate from upstream `SKILL.md`, preserving the form contract. Do not copy raw `SKILL.md` over either file.

Command form must be exactly:

```
---
description: Explain one teachable concept grain as a short series of dual-coded stepped visuals. Gates on a small assumption graph; splits when overloaded; serves ephemeral local HTML (127.0.0.1, stoppable). Not for data dashboards, full courses, or adaptive tutoring.
argument-hint: [concept to explain — e.g. "how hash table chaining stores a collision"]
---

# Concept Viz

Target: $ARGUMENTS. If empty, ask which concept to explain and for whom.

This protocol was seeded from `ShadowNLT/concept-viz` (`concept-viz/SKILL.md` + catalog + skeletons + scripts). The procedure below is the upstream skill body; follow it end to end. Do not improvise a visual series outside that procedure.

[Asset resolution section — verbatim from the current command file's Asset resolution block, or from protocols/concept-viz/command.md if the current file has no such section — then the full body of upstream SKILL.md starting after its frontmatter `---` block]
```

Skill form must be exactly:

```
---
name: concept-viz
description: Explain one teachable concept grain as a short series of dual-coded stepped visuals. Gates on a small assumption graph; splits when overloaded; serves ephemeral local HTML (127.0.0.1, stoppable). Not for data dashboards, full courses, or adaptive tutoring. Trigger on: "concept-viz", "explain this concept visually", "mechanism diagram", "teach this grain", "stepped visual explainer", or when someone wants a short local HTML teaching series rather than a course, dashboard, or tutor.
---

# Concept Viz

Infer the concept from the conversation: the grain to teach, the audience prior, and whether they asked for a visual series. If several concepts are in play, or the request is too vague to gate, ask which concept and for whom before opening the catalog.

This protocol was seeded from `ShadowNLT/concept-viz` (`concept-viz/SKILL.md` + catalog + skeletons + scripts). The procedure below is the upstream skill body; follow it end to end. Do not improvise a visual series outside that procedure.

[same Asset resolution block as the command — then the full body of upstream SKILL.md starting after its frontmatter `---` block]
```

Implementation: `Read` the current `$COMMAND_FILE` to capture its exact frontmatter + Asset resolution preamble, then `Read` upstream `SKILL.md`, strip its frontmatter, splice them, and `Write` the candidates via the file tools (not `cp`). If the current command file is missing or corrupted, use `protocols/concept-viz/command.md` as the fallback. Keep the Asset resolution block agent-agnostic — never rewrite it to name one harness's home path.

After copying, re-run the `cmp -s` / `diff -rq` checks from §3 to confirm every seeded path is now IDENTICAL. If any still reports DIFFERS, surface the `diff` and do not claim success.

### 5. Clean up and report

```bash
rm -rf /tmp/concept-viz-upstream /tmp/concept-viz-candidate.md /tmp/concept-viz-skill-candidate.md
ls -lh "$COMMAND_FILE" "$SIDECAR"/SKILL.md "$SIDECAR"/SKILL.upstream.md "$SIDECAR"/catalog.py
```

Final message must state:
- Which harness and paths were resolved in §0
- How many files were IDENTICAL vs updated (recursive dirs as counts plus named diffs)
- For each updated top-level file: `old sha256 → new sha256` (from the shasum snapshots)
- The exact `git rev-parse --short HEAD` or `git log --oneline -1` from the temp clone (capture before deleting, e.g. `git -C /tmp/concept-viz-upstream rev-parse --short HEAD`)
- That `/tmp/concept-viz-upstream` was removed

Never leave `/tmp/concept-viz-upstream` behind on success. On network/clone failure, report the error, leave local files untouched, and suggest retrying with `git ls-remote https://github.com/ShadowNLT/concept-viz.git HEAD` to diagnose.

## Flags

- No flag: check and update drifted files.
- `--check-only`: only report the table, do not write.
- `--force`: overwrite all files even if IDENTICAL (still report before/after shasums).

## Safety

- This command only writes `$COMMAND_FILE`, `$SIDECAR`, and `$REPO_PROTOCOL` when set. It never touches other commands, and it never seeds `concept-viz` as a skill.
- Do not run `npx skills add` inside this command — that would seed as a skill, which is a different install path than this pair.
- Do not copy `tests/`, repo-root `evals/`, repo-root `README.md`, `.gitignore`, `decisions.tsv`, or the rest of `docs/` into the sidecar or the repo protocol.
