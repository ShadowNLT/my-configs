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

When the user asks to install a protocol globally, **ask where each harness
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

Only install when the user asks. Echo the resolved `CONFIG_DIR` /
`COMMANDS_DIR` (and `SKILLS_DIR` if any) and get confirmation before writing.

## Sidecar layout

Sidecar for command-form supporting files: `$CONFIG_DIR/<name>/`.

At run time, resolve supporting files in this order:

1. The protocol folder that already contains them (this repo's
   `protocols/<name>/`, or a skill install under `$SKILLS_DIR/<name>/`).
2. Otherwise this is a command file in a flat commands dir — use the sidecar
   `$CONFIG_DIR/<name>/` (parent of `$COMMANDS_DIR` when `COMMANDS_DIR` is a
   direct child of the config root; if the user gave a layout that is not
   that, trust the `CONFIG_DIR` they named).

## Protocols that need a sidecar

These four are not self-contained markdown. Command install is the `.md` **plus**
the sidecar. Do not also install the skill unless the user asked for auto-discovery.

| Protocol | Copy into `$CONFIG_DIR/<name>/` |
| -------- | -------------------------------- |
| `system-atlas` | `assets/`, `references/`, `evals.json`, `SKILL.md` (raw upstream copy for the updater) |
| `concept-viz` | `template/` |
| `layman-terms` | `denylist.txt` |
| `write-tests` | `references.md` |
| `teaching-standard` | `Teaching-Standard.md` (harness-local; **not** a knowledge vault path — see that folder's README) |

`system-atlas` and `system-atlas-update` are a pair. Whenever you install
`system-atlas`, also copy `protocols/system-atlas-update/command.md` to
`$COMMANDS_DIR/system-atlas-update.md`. Never seed one without the other.
`system-atlas-update` is markdown-only (it writes the `system-atlas` sidecar;
it has none of its own).

Every other protocol in this folder is markdown-only: copy `command.md` and stop.

Command-form install after the user has named `$COMMANDS_DIR` and `$CONFIG_DIR`:

```bash
# system-atlas + system-atlas-update (always together)
cp protocols/system-atlas/command.md "$COMMANDS_DIR/system-atlas.md"
mkdir -p "$CONFIG_DIR/system-atlas/assets" "$CONFIG_DIR/system-atlas/references"
cp protocols/system-atlas/assets/* "$CONFIG_DIR/system-atlas/assets/"
cp protocols/system-atlas/references/* "$CONFIG_DIR/system-atlas/references/"
cp protocols/system-atlas/evals.json protocols/system-atlas/SKILL.md "$CONFIG_DIR/system-atlas/"
cp protocols/system-atlas-update/command.md "$COMMANDS_DIR/system-atlas-update.md"

# concept-viz
cp protocols/concept-viz/command.md "$COMMANDS_DIR/concept-viz.md"
mkdir -p "$CONFIG_DIR/concept-viz/template"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"

# layman-terms
cp protocols/layman-terms/command.md "$COMMANDS_DIR/layman-terms.md"
mkdir -p "$CONFIG_DIR/layman-terms"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"

# write-tests
cp protocols/write-tests/command.md "$COMMANDS_DIR/write-tests.md"
mkdir -p "$CONFIG_DIR/write-tests"
cp protocols/write-tests/references.md "$CONFIG_DIR/write-tests/"

# teaching-standard (every harness that teaches — corporate or personal)
mkdir -p "$CONFIG_DIR/teaching-standard"
cp protocols/teaching-standard/Teaching-Standard.md "$CONFIG_DIR/teaching-standard/"
```

If `concept-viz` or `layman-terms` were already seeded from `corporate/commands/`
(those copies carry `{{AGENT_*}}` variables), keep that command file and only
copy the sidecar files from `protocols/` as above. Do not overwrite the corporate
command with the protocol `command.md` unless you intend to drop the variables.

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
  installed form is a wrapping concern: ask the user for `$CONFIG_DIR` and
  `$COMMANDS_DIR`, then copy. Never bake a harness home path into the procedure.
- Update both forms when a procedure changes; they must not drift.