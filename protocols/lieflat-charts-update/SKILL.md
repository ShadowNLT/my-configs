---
name: lieflat-charts-update
description: Check larashero3-dotcom/lieflat-charts upstream and update the locally-seeded lieflat-charts command/assets if they are not byte-identical to the upstream. Trigger on: "update lieflat-charts", "check if lieflat-charts is up to date", "sync lieflat-charts from upstream", "are we on the latest lieflat skill", "refresh the lieflat-charts command".
---

# Lieflat Charts Update

Infer the intent from the conversation: the user wants to know if the locally-seeded `lieflat-charts` command is byte-identical to upstream `https://github.com/larashero3-dotcom/lieflat-charts` and, unless they asked for a check-only audit, to update any drifted files. If the request is ambiguous (e.g. "update the charts" could mean this updater vs redrawing a specific project's HTML), ask which is meant before fetching.

You are the updater for a globally installed `lieflat-charts` command. Upstream is `https://github.com/larashero3-dotcom/lieflat-charts` (skill at repo root `SKILL.md`). When seeded from this repo, the source of the seed is `protocols/lieflat-charts/` — still resolve the live install by asking for that harness's `CONFIG_DIR` and `COMMANDS_DIR`. This skill is the only writer for those install paths.

## What "bytes identical" means

Byte-for-byte equality as `cmp -s` / `sha256sum` reports, not semantic equivalence. Line endings, whitespace, and frontmatter all count. The command file and the skill-form `SKILL.md` are *derived* (upstream `SKILL.md` wrapped with form-specific frontmatter + Asset resolution preamble), so they are never byte-identical to raw `SKILL.md` — compare each derived form to a freshly wrapped candidate, and compare raw `SKILL.md` separately as `$SIDECAR/SKILL.upstream.md`.

## Seeded paths (sync these; skip the rest)

Upstream is the repo root, not a `skills/` subfolder. Seed the runtime files the skill opens. Do **not** seed `docs/` (README marketing images), repo-root `README.md` / `README.en.md`, `agents/`, or `.gitignore`. Nested READMEs under `templates/` and `examples/` are seeded.

Asset paths (byte-copy):

- `catalog.md`
- `report-catalog.md`
- `color-presets.js`
- `mono-tokens.js`
- `LICENSE`
- `THIRD_PARTY_NOTICES.md`
- `templates/` (recursive)
- `examples/` (recursive)
- `scripts/` (recursive)
- `SKILL.md` → stored as `$SIDECAR/SKILL.upstream.md` (raw)

Derived paths (regenerate, do not `cp` raw `SKILL.md` over them):

- `$COMMAND_FILE` — command form
- `$SIDECAR/SKILL.md` and `$REPO_PROTOCOL/SKILL.md` — skill form

## Procedure — run every time this skill is triggered

Do all steps in order, with observable shell output. Do not skip the temp clone even if the network feels slow. If the user said "check only" or "audit without updating", treat that as `--check-only`; if they said "force", treat as `--force`; otherwise default is to update drifted files.

### 0. Resolve where this install lives — ask, do not assume

Ask which harness install to update if it is not already obvious in this conversation. Get `COMMANDS_DIR` and `CONFIG_DIR` from the user (see `protocols/README.md`). Do not look up a product name in a path table and do not default to a home directory.

Set:

- `SIDECAR="$CONFIG_DIR/lieflat-charts"`
- `COMMAND_FILE="$COMMANDS_DIR/lieflat-charts.md"`
- `UPDATE_FILE="$COMMANDS_DIR/lieflat-charts-update.md"`

If this repo is the workspace, also set `REPO_PROTOCOL` to `protocols/lieflat-charts/` and keep it in sync with the sidecar when you write. If `lieflat-charts` is installed and `lieflat-charts-update` is missing, copy `protocols/lieflat-charts-update/command.md` to `$UPDATE_FILE` as part of this run.

Echo the resolved paths before continuing.

### 1. Fetch upstream to a fresh temp dir

```bash
rm -rf /tmp/lieflat-charts-upstream
git clone --depth 1 https://github.com/larashero3-dotcom/lieflat-charts.git /tmp/lieflat-charts-upstream 2>&1
git -C /tmp/lieflat-charts-upstream rev-parse --short HEAD
git -C /tmp/lieflat-charts-upstream log --oneline -1
find /tmp/lieflat-charts-upstream -not -path '*/.git/*' -not -path '*/docs/*' -type f | sort
```

### 2. Snapshot local state

```bash
ls -lh "$COMMAND_FILE" "$SIDECAR"/SKILL.md "$SIDECAR"/SKILL.upstream.md \
  "$SIDECAR"/catalog.md "$SIDECAR"/report-catalog.md \
  "$SIDECAR"/color-presets.js "$SIDECAR"/mono-tokens.js 2>&1
find "$SIDECAR"/templates "$SIDECAR"/examples "$SIDECAR"/scripts -type f 2>/dev/null | wc -l
```

### 3. Byte-compare each seeded path

```bash
UP=/tmp/lieflat-charts-upstream
for f in catalog.md report-catalog.md color-presets.js mono-tokens.js LICENSE THIRD_PARTY_NOTICES.md; do
  cmp -s "$UP/$f" "$SIDECAR/$f" && echo "$f: IDENTICAL" || echo "$f: DIFFERS"
done
cmp -s "$UP/SKILL.md" "$SIDECAR/SKILL.upstream.md" && echo "SKILL.upstream.md: IDENTICAL" || echo "SKILL.upstream.md: DIFFERS"
diff -rq "$UP/templates" "$SIDECAR"/templates
diff -rq "$UP/examples" "$SIDECAR"/examples
diff -rq "$UP/scripts" "$SIDECAR"/scripts
```

Summarize recursive dirs as counts, and list every DIFFERS / NEW / GONE path (do not print 70 IDENTICAL rows).

Then build derived candidates and compare those:

1. Read upstream `/tmp/lieflat-charts-upstream/SKILL.md`, strip its YAML frontmatter (the opening `---` block).
2. Write `/tmp/lieflat-charts-candidate.md` as the command form in §4.
3. Write `/tmp/lieflat-charts-skill-candidate.md` as the skill form in §4.
4. Compare:

```bash
cmp -s /tmp/lieflat-charts-candidate.md "$COMMAND_FILE" && echo "lieflat-charts.md (derived command): IDENTICAL" || echo "lieflat-charts.md (derived command): DIFFERS"
cmp -s /tmp/lieflat-charts-skill-candidate.md "$SIDECAR"/SKILL.md && echo "SKILL.md (derived skill): IDENTICAL" || echo "SKILL.md (derived skill): DIFFERS"
diff -u "$COMMAND_FILE" /tmp/lieflat-charts-candidate.md | head -n 80
```

Present a table:

| File | Status |
|------|--------|
| catalog.md | IDENTICAL / DIFFERS |
| report-catalog.md | ... |
| color-presets.js | ... |
| mono-tokens.js | ... |
| LICENSE | ... |
| THIRD_PARTY_NOTICES.md | ... |
| SKILL.upstream.md (raw) | ... |
| templates/ | N identical, N differs, N new, N gone |
| examples/ | ... |
| scripts/ | ... |
| `<name>.md` in the commands dir (derived) | ... |
| SKILL.md (derived skill) | ... |

If the user asked for check-only, stop here after the table and clean up `/tmp/lieflat-charts-upstream` (and candidates). Do not write.

### 4. Update any file that is not bytes identical (default)

Only files marked DIFFERS / NEW / GONE are overwritten. Never touch files marked IDENTICAL unless the user said force.

**For asset paths** — direct byte copy into `$SIDECAR` (and `$REPO_PROTOCOL` when set). Use `--delete` on the recursive dirs so removed upstream files disappear locally:

```bash
UP=/tmp/lieflat-charts-upstream
cp "$UP/catalog.md" "$SIDECAR"/catalog.md
cp "$UP/report-catalog.md" "$SIDECAR"/report-catalog.md
cp "$UP/color-presets.js" "$SIDECAR"/color-presets.js
cp "$UP/mono-tokens.js" "$SIDECAR"/mono-tokens.js
cp "$UP/LICENSE" "$SIDECAR"/LICENSE
cp "$UP/THIRD_PARTY_NOTICES.md" "$SIDECAR"/THIRD_PARTY_NOTICES.md
cp "$UP/SKILL.md" "$SIDECAR"/SKILL.upstream.md
rsync -a --delete "$UP/templates/" "$SIDECAR"/templates/
rsync -a --delete "$UP/examples/" "$SIDECAR"/examples/
rsync -a --delete "$UP/scripts/" "$SIDECAR"/scripts/
```

If `REPO_PROTOCOL` is set, copy the same bytes into that folder so the repo stays identical to the sidecar.

**For the command file** `$COMMAND_FILE` and **skill-form** `SKILL.md` — regenerate from upstream `SKILL.md`, preserving the form contract. Do not copy raw `SKILL.md` over either file.

Command form must be exactly:

```
---
description: Turn data into polished, self-contained HTML charts — and, only when asked, full-page HTML reports — from the Lieflat Charts galleries (Lupi editorial, Lupi basics, Glance, Maps, Interactive) plus 12 bilingual report templates. Mono is the default palette; color presets apply when the data warrants them. Default output is charts, not reports.
argument-hint: [chart task — e.g. "chart this CSV for a newsletter" or "Glance weekly ranking"]
---

# Lieflat Charts

Target: $ARGUMENTS. If empty, ask what data to chart and for what occasion.

This protocol was seeded from `larashero3-dotcom/lieflat-charts` (`SKILL.md` + catalogs + tokens + `templates/`). The procedure below is the upstream skill body; follow it end to end. Do not improvise a chart outside that procedure.

[Asset resolution section — verbatim from the current command file's Asset resolution block, or from protocols/lieflat-charts/command.md if the current file has no such section — then the full body of upstream SKILL.md starting after its frontmatter `---` block]
```

Skill form must be exactly:

```
---
name: lieflat-charts
description: Turn data into polished, self-contained HTML charts — and, only when asked, full-page HTML reports — from the Lieflat Charts galleries (Lupi editorial, Lupi basics, Glance, Maps, Interactive) plus 12 bilingual report templates. Mono is the default palette; color presets apply when the data warrants them. Default output is charts, not reports. Trigger on: "lieflat chart", "make a lieflat chart", "chart this data", "Lupi/Glance chart", "visualize this as HTML", "make a report from this data", or when someone wants a publishable single-file HTML chart rather than a screenshot or notebook plot.
---

# Lieflat Charts

Infer the chart task from the conversation: the dataset, the occasion, and whether they asked for a report. If several datasets are in play, or the request is too vague to chart, ask what data and for what occasion before opening a template.

This protocol was seeded from `larashero3-dotcom/lieflat-charts` (`SKILL.md` + catalogs + tokens + `templates/`). The procedure below is the upstream skill body; follow it end to end. Do not improvise a chart outside that procedure.

[same Asset resolution block as the command — then the full body of upstream SKILL.md starting after its frontmatter `---` block]
```

Implementation: `Read` the current `$COMMAND_FILE` to capture its exact frontmatter + Asset resolution preamble, then `Read` upstream `SKILL.md`, strip its frontmatter, splice them, and `Write` the candidates via the file tools (not `cp`). If the current command file is missing or corrupted, use `protocols/lieflat-charts/command.md` as the fallback. Keep the Asset resolution block agent-agnostic — never rewrite it to name one harness's home path.

After copying, re-run the `cmp -s` / `diff -rq` checks from §3 to confirm every seeded path is now IDENTICAL. If any still reports DIFFERS, surface the `diff` and do not claim success.

### 5. Clean up and report

```bash
rm -rf /tmp/lieflat-charts-upstream /tmp/lieflat-charts-candidate.md /tmp/lieflat-charts-skill-candidate.md
ls -lh "$COMMAND_FILE" "$SIDECAR"/SKILL.md "$SIDECAR"/SKILL.upstream.md "$SIDECAR"/catalog.md
```

Final message must state:
- Which harness and paths were resolved in §0
- How many files were IDENTICAL vs updated (recursive dirs as counts plus named diffs)
- For each updated top-level file: `old sha256 → new sha256` (from the shasum snapshots)
- The exact `git rev-parse --short HEAD` or `git log --oneline -1` from the temp clone (capture before deleting, e.g. `git -C /tmp/lieflat-charts-upstream rev-parse --short HEAD`)
- That `/tmp/lieflat-charts-upstream` was removed

Never leave `/tmp/lieflat-charts-upstream` behind on success. On network/clone failure, report the error, leave local files untouched, and suggest retrying with `git ls-remote https://github.com/larashero3-dotcom/lieflat-charts.git HEAD` to diagnose.

## Safety

- This skill only writes `$COMMAND_FILE`, `$SIDECAR`, and `$REPO_PROTOCOL` when set. It never touches other commands, and it never seeds `lieflat-charts` as a skill.
- Do not run `npx skills add` — that would seed as a skill.
- Do not copy `docs/` into the sidecar or the repo protocol.
