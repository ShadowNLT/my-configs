# Corporate — Agent-agnostic source of truth

This folder survives a machine reset. An agent seeds it to its own config dir; no symlink.

## What lives here
- `AGENT.md` — the durable, agent-agnostic source for global rules.
- `commands/` — 21 corporate slash commands (excludes `adversarial-review` which lives in `protocols/adversarial-review/` and is versioned separately). Each file is a template with variables.

## Variables (resolved at seed time)

Ask the user which harnesses to seed and **where each one lives** (`CONFIG_DIR`,
`COMMANDS_DIR`, and harness memory path if needed). Do not assume a product
maps to one directory. Then substitute:

- `{{VAULT_AGENT_DIR}}` -> `~/Documents/DigitalBrain/Agent`
- `{{AGENT_CONFIG_DIR}}` -> the `CONFIG_DIR` the user named for this harness
- `{{AGENT_COMMANDS_DIR}}` -> the `COMMANDS_DIR` the user named for this harness
- `{{AGENT_HARNESS_MEMORY}}` -> the harness memory path the user named (if any)
- `{{AGENT_SOURCE_FILE}}` -> the absolute path to this checkout's `corporate/AGENT.md`

Every seeded harness uses the same names: `AGENT.md`, `AGENT-review-log.md`, and `Agent/`.
Do not rename them for a product or make one harness's home directory authoritative for another.

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

Ask which harnesses and their `CONFIG_DIR` / `COMMANDS_DIR`. Echo the paths and
get confirmation, then:

```bash
src=corporate/commands
dst="$COMMANDS_DIR"
AGENT_SOURCE_FILE="$(pwd)/corporate/AGENT.md"
mkdir -p "$dst"
for f in "$src"/*.md; do
  sed "s|{{VAULT_AGENT_DIR}}|~/Documents/DigitalBrain/Agent|g; s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g; s|{{AGENT_HARNESS_MEMORY}}|$AGENT_HARNESS_MEMORY|g; s|{{AGENT_SOURCE_FILE}}|$AGENT_SOURCE_FILE|g" "$f" > "$dst/$(basename "$f")"
done
cp "$AGENT_SOURCE_FILE" "$CONFIG_DIR/AGENT.md"
mkdir -p "$CONFIG_DIR/concept-viz/template" "$CONFIG_DIR/layman-terms"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"
```

Repeat once per harness the user named. Do not keep a per-product copy of this
block with baked-in home paths. A harness that cannot load `AGENT.md` directly
needs an adapter outside this source tree; the adapter must point to the seeded
`AGENT.md` and must never become a second source of truth.
