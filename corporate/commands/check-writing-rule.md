---
description: Audit a piece of text against the Writing style rules in AGENT.md, applying only the rules relevant to what kind of artifact it is, and report findings without editing anything.
argument-hint: [the text, file, or artifact to check, or leave blank to target the most recent draft in this conversation]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> harness config root, {{AGENT_COMMANDS_DIR}} -> harness command dir, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Check Writing Rule

Target: $ARGUMENTS — or, if empty, the most recent thing about to be sent: the assistant's most recent substantive reply (a real answer, not a short acknowledgment like "sure, one sec"), or the most recent draft of a PR title/body, commit message, or doc discussed in this conversation, whichever is actually pending right now. If it's ambiguous which one that is, ask rather than guess.

## When to use

On demand, any time before sending or committing a piece of writing, whenever you want a second pass against `{{AGENT_CONFIG_DIR}}/AGENT.md`'s Writing style section instead of trusting that self-check during drafting caught everything. Not a hook, doesn't run automatically. This exists because relying on self-check during drafting has already failed once: an em dash slipped into a PR description, then again into the very message explaining the fix. The point of running this separately is that it's a deliberate second read, done after the fact, not another pass by the same drafting process that missed it the first time.

## Relationship to apply-writing-rule and update-writing-rule

This command only reports. It does not revise the target and does not touch AGENT.md.
- If a finding here is something you want actually fixed, through as many rounds as it takes, hand it to `/apply-writing-rule`, that command owns the fix-and-resubmit loop.
- If a finding suggests the rules themselves have a gap, something reads as generated even though it technically passes every existing rule, that's `/update-writing-rule`'s job, not this command's. It owns editing AGENT.md, with its own adversarial-review and sign-off gate.

Point at those two commands rather than editing anything from here.

## Process

1. **Identify the target text**, per the Target line above. Quote the exact text being checked before analyzing it, don't work from a paraphrase or a memory of it. If `$ARGUMENTS` points at more than one distinct piece of text, ask which one to focus on rather than picking one arbitrarily.

2. **Classify what kind of artifact this is.** The Writing style section's own Scope note applies different weight to different kinds, so get this right before checking anything else:
   - **Exempt entirely** — code, code comments, docstrings, or structured/machine-readable output (tables, JSON, logs, error strings). If the whole target is one of these, say so and stop; there's nothing to check. If only part of it is (a code block, log excerpt, or diff pasted inside an otherwise full-weight or loose-treatment artifact), exempt just that embedded portion from steps 3 and 4's checks and keep checking the surrounding prose normally.
   - **Full weight** — anything that will exist as its own artifact someone else can open later: a PR title, a PR body, a commit message, a doc, a code-review reply, or any message likely to get copied or forwarded elsewhere.
   - **Loose treatment** — a chat reply that lives and dies in this conversation window. The structural rules (list-merging, bold usage, repeated openers) still apply, per AGENT.md's own wording, but loosely, not worth flagging on every borderline line.

   If genuinely unclear which bucket it falls into (e.g. a chat reply that's actually about to be pasted into a PR), ask, since the answer changes how strict the rest of this check is.

3. **Run the mechanical check.** This part is deterministic, a literal scan, not a judgment call: search the exact text (skipping any embedded code/log/diff portion carved out in step 2) for an em dash character (—) and for any spaced hyphen ( - ) doing the same job (joining two clauses where a comma, period, colon, or connecting word would normally go). Report every instance found, quoted, with its location. This is the one rule in the whole section that's actually checkable by pattern-matching; everything in step 4 requires reading, not grepping, and should be reported with that distinction visible, not with false confidence borrowed from this step's precision.

4. **Run the judgment-based checks.** These require reading the prose the way a skeptical colleague would, not scanning for a banned-word list. The categories below restate AGENT.md's Writing style section for convenience, that file stays the source of truth, not this summary. The tells list especially is explicitly a living, appendable sample (new entries get added there, dated, once a pattern recurs), so if this command hasn't been touched in a while, glance at the live AGENT.md text rather than trusting this restatement to be current. Check each, weighted per the classification from step 2:
   - **First-principles writing** — only for claims that are non-obvious, contestable, or a judgment call; simple facts and short procedural updates ("Running tests now," "Done, fixed in file.py") are exempt by the rule's own text. Does the supporting fact appear before the conclusion it justifies? Is anything asserted that can't be traced to something observed, tested, or already agreed, without being flagged as an assumption ("Assuming X..." / "Unconfirmed:")?
   - **Tone** — does the format (direct sentence, connected prose, list, or table) match what's actually being communicated? Is anything present that wouldn't change what the reader believes or does next?
   - **Avoiding AI-sounding prose** — the operative test is AGENT.md's own: cut any word or clause whose removal wouldn't change the sentence's claim or its intended emphasis; if you can't state in one clause what would be lost, it's filler. The dated tells list (contrastive "not just X, it's Y" framing, a rhetorical question used as a transition, restating the question before answering, an enthusiastic opener, a closing sentence that just recaps what was already said, symmetric hedging between two readings instead of committing, stacked vague hedges, a chain of formal connectors like "however"/"moreover"/"additionally" where a period would do, a stacked triplet of adjectives used as a generic capstone) is a non-exhaustive sample of what that test tends to catch, not the check itself, don't stop once the text clears every item on the list. Apply at full weight for full-weight artifacts, loosely for chat-window text per step 2.
   - **Structure** — list items merged only when they restate/cause/instantiate each other, bold reserved for a literal string, UI label, table key, or genuine irreversible-consequence warning, no sentence-opener repeated three or more times outside deliberate parallelism, no emoji-as-bullets or tacked-on TL;DR, and when two phrasings assert the same claim and neither is obviously shorter, the one closer to spoken register wins. Full weight only for full-weight artifacts per the Scope note; for loose-treatment text, flag only if actually distracting, not on every borderline case.

5. **Report findings.** For each rule category: state pass or flag. For a flagged item, quote the exact offending text and name the specific rule it violates, don't describe the problem abstractly. One line covering a category is enough when it's clean; don't pad the report with a per-sub-rule pass line. Don't fold distinct flags into one entry to look shorter, either, each real issue gets its own line.

## Output

State the artifact classification (and which weight it got) first, since that governs everything after. Then the mechanical check's result: pass, or every em-dash/spaced-hyphen instance found, quoted with location. Then the judgment-based findings, grouped by the four categories in step 4, each either "clean" or a quoted flag naming the specific rule it trips. Close with a one-line pointer to `/apply-writing-rule` (to actually fix something flagged) or `/update-writing-rule` (if a finding suggests the rules themselves have a gap), only when there's something to point at, don't repeat that line on a report with zero findings.
