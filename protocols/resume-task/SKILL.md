---
name: resume-task
description: >-
  Resume a Ship and continue its driver. Paused Ships are the normal case.
  A Ship that could not be paused because the agent died can be resumed
  too, after a warning. The operator runs it to continue a Ship. It reruns
  vault-research and hands the Ship folder to the driver.
  Trigger on: "/resume-task", "resume-task", "resume this Ship", "continue a Ship".
---

# resume-task

A standalone protocol. The operator runs it directly to continue a Ship.
It resumes the Ship and continues its driver. Paused Ships are the normal
case. A Ship that could not be paused because the agent died can be
resumed too, after a warning. Shared primitive. It hands the Ship folder
down to `vault-research` and the driver.

A Ship is `Ships/<ship_uid>-<slug>/` with `work.md` and `learning.md`.
Many Ships can be open at once. It shows the Ship to the operator, and
nothing is done until the operator confirms.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

`seed_state.py` is in this folder. Resolve this folder per `protocols/README.md`:
this folder in the repo, the skill folder after a skill install, or the
command-form sidecar `$CONFIG_DIR/resume-task/` after a command install.
The one-time install is `install.sh` in this same folder. It stops, and
installs nothing for that harness, when the path it is given is not a seeded
vault.

---

## 1. Take the pick or the words

There is no argument string to parse. Take the operator's pick from the
list, or a few words describing the Ship. The agent suggests a match. The
operator picks. If neither a pick nor a few words is given, list the
eligible Ships.

| Parameter | Default | Meaning |
|---|---|---|
| pick or words | the list | The operator's pick from the list, or a few words describing the Ship. It suggests a match. The operator decides. |

---

## 2. Start check

At the start, in this order. These checks run before any Ship file is read:

1. If the knowledge vault root above is still the unfilled placeholder
   (double braces), stop: "Resume task stopped: install has not run for
   this harness."
2. Run `python3 seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"` from this folder.
   This is the same check install runs. If `.seed-state` does not say
   done, it stops. Show its one reason line and tell the operator to run
   the seed first.
3. Confirm these protocols exist: `vault-research`, `ship-goal`, and
   `review-goal`. If one is missing, stop with one line that names it.

---

## 3. Eligible Ships

Eligible Ships are only `in-progress` and `paused` ones. Completed Ships
are never listed or matched.

Read the frontmatter of every `{{KNOWLEDGE_VAULT_ROOT}}/Ships/*/work.md`
to build the list or match the words. A folder without `work.md` or with
no frontmatter is listed as unreadable and can't be picked.

If no eligible Ship is found, stop with one line saying so.

---

## 4. Pick

Either list the eligible Ships, each with the summary (slug, one-line
goal, status, last change `started_at` or `paused_at`, ship uid last),
and the operator picks one. Or the operator gives a few words, it matches
them against the eligible Ships and suggests the best match, and the
operator decides.

When in doubt, list all eligible Ships. It never picks. The operator
always decides.

---

## 5. Not paused

If the picked Ship is not `paused`, warn first: "This Ship is not paused.
Another agent may still be working on it, and resuming may change its
work."

---

## 6. Confirm

Read the picked Ship's `work.md` Handoff, to show it to the operator. If
`work.md` is missing, stop and do nothing. If the Handoff section is
missing, say so in one line and continue.

Read the picked Ship's `learning.md` frontmatter, to set status. If
`learning.md` is missing, stop and do nothing.

Show the summary and the Handoff and ask "Resume this Ship? (yes/no)".
Nothing is done until the operator says yes. If the operator says no,
nothing is written.

---

## 7. Stamp

On yes, stamp a new `agent_id` (this agent's), set `status: in-progress`,
and clear `paused_at`, in both files.

---

## 8. Research

Rerun `vault-research` on the Ship's goal with the Ship folder. The Ship
folder is handed only as one line, `Ship folder: <absolute path>`. It
rewrites `findings.md`.

---

## 9. Research stopped

If `vault-research` stops, show its one reason line and stop.

---

## 10. Continue the driver

Continue the driver. The Ship folder is handed only as
`Ship folder: <absolute path>`.

Kind goal: `ship-goal` with the goal, the `Ship folder:` line, and the
findings.

Kind code-review: `review-goal` with the PR, the `Ship folder:` line, and
the findings.

After `vault-research`, read `findings.md`. If `findings.md` is missing
after a run that did not stop, say so in one line and hand over without
findings.

Output: the Ship is back `in-progress` with the new `agent_id`, fresh
`findings.md`, and the driver running.

---

## 11. PR closed or merged

If `review-goal` hands control back saying the PR is closed or merged,
ask the operator "End this Ship? (yes/no)".

On yes, in both files set `status: completed` and `ended_at` now, as
end-task does.

On no, pause it and say why it stopped: in both files set `status: paused`
and `paused_at` now, and write the Handoff in `work.md` as the line
"Stopped: PR #<n> is <state>."

---

## Out of scope

- Rebuilding paused lessons on the latest verified code, and the line
  "The chunks ahead were rebuilt on the latest verified code." Those
  belong to the change-lesson PR.
- Checking the PR state on resume. review-goal already checks the PR
  state on every resume.

---

## Fixed points

- It says "operator", never a name.
- It never hardcodes the operator or a vault path. The vault path is the
  knowledge vault root filled in at install, and it runs only on a seeded
  vault.
- Writes go only inside the seeded `Ships/` folder. Legacy content is
  read, never written.
- No credentials or account details go into Ship notes, findings or logs.
- `agent_id` is the running agent's own id. On resume it stamps a new one,
  this agent's.
- It shows the Ship to the operator, and nothing is done until the
  operator confirms.
- The operator runs it directly. It hands the Ship folder down to
  `vault-research` and the driver.
- It never picks. The operator always decides. Completed Ships are never
  listed or matched.
- Ship summary: slug, one-line goal, status, when it last changed
  (`started_at` or `paused_at`), ship uid last. The prompt ends with a
  plain yes/no question.
