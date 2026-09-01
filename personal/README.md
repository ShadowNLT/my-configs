# Personal — durable agent seed

Personal-profile counterpart to `corporate/`. Nothing work-related belongs here.

## What lives here

- `AGENT.md` — personal-profile global rules. The durable source; a harness gets a copy.

Commands for a personal harness come from `protocols/`, not from `corporate/commands/`.

## Seed (agent copies, never symlinks)

The live name in every harness is `$CONFIG_DIR/AGENT.md`. Ask for `CONFIG_DIR` and
`COMMANDS_DIR`, echo them, get confirmation, then:

```bash
sed "s|{{AGENT_COMMANDS_DIR}}|$COMMANDS_DIR|g; s|{{AGENT_CONFIG_DIR}}|$CONFIG_DIR|g" personal/AGENT.md > "$CONFIG_DIR/AGENT.md"
```

Do not also write a `CLAUDE.md` or any other alias. If one already exists in that
config dir, delete it so it cannot become a second source of truth.

Install protocols the user wants on this profile per `protocols/README.md`
(command form plus sidecar). Do not seed `corporate/commands/` here.
