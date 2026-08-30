# Corporate — Agent-agnostic source of truth

This folder survives a machine reset. An agent seeds it to its own config dir; no symlink.

## What lives here
- `AGENT.md` — global rules (was `CLAUDE.md` in some harnesses). Agent-agnostic.
- `commands/` — 21 corporate slash commands (excludes `adversarial-review` which lives in `protocols/adversarial-review/` and is versioned separately). Each file is a template with variables.

## Variables (resolved at seed time)

Ask the user which harnesses to seed and **where each one lives** (`CONFIG_DIR`,
`COMMANDS_DIR`, and harness memory path if needed). Do not assume a product
maps to one directory. Then substitute:

- `{{VAULT_AGENT_DIR}}` -> `~/Documents/DigitalBrain/Agent`
- `{{AGENT_CONFIG_DIR}}` -> the `CONFIG_DIR` the user named for this harness
- `{{AGENT_COMMANDS_DIR}}` -> the `COMMANDS_DIR` the user named for this harness
- `{{AGENT_HARNESS_MEMORY}}` -> the harness memory path the user named (if any)
- `AGENT.md` replaces `CLAUDE.md`, `AGENT-review-log.md` replaces `CLAUDE-review-log.md`, `Agent/` replaces `Claude/` in vault.

## Sidecars

`concept-viz` and `layman-terms` are not self-contained `.md` files. After
copying commands, copy their supporting files from `protocols/` into
`$CONFIG_DIR/<name>/` (see `protocols/README.md`). Do not skip this; a command
directory cannot hold those files.

```bash
mkdir -p "$CONFIG_DIR/concept-viz/template" "$CONFIG_DIR/layman-terms"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"
```

`write-tests` is not in this folder; seed it from `protocols/` when the user wants it.

`system-atlas` is not in this folder. When the user wants it, seed it from
`protocols/` **together with** `system-atlas-update` (never one without the other).
See `protocols/README.md`.

## Seed (agent copies, never symlinks)

Ask which harnesses and their `CONFIG_DIR` / `COMMANDS_DIR` (and whether
`AGENT.md` should also be copied as `CLAUDE.md` for that harness). Echo the
paths and get confirmation, then:

```bash
src=corporate/commands
dst="$COMMANDS_DIR"
mkdir -p "$dst"
for f in "$src"/*.md; do
  sed "s|{{VAULT_AGENT_DIR}}|~/Documents/DigitalBrain/Agent|g; s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g; s|{{AGENT_HARNESS_MEMORY}}|$AGENT_HARNESS_MEMORY|g" "$f" > "$dst/$(basename "$f")"
done
cp corporate/AGENT.md "$CONFIG_DIR/AGENT.md"
# if this harness still reads CLAUDE.md, also:
# cp corporate/AGENT.md "$CONFIG_DIR/CLAUDE.md"
mkdir -p "$CONFIG_DIR/concept-viz/template" "$CONFIG_DIR/layman-terms"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"
```

Repeat once per harness the user named. Do not keep a per-product copy of this
block with baked-in home paths.

Vault is already renamed: `~/Documents/DigitalBrain/Claude` -> `~/Documents/DigitalBrain/Agent` (no shim, all 65 vault notes patched).
