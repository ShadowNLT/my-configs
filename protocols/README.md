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
Supporting assets live beside both so a folder installed anywhere stays whole.

When the user asks to install a protocol globally, pick the form that fits each
harness and install it:

- **Command** — the user will invoke it explicitly (`/name <input>`). Copy
  `command.md` into the harness's command directory.
- **Skill** — the agent should apply it on its own when a request matches.
  Copy the folder (or `SKILL.md` plus its assets) into the harness's skill
  directory.
- **Standing rule or convention** — neither form; it belongs in project
  instructions (`CLAUDE.md`, `AGENTS.md`, rules) rather than a command or skill.

Only install when the user asks.

## Global install locations

| Harness  | Commands                        | Skills                 |
| -------- | ------------------------------- | ---------------------- |
| Claude   | `~/.claude/commands/`           | `~/.claude/skills/`    |
| opencode | `~/.config/opencode/command/`   | `~/.config/opencode/skill/` |
| Codex    | `~/.codex/prompts/`             | `~/.codex/skills/`     |
| Cursor   | `~/.cursor/commands/`           | (no global skill dir)  |

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
  installed form is a wrapping concern, handled at install time.
- Update both forms when a procedure changes; they must not drift.