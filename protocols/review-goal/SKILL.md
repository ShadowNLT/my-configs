---
name: review-goal
description: >-
  Review one pull request: read any findings a calling protocol passes
  in, do nothing until the operator confirms, discover before
  teaching, teach with code-concept-curriculum, run app-breaker, and reach a
  verdict of approve, request changes, or comment with the operator. With a
  Ship folder it writes `work.md` and `learning.md` there. The
  operator can run it directly, and other protocols can call it.
  Trigger on: "/review-goal", "review-goal", "review this PR", "code review
  this pull request".
---

# review-goal

The operator can run this directly, and other protocols can call it.

---

## 1. Take the review

There is no argument string to parse. Take the pull request from the caller,
or from the operator on a direct run. The Ship folder and the findings come
only in a calling protocol's hand-over. The operator is never asked for them.

| Parameter | Default | Meaning |
|---|---|---|
| pull request | required | The PR to review (number or URL). If it is ambiguous, ask the operator. |
| Ship folder | optional | Only a calling protocol passes it, in its hand-over. Never an operator input, and never asked for. Without one, the run has no Ship: §5 uses the no-Ship line. |
| findings | optional | Only a calling protocol passes them, in its hand-over. Never an operator input. Without them, §3 is skipped. |

With a Ship folder it writes `work.md` and `learning.md` there.

---

## 2. Start check

At the start, confirm these protocols exist: `code-concept-curriculum` (CCC),
`code-discovery-machine`, `app-breaker` and `verifier`. If any of them is
missing, stop and tell the operator which one.

---

## 3. Findings

If a calling protocol passed findings in, read them. Otherwise skip this
step without saying anything.

---

## 4. Confirm

The PR state check (§5) runs first, at the start and on every resume, before the operator confirms.
Nothing is done until the operator confirms.

---

## 5. The PR's state

The agent checks the PR's state on every resume and at the start of every
round. If the PR is closed, merged or deleted, no round starts and the agent
asks nothing. With a Ship folder handed over by a calling protocol, it says
"PR #<n> is <state>." and hands control back to that caller with the PR's
state; the caller decides what happens next. Without a Ship folder, it says
"PR #<n> is <state>. Nothing to review." in the chat and stops.

---

## 6. Rounds

Each round is one full pass, with full discovery. With a Ship folder, every
round runs in that same Ship, and an earlier graph is reused only when both
base and head are unchanged. Without a Ship folder, the review still runs in
full, and only this run's own earlier rounds are reused. The operator
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
per pass. With a Ship folder, a later pass builds on what `learning.md`
records as taught and covers only what's new. Without a Ship folder, the
teaching stays in the reply. A later pass builds only on what this run
already taught, and `learning.md` is neither read nor written.

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

With a Ship folder, the Log in `work.md` gets one entry per pass (pinned
commits, verdict, who posted), and `learning.md` gets the teaching.

---

## Out of scope

- producing the findings, and any vault check (a calling protocol that works with the vault does both and passes the findings in)
- pause-task
- end-task
