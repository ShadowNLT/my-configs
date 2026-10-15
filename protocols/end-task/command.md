---
description: >-
  Complete the Ship: set status and timestamp. No more writes to that
  work.md / learning.md pair after this. The operator runs it when the
  operator decides the Ship is done. For a code-review Ship, the Ship ends
  when the PR is closed, merged or deleted. Nothing calls it.
argument-hint: [none. The Ship is the current one. The operator types nothing.]
---

# end-task

A standalone protocol. The operator runs it directly. The operator decides
the Ship is done. For a code-review Ship, the Ship ends when the PR is
closed, merged or deleted. It completes the Ship: set status and
timestamp. No more writes to that `work.md` / `learning.md` pair after
this. Nothing calls it.

A Ship is `Ships/<ship_uid>-<slug>/` with `work.md` and `learning.md`.
Many Ships can be open at once. The agent knows its Ship because it
stamped its `agent_id` on it. It shows that Ship to the operator, and
nothing is done until the operator confirms.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

`seed_state.py` is in this folder. Resolve this folder per `protocols/README.md`:
this folder in the repo, the skill folder after a skill install, or the
command-form sidecar `$CONFIG_DIR/end-task/` after a command install.
The one-time install is `install.sh` in this same folder. It stops, and
installs nothing for that harness, when the path it is given is not a seeded
vault.

---

## 1. Parse arguments

`$ARGUMENTS` is empty. None from the operator. The Ship is the current
one: the running Ship carrying this agent's `agent_id`. No list.

| Token | Default | Meaning |
|---|---|---|
| (none) | none | The operator types nothing. The current Ship carries this agent's `agent_id`. No list. |

---

## 2. Start check

At the start, in this order. These checks run before any Ship file is read:

1. If the knowledge vault root above is still the unfilled placeholder
   (double braces), stop: "End task stopped: install has not run for
   this harness."
2. Run `python3 seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"` from this folder.
   This is the same check install runs. If `.seed-state` does not say
   done, it stops. Show its one reason line and tell the operator to run
   the seed first.

No other protocol. If the start check fails, stop.

---

## 3. Take the current Ship

Read the frontmatter of `{{KNOWLEDGE_VAULT_ROOT}}/Ships/*/work.md` to find
the current Ship. The current Ship is the one with this agent's
`agent_id` and `status: in-progress`. No list.

If no current Ship is found, stop with one line saying so, and write
nothing.

Read the matched Ship's `work.md` and `learning.md` frontmatter, to set
status. If either file is missing, stop and do nothing.

It does not read `findings.md`.

---

## 4. Confirm

Show the Ship summary: slug, one-line goal, status, when it last changed
(`started_at` or `paused_at`), ship uid last.

Ask "End this Ship? (yes/no)". Nothing is done until the operator says
yes. If the operator says no, nothing is written.

---

## 5. Complete

On yes, in both files set `status: completed` and `ended_at` now. No
closing Log line.

Output: both files marked completed.

---

## 6. No more writes

After this, no protocol writes to that `work.md` / `learning.md` again.

---

## Out of scope

- A closing Log line. Status and `ended_at` only.
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
- The operator runs it directly. Nothing calls it.
- Ship summary: slug, one-line goal, status, when it last changed
  (`started_at` or `paused_at`), ship uid last. The prompt ends with a
  plain yes/no question.
- After §6, no protocol writes to that `work.md` / `learning.md` again.
