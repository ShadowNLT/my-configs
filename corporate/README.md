# Corporate — durable agent seed

This folder survives a machine reset. An agent seeds it to a harness config dir; no symlink.

Work profile only. The personal profile lives in `personal/`; never seed it from here.

## What lives here

- `corporate-agent.md` — work-profile global rules. Seeded to a harness as `$CONFIG_DIR/AGENT.md`.
- `commands/` — 21 work slash commands (excludes `adversarial-review`, which lives in `protocols/adversarial-review/` and is versioned separately). Each file is a template with variables.

## Variables (resolved at seed time)

Ask the user which harnesses to seed as work harnesses and **where each one
lives** (`CONFIG_DIR`, `COMMANDS_DIR`, knowledge vault root, and harness memory
path if needed). Do not assume a product maps to one directory. Then substitute:

- `{{KNOWLEDGE_VAULT_ROOT}}` -> the knowledge/work vault root the user named (corporate work data: sessions, curricula, Concepts/, Learning/, etc.)
- `{{VAULT_AGENT_DIR}}` -> `$KNOWLEDGE_VAULT_ROOT/Agent`
- `{{TEACHING_STANDARD_PATH}}` -> `$CONFIG_DIR/teaching-standard/Teaching-Standard.md`
- `{{AGENT_CONFIG_DIR}}` -> the `CONFIG_DIR` the user named for this harness
- `{{AGENT_COMMANDS_DIR}}` -> the `COMMANDS_DIR` the user named for this harness
- `{{AGENT_HARNESS_MEMORY}}` -> the harness memory path the user named (if any)
- `{{AGENT_SOURCE_FILE}}` -> the absolute path to this checkout's `corporate/corporate-agent.md`

Every seeded harness uses the same live names: `AGENT.md`, `AGENT-review-log.md`, and `Agent/`.
Do not rename them for a product or make one harness's home directory authoritative for another.

## Sidecars

After copying commands, copy protocol sidecars from `protocols/` into
`$CONFIG_DIR/<name>/` (see `protocols/README.md`). Do not skip this; a command
directory cannot hold those files.

Required for corporate work harnesses:

- `teaching-standard/Teaching-Standard.md` — canonical teaching doctrine (harness-local, **not** inside the knowledge vault). Substitute `{{AGENT_COMMANDS_DIR}}` at seed time.
- `concept-viz/template/`
- `layman-terms/denylist.txt`

```bash
mkdir -p "$CONFIG_DIR/teaching-standard" "$CONFIG_DIR/concept-viz/template" "$CONFIG_DIR/layman-terms"
sed "s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g" \
  protocols/teaching-standard/Teaching-Standard.md \
  > "$CONFIG_DIR/teaching-standard/Teaching-Standard.md"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"
```

`write-tests` is not in this folder; seed it from `protocols/` when the user wants it.

`system-atlas` is not in this folder. When the user wants it, seed it from
`protocols/` **together with** `system-atlas-update` (never one without the other).
See `protocols/README.md`.

`lieflat-charts` is not in this folder. When the user wants it, seed it from
`protocols/` **together with** `lieflat-charts-update` (never one without the other).
See `protocols/README.md`.

A personal harness never gets this folder's `commands/` dump or
`corporate-agent.md`. Seed it from `personal/` and `protocols/` instead.

## Seed (agent copies, never symlinks)

Ask which harnesses and their `CONFIG_DIR`, `COMMANDS_DIR`, and
`KNOWLEDGE_VAULT_ROOT`. Echo the paths and get confirmation, then:

```bash
src=corporate/commands
dst="$COMMANDS_DIR"
CONFIG_DIR="$CONFIG_DIR"   # harness config root — user-named
KNOWLEDGE_VAULT_ROOT="$KNOWLEDGE_VAULT_ROOT"   # user-named
TEACHING_STANDARD_PATH="$CONFIG_DIR/teaching-standard/Teaching-Standard.md"
AGENT_SOURCE_FILE="$(pwd)/corporate/corporate-agent.md"
mkdir -p "$dst"
for f in "$src"/*.md; do
  sed \
    "s|{{KNOWLEDGE_VAULT_ROOT}}|$KNOWLEDGE_VAULT_ROOT|g; \
     s|{{VAULT_AGENT_DIR}}|$KNOWLEDGE_VAULT_ROOT/Agent|g; \
     s|{{TEACHING_STANDARD_PATH}}|$TEACHING_STANDARD_PATH|g; \
     s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; \
     s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g; \
     s|{{AGENT_HARNESS_MEMORY}}|$AGENT_HARNESS_MEMORY|g; \
     s|{{AGENT_SOURCE_FILE}}|$AGENT_SOURCE_FILE|g" \
    "$f" > "$dst/$(basename "$f")"
done
sed \
  "s|{{KNOWLEDGE_VAULT_ROOT}}|$KNOWLEDGE_VAULT_ROOT|g; \
   s|{{VAULT_AGENT_DIR}}|$KNOWLEDGE_VAULT_ROOT/Agent|g; \
   s|{{TEACHING_STANDARD_PATH}}|$TEACHING_STANDARD_PATH|g; \
   s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; \
   s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g" \
  "$AGENT_SOURCE_FILE" > "$CONFIG_DIR/AGENT.md"
mkdir -p "$CONFIG_DIR/teaching-standard" "$CONFIG_DIR/concept-viz/template" "$CONFIG_DIR/layman-terms"
sed "s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g" \
  protocols/teaching-standard/Teaching-Standard.md \
  > "$CONFIG_DIR/teaching-standard/Teaching-Standard.md"
cp protocols/concept-viz/template/player.html "$CONFIG_DIR/concept-viz/template/"
cp protocols/layman-terms/denylist.txt "$CONFIG_DIR/layman-terms/"
```

Repeat once per work harness the user named. Do not keep a per-product copy of
this block with baked-in home paths. A harness that cannot load `AGENT.md` directly
needs an adapter outside this source tree; the adapter must point to the seeded
`AGENT.md` and must never become a second source of truth.

## Vault seed (living meta docs only)

Operational vault meta docs (session schema, Agent/README, Engine corners, etc.) live in the
knowledge vault, not in the harness. Source copies with **vault-relative language** (no
`{{AGENT_*}}` placeholders) live in `corporate/vault-seed/`. See
`corporate/vault-seed/00-SEED-MANIFEST.md` for scope, exclusions, and the full file list.

**Policy:** copy-if-missing only — the live vault wins once it exists. Never bulk-overwrite
session notes, review logs, or design records.

After harness seed, run the vault seed pass (same `KNOWLEDGE_VAULT_ROOT`):

```bash
src="$(pwd)/corporate/vault-seed"
dst="$KNOWLEDGE_VAULT_ROOT"   # user-named

while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"
  target="$dst/$rel"
  if [ -f "$target" ]; then
    echo "skip (exists): $rel"
  else
    mkdir -p "$(dirname "$target")"
    cp "$f" "$target"
    echo "seeded: $rel"
  fi
done < <(find "$src" -type f ! -name '00-SEED-MANIFEST.md' -print0)
```

To refresh one meta doc the user explicitly wants updated, copy that file directly — see the
manifest for examples.
