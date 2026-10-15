---
description: >-
  Open a Ship and drive it. Kind goal goes to ship-goal, kind code-review
  goes to review-goal. Same note premise for both kinds. The operator runs
  it to start a new goal or a new code review. Nothing calls it.
argument-hint: [the goal, or the PR to review, as one line.]
---

# start-task

A standalone protocol. The operator runs it directly to start a new goal
or a new code review. It opens a Ship and drives it: kind goal with
`ship-goal`, kind code-review with `review-goal`. Same note premise for
both kinds. It is the caller that hands the Ship folder down. Nothing
calls it.

A Ship is `Ships/<ship_uid>-<slug>/` with `work.md` and `learning.md`.
Many Ships can be open at once. The agent knows its Ship because it
stamped its `agent_id` on it. It shows the Ship to the operator, and
nothing is done until the operator confirms.

Knowledge vault root: `{{KNOWLEDGE_VAULT_ROOT}}`

`seed_state.py` is in this folder. Resolve this folder per `protocols/README.md`:
this folder in the repo, the skill folder after a skill install, or the
command-form sidecar `$CONFIG_DIR/start-task/` after a command install.
The one-time install is `install.sh` in this same folder. It stops, and
installs nothing for that harness, when the path it is given is not a seeded
vault.

---

## 1. Parse arguments

`$ARGUMENTS` is the goal, or the PR to review, as one line. That one line
is required. If `$ARGUMENTS` is empty, ask the operator for it. For kind
code-review, that one line is the PR. It is the Ship's `goal` either way.

It reads no Ship files at start. It creates them. After `vault-research`,
it reads `Ships/<ship>/findings.md`.

The kind (`goal` or `code-review`) and the slug are not asked up front.
It proposes both. A PR link means code-review. The slug comes from the
goal. The operator types only to change them.

| Token | Default | Meaning |
|---|---|---|
| goal or PR | required | The goal, or the PR to review, as one line. This one line is the Ship's `goal`. For kind code-review, it is the PR. |
| kind | proposed | `goal` or `code-review`. A PR link means code-review. The operator types only to change it. |
| slug | proposed | From the goal. The operator types only to change it. |

---

## 2. Start check

At the start, in this order. These checks run before any Ship file is written:

1. If the knowledge vault root above is still the unfilled placeholder
   (double braces), stop: "Start task stopped: install has not run for
   this harness."
2. Run `python3 seed_state.py "{{KNOWLEDGE_VAULT_ROOT}}"` from this folder.
   This is the same check install runs. If `.seed-state` does not say
   done, it stops. Show its one reason line and tell the operator to run
   the seed first.
3. Confirm these protocols exist: `vault-research`, `ship-goal`, and
   `review-goal`. If one is missing, stop with one line that names it.

---

## 3. Propose the Ship

Make `ship_uid` (a UUID) and propose the kind and a slug. A PR link means
code-review. The slug comes from the goal.

---

## 4. Confirm

Show the Ship summary: slug, one-line goal, kind, ship uid. Kind and slug
are proposed. The operator types only to change them.

Then ask "Start this Ship? (yes/no)". Nothing is written until the
operator says yes. If the operator says no, nothing is written.

---

## 5. Create the Ship

On yes, create `{{KNOWLEDGE_VAULT_ROOT}}/Ships/<ship_uid>-<slug>/work.md`
and `learning.md` in that same folder.

Both files share one frontmatter:

- `type: ship-note`
- `role`: `work` on `work.md`, `learning` on `learning.md`
- `kind`: `goal` or `code-review`
- `ship_uid`
- `slug`
- `goal`: the one line
- `status: in-progress`
- `started_at`: now
- `paused_at`: empty until the Ship is paused
- `ended_at`: empty until the Ship is completed
- `agent_id`: this agent's id
- `continues`: optional

`work.md` body: Goal, Log, Decisions, Follow-ups. Handoff is written when
the Ship is paused, not at creation.

`learning.md` body: Lessons, Open questions.

Writes go only inside `Ships/`.

---

## 6. Research

Run `vault-research` on the goal, handing it the Ship folder. The Ship
folder is handed only as one line, `Ship folder: <absolute path>`.

`vault-research` researches the whole vault, `legacy/` included, and
writes `findings.md` in the Ship folder.

---

## 7. Research stopped

If `vault-research` stops, show its one reason line. In both files set
`status: paused` and `paused_at` now. Write the Handoff in `work.md` as
just the line "Research stopped: <reason line>". No chunk or next step
exists yet, so not the full per-kind shape. Then stop. No driver run.
resume-task shows that Handoff.

---

## 8. Hand off

Hand off to the driver. The Ship folder is handed only as
`Ship folder: <absolute path>`.

Kind goal: `ship-goal` with the goal, the `Ship folder:` line, and the
findings.

Kind code-review: `review-goal` with the PR, the `Ship folder:` line, and
the findings.

After `vault-research`, read `Ships/<ship>/findings.md`. If `findings.md`
is missing after a run that did not stop, say so in one line and hand
over without findings.

Output: the Ship folder with `work.md`, `learning.md`, and `findings.md`.
Then the driver's own run.

---

## 9. PR closed or merged

If `review-goal` hands control back saying the PR is closed or merged,
ask the operator "End this Ship? (yes/no)".

On yes, in both files set `status: completed` and `ended_at` now, as
end-task does.

On no, pause it and say why it stopped: in both files set `status: paused`
and `paused_at` now, and write the Handoff in `work.md` as the line
"Stopped: PR #<n> is <state>."

---

## Out of scope

- Writing `findings.md`. `vault-research` writes it in the Ship folder.
- The driver's own procedure, after the hand-off.
- The full per-kind Handoff when `vault-research` stops. No chunk or next
  step exists yet. §7 writes one line.

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
- Many Ships can be open at once.
