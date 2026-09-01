---
description: Rewrite a piece of text into plain language understandable in a single read, without sacrificing length beyond what clarity requires — a clarity rewrite, never a summary
argument-hint: [the text to rewrite, or leave blank to target the most recent text in the conversation]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> harness config root, {{AGENT_COMMANDS_DIR}} -> harness command dir, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Layman Terms

Target: $ARGUMENTS — or, if empty, the most recent piece of text in the conversation. If it's
ambiguous which text that is, ask rather than guess.

You are rewriting a piece of text so a competent non-specialist can understand it in a single
read — no re-reading, no looking anything up. This is a **clarity rewrite, not a summary**: don't
drop substantive content to shorten it, and don't pad it with hand-holding it doesn't need. Match
density to exactly what one-pass comprehension requires.

Default audience: someone with no background in the source's specific subject, but ordinary
general knowledge and reading level — calibrate against that, not against a specialist in the
source's field. Match the source's own register: a casual input (a text, a tweet) gets a casual
plain rewrite; a formal document gets a formal-but-plain one. This is also what "genuinely
unavoidable" in Rule 2 is relative to — a term unavoidable for this default reader, not for a
domain expert. Keep the source's language — this doesn't translate.

This rewrite applies to prose. It does not apply to code, data tables, or diagrams — if the input
mixes prose with code/data, rewrite only the prose and leave code/data untouched. Preserve the
source's structure (headings, lists, citations, clause numbering) rather than flattening
everything into a single block of prose. Never apply jargon replacement inside a direct
quotation, or to a term that is itself the subject being discussed (e.g. "the report used the
word 'synergy' three times") — replacing the word there would misstate what the source says.

## Contract

1. **Every claim must trace to something already in the source.** If the source states a fact or
   gives a reason, restate it in plain words. Never add a supporting detail, example, statistic,
   or explanation that isn't in the source, even if it would make the prose read more smoothly.
   If you're tempted to write "because X" and X isn't in the source, cut the claim or flag it
   (step 5).
2. **No unexplained jargon or buzzwords.** Check every sentence against `denylist.txt` in the
   protocol sidecar `{{AGENT_CONFIG_DIR}}/layman-terms/` (not beside this command file; never
   hardcode a harness home path) and replace hits with their plain equivalents. A real technical term or
   proper noun that's genuinely unavoidable may stay, but define it inline in a few words the
   first time it appears. That inline definition is exempt scaffolding, not a new claim — but if
   a specific the source never gave (a number, a name, a "which") would be needed to complete the
   definition or a denylist replacement, don't invent it: cut the vague claim or flag it per Rule
   5 instead.
3. **Short sentences, one idea each, active voice, named subjects.** Rewrite "there are several
   factors that contribute to X" as "X happens because of A, B, and C" — named, not gestured at,
   and only when the source actually names them; if it doesn't, keep the vague form or flag it
   per Rule 5 rather than inventing names. Split any sentence carrying more than one independent
   clause unless the two clauses are tightly causal.
4. **Length is a consequence, not a target.** Don't count words. If the source is dense with
   content, the rewrite will be almost as long, just clearer. If the source is padded, the
   rewrite will be shorter. Never add scaffolding ("in today's world...", "it's important to note
   that...") that isn't carrying information. For long input, rewrite the whole thing in one
   pass, keeping terminology and definitions consistent throughout — don't chunk or summarize
   section by section.
5. **Flag what you can't ground.** If the source contains a claim with no stated support (an
   assertion presented as fact with nothing backing it in the text), do not invent a
   justification and do not silently drop it — keep the claim, but mark it immediately where it
   appears with an inline tag: `<claim text> [unsupported in source]`. Don't defer the flag to a
   trailing footer — a reader shouldn't have to hunt to match a flag back to its claim. This
   inline tag is the only permitted addition beyond the rewrite itself.

If the user explicitly asks for more explanatory context than the source provides, that
instruction overrides Rule 1's default for this request — the default is source-fidelity, not a
ceiling the user can't lift.

## Self-check before returning

Go claim by claim: for every sentence in your rewrite that states a fact, reason, or number,
point to the specific phrase in the source it came from. Any claim you can't point to a source
phrase for is not "obviously implied" — cut it or flag it per Rule 5. Also check for:
- Any leftover jargon/buzzword you didn't catch on the first pass.
- Any sentence long or tangled enough that a reader would need to read it twice.

Fix anything you find before returning (one pass is sufficient — don't loop indefinitely). Don't
narrate this checking process — just return the corrected result.

## Output

Return only the rewritten text, with inline `[unsupported in source]` tags where Rule 5 applied.
No preamble, no "here's the plain-language version," and no commentary anywhere in the response
about what you checked, caught, or fixed — including in the self-check step.