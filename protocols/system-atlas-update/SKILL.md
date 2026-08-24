---
name: system-atlas-update
description: Check inkboard/system-atlas upstream and update the locally-seeded system-atlas command/assets if they are not byte-identical to the upstream. Trigger on: "update system-atlas", "check if system-atlas is up to date", "sync system-atlas from upstream", "are we on the latest atlas skill", "refresh the atlas command".
---

# System Atlas Update

Infer the intent from the conversation: the user wants to know if the locally-seeded `system-atlas` command is byte-identical to upstream `https://github.com/inkboard/system-atlas` and, unless they asked for a check-only audit, to update any drifted files. If the request is ambiguous (e.g. "update the atlas" could mean the system-atlas updater vs updating a specific project's atlas data), ask which is meant before fetching.

You are the updater for the globally-seeded `system-atlas` command. Upstream is `https://github.com/inkboard/system-atlas` (skill at `skills/system-atlas/`). Local seed is `~/.config/opencode/command/system-atlas.md` (command) + `~/.config/opencode/system-atlas/` (assets/references/evals). When seeded from this repo, the source of the seed is `protocols/system-atlas/` and `protocols/system-atlas-update/` — but the updater still checks the live upstream and writes to the harness's installed locations, not back into the repo. This skill is the only writer for those installed paths.

## What "bytes identical" means

Byte-for-byte equality as `cmp -s` / `sha256sum` reports, not semantic equivalence. Line endings, whitespace, and frontmatter all count. The command file is *derived* (upstream `SKILL.md` wrapped with opencode command frontmatter + Seeding preamble), so it is never byte-identical to raw `SKILL.md` — compare the derived form to the existing command, and compare raw `SKILL.md` separately as `~/.config/opencode/system-atlas/SKILL.md` if present.

## Procedure — run every time this skill is triggered

Do all steps in order, with observable shell output. Do not skip the temp clone even if the network feels slow. If the user said "check only" or "audit without updating", treat that as `--check-only`; if they said "force", treat as `--force`; otherwise default is to update drifted files.

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

If the user asked for check-only, stop here after the table and clean up `/tmp/system-atlas-upstream` (and candidate). Do not write.

### 4. Update any file that is not bytes identical (default)

Only files marked DIFFERS are overwritten. Never touch files marked IDENTICAL unless the user said force.

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

**For the command file** `~/.config/opencode/command/system-atlas.md` — regenerate from upstream SKILL.md, preserving the command contract. Do not copy raw SKILL.md over the command. The derived file must be exactly the command form (frontmatter with `description` + `argument-hint`, then `Target: $ARGUMENTS` header, Seeding block, then upstream body). Implementation: `Read` the current `~/.config/opencode/command/system-atlas.md` to capture its exact frontmatter + Seeding preamble, then `Read` upstream `SKILL.md`, strip its frontmatter, splice them, and `Write` the candidate. If the current command file is missing, use the frontmatter from `protocols/system-atlas/command.md` as fallback.

After copying, re-run the `cmp -s` / `shasum` checks from §2-§3 to confirm every file is now IDENTICAL. If any still reports DIFFERS, surface the `diff` and do not claim success. Also update `protocols/system-atlas/` in the repo if the installed files were intentionally seeded from there and you are maintaining the repo — copy the same upstream bytes into `protocols/system-atlas/assets/*`, `references/*`, `SKILL.md`, `evals.json` so the repo stays byte-identical to upstream (and to `~/.config/opencode/system-atlas/`).

### 5. Clean up and report

```bash
rm -rf /tmp/system-atlas-upstream /tmp/system-atlas-candidate.md
ls -lh ~/.config/opencode/command/system-atlas.md ~/.config/opencode/system-atlas/assets/* ~/.config/opencode/system-atlas/references/* ~/.config/opencode/system-atlas/SKILL.md ~/.config/opencode/system-atlas/evals.json
```

Final message must state:
- How many files were IDENTICAL vs updated
- For each updated file: `old sha256 → new sha256`
- The exact `git rev-parse --short HEAD` from the temp clone
- That `/tmp/system-atlas-upstream` was removed

Never leave `/tmp/system-atlas-upstream` behind on success. On network/clone failure, report the error, leave local files untouched, and suggest `git ls-remote https://github.com/inkboard/system-atlas.git HEAD`.

## Safety

- This skill only writes inside `~/.config/opencode/command/system-atlas.md` and `~/.config/opencode/system-atlas/` (and optionally `protocols/system-atlas/` in the repo when staying in sync). It never touches `~/.config/opencode/skill/`, other commands, or repo workdirs beyond `protocols/system-atlas/`.
- Do not run `npx skills add` — that would seed as a skill.
