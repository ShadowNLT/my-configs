---
type: meta
created: 2026-10-14
---

# Parking lot

Deferred items: real issues set aside instead of being handled where they were noticed.

## Layout

- `INDEX.md` — flat index. Read it first, then open the item file you need.
- `<repo>/<slug>.md` — one item per file.

## Item schema

```yaml
---
type: parking-item
repo: <repo>
slug: <slug>
title: <one line>
status: open | resolved | wontfix
source_ship:            # optional ship_uid
opened: <YYYY-MM-DD>
---

What was noticed, and what would resolve it.
```

`source_ship` is optional. An item stands on its own when no Ship parked it. Nothing outside this folder is required for an item to be valid.

When `status` changes, update the matching row in `INDEX.md` in the same pass. The seed leaves both the index and the item tree empty.
