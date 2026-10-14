---
type: meta
created: 2026-10-14
---

# Ships

Runtime notes for work in flight. Many ships sit side by side. There is no `meta.md`.

The seed creates this folder and this README only. It does not create `Ships/<ship_uid>-<slug>/` directories.

## Layout

```
Ships/<ship_uid>-<slug>/
  work.md
  learning.md
```

`<ship_uid>` is a UUID. `<slug>` is a short stable name. Both files share the frontmatter below. `role: work` belongs on `work.md`. `role: learning` belongs on `learning.md`.

## Frontmatter

```yaml
---
type: ship-note
role: work | learning
kind: goal | code-review
ship_uid: <uuid>
slug: <slug>
goal: <one-line>
status: in-progress | paused | completed
started_at:
paused_at:
ended_at:
agent_id:
continues:          # optional
---
```

`started_at`, `paused_at`, and `ended_at` are timestamps, set when the ship enters that state. `continues` is optional and names an earlier ship when this one carries that ship forward.

## Body

`work.md`:

- Goal
- Log
- Decisions
- Follow-ups
- Handoff, written when `status` is `paused`

`learning.md`:

- Lessons
- Open questions

Future harness commands will create and update these ship notes. This file only records the layout they write.
