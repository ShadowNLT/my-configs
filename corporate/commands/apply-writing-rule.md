---
name: apply-writing-rule
description: >
  When you judge an assistant reply unsatisfactory against the Writing style rules, iterate on
  that specific reply with feedback rounds until you're satisfied, then hand the full before/after
  trail to update-writing-rule so it can judge whether the rules themselves need a fix.
argument-hint: [optional: paste or point at the specific output to iterate on, if it's not the immediately preceding reply]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> harness config root, {{AGENT_COMMANDS_DIR}} -> harness command dir, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Apply Writing Rule

Triggered when you flag an assistant reply as not good enough and want it actually fixed, not just diagnosed. This command fixes the instance first, through as many rounds as it takes, then feeds the resolved case into `update-writing-rule` to check whether the rules themselves need updating. It exists because a single fix-and-move-on cycle throws away the information in how many tries it took and what didn't work, and that's exactly the evidence `update-writing-rule` needs to tell a real gap from a one-off miss.

## Phase A: iterate on the instance

1. **Identify the target text.** Default to the assistant's most recent substantive reply (a real answer, not a short acknowledgment like "sure, one sec"). If `$ARGUMENTS` points elsewhere (pasted excerpt, earlier message, PR comment), use that instead. If `$ARGUMENTS` points at more than one distinct piece of text (a whole file, several separate replies), ask which one to focus on rather than picking one arbitrarily, this command iterates on one piece of text at a time. Quote the exact text before starting.

2. **Track a history list** for this run: each round records the draft produced and the feedback that followed it. Start empty.

3. **Loop:**
   a. Diagnose the current draft against `{{AGENT_CONFIG_DIR}}/AGENT.md`'s Writing style section, same lens as `update-writing-rule` step 2: check against each existing rule, then read fresh for anything that reads generated even if it technically passes. Also check the revision doesn't reintroduce anything already flagged and fixed earlier in this run's history. If the most recent feedback is too thin to act on (a bare "no," "still off," or similar with no specifics), ask one direct clarifying question before revising rather than guessing blind.
   b. Produce a revision addressing what was found.
   c. Present the revision.
   d. Append `{draft, feedback: pending}` to history.
   e. Wait for the user's response:
      - **Explicit approval** — a clear, affirmative sign-off on this specific draft: "yes," "good," "ship it," "that's it," or equivalent. Lukewarm or ambiguous replies ("fine I guess," "sure," "better," a reply that raises a new topic without commenting on the draft) are not approval, treat them as further feedback (ask what's still off, if nothing concrete is offered) rather than exiting the loop. When genuinely unsure which bucket a reply falls into, ask directly rather than guessing. Once approval is confirmed, record it, exit the loop, go to Phase B.
      - **Further feedback or rejection** — fill in the pending feedback, set the current draft to this revision, go back to (a) incorporating the new feedback.
      - **Abandons or cancels** — stop entirely, skip Phase B, but before stopping, append a short entry to `{{AGENT_CONFIG_DIR}}/AGENT-review-log.md` following that file's existing dated-heading format (`## <date> — <title>`), e.g. `## 2026-07-03 — apply-writing-rule: unresolved, abandoned after 3 rounds`, recording the original text (or a pointer to it), how many rounds ran, and the last feedback given.
      - **Reopened after approval** — if more feedback arrives after approval but before or during Phase B, treat the approval as void: return to the loop with this new feedback, and discard any in-progress trail assembly, it isn't final yet.

4. **Check in after 8 rounds without approval** (this number was your own choice as of 2026-07-03; if it consistently turns out too high or low in practice, revisit it here rather than working around it silently). A round is one full pass through step 3(a)-(e) that ends in rejection or further feedback, the initial diagnosis-and-first-draft is round 1's draft, and the 8th rejection triggers this check-in. Don't keep looping silently past that point. Say where things stand and ask whether to keep iterating or stop here, for instance if they'd rather hand-edit it themselves. Only continue looping on their say-so; don't assume "keep going" as the default past this point. The check-in message itself is not a history entry and not feedback on the draft, don't treat "keep going" as content critique when producing the next revision.
   - **If they say keep going:** resume the loop and check in again after every 4 further rounds, not another full 8, the ceiling should get more attentive the longer a run drags, not less.
   - **If they say stop without approving:** treat it like abandonment (step 3e) — skip Phase B, but still persist the trail so far using step 3e's abandon-branch logging.

## Phase B: hand off to update-writing-rule

5. Once approved (or Phase A is deliberately cut short via the early-escalation exception in the closing reminder), ask whether this is worth a rule-level look: "Is this a one-off, or do you want `update-writing-rule` to check whether the rules need a fix?" If it's a one-off, stop here, the instance is fixed, that's the whole job for this run, but still log it to `AGENT-review-log.md` using step 3e's format (`## <date> — apply-writing-rule: resolved, no rule check requested`). If they want the rule check, or have no strong opinion (default to running it, since it's cheap and this command's whole reason for existing is not losing that evidence), assemble the trail: the original text, the final approved version, and every intermediate draft with the feedback that killed it. When assembling it, tag any round whose feedback was about correctness or facts rather than style, since `update-writing-rule` only handles style-level gaps and should disregard those rounds. Also flag if the same complaint recurred more than once, or if feedback contradicted an earlier round's feedback, recurring or contradictory feedback is itself evidence of a possible rule gap, not just noise.

6. Invoke `update-writing-rule`, but note that its own step 1 is written to diagnose one piece of target text, not a multi-round trail. To actually get the benefit of the full history rather than just the final draft, format the trail as one document before invoking it: the original, each rejected draft paired with the feedback that killed it in order, then the final approved version, each clearly labeled. Hand `update-writing-rule` that formatted document as its target text, and explicitly tell it to diagnose the pattern across the whole trail (what recurred, what never got flagged by an existing rule), not just the final string. It decides from there whether this reveals an actual gap in the Writing style section or was just a rule that already existed and got missed, drafts a surgical fix only if warranted, and still requires its own sign-off before touching `AGENT.md`. This command never edits `AGENT.md` directly, that stays `update-writing-rule`'s job. If `update-writing-rule` can't be invoked (missing, erroring) or the user cancels right at handoff, don't lose the trail, apply step 3e's persistence logging so the case isn't dropped.

This is a workaround, not a real interface: `update-writing-rule.md` was authored for a single-reply input and hasn't been updated to natively reason about a trail. If the pattern-across-rounds diagnosis matters enough to rely on regularly, `update-writing-rule.md` itself should be revised to handle trail-shaped input, as a separate change with its own sign-off.

Reminder: Phase A is about getting one piece of text right, not about the rules. Don't reach for a `AGENT.md` edit mid-loop. If the user tries to fix the rule before the instance is settled, point out that `update-writing-rule` exists for that and this command hands off to it automatically once Phase A closes. Exception: if a round's diagnosis in step 3(a) comes up empty against every existing rule (the problem is real but no listed rule covers it), that's worth surfacing immediately rather than waiting out the rest of the loop, say so when you present that round's revision, and let the user decide whether to keep iterating on the instance or jump straight to Phase B on the trail so far.
