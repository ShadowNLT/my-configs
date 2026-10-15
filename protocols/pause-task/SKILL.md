---
name: pause-task
description: >-
  Pause the active Ship: set status and timestamp, and write the Handoff
  in work.md. Shared primitive for every kind. The operator runs it to
  stop work on a Ship and come back later. It writes only to the Ship
  this agent stamped.
  Trigger on: "/pause-task", "pause-task", "pause this Ship".
---

# pause-task

A standalone protocol. The operator runs it directly to stop work on a
Ship and come back later. It pauses the active Ship: set status and
timestamp, write the Handoff in `work.md`. Shared primitive for every
kind. It writes only to the Ship this agent stamped.

A Ship is `Ships/<ship_uid>-<slug>/` with `work.md` and `learning.md`.
Many Ships can be open at once. The agent knows its Ship because it
stamped its `agent_id` on it. It shows that Ship to the operator, and
nothing is done until the operator confirms.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

`seed_state.py` is in this folder. Resolve this folder per `protocols/README.md`:
this folder in the repo, the skill folder after a skill install, or the
command-form sidecar `$CONFIG_DIR/pause-task/` after a command install.
The one-time install is `install.sh` in this same folder. It stops, and
installs nothing for that harness, when the path it is given is not a seeded
vault.

---

## 1. Take the current Ship

There is no argument string to parse. None from the operator. The Ship is
the current one: the running Ship carrying this agent's `agent_id`. No
list.

| Parameter | Default | Meaning |
|---|---|---|
| (none) | none | The operator types nothing. The current Ship carries this agent's `agent_id`. No list. |

---

## 2. Start check

At the start, in this order. These checks run before any Ship file is read:

1. If the knowledge vault root above is still the unfilled placeholder
   (double braces), stop: "Pause task stopped: install has not run for
   this harness."
2. Run `python3 seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"` from this folder.
   This is the same check install runs. If `.seed-state` does not say
   done, it stops. Show its one reason line and tell the operator to run
   the seed first.

No other protocol. If the start check fails, stop.

---

## 3. Take the current Ship

Read the frontmatter of `{{KNOWLEDGE_VAULT_ROOT}}/Ships/*/work.md` to find
the current Ship. The current Ship is the one whose `agent_id` is this
agent's and whose `status` is `in-progress`. No list.

If no current Ship is found, stop with one line saying so, and write
nothing.

Read the matched Ship's `work.md`, to write the Handoff. Read the matched
Ship's `learning.md` frontmatter, to set status. If `work.md` or
`learning.md` is missing, stop and do nothing.

It does not read `findings.md`.

---

## 4. Confirm

Show the Ship summary: slug, one-line goal, status, when it last changed
(`started_at` or `paused_at`), ship uid last.

Ask "Pause this Ship? (yes/no)". Nothing is done until the operator says
yes. If the operator says no, nothing is written.

---

## 5. Pause

On yes, in both files set `status: paused` and `paused_at` now.

---

## 6. Handoff

Write the Handoff section in `work.md`, one shape per kind.

Goal: task, chunk k of n, next step, open decisions, pinned commit.

Code-review: PR number, review round, open comments.

Output: updated frontmatter in both files, and the Handoff in `work.md`.

---

## Out of scope

- What happens to a lesson or task cut off mid-way. That belongs to the
  change-lesson PR. pause-task only writes the Ship notes.
- Reading `findings.md`.
- Listing Ships. No list.

---

## Fixed points

- It says "operator", never a name.
- It never hardcodes the operator or a vault path. The vault path is the
  knowledge vault root filled in at install, and it runs only on a seeded
  vault.
- Writes go only inside the seeded `Ships/` folder. Legacy content is
  read, never written.
- No credentials or account details go into Ship notes, findings or logs.
- `agent_id` is the running agent's own id.
- It shows the Ship to the operator, and nothing is done until the
  operator confirms.
- The operator runs it directly. It writes only to the Ship this agent
  stamped.
- Ship summary: slug, one-line goal, status, when it last changed
  (`started_at` or `paused_at`), ship uid last. The prompt ends with a
  plain yes/no question.
