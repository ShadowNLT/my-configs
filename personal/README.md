# Personal — durable agent seed

Personal-profile counterpart to `corporate/`. Nothing work-related belongs here.

## What lives here

- `AGENT.md` — personal-profile global rules. The durable source; a harness gets a copy.

Commands for a personal harness come from `protocols/`, not from `corporate/commands/`.

## Seed (agent copies, never symlinks)

The live name in every harness is `$CONFIG_DIR/AGENT.md`. Ask for `CONFIG_DIR` and
`COMMANDS_DIR`, echo them, get confirmation, then:

```bash
TEACHING_STANDARD_PATH="$CONFIG_DIR/teaching-standard/Teaching-Standard.md"
sed "s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g; s|{{TEACHING_STANDARD_PATH}}|$TEACHING_STANDARD_PATH|g" personal/AGENT.md > "$CONFIG_DIR/AGENT.md"
mkdir -p "$CONFIG_DIR/teaching-standard"
cp protocols/teaching-standard/Teaching-Standard.md "$CONFIG_DIR/teaching-standard/"
```

Do not also write a `CLAUDE.md` or any other alias. If one already exists in that
config dir, delete it so it cannot become a second source of truth.

Install protocols the user wants on this profile per `protocols/README.md`
(command form plus sidecar). **Always install `teaching-standard`** when seeding
protocols that teach (`explain-first-principles`, `layman-terms`, etc.) — see
`protocols/teaching-standard/README.md`. Do not seed `corporate/commands/` here.
