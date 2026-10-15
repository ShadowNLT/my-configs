# Protocols

Agent-agnostic procedures and workflows. Each protocol is a folder named after
what it does, shipping **both** artifact forms so any harness can install
whichever fits:

```
protocols/<name>/
  command.md   command form: YAML frontmatter (description, argument-hint) + a body that takes
               $ARGUMENTS / $1..$9. Installed into the harness's command directory.
  SKILL.md     skill form: name + description with discovery/trigger cues + a self-contained
               procedure that infers its target from context instead of parsing arguments.
               Installed into the harness's skill directory.
  <assets>     supporting files (a denylist, scripts, templates) that both forms reference.
```

The two forms share one procedure written once and adapted per form: the command
form parses arguments, the skill form infers its target from the conversation.
Supporting files live in the protocol folder. Protocol bodies never hardcode a
harness home path. They resolve assets from this folder, or from the sidecar
rule below after a command install.

## Terminology

**Operator** is the person running the agent (confirms tabs, answers escalations, freezes specs).

**App user** is an account inside the software under test; add its role where known, e.g. 'app user (admin)'.

In `app-breaker --user`, the operator logs in with the app user's test account, or gives the details so the agent can log in.

`system-atlas` is the sole exception to this terminology rule because it is copied from `inkboard/system-atlas`.

When the operator asks to install a protocol globally, **ask where each harness
lives before copying anything.** Do not assume a product name maps to one
directory (work vs personal Cursor, a renamed config dir, etc.). For every
harness they want seeded, get:

- `CONFIG_DIR` — the harness config root
- `COMMANDS_DIR` — where slash-command `.md` files go (a flat directory)
- `SKILLS_DIR` — only if they also want the skill form; omit if unused

Then install:

- **Command** — copy `command.md` to `$COMMANDS_DIR/<name>.md`. Command
  directories are a flat dump of markdown, so supporting files cannot sit
  beside the command. If the protocol folder contains anything besides
  `command.md` and `SKILL.md`, also copy those supporting files to the
  **sidecar**: `$CONFIG_DIR/<name>/`, same relative layout as in
  `protocols/<name>/`.
- **Skill** — if they asked for auto-discovery and gave a `SKILLS_DIR`, copy
  the folder (or `SKILL.md` plus supporting files) to `$SKILLS_DIR/<name>/`.
  Assets then sit beside `SKILL.md`. If they did not give a skills dir, use
  command form plus sidecar only.
- **Standing rule or convention** — neither form; it belongs in project
  instructions (`AGENT.md`, `AGENTS.md`, rules) rather than a command or skill.

Only install when the operator asks. Echo the resolved `CONFIG_DIR` /
`COMMANDS_DIR` (and `SKILLS_DIR` if any) and get confirmation before writing.

## Sidecar layout

Sidecar for command-form supporting files: `$CONFIG_DIR/<name>/`.

At run time, resolve supporting files in this order:

1. The protocol folder that already contains them (this repo's
   `protocols/<name>/`, or a skill install under `$SKILLS_DIR/<name>/`).
2. Otherwise this is a command file in a flat commands dir — use the sidecar
   `$CONFIG_DIR/<name>/` (parent of `$COMMANDS_DIR` when `COMMANDS_DIR` is a
   direct child of the config root; if the operator gave a layout that is not
   that, trust the `CONFIG_DIR` they named).

## Protocols that need a sidecar

These are not self-contained markdown. Command install is the `.md` **plus**
the sidecar. Do not also install the skill unless the operator asked for auto-discovery.

| Protocol | Copy into `$CONFIG_DIR/<name>/` |
| -------- | -------------------------------- |
| `system-atlas` | `assets/`, `references/`, `evals.json`, `SKILL.md` (raw upstream copy for the updater) |
| `lieflat-charts` | `catalog.md`, `report-catalog.md`, `color-presets.js`, `mono-tokens.js`, `LICENSE`, `THIRD_PARTY_NOTICES.md`, `templates/`, `examples/`, `scripts/`, `SKILL.md` (skill form), `SKILL.upstream.md` (raw upstream `SKILL.md` for the updater). Do not copy `docs/`. |
| `concept-viz` | `catalog.py`, `gate.py`, `render.py`, `retrieval.py`, `runstore.py`, `LICENSE`, `catalog/`, `eval/`, `schemas/`, `scripts/`, `seeds/`, `skeletons/`, `examples/`, `docs/concept-viz-hardened.md`, `docs/concept-viz-serve-stop.md`, `docs/coverage-scorecard.md`, `SKILL.md` (skill form), `SKILL.upstream.md` (raw upstream `SKILL.md` for the updater). Do not copy repo-root `README.md`, `.gitignore`, `decisions.tsv`, `tests/`, repo-root `evals/`, or the rest of `docs/`. |
| `layman-terms` | `denylist.txt` |
| `write-tests` | `references.md` |
| `proof-duel` | `lens-catalog.md`, `lens-cast.md`, `cast-lenses.sh` |
| `code-concept-curriculum` | `code-concept-curriculum.md`, `code-concept-curriculum-algo-sketch.md` (README optional) |
| `code-discovery-machine` | `code-discovery-machine.md`, `code-discovery-machine-algo-sketch.md` (README optional). Install this whenever you install `code-concept-curriculum` (CCC calls it for discovery), the same way the term check needs `layman-terms`. |

`system-atlas` and `system-atlas-update` are a pair. Whenever you install
`system-atlas`, also copy `protocols/system-atlas-update/command.md` to
`$COMMANDS_DIR/system-atlas-update.md`. Never seed one without the other.
`system-atlas-update` is markdown-only (it writes the `system-atlas` sidecar;
it has none of its own).

`lieflat-charts` and `lieflat-charts-update` are a pair the same way.
Whenever you install `lieflat-charts`, also copy
`protocols/lieflat-charts-update/command.md` to
`$COMMANDS_DIR/lieflat-charts-update.md`. Never seed one without the other.
`lieflat-charts-update` is markdown-only (it writes the `lieflat-charts` sidecar;
it has none of its own).

`concept-viz` and `concept-viz-update` are a pair the same way.
Whenever you install `concept-viz`, also copy
`protocols/concept-viz-update/command.md` to
`$COMMANDS_DIR/concept-viz-update.md`. Never seed one without the other.
`concept-viz-update` is markdown-only (it writes the `concept-viz` sidecar;
it has none of its own).

Every other protocol in this folder is markdown-only: copy `command.md` and stop
(and copy `SKILL.md` only if a skills dir was requested). That includes
`algo-sketch`, `simplified-english`, `step-by-step`, `adversarial-review`, `app-breaker`,
`agent-browser-testing`,
`verifier`,
`ship-goal` (needs a harness that can run background agents),
`freeze-task-ship` (called only by `ship-goal`, not a standalone command),
`review-goal` (the operator can run it directly, and other protocols can call it),
`code-pi`, `converge`, `delegate`, `ponytail`, and similar markdown-only protocols.
`proof-duel`, `code-concept-curriculum`, and `code-discovery-machine` are **not** markdown-only — use the sidecar install block below. `code-concept-curriculum` depends on `code-discovery-machine`. Install both, the same way the term check needs `layman-terms`.

Command-form install after the operator has named `$COMMANDS_DIR` and `$CONFIG_DIR`:

```bash
# system-atlas + system-atlas-update (always together)
cp protocols/system-atlas/command.md "$COMMANDS_DIR/system-atlas.md"
mkdir -p "$CONFIG_DIR/system-atlas/assets" "$CONFIG_DIR/system-atlas/references"
cp protocols/system-atlas/assets/* "$CONFIG_DIR/system-atlas/assets/"
cp protocols/system-atlas/references/* "$CONFIG_DIR/system-atlas/references/"
cp protocols/system-atlas/evals.json protocols/system-atlas/SKILL.md "$CONFIG_DIR/system-atlas/"
cp protocols/system-atlas-update/command.md "$COMMANDS_DIR/system-atlas-update.md"

# lieflat-charts + lieflat-charts-update (always together)
cp protocols/lieflat-charts/command.md "$COMMANDS_DIR/lieflat-charts.md"
mkdir -p "$CONFIG_DIR/lieflat-charts"
rsync -a --delete \
  --exclude command.md \
  protocols/lieflat-charts/ "$CONFIG_DIR/lieflat-charts/"
cp protocols/lieflat-charts-update/command.md "$COMMANDS_DIR/lieflat-charts-update.md"

# concept-viz + concept-viz-update (always together)
cp protocols/concept-viz/command.md "$COMMANDS_DIR/concept-viz.md"
mkdir -p "$CONFIG_DIR/concept-viz"
rsync -a --delete \
  --exclude command.md \
  protocols/concept-viz/ "$CONFIG_DIR/concept-viz/"
cp protocols/concept-viz-update/command.md "$COMMANDS_DIR/concept-viz-update.md"

# layman-terms
cp protocols/layman-terms/command.md "$COMMANDS_DIR/layman-terms.md"
mkdir -p "$CONFIG_DIR/layman-terms"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"

# write-tests
cp protocols/write-tests/command.md "$COMMANDS_DIR/write-tests.md"
mkdir -p "$CONFIG_DIR/write-tests"
cp protocols/write-tests/references.md "$CONFIG_DIR/write-tests/"

# proof-duel (lenses + cast script)
cp protocols/proof-duel/command.md "$COMMANDS_DIR/proof-duel.md"
mkdir -p "$CONFIG_DIR/proof-duel"
cp protocols/proof-duel/lens-catalog.md protocols/proof-duel/lens-cast.md \
  protocols/proof-duel/cast-lenses.sh "$CONFIG_DIR/proof-duel/"
chmod +x "$CONFIG_DIR/proof-duel/cast-lenses.sh"

# code-concept-curriculum (process twins)
# Also install code-discovery-machine. CCC calls it for discovery.
cp protocols/code-concept-curriculum/command.md "$COMMANDS_DIR/code-concept-curriculum.md"
mkdir -p "$CONFIG_DIR/code-concept-curriculum"
cp protocols/code-concept-curriculum/code-concept-curriculum.md \
  protocols/code-concept-curriculum/code-concept-curriculum-algo-sketch.md \
  "$CONFIG_DIR/code-concept-curriculum/"

# code-discovery-machine (sidecar; CCC depends on it, like layman-terms)
cp protocols/code-discovery-machine/command.md "$COMMANDS_DIR/code-discovery-machine.md"
mkdir -p "$CONFIG_DIR/code-discovery-machine"
cp protocols/code-discovery-machine/code-discovery-machine.md \
  protocols/code-discovery-machine/code-discovery-machine-algo-sketch.md \
  "$CONFIG_DIR/code-discovery-machine/"
```

If `$COMMANDS_DIR/layman-terms.md` already exists and differs from
`protocols/layman-terms/command.md`, ask the operator before overwriting it.
Always copy the sidecar files from `protocols/` as above.

## Vault commands

Vault commands run against a seeded knowledge vault. Install asks for the path
of a seeded vault, plus `CONFIG_DIR` and `COMMANDS_DIR`. If `.seed-state` in
that vault does not say done, install stops with one reason line and writes
nothing. If it does, install fills `{{KNOWLEDGE_VAULT_ROOT}}` only in the
copy installed for that harness. The copies in this repo keep the
placeholders. Every vault command ships the same `seed_state.py`, byte for
byte. For memory-map, install creates a virtual environment at
`${XDG_DATA_HOME:-$HOME/.local/share}/memory-map/venv`, outside the repo,
installs the pinned requirements there, and fills `{{MEMORY_MAP_PYTHON}}`
with that environment's Python. The installed memory-map runs
`memory_map.py` with that Python. On macOS, memory-map's `hnswlib==0.8.0`
builds from source and needs the Xcode command-line tools
(`xcode-select --install`).
This block is separate from the markdown-only list and the sidecar block above.

| Protocol | Line |
| -------- | ---- |
| `memory-map` | `install.sh` creates that virtual environment, installs the pinned requirements into it, and downloads the model and the English and German OCR files once, to local folders outside the repo. |
| `vault-research` | `install.sh` runs the seed check and fills `{{KNOWLEDGE_VAULT_ROOT}}`. Standard library only: no virtual environment, no downloads. |
| `start-task` | `install.sh` runs the seed check and fills `{{KNOWLEDGE_VAULT_ROOT}}`. Opens a Ship, runs `vault-research`, hands the Ship to `ship-goal` or `review-goal`. |
| `pause-task` | Same install. Pauses this agent's Ship and writes the Handoff. |
| `resume-task` | Same install. Lists in-progress and paused Ships, resumes the in-progress or paused one picked, reruns `vault-research`, continues the driver. |
| `end-task` | Same install. Completes this agent's Ship. |

```bash
# Ask the operator for the seeded vault path, CONFIG_DIR, and COMMANDS_DIR.
# Stop with one reason line unless `.seed-state` says done.
# memory-map: Fill {{KNOWLEDGE_VAULT_ROOT}} and {{MEMORY_MAP_PYTHON}} only in the installed copy.
# memory-map: The virtual environment is ${XDG_DATA_HOME:-$HOME/.local/share}/memory-map/venv.
# memory-map: On macOS, hnswlib==0.8.0 builds from source and needs the Xcode command-line tools (xcode-select --install).
protocols/memory-map/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
protocols/vault-research/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
protocols/start-task/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
protocols/pause-task/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
protocols/resume-task/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
protocols/end-task/install.sh "$KNOWLEDGE_VAULT_ROOT" "$CONFIG_DIR" "$COMMANDS_DIR"
```

Every protocol that works on the vault is seeded per harness with a seeded
vault path. If that path is not a seeded vault, seeding that protocol fails
for that harness.

## Writing protocols

- One folder per procedure, named after what it does (no spaces), containing
  both `command.md` and `SKILL.md`.
- `command.md`: frontmatter with `description` (what the command does) and
  `argument-hint` (the expected input), then the procedure written to read
  `$ARGUMENTS` where the target goes.
- `SKILL.md`: frontmatter with `name` and a `description` that leads with what
  the skill does and ends with `Trigger on: ...` cues, then the same procedure
  written to infer its target from context.
- Keep the file consumable as-is by an agent reading it in-context. The
  installed form is a wrapping concern: ask the operator for `$CONFIG_DIR` and
  `$COMMANDS_DIR`, then copy. Never bake a harness home path into the procedure.
- Update both forms when a procedure changes; they must not drift.