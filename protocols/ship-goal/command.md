---
description: >-
  Take the operator's goal through to proven: ask what they want to achieve and
  why, run code-concept-curriculum (restart it when the operator changes the
  goal, until the goal settles), check the settled goal for contradictions and
  limitations still left, split it into atomic vertical slices, freeze each
  task with the operator, order the tasks, hand each frozen task to
  freeze-task-ship, then verify the original goal. The operator runs it.
argument-hint: [the goal to ship. If empty, ask the operator for the goal.]
---

# ship-goal

Goal: `$ARGUMENTS`. If empty, ask the operator for the goal.

The operator runs this.

---

## 1. Parse arguments

`$ARGUMENTS` is the operator's goal. If empty, ask the operator for the goal.

| Token | Default | Meaning |
|---|---|---|
| goal text | required | The operator's goal. **State which you picked.** |

State in one line: `goal=<one-line restatement>` then proceed.

---

## 2. Start check

Confirm these protocols exist: `code-concept-curriculum` (CCC),
`code-discovery-machine`, `freeze-task-ship` and `verifier`. If any is
missing, stop and tell the operator which one.

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
sequence. Tasks can run in parallel if they don't touch the same files. Wait
rule: if two parallel tasks' proven plans name the same file, the task whose
plan was proven second waits until the other task finishes, merged or
stopped, then replans on the current `main`.

---

## 9. Run

Hand each task to `freeze-task-ship` as a frozen task from `ship-goal` (the
goal cosigned with the operator in §7 (Freeze)) and keep running tasks until
all of them are proven.

- If a task fails its own verifier, its unproven part becomes a new atomic
  task through §6 (Split into atomic tasks) and §7 (Freeze).
- If the same criterion comes back unproven a second time, it goes to the
  operator.

---

## 10. Final verify

Once every task is proven, run `verifier` on the original goal settled in §4
(Question, then CCC loop). Whatever it can't prove goes back to §4 (Question,
then CCC loop) as a new goal.
