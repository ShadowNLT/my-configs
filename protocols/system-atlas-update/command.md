---
description: Check inkboard/system-atlas upstream and update local system-atlas command/assets if not byte-identical
argument-hint: [--check-only | --force]
---

# System Atlas Update

Target: $ARGUMENTS (flags: `--check-only` reports without writing, `--force` overwrites even if bytes identical).

You are the updater for a globally installed `system-atlas` command. Upstream is `https://github.com/inkboard/system-atlas` (skill at `skills/system-atlas/`). This command is the only writer for the current harness's `system-atlas` install paths.

## What "bytes identical" means

Byte-for-byte equality as `cmp -s` / `sha256sum` reports, not semantic equivalence. Line endings, whitespace, and frontmatter all count. The command file is *derived* (upstream `SKILL.md` wrapped with command-form frontmatter + Asset resolution preamble), so it is never byte-identical to raw `SKILL.md` — compare the derived form to the existing command, and compare raw `SKILL.md` separately as `$SIDECAR/SKILL.md` if present.

## Procedure — run every time this command is invoked

Do all steps in order, with observable shell output. Do not skip the temp clone even if the network feels slow.

### 0. Resolve where this install lives — ask, do not assume

Ask which harness install to update if it is not already obvious in this conversation. Get `COMMANDS_DIR` and `CONFIG_DIR` from the user (see `protocols/README.md`). Do not look up a product name in a path table and do not default to a home directory.

Set:

- `SIDECAR="$CONFIG_DIR/system-atlas"`
- `COMMAND_FILE="$COMMANDS_DIR/system-atlas.md"`
- `UPDATE_FILE="$COMMANDS_DIR/system-atlas-update.md"`

If this repo is the workspace, also set `REPO_PROTOCOL` to `protocols/system-atlas/` and keep it in sync with the sidecar when you write. If `system-atlas` is installed and `system-atlas-update` is missing, copy `protocols/system-atlas-update/command.md` to `$UPDATE_FILE` as part of this run.

Echo the resolved paths before continuing.

### 1. Fetch upstream to a fresh temp dir

```bash
rm -rf /tmp/system-atlas-upstream
git clone --depth 1 https://github.com/inkboard/system-atlas.git /tmp/system-atlas-upstream 2>&1
ls -R /tmp/system-atlas-upstream/skills/system-atlas
```

Upstream files of interest:
- `skills/system-atlas/SKILL.md`
- `skills/system-atlas/assets/template.html`
- `skills/system-atlas/assets/build.mjs`
- `skills/system-atlas/assets/data.example.mjs`
- `skills/system-atlas/references/design-language.md`
- `skills/system-atlas/references/process-and-lessons.md`
- `skills/system-atlas/evals/evals.json`

### 2. Snapshot local state

```bash
ls -lh "$COMMAND_FILE" "$SIDECAR"/assets/* "$SIDECAR"/references/* "$SIDECAR"/evals.json "$SIDECAR"/SKILL.md 2>&1
for f in "$SIDECAR"/assets/template.html "$SIDECAR"/assets/build.mjs "$SIDECAR"/assets/data.example.mjs "$SIDECAR"/references/design-language.md "$SIDECAR"/references/process-and-lessons.md "$SIDECAR"/evals.json; do echo "--- $f"; shasum -a 256 "$f" 2>&1 | head -n1; done
shasum -a 256 /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md 2>&1
```

### 3. Byte-compare each file

For each asset/reference/eval, run:

```bash
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html "$SIDECAR"/assets/template.html && echo "template.html: IDENTICAL" || echo "template.html: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs "$SIDECAR"/assets/build.mjs && echo "build.mjs: IDENTICAL" || echo "build.mjs: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs "$SIDECAR"/assets/data.example.mjs && echo "data.example.mjs: IDENTICAL" || echo "data.example.mjs: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md "$SIDECAR"/references/design-language.md && echo "design-language.md: IDENTICAL" || echo "design-language.md: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md "$SIDECAR"/references/process-and-lessons.md && echo "process-and-lessons.md: IDENTICAL" || echo "process-and-lessons.md: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json "$SIDECAR"/evals.json && echo "evals.json: IDENTICAL" || echo "evals.json: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md "$SIDECAR"/SKILL.md && echo "SKILL.md: IDENTICAL" || echo "SKILL.md: DIFFERS"
```

Then assess the command file. The command is derived, so build a *candidate* derived file in `/tmp` and compare that candidate to the existing command:

```bash
# Build candidate derived command to /tmp/system-atlas-candidate.md by wrapping upstream SKILL.md:
# - frontmatter is fixed (see §4), body is Asset resolution preamble + upstream SKILL.md body after its frontmatter
# Then:
cmp -s /tmp/system-atlas-candidate.md "$COMMAND_FILE" && echo "system-atlas.md (derived command): IDENTICAL" || echo "system-atlas.md (derived command): DIFFERS"
diff -u "$COMMAND_FILE" /tmp/system-atlas-candidate.md | head -n 120
```

Present a table:

| File | Status |
|------|--------|
| assets/template.html | IDENTICAL / DIFFERS |
| assets/build.mjs | ... |
| assets/data.example.mjs | ... |
| references/design-language.md | ... |
| references/process-and-lessons.md | ... |
| evals/evals.json | ... |
| SKILL.md (raw) | ... |
| `<name>.md` in the commands dir (derived) | ... |

If `--check-only` was passed, stop here after the table and clean up `/tmp/system-atlas-upstream` (and candidate). Do not write.

### 4. Update any file that is not bytes identical (default)

Only files marked DIFFERS are overwritten. Never touch files marked IDENTICAL unless `--force` is set.

**For assets/references/evals/SKILL.md** — direct byte copy into `$SIDECAR` (and `$REPO_PROTOCOL` when set):

```bash
mkdir -p "$SIDECAR"/assets "$SIDECAR"/references
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html "$SIDECAR"/assets/template.html
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs "$SIDECAR"/assets/build.mjs
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs "$SIDECAR"/assets/data.example.mjs
cp /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md "$SIDECAR"/references/design-language.md
cp /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md "$SIDECAR"/references/process-and-lessons.md
cp /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json "$SIDECAR"/evals.json
cp /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md "$SIDECAR"/SKILL.md
```

If `REPO_PROTOCOL` is set, copy the same bytes into that folder so the repo stays identical to the sidecar.

**For the command file** `$COMMAND_FILE` — regenerate from upstream SKILL.md, preserving the command contract. Do not copy raw SKILL.md over the command. The derived file must be exactly:

```
---
description: Build and maintain an explorable, progressively-disclosed isometric atlas of a system's architecture — an interactive page (hover to read, click to pin, go inside for steps, moving data packets you can inspect, chapters that reveal the system a few structures at a time) plus a generated text twin (SYSTEM.md) and question tracking by ID, all from one data file in the repo.
argument-hint: [atlas task — e.g. "map this pipeline" or "update the atlas"]
---

# System Atlas

Target: $ARGUMENTS. If empty, ask what system to map or what update to apply.

[Asset resolution section — verbatim from the current command file's Asset resolution block, or from protocols/system-atlas/command.md if the current file has no such section — then the full body of upstream SKILL.md starting after its frontmatter `---` block]
```

Implementation: `Read` the current `$COMMAND_FILE` to capture its exact frontmatter + Asset resolution preamble, then `Read` upstream `SKILL.md`, strip its frontmatter, splice them, and `Write` the candidate via the file tools (not `cp`). If the current command file is missing or corrupted, use `protocols/system-atlas/command.md` as the fallback. Keep the Asset resolution block agent-agnostic — never rewrite it to name one harness's home path.

After copying, re-run the `cmp -s` / `shasum` checks from §2-§3 to confirm every file is now IDENTICAL. If any still reports DIFFERS, surface the `diff` and do not claim success.

### 5. Clean up and report

```bash
rm -rf /tmp/system-atlas-upstream /tmp/system-atlas-candidate.md
ls -lh "$COMMAND_FILE" "$SIDECAR"/assets/* "$SIDECAR"/references/* "$SIDECAR"/SKILL.md "$SIDECAR"/evals.json
```

Final message must state:
- Which harness and paths were resolved in §0
- How many files were IDENTICAL vs updated
- For each updated file: `old sha256 → new sha256` (from the shasum snapshots)
- The exact `git rev-parse --short HEAD` or `git log --oneline -1` from the temp clone (capture before deleting, e.g. `git -C /tmp/system-atlas-upstream rev-parse --short HEAD`)
- That `/tmp/system-atlas-upstream` was removed

Never leave `/tmp/system-atlas-upstream` behind on success. On network/clone failure, report the error, leave local files untouched, and suggest retrying with `git ls-remote https://github.com/inkboard/system-atlas.git HEAD` to diagnose.

## Flags

- No flag: check and update drifted files.
- `--check-only`: only report the table, do not write.
- `--force`: overwrite all files even if IDENTICAL (still report before/after shasums).

## Safety

- This command only writes `$COMMAND_FILE`, `$SIDECAR`, and `$REPO_PROTOCOL` when set. It never touches other commands, and it never seeds `system-atlas` as a skill.
- Do not run `npx skills add` inside this command — that would seed as a skill, which the user explicitly rejected.
