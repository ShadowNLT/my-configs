---
description: Explain any input from first principles, scaled to how deep it actually needs to go, each concept built strictly on ones already established
argument-hint: [term, question, block of text/code, or leave blank to target the most recent complex thing discussed]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> ~/.claude|~/.cursor|~/.codex|~/.config/opencode, {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Layman Term

Target: $ARGUMENTS — or, if empty, the most recent complex/technical thing discussed. If it's ambiguous which thing that is, ask rather than guess.

Goal: make the target genuinely understood by someone with no prior background — not simplified to the point of being wrong, not jargon relabeled, and not longer than the actual dependency chain requires. Every new idea is built entirely out of ideas already established earlier in the explanation, or true common knowledge — never introduced by assuming familiarity.

This command is the **command-form embodiment of the Teaching Standard's TS-1** (see `Teaching-Standard.md`) — the same "derive everything, no undefined jargon, scaled to the real dependency chain" bar that governs teaching in every other command. When the target is code, also cite it by `repo/path` (TS-2); keep the step-8 confirming question plain, never cryptic (TS-4).

## Process (your reasoning steps — not a template to reproduce in the output)

1. **Identify the terminal concept.** One sentence: what needs to be understood? If the target is a decision or tradeoff (e.g. "why Postgres over Mongo") rather than a term, the terminal concept is the reasoning chain, not a definition.
2. **Decompose into a prerequisite chain**, working backward until you hit ideas an ordinary adult already has — that's the floor. Note how deep the chain actually is (e.g. "what's a webhook" is one real link; "why is checkout idempotency hard" is several).
3. **Scale to that depth.** A shallow chain gets a compact, direct answer — a couple sentences, no ceremony. Only a genuinely multi-layered concept gets the full build-up in steps 4-5.
4. **Build forward, one link at a time**, using only common knowledge or concepts already established earlier in this same response. Make the callback explicit ("Now that you know X, Y is just X but...").
5. **Use analogies deliberately, not decoratively** — only when they clarify a real relationship, and flag where they break down.
6. **Flag precision-critical targets.** If it's security, legal, financial, medical, or compliance-adjacent — anywhere a confidently-wrong simplification could be acted on — say so explicitly, note what's necessarily simplified or omitted, and point back to the authoritative source.
7. **Self-check before delivering.** Re-scan once for any term used before it was defined; fix any you find.
8. **Land it**, scaled the same way as step 3: a compact answer just ends — don't tack on a quiz question it doesn't need. A full build-up closes with "So [terminal concept] = [what was built]," plus one question the reader can answer to confirm it landed.

## Output
Deliver as natural prose (or natural code/comments, if the target is code) — the steps above are how you get there, not labels to show your work with, unless the user explicitly asks to see the breakdown.

## Constraints
- No jargon without an immediate, built-from-scratch definition — including terms a domain expert would consider basic.
- No skipped links — if you're relying on something not yet established, back up and add it.
- Depth matches the real dependency chain, not a fixed template.
