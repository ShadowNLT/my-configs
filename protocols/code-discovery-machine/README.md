# code-discovery-machine

Find the code-forced fact set for one concept and return one record. The procedure is the two process twins in this folder. `command.md` and `SKILL.md` only point at them.

This process does not teach and does not talk to the learner. code-concept-curriculum calls it. Installing this protocol copies only its own files and must not overwrite any other protocol's folder or installed `$CONFIG_DIR/` sidecar.

## Files

| File | Role |
|---|---|
| `command.md` | Command form. Installs to `$COMMANDS_DIR/code-discovery-machine.md`. |
| `SKILL.md` | Skill form. Install only when a skills dir was requested. |
| `code-discovery-machine.md` | Simplified Technical English process (source of truth prose). |
| `code-discovery-machine-algo-sketch.md` | Equivalent algo sketch. |
| `README.md` | This install note. Optional in the command sidecar. |

## Install

Ask the operator for `CONFIG_DIR` (harness config root), `COMMANDS_DIR` (flat slash-command directory), and `SKILLS_DIR` only if they also want the skill form. Echo the resolved paths and get confirmation before copying. Never assume a harness home path.

**Command** — copy the command file, and sidecar the two process twins (README optional):

```bash
cp protocols/code-discovery-machine/command.md "$COMMANDS_DIR/code-discovery-machine.md"
mkdir -p "$CONFIG_DIR/code-discovery-machine"
cp protocols/code-discovery-machine/code-discovery-machine.md \
  protocols/code-discovery-machine/code-discovery-machine-algo-sketch.md \
  "$CONFIG_DIR/code-discovery-machine/"
# optional:
# cp protocols/code-discovery-machine/README.md "$CONFIG_DIR/code-discovery-machine/"
```

**Skill** — only if they asked and gave `SKILLS_DIR`. Copy the whole folder so the twins sit beside `SKILL.md`:

```bash
mkdir -p "$SKILLS_DIR/code-discovery-machine"
cp -R protocols/code-discovery-machine/. "$SKILLS_DIR/code-discovery-machine/"
```

Do not install the skill unless they asked for auto-discovery.
