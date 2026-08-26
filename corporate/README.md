# Corporate — Agent-agnostic source of truth

This folder survives a machine reset. An agent seeds it to its own config dir; no symlink.

## What lives here
- `AGENT.md` — global rules (was `~/.claude/CLAUDE.md` / `CLAUDE.md`). Agent-agnostic.
- `commands/` — 21 corporate slash commands (excludes `adversarial-review` which lives in `protocols/adversarial-review/` and is versioned separately). Each file is a template with variables.

## Variables (resolved at seed time)
- `{{VAULT_AGENT_DIR}}` -> `~/Documents/DigitalBrain/Agent`
- `{{AGENT_CONFIG_DIR}}` -> `~/.claude` (Claude Code), `~/.cursor` (Cursor), `~/.codex` (Codex), `~/.config/opencode` (opencode)
- `{{AGENT_COMMANDS_DIR}}` -> `{{AGENT_CONFIG_DIR}}/commands` (or `/command` for opencode)
- `{{AGENT_HARNESS_MEMORY}}` -> harness memory path (`~/.claude/projects/.../memory` etc)
- `AGENT.md` replaces `CLAUDE.md`, `AGENT-review-log.md` replaces `CLAUDE-review-log.md`, `Agent/` replaces `Claude/` in vault.

## Seed (agent copies, never symlinks)
Claude Code:
```bash
src=corporate/commands dst=~/.claude/commands
mkdir -p "$dst"
for f in "$src"/*.md; do sed "s|{{VAULT_AGENT_DIR}}|~/Documents/DigitalBrain/Agent|g; s|{{AGENT_COMMANDS_DIR}}|~/.claude/commands|g; s|{{AGENT_CONFIG_DIR}}|~/.claude|g; s|{{AGENT_HARNESS_MEMORY}}|~/.claude/projects/.../memory|g" "$f" > "$dst/$(basename "$f")"; done
cp corporate/AGENT.md ~/.claude/AGENT.md
# compat: keep CLAUDE.md as copy for old references (no shim needed long-term, but harmless now)
cp corporate/AGENT.md ~/.claude/CLAUDE.md
```

Cursor:
```bash
src=corporate/commands dst=~/.cursor/commands
mkdir -p "$dst"
for f in "$src"/*.md; do sed "s|{{VAULT_AGENT_DIR}}|~/Documents/DigitalBrain/Agent|g; s|{{AGENT_COMMANDS_DIR}}|~/.cursor/commands|g; s|{{AGENT_CONFIG_DIR}}|~/.cursor|g" "$f" > "$dst/$(basename "$f")"; done
```

opencode (only `command`, singular):
```bash
src=corporate/commands dst=~/.config/opencode/command
mkdir -p "$dst"
for f in "$src"/*.md; do sed "s|{{VAULT_AGENT_DIR}}|~/Documents/DigitalBrain/Agent|g; s|{{AGENT_COMMANDS_DIR}}|~/.config/opencode/command|g; s|{{AGENT_CONFIG_DIR}}|~/.config/opencode|g" "$f" > "$dst/$(basename "$f")"; done
```

Vault is already renamed: `~/Documents/DigitalBrain/Claude` -> `~/Documents/DigitalBrain/Agent` (no shim, all 65 vault notes patched).
