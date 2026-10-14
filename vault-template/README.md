---
type: meta
created: 2026-10-14
---

# Knowledge vault

Vault root. Seeded canon:

- the company folder — company knowledge, named for the company when the vault is seeded; see that folder's README
- `Agent/` — the agent's corner; see `Agent/README.md`
- `Parking-Lot/` — deferred items; see `Parking-Lot/README.md`
- `Ships/` — in-flight ship notes; see `Ships/README.md`
- `.seed-state` — records the one-time move of pre-existing content into `legacy/`

```
<vault>/
  README.md
  .seed-state
  <company>/
  Agent/
  Parking-Lot/
  Ships/
```

## Diagrams

Applies to notes the agent writes in this vault for the operator to read. Does not apply to `Agent/`. That corner is the agent's own reference, and the agent uses whatever format a later read needs, diagram or prose.

Use a Mermaid diagram when a relationship, sequence, state machine, or hierarchy is structural: the note depends on the reader seeing how the pieces connect. Naming several things in one sentence is not a diagram case.

- A structural relationship among three or more things → flowchart or graph
- A sequence of steps across time or across actors → sequence diagram
- A state machine or lifecycle → state diagram
- A hierarchy or an ordering where one thing depends on another → flowchart or tree
- A comparison across options or attributes → a markdown table
- A data-relationship model → an ER diagram when a table would be unreadable

Skip a diagram when it would be trivial (two nodes, a straight line, nothing a sentence does not already say) or too large. Past roughly 12-15 nodes, split it into linked diagrams or use a table.

Every diagram gets at least one sentence of prose alongside it. A Mermaid block must not be the only carrier of the information. It does not render in every viewer, and a syntax error would otherwise drop that point from the note.

## Legacy

- **Seeded canon** means the root `README.md`, `.seed-state`, the company folder, `Agent/`, `Parking-Lot/` and `Ships/`. Everything else in the vault is **legacy**.
- **Crawlable** means it may be read and searched. The whole vault is crawlable, legacy folders and files included.
- **Write** means create, edit, delete, rename or move. Writes go only into seeded canon.
- Protocols may restrict writes further, and the narrower rule wins.
- Seeded canon may reference any crawlable content by link or path. Naming or quoting legacy content inside canon is allowed too.
- Legacy never references seeded canon, because that would mean editing legacy.
- If the vault doesn't fit these rules, report the conflict to the operator. The operator handles cleanup.

Seeding moves pre-existing content into `legacy/` exactly once, after a dry run the operator confirms, and never deletes.
