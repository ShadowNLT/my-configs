---
name: freeze-task-ship
description: >-
  Ship one task that ship-goal already froze with the operator: take the goal
  sentence, the numbered true/false criteria, and the out-of-scope list, pin
  the commit, discover facts, agree on a plan, prove it, write tests before
  any code, implement, then verify. Only ship-goal calls it. It isn't a
  standalone command. Personality: lazy but effective.
  Trigger on: "frozen task from ship-goal".
---

# freeze-task-ship

If no frozen task was handed over by `ship-goal`, stop immediately and tell
the operator to run `ship-goal` instead.

Only `ship-goal` calls this. It isn't a standalone command, because `ship-goal`
handles the brainstorm with the operator, splits the goal into atomic vertical
slices that each run end to end, and freezes each task with the operator.

**Personality:** lazy but effective.

---

## 1. Infer the frozen task

There is no argument string to parse. Infer the frozen task from the caller
(`ship-goal`):

| Parameter | Default | Meaning |
|---|---|---|
| frozen task | required | The goal sentence, the numbered true/false criteria, and the out-of-scope list. **State which you picked.** |

State in one line: `task=<one-line restatement>` then proceed.

---

## 2. Start check

Confirm that `write-tests`, `ponytail`, `converge`, `code-pi`,
`code-discovery-machine`, and `verifier` all exist. If any is missing, stop
and tell the operator which one.

---

## 3. Take in the frozen task

Take in the frozen task: the goal sentence, the numbered true/false criteria,
and the out-of-scope list. Pin the commit. If the task is unfrozen, it goes
back to `ship-goal`.

---

## 4. Discovery

Map each criterion to an area of code, and have `code-discovery-machine`
collect the facts for that area. Every fact cites a file and line at the
pinned commit, or the output of running the code. Discovery has a time budget.
A fact that can't be settled is marked open, and it goes to the operator if
the plan depends on it. If `main` moves, discovery runs again.

---

## 5. Agree on a plan

Two independent planners each get only the frozen goal and the facts, and
neither plans anything that isn't needed. Their plans go through `converge`,
with the frozen criteria as the task. The plans count as converged when they
reach the same result on the same facts, even if their steps differ. A
mismatch only counts once `converge`'s rounds have run out. `converge` returns
both converged plans, and `freeze-task-ship` takes the one with less work
forward. The cap is 3 rounds in total. `freeze-task-ship` keeps one round
counter across all its `converge` calls, and each call gets `n` = 3 minus the
rounds already used. When the counter reaches 3, the cap has run out and the
decision goes to the operator.

---

## 6. Proof

A third agent gets the same inputs and proves the plan meets each criterion.
Where the plan doesn't meet one, it shows a concrete failing case. `code-pi`
also runs on the plan. A hole in the plan goes back to §5 (Agree on a plan)
and counts against the same 3-round cap. A hole in the goal goes to the
operator.

---

## 7. Tests first

`write-tests` writes the tests before any code is written.

---

## 8. Implement

Follow the proven plan. If a planned step turns out not to work as written,
stop work on that step and anything that depends on it. A changed step can
have side effects on the rest of the plan, so the whole plan is rethought with
the new information, including the step that didn't work. The rethink goes
back through §5 (Agree on a plan) and §6 (Proof) and counts against the same
3-round cap. It picks one of two options:

1. **Continue with minimal changes.** The edits made so far stay. The §7
   (Tests first) tests stay too, unless the new plan changes code they rely
   on. In that case, `write-tests` updates only those tests, and they still
   check the same frozen criteria. The verifier and the tests prove the
   minimal changes later.
2. **Restart from scratch** with a new plan that accounts for the new
   information. All edits made so far are deleted, including the tests, and
   §7 (Tests first) writes new tests.

If the task can't be solved according to the goal, it goes back to the
operator.

---

## 9. Minimality and side effects

`ponytail` runs on the code and leaves out the §7 (Tests first) tests.
`code-pi` runs on the diff. Best practices apply only to code the change
touches, and security holes get fixed.

---

## 10. Verify

`verifier` checks against the frozen criteria and the pinned facts, not
against the implementer's own account. It reports to the operator, as its
point 13 says. Whatever it couldn't prove goes back to `ship-goal` as a new
goal, which is the old goal minus what was proven, with a new brainstorm and
a new freeze.

---

## 11. Impossible goals

The protocol calls a goal impossible only with an actual proof.

---

## 12. When the operator hears from it

The operator hears from it through the verifier's report and the final
result, plus these exceptions: a hole in the goal, the cap running out, a
proof that the goal is impossible, an open fact the plan depends on, or a §8
(Implement) rethink that can't be solved according to the goal. Each message
leads with the decision and its options, and there's at most one decision per
round.
