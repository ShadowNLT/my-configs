---
description: >-
  Review one pull request when start-task's kind is code-review: read the
  vault findings start-task wrote into the Ship's folder, do nothing until
  the operator confirms, discover before teaching, teach with
  code-concept-curriculum, run app-breaker, and reach a verdict of approve,
  request changes, or comment with the operator. Same Ship notes as
  ship-goal (work.md, learning.md), with a different run. The operator
  runs it.
argument-hint: [the review. start-task invokes this when the kind is code-review.]
---

# review-goal

Review: `$ARGUMENTS`. `start-task` invokes this when the kind is code-review.

The operator runs this.

---

## 1. Parse arguments

`$ARGUMENTS` is the operator's review. `start-task` invokes this when the kind
is code-review.

It uses the same Ship notes (`work.md`, `learning.md`) as `ship-goal`, with a
different run.

---

## 2. Start check

At the start, confirm these protocols exist: `code-concept-curriculum` (CCC),
`code-discovery-machine`, `app-breaker` and `verifier`. If any of them is
missing, stop and tell the operator which one.

---

## 3. Findings

Read the vault findings that `start-task` wrote into the Ship's folder.

---

## 4. Confirm

Nothing is done until the operator confirms.

---

## 5. The PR's state

The agent checks the PR's state on every resume and at the start of every
round. If the PR is closed, merged or deleted, it says "PR #<n> is <state>.
End this Ship? (yes/no)" and no round starts. The Ship ends when the PR is
closed, merged or deleted.

---

## 6. Rounds

Each round is one full pass in the same Ship, with full discovery. An earlier
graph is reused only when both base and head are unchanged. The operator
pauses between rounds and resumes when ready, and nothing watches the PR. A
new round starts when the operator gives an instruction that either says the
PR has updates or asks the agent to check, and the PR has in fact been
updated.

If the operator asks the agent to check and the PR hasn't changed, the agent
says "No changes since round <n>." and no round starts.

At the start of each later round, the operator sees the previous verdict and
what changed in the PR since the last pass, then confirms with "Start round
<n>? (yes/no)".

---

## 7. Pin the commits

Each pass pins the base and head commits at its start.

---

## 8. Source of truth

Code is the source of truth. What the PR does is inferred from the code, even
when the PR description is empty or misleading.

---

## 9. Discovery, then teaching

Discovery comes first, then teaching. `code-discovery-machine` runs the
discovery. The teaching is `code-concept-curriculum` (CCC).

The teaching (CCC) covers the current state, the problem, why the PR exists,
what the solution would be, and whether the PR does that. There's one teaching
per pass. A later pass builds on what `learning.md` records as taught and
covers only what's new.

The solution is taught before the diff.

---

## 10. app-breaker

Run `app-breaker`.

---

## 11. Verifier

Every claim in the teaching and the verdict goes through `verifier`, the
protocol on `main` (`protocols/verifier/`). `verifier` decides how unproven
claims are handled.

---

## 12. Verdict

The verdict is one of approve, request changes, or comment. The operator
gives theirs first, then the operator and the agent reach the verdict
together.

---

## 13. Who posts

The operator decides who posts the review: the agent or the operator.

---

## 14. Notes

The Log in `work.md` gets one entry per pass (pinned commits, verdict, who
posted), and `learning.md` gets the teaching.

---

## Out of scope

- start-task's vault research and writing of findings
- resume-task's rerun of the vault research
- the ship-goal edit to read start-task's findings
- pause-task
- end-task
