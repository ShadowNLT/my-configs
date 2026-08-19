# Protocols

Agent-agnostic procedures and workflows. Each `.md` file is a self-contained
protocol: a repeatable procedure the user wants any agent to be able to run,
on any machine, in any harness.

The file itself is plain markdown, not tied to any harness's format. When the
user asks to install a protocol globally, read the file and infer the most
appropriate artifact form for each harness:

- If it is a reusable prompt with arguments, it fits a slash command (`.md`
  with YAML frontmatter) in the harness's command directory.
- If it is a procedure with discovery cues and progressive instructions, it
  fits a skill (`SKILL.md` in a named folder).
- If it is a standing rule or convention, it fits project instructions
  (`CLAUDE.md`, `AGENTS.md`, rules, etc.) rather than a command.

Choose per harness; the same protocol may land as a command in one and a
skill in another. Only install when the user asks.

## Global install locations

| Harness  | Commands                        | Skills                 |
| -------- | ------------------------------- | ---------------------- |
| Claude   | `~/.claude/commands/`           | `~/.claude/skills/`    |
| opencode | `~/.config/opencode/command/`   | `~/.config/opencode/skill/` |
| Codex    | `~/.codex/prompts/`             | `~/.codex/skills/`     |
| Cursor   | `~/.cursor/commands/`           | (no global skill dir)  |

## Writing protocols

- One file per procedure, named after what it does (no spaces). A protocol
  that bundles supporting assets (a denylist, scripts, references) lives in a
  folder named after the protocol, e.g. `layman-terms/SKILL.md` +
  `layman-terms/denylist.md` — install the folder as a unit.
- Write the full procedure in plain markdown: when to use it, steps,
  constraints, examples.
- Use `$ARGUMENTS` / `$1..$9` where the protocol takes input; most harnesses
  expand these inside command templates.
- Keep the file consumable as-is by an agent reading it in-context. The
  installed form is a wrapping concern, handled at install time.