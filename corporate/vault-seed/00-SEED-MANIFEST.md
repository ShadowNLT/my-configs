# Vault seed — living meta docs only

Source-of-truth copies for **operational vault meta docs** that agents read during work,
learning, and curriculum sessions. These files use **vault-relative language** (e.g. "the harness
`/start-work` command", "seeded harness `AGENT.md`") — never `{{AGENT_*}}` template tokens.

## What gets seeded

Paths under this directory mirror the knowledge vault layout. Only files listed here are in scope.

| Path | Role |
|---|---|
| `README.md` | Vault-wide conventions (diagrams, scope) |
| `Agent/README.md` | Claude's corner — patterns, Feedback, dreaming |
| `Agent/Patterns/vivenu-core/pr-template.md` | PR body template pattern |
| `Agent/Patterns/vivenu-core/git-branch-and-commit-conventions.md` | Branch/commit/PR-title rules |
| `Learning/README.md` | Freestanding `/learn` notes schema |
| `Work/00-How-Work-Tracking-Works.md` | Session note schema, Journal Protocol, command overview |
| `Vivenu/Onboarding/Engine/{README,Sync-Core,Note-System}.md` | Checkout curriculum mechanics |
| `Vivenu/Onboarding-Web3/Engine/{README,Sync-Core,Note-System,00-How-This-Works}.md` | Web3 curriculum mechanics |

## Explicitly out of scope (never seed, never overwrite)

These stay only in the live vault; placeholders in them are **historical**, not operational bugs:

- `Work/*/Sessions/**` — frozen session notes
- `Work/01-Tutorial-Sandbox-Design.md`, `Work/Journaling-And-Lessons-Design-Record.md` — design records
- `**/Review-Logs/**` — adversarial-review logs
- `Agent/Dreams/**` — dream run logs
- `Vivenu/LocalDevSetup/**` — one-off design/review artifacts
- All curriculum **content** (`Modules/`, `Lessons/`, `Concepts/`, dashboards, maps) — user data, not protocol

## Seed policy

**Copy-if-missing only** by default. The live vault is authoritative once it exists; this tree is
for fresh-machine bootstrap and disaster recovery, not routine overwrites.

To force-refresh one file after a deliberate repo update, copy it explicitly — never bulk-sync the
whole vault.

## Seed command

Ask the user for `KNOWLEDGE_VAULT_ROOT` (e.g. `~/Documents/DigitalBrain`). Echo and confirm, then:

```bash
src="$(pwd)/corporate/vault-seed"
dst="$KNOWLEDGE_VAULT_ROOT"   # user-named

# Copy each seeded file only if the destination does not exist yet
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

To **update** a single meta doc the user explicitly wants refreshed:

```bash
cp corporate/vault-seed/Work/00-How-Work-Tracking-Works.md "$KNOWLEDGE_VAULT_ROOT/Work/"
```

## Relationship to harness seed

Harness seed (`corporate/README.md`) installs commands, `AGENT.md`, and sidecars with
machine-resolved paths. Vault seed installs **vault meta docs** with harness-agnostic prose. The two
passes are independent; run both on a fresh machine.

When a living meta doc changes, update **both** the live vault and the matching file here in the
same commit.
