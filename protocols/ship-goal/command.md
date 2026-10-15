---
description: >-
  Take the operator's goal through to proven: ask what they want to achieve and
  why, run code-concept-curriculum (restart it when the operator changes the
  goal, until the goal settles), check the settled goal for contradictions and
  limitations still left, split it into atomic vertical slices, freeze each
  task with the operator, order the tasks, hand each frozen task to
  freeze-task-ship, then verify the original goal. The operator can run it
  directly, and other protocols can call it.
argument-hint: [the goal to ship. If empty, ask the operator for the goal.]
---

# ship-goal

Goal: `$ARGUMENTS`. If empty, ask the operator for the goal.

The operator can run this directly, and other protocols can call it.

---

## 1. Parse arguments

`$ARGUMENTS` is the operator's goal. If empty, ask the operator for the goal.

| Token | Default | Meaning |
|---|---|---|
| goal text | required | The operator's goal. **State which you picked.** |
| Ship folder | optional | Only a calling protocol passes it, in its hand-over, as `Ship folder: <absolute path>`. Never an operator input, never asked for. |
| findings | optional | Only a calling protocol passes them, in its hand-over. ship-goal does not open `findings.md`. Never an operator input. |

State in one line: `goal=<one-line restatement>` then proceed.

---

## 2. Start check

Confirm these protocols exist: `code-concept-curriculum` (CCC),
`code-discovery-machine`, `freeze-task-ship` and `verifier`. If any is
missing, stop and tell the operator which one. ship-goal needs a harness
that can run background agents, checked the same way as the protocols it
depends on.

With a Ship folder, check it exists and is writable, else stop with one line
naming the path and the problem. Without one, print nothing about it. A
handed folder that lacks `work.md` or `learning.md`: stop and do nothing.

---

## Findings

If findings were handed over, read them from the hand-over (never from
`findings.md`) before §3 (Assess) and use them in §4 (Question, then CCC
loop). No findings and no Ship folder: skip silently.

---

## 3. Assess

Take the operator's goal, for example "extend the dashboard to account for
new user types and tweak the UI accordingly". Judge whether it's non-trivial,
meaning it can't run as a single atomic task.

---

## 4. Question, then CCC loop

- First, ask the operator what they want to achieve and why.
- Based on that, start CCC. CCC does the discovery and teaches the operator
  along the way.
- If the goal hasn't changed, continue to §5 (Final security layer).
- If the operator changes or tweaks the goal, restart CCC with the new goal.
  Pass in the earlier discovery if the commit hasn't moved (CCC takes that as
  an optional caller-supplied input, and only in this case); teaching still
  runs in full. Repeat this until the goal stops changing.
- At the end of this step, the operator has a goal and has learned enough to
  know everything the code says about that goal.
- With a Ship folder, every chunk CCC teaches is written into `learning.md`
  (Lessons section) the way CCC teaches it, using the record CCC hands back
  (G5b). CCC hands back; ship-goal writes.
- With a Ship folder, `work.md` Log gets one entry for the goal settled.

---

## 5. Final security layer

Check the settled goal for logical contradictions and limitations that are
still left. Discovery during CCC should already have found them.

---

## 6. Split into atomic tasks

Each task is one thing, done as a vertical slice end to end. That means a
slice on a feature, never the database layer first, then the backend, then
the frontend. Each task must fit `freeze-task-ship`.

---

## 7. Freeze

Cosign the goal of each task with the operator. That's the freeze part.

---

## 8. Order

Using discovery, mark which tasks can run in parallel and which must run in
sequence. Tasks can run in parallel if they don't touch the same files. A
task that runs in sequence after another starts from the verified code of
the task it follows. Wait rule: if two parallel tasks' proven plans name the
same file, the task whose plan was proven second waits until the other task
finishes, merged or stopped, then replans on the current `main`.

---

## 9. Run

Hand each task to `freeze-task-ship` as a frozen task from `ship-goal` (the
goal cosigned with the operator in §7 (Freeze)) and keep running tasks until
all of them are proven. For a task that runs in sequence after another,
ship-goal hands the verified-code commit of the task it follows to
`freeze-task-ship` as that frozen task's start commit.

- If a task fails its own verifier, its unproven part becomes a new atomic
  task through §6 (Split into atomic tasks) and §7 (Freeze).
- If the same criterion comes back unproven a second time, it goes to the
  operator.
- With a Ship folder, `work.md` Log gets one entry for each task handed to
  `freeze-task-ship`, with its frozen commit, and one entry for each result.

---

## 10. Final verify

Once every task is proven, run `verifier` on the original goal settled in §4
(Question, then CCC loop). Whatever it can't prove goes back to §4 (Question,
then CCC loop) as a new goal. With a Ship folder, `work.md` Log gets one
entry for the final verification.

---

## 11. Notes

No Ship folder: write nothing to disk, print no notice about it, output only
in chat. With a Ship folder: write only `work.md` and `learning.md` in it,
and end by listing the files written. With a Ship folder, decisions go into
`work.md` (Decisions section). Every cite ship-goal writes in the notes
carries the commit: `file:line @ sha`.

---

## Out of scope

- Producing the findings and any vault access.
- Opening `findings.md`.
- Ship frontmatter (status, timestamps), the Handoff, and ending the Ship.
  ship-goal never writes frontmatter or the Handoff: pause-task, resume-task
  and end-task own those.
