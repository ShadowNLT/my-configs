---
description: >
  Prove a task in a browser. At the start, run /code-discovery-machine and work
  out which browser to use at the same time: agent browser first, then Chrome.
  Confirm each new tab with the operator. Return proven, unproven, or browser
  unavailable, plus the evidence.
argument-hint: [the task to prove in a browser, or leave blank to infer]
---

# agent-browser-testing

Target: $ARGUMENTS — or, if empty, the task to prove in a browser most recently under discussion.
If it is ambiguous which task that is, ask the operator.

## 1. Start check

Confirm that `/code-discovery-machine` and `/step-by-step` exist. If any is
missing, stop and tell the operator which one.

## 2. How it runs

It works on its own, and other protocols can call it.

## 3. Context

It's usually called after a task, so the agent will have the context. If anything
is missing, ask the operator.

## 4. Discovery and browser order

At the start, run discovery and work out which browser to use at the same time.
Always run your own `/code-discovery-machine`. Cross-check any facts the calling
protocol sends against that discovery before using them, and never trust them
blindly. Try the agent browser first, then Chrome. Everything it does in the
browser uses the discovery facts. If neither browser works, or the task can't be
done in a browser, report to the operator with a `/step-by-step` list built from
the discovery facts.

## 5. Tabs

For each new tab, try to get the operator to confirm they can see it, and make it
hard for them not to confirm. Skip this only if the operator specifically says
not to confirm tabs with them. If the operator still doesn't confirm, the run
continues, because the screenshots and requests still prove the facts. The result
then notes that it ran in a browser the operator didn't confirm seeing. If Chrome
reports the tab as not active or in the background and the agent judges that an
impediment, report to the operator immediately so they can fix it.

## 6. Role switch

When it switches to another app user, clear the site's data first.

## 7. Screenshots

Screenshots are high resolution, so they can be reused in the PR. Passwords and
personal data are blurred. Save them outside the repo, in a folder the operator
chooses; if none is set, ask at the start. Never add them to the repo or count
them as a change unless the operator says so.

## 8. Evidence

The 'before' screenshot shows which app user and role are logged in. If a break
doesn't show on screen, attach the request and response or a log line.

## 9. Where it runs

Local only for now, or wherever the operator points it. Ideally nothing
destructive, so every action can be undone at the end. Always ask the operator
before anything destructive.

## 10. 2FA

On 2FA, stop and ask the operator.

## 11. Result

The result is proven, unproven, or browser unavailable, plus the evidence. Go
back to the operator or to the protocol that called it.
