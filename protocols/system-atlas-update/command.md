---
description: Check inkboard/system-atlas upstream and update local system-atlas command/assets if not byte-identical
argument-hint: [--check-only | --force]
---

# System Atlas Update

Target: $ARGUMENTS (flags: `--check-only` reports without writing, `--force` overwrites even if bytes identical).

You are the updater for the globally-seeded `system-atlas` command. Upstream is `https://github.com/inkboard/system-atlas` (skill at `skills/system-atlas/`). Local seed is `~/.config/opencode/command/system-atlas.md` (command) + `~/.config/opencode/system-atlas/` (assets/references/evals). This command is the only writer for those paths.

## What "bytes identical" means

Byte-for-byte equality as `cmp -s` / `sha256sum` reports, not semantic equivalence. Line endings, whitespace, and frontmatter all count. The command file is *derived* (upstream `SKILL.md` wrapped with opencode command frontmatter + Seeding preamble), so it is never byte-identical to raw `SKILL.md` — compare the derived form to the existing command, and compare raw `SKILL.md` separately as `~/.config/opencode/system-atlas/SKILL.md` if present.

## Procedure — run every time this command is invoked

Do all steps in order, with observable shell output. Do not skip the temp clone even if the network feels slow.

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
ls -lh ~/.config/opencode/command/system-atlas.md ~/.config/opencode/system-atlas/assets/* ~/.config/opencode/system-atlas/references/* ~/.config/opencode/system-atlas/evals.json ~/.config/opencode/system-atlas/SKILL.md 2>&1
for f in ~/.config/opencode/system-atlas/assets/template.html ~/.config/opencode/system-atlas/assets/build.mjs ~/.config/opencode/system-atlas/assets/data.example.mjs ~/.config/opencode/system-atlas/references/design-language.md ~/.config/opencode/system-atlas/references/process-and-lessons.md ~/.config/opencode/system-atlas/evals.json; do echo "--- $f"; shasum -a 256 "$f" 2>&1 | head -n1; done
shasum -a 256 /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md 2>&1
```

### 3. Byte-compare each file

For each asset/reference/eval, run:

```bash
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html ~/.config/opencode/system-atlas/assets/template.html && echo "template.html: IDENTICAL" || echo "template.html: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs ~/.config/opencode/system-atlas/assets/build.mjs && echo "build.mjs: IDENTICAL" || echo "build.mjs: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs ~/.config/opencode/system-atlas/assets/data.example.mjs && echo "data.example.mjs: IDENTICAL" || echo "data.example.mjs: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md ~/.config/opencode/system-atlas/references/design-language.md && echo "design-language.md: IDENTICAL" || echo "design-language.md: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md ~/.config/opencode/system-atlas/references/process-and-lessons.md && echo "process-and-lessons.md: IDENTICAL" || echo "process-and-lessons.md: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json ~/.config/opencode/system-atlas/evals.json && echo "evals.json: IDENTICAL" || echo "evals.json: DIFFERS"
cmp -s /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md ~/.config/opencode/system-atlas/SKILL.md && echo "SKILL.md: IDENTICAL" || echo "SKILL.md: DIFFERS"
```

Then assess the command file. The command is derived, so build a *candidate* derived file in `/tmp` and compare that candidate to the existing command:

```bash
# Build candidate derived command to /tmp/system-atlas-candidate.md by wrapping upstream SKILL.md:
# - frontmatter is fixed (see §4), body is Seeding preamble + upstream SKILL.md body after its frontmatter
# Then:
cmp -s /tmp/system-atlas-candidate.md ~/.config/opencode/command/system-atlas.md && echo "system-atlas.md (derived command): IDENTICAL" || echo "system-atlas.md (derived command): DIFFERS"
diff -u ~/.config/opencode/command/system-atlas.md /tmp/system-atlas-candidate.md | head -n 120
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
| command/system-atlas.md (derived) | ... |

If `--check-only` was passed, stop here after the table and clean up `/tmp/system-atlas-upstream` (and candidate). Do not write.

### 4. Update any file that is not bytes identical (default)

Only files marked DIFFERS are overwritten. Never touch files marked IDENTICAL unless `--force` is set.

**For assets/references/evals/SKILL.md** — direct byte copy:

```bash
mkdir -p ~/.config/opencode/system-atlas/assets ~/.config/opencode/system-atlas/references
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/template.html ~/.config/opencode/system-atlas/assets/template.html
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/build.mjs ~/.config/opencode/system-atlas/assets/build.mjs
cp /tmp/system-atlas-upstream/skills/system-atlas/assets/data.example.mjs ~/.config/opencode/system-atlas/assets/data.example.mjs
cp /tmp/system-atlas-upstream/skills/system-atlas/references/design-language.md ~/.config/opencode/system-atlas/references/design-language.md
cp /tmp/system-atlas-upstream/skills/system-atlas/references/process-and-lessons.md ~/.config/opencode/system-atlas/references/process-and-lessons.md
cp /tmp/system-atlas-upstream/skills/system-atlas/evals/evals.json ~/.config/opencode/system-atlas/evals.json
cp /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md ~/.config/opencode/system-atlas/SKILL.md
```

**For the command file** `~/.config/opencode/command/system-atlas.md` — regenerate from upstream SKILL.md, preserving the command contract. Do not copy raw SKILL.md over the command. The derived file must be exactly:

```
---
description: Build and maintain an explorable, progressively-disclosed isometric atlas of a system's architecture — an interactive page (hover to read, click to pin, go inside for steps, moving data packets you can inspect, chapters that reveal the system a few structures at a time) plus a generated text twin (SYSTEM.md) and question tracking by ID, all from one data file in the repo.
argument-hint: [atlas task — e.g. "map this pipeline" or "update the atlas"]
---

# System Atlas

Target: $ARGUMENTS. If empty, ask what system to map or what update to apply.

[Seeding / asset resolution section — verbatim from the current command file's Seeding block, or the block below if the current file has no such section — then the full body of upstream SKILL.md starting after its frontmatter `---` block]

Seeding block to preserve (if regenerating):
  "This command was seeded from `inkboard/system-atlas` (`skills/system-atlas/SKILL.md` + `assets/` + `references/`). Installed as a **command** (not a skill) per user preference: ..."
  plus the Upstream source line and the Files table with `~/.config/opencode/system-atlas/...` paths.

Body: take /tmp/system-atlas-upstream/skills/system-atlas/SKILL.md, strip its leading `---` frontmatter block (first `---` through second `---`), and append the remainder verbatim after the Seeding block. Keep upstream headings, process steps, and file lists intact, but rewrite any `assets/` or `references/` path mentions to note they resolve to `~/.config/opencode/system-atlas/...` per Seeding.
```

Implementation note for the agent: the simplest correct way is to `Read` the current `~/.config/opencode/command/system-atlas.md` to capture its exact frontmatter + Seeding preamble, then `Read` upstream `SKILL.md`, strip its frontmatter, splice them, and `Write` the candidate to `~/.config/opencode/command/system-atlas.md` via the file tools (not `cp`). If the current command file is missing or corrupted, use the template above as the fallback frontmatter + Seeding block.

After copying, re-run the `cmp -s` / `shasum` checks from §2-§3 to confirm every file is now IDENTICAL. If any still reports DIFFERS, surface the `diff` and do not claim success.

### 5. Clean up and report

```bash
rm -rf /tmp/system-atlas-upstream /tmp/system-atlas-candidate.md
ls -lh ~/.config/opencode/command/system-atlas.md ~/.config/opencode/system-atlas/assets/* ~/.config/opencode/system-atlas/references/* ~/.config/opencode/system-atlas/SKILL.md ~/.config/opencode/system-atlas/evals.json
```

Final message must state:
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

- This command only writes inside `~/.config/opencode/command/system-atlas.md` and `~/.config/opencode/system-atlas/`. It never touches `~/.config/opencode/skill/`, repo workdirs, or any other command file.
- Do not run `npx skills add` inside this command — that would seed as a skill, which the user explicitly rejected.
