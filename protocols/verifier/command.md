---
description: >
  Prove that claims hold. Use when a claim, a change, or a task's aim has to
  be checked against facts: tests, a map of facts from code-discovery-machine,
  the browser, and a security pass with app-breaker. It runs standalone, and
  other protocols can call it with one atomic claim.
argument-hint: [one atomic claim to verify, or leave blank to infer]
---

# verifier

Target: $ARGUMENTS — or, if empty, what to verify, inferred from the conversation.

Account details and credentials never go into the repo, screenshots or logs.

## 1. Start check

At the start, check that `/code-discovery-machine`, `/agent-browser-testing`,
`/app-breaker`, and `/write-tests` exist. If any of them is missing, stop and
tell the operator which one.

## 2. Job

It is a verifier. It proves that claims hold.

## 3. Facts only

Create an agent or other process that only allows facts. A claim counts as
holding only when that process allows it as a fact. The process does not guess.

Code counts as fact, because code only means one thing and can't be misread.
For example, `type Human struct{ name string age int }` is a struct named Human
with exactly two properties, name of type string and age of type int.

## 4. How it runs

It runs standalone, and other protocols can call it.

## 5. What to verify

It infers what to verify from context. When it is called, the caller tells it
what to verify, ideally something atomic. That way a caller can call it in a
loop to go over facts one by one.

## 6. Unclear goal

If it is unsure what to verify, it always asks. When an operator runs it, it
asks the operator. When another protocol calls it, it asks that protocol to
specify the goal properly. It waits for that answer before the checks below.

## 7. Goal

It always knows the task's aim, the goal, and verifies against it. State the
task's aim and the goal before checking. Verify against them through tests,
through `/agent-browser-testing`, and through the other checks in this
protocol.

## 8. Tests

If tests that cover the claim already exist, run them. If they do not, call
`/write-tests` to write them, then run them itself. `/write-tests` writes the
tests. The verifier runs them. A passing test that does not cover the claim is
not proof of the claim.

## 9. Map of facts

Use `/code-discovery-machine` to build facts into a map of facts. Call it for
the concept, or for the code the concept lives in. It returns one saved record
of the code-forced fact set: exhaustive discovery, the knowledge graph,
converge, and the graph-level adversary. Build that record into the map. It
does not teach, and it does not edit the target code. An escalated result
comes back to the verifier. If the concept is ambiguous, do not guess a
concept; §6 applies.

## 10. Browser

Use `/agent-browser-testing` to verify things whenever that's possible. It
proves a task in a browser and returns proven, unproven, or browser
unavailable, plus the evidence. That result comes back to the verifier. When a
browser check is not possible, say so. Do not invent a browser result.

## 11. Security

Use `/app-breaker` to make sure the changes are tight security-wise. Point it
at the changes, or at the concrete artifact the claim is about.
`/app-breaker` hunts how that artifact breaks in practice, including security
exposure, and it does not edit the artifact. Its findings come back to the
verifier.

## 12. Summary

Always end with a summary of what was verified, what wasn't, what failed, what
couldn't be proven, and a final verdict. That goes to the operator, or back to
the calling protocol. The verdict is only what the facts-only process allows.
A skip, a failure, or a check that could not be proven stays in the summary as
not verified.

## 13. Failures

When something fails or can't be proven, the verifier brings it straight to the
operator, even when another protocol called it. The operator decides, for
example skip or retry, and the verifier continues. On skip, leave that item
unverified and continue. On retry, run that check again. Calling protocols
need no changes.

Results from `/agent-browser-testing` and findings from `/app-breaker` come
back to the verifier, so they go through this same way.

Exception: when app-breaker has no browser, it pauses and runs `/step-by-step`
with the operator directly, as frozen in step 2 (app-breaker, No browser). The
operator runs each step and reports what they saw. When the walkthrough ends,
control returns to app-breaker, which marks those findings 'operator-reported'
and finishes its report. The verifier does not take over that pause. Its
operator-reported results then come back to the verifier like any other
finding, and then go through this same way.
