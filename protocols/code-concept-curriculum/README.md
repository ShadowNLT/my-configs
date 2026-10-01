# code-concept-curriculum

Teach one code concept as a knowledge-graph curriculum. The procedure is the two process twins in this folder. `command.md` and `SKILL.md` only point at them.

Teaching Standard is **off** this process's default path. Do not run Teaching Standard §Procedure as this process. Installing this protocol must not overwrite `protocols/teaching-standard/` or an installed `$CONFIG_DIR/teaching-standard/` sidecar.

## Files

| File | Role |
|---|---|
| `command.md` | Command form. Installs to `$COMMANDS_DIR/code-concept-curriculum.md`. |
| `SKILL.md` | Skill form. Install only when a skills dir was requested. |
| `code-concept-curriculum.md` | Simplified Technical English process (source of truth prose). |
| `code-concept-curriculum-algo-sketch.md` | Equivalent algo sketch. |
| `README.md` | This install note. Optional in the command sidecar. |

## Install

Ask the user for `CONFIG_DIR` (harness config root), `COMMANDS_DIR` (flat slash-command directory), and `SKILLS_DIR` only if they also want the skill form. Echo the resolved paths and get confirmation before copying. Never assume a harness home path.

**Command** — copy the command file, and sidecar the two process twins (README optional):

```bash
cp protocols/code-concept-curriculum/command.md "$COMMANDS_DIR/code-concept-curriculum.md"
mkdir -p "$CONFIG_DIR/code-concept-curriculum"
cp protocols/code-concept-curriculum/code-concept-curriculum.md \
  protocols/code-concept-curriculum/code-concept-curriculum-algo-sketch.md \
  "$CONFIG_DIR/code-concept-curriculum/"
# optional:
# cp protocols/code-concept-curriculum/README.md "$CONFIG_DIR/code-concept-curriculum/"
```

**Skill** — only if they asked and gave `SKILLS_DIR`. Copy the whole folder so the twins sit beside `SKILL.md`:

```bash
mkdir -p "$SKILLS_DIR/code-concept-curriculum"
cp -R protocols/code-concept-curriculum/. "$SKILLS_DIR/code-concept-curriculum/"
```

Do not install the skill unless they asked for auto-discovery.
