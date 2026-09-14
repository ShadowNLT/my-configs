---
version: 1 — 2026-09-14 (bump on every edit; a mirror whose version differs from the repo copy is stale)
description: >
  Rewrite technical/instructional prose into Simplified Technical English style
  (ASD-STE100 Issue 9 principles): short sentences, one meaning per word, active
  voice, condition-before-action when it gates. Never claims ASD dictionary
  compliance. Pragmatic by default; Strict only on explicit Strict/compliance cues.
argument-hint: "[mode=pragmatic|strict] [text to rewrite, or blank for most recent prose]"
---

# Simplified English

Version: 1 — 2026-09-14

Rewrite the target into Simplified Technical English style so a tired or
non-native **technical operator** cannot easily misread it. This is a **clarity
rewrite, not a summary**. Paraphrase reference: **ASD-STE100 Issue 9 (January
2025)** — principles and a structural subset only. This protocol does **not**
ship ASD’s official dictionary and **never** claims dictionary compliance
(Pragmatic or Strict).

Not `layman-terms`: that protocol is for jargon/density aimed at a lay
non-specialist. This one is for ambiguity/misparse in technical instruction.
If the ask is dual-cued, **ask** which protocol (do not auto-run both).

## Target and mode

Target: `$ARGUMENTS` — strip a leading `mode=pragmatic`, `mode=strict`,
`--strict`, or `strict` token for mode; the remainder is the text. If the text
part is empty, use the most recent prose in the conversation (ask if ambiguous).

**Mode (default `pragmatic`):**

| Mode | When | Output |
|------|------|--------|
| **Pragmatic** | Default. Also when the user named STE / ASD-STE100 / Simplified Technical English **without** a Strict cue | Rewrite only |
| **Strict** | Clear Strict cues only: `strict mode`, `STE strict`, `simplified-english strict`, `mode=strict`, `--strict`, `/simplified-english strict`, `STE compliance`, `ASD-STE100 compliance`, `dictionary-compliant STE`, `official STE compliance`, `certify as STE`, `certify as ASD-STE100`. Bare `compliance`, bare `dictionary`, or bare `official STE` alone do **not** count | Rewrite + mandatory footer below |

Invalid `mode=` → reject and ask; do not coerce. STE brand alone never escalates to Strict.

**Default audience:** a competent technical operator or maintainer reading
instructions (may be non-native). Domain nouns may stay under W6 relative to
this audience.

## Structural rules

### Words

| # | Rule |
|---|------|
| W1 | Use the shortest common word that keeps the meaning. |
| W2 | One meaning per word in this rewrite — do not use a word in a second sense. |
| W3 | Do not use a synonym for variety when the same action/thing already has a word in the text. |
| W4 | Prefer concrete verbs over noun stacks (“configure the service” not “perform a configuration of the service”). |
| W5 | Avoid filler and hedges that add no condition: “basically”, “simply”, “just”, “it is important to note that”, “in order to” → “to”. |
| W6 | Keep unavoidable technical nouns/verbs. Define on first use **only when** this default audience might not know the term (opaque acronym, rare jargon); otherwise leave it bare. Inline definition is exempt scaffolding — but if a specific detail the source never gave would be needed to complete it, leave the term undefined (do **not** use T5 for a missing gloss). |

### Sentences

| # | Rule |
|---|------|
| S1 | Procedural / imperative: aim ≤ 20 words. Descriptive: aim ≤ 25. Split if over, **unless** one extra word keeps a mandatory technical term (soft aim, not a hard reject). |
| S2 | One instruction or one main idea per sentence (unless two actions must be simultaneous — then say that explicitly). |
| S3 | Instructions in the imperative: “Run the migration.” |
| S4 | When a condition **gates** the action, put the condition before the command: “If X, do Y.” Do not reorder informational or optional trailing clauses. |
| S5 | Prefer active voice and a named subject. |
| S6 | Prefer simple present / simple past / imperative. Avoid nested conditionals in one sentence. |

### Structure and safety

| # | Rule |
|---|------|
| T1 | Preserve headings, lists, warnings, code fences, and citations. Rewrite prose only. |
| T2 | Do not rewrite inside direct quotations, or terms that are themselves the subject under discussion. |
| T3 | Do not invent facts, examples, reasons, or **procedural steps** absent from the source. Do not drop steps, warnings, or cautions to sound cleaner. |
| T4 | Do not soften mandatory language. Do not **strengthen** modality (`should` / `may` / `can` → `must`) unless the source already uses must/shall/required (or equivalent). |
| T5 | Unsupported claims: keep and tag `[unsupported in source]` inline. |
| T6 | Do not turn a state description into a command unless the source is already instructing that action. |

### Out of theater

- Match register within STE constraints — do not aerospace-costume casual chat.
- Do not strip personality from creative writing unless the user asked for a technical rewrite.
- Do not apply STE rules inside code, data tables, or diagrams.

## Contract

1. **Rewrite, don’t summarize** — word limits force splits, not cuts of substance.
2. **Apply the rules above** for the selected mode.
3. **Self-check once** before return:
   - any sentence over budget without a mandatory-term carve-out?
   - any synonym rotation for the same action?
   - any passive where active is clearer?
   - any gating condition after its command?
   - any claim, step, or modality not grounded in the source (including should→must or state→command)?
   - any body text claiming ASD certification / dictionary compliance?
   - (Strict only) footer present after in-text disambiguation attempt?
4. **Output**
   - **All modes:** the rewrite body must **never** say the text is ASD-certified, dictionary-compliant, official STE, or equivalent.
   - **Pragmatic:** only the rewrite — no preamble, no commentary, no footer.
   - **Strict:** the rewrite, then exactly:

```text
---
STE notes: Not ASD dictionary-certified. Check the official dictionary (ASD-STE100 Issue 9 or newer): https://www.asd-ste100.org/
Ambiguous words: <word; word> | (none)
```

**Ambiguous-words membership:** list a word only if it appears in the rewrite
**and** still has two plausible senses in context (W2 risk). Prefer fixing
dual meaning in the rewrite first. Cap at 8; otherwise `(none)`. Do not invent
ASD disallow-lists.

Optional annotated pass (user must ask; separate from Strict): prefix violating
sentences with `[Wn|Sn|Tn]` before rewriting that sentence.

## Worked micro-example

**Source**

> In order to ensure that the deployment is successful, the configuration should
> be verified by the operator prior to initiating the rollout, and if any issues
> are identified they must be resolved accordingly.

**Pragmatic rewrite**

> Before the operator starts the rollout, the operator should check the
> configuration.
> If the operator finds a problem, the operator must fix the problem.

## Scope

**In:** technical docs, READMEs, runbooks, procedures, errors, release notes,
agent instructions, STE/ASD-STE100 asks.

**Out:** marketing that must stay branded; creative fiction as primary genre;
claiming ASD dictionary certification in any mode (including Strict + user PDF);
replacing `layman-terms` for “explain to a layperson”; translation.

## vs `layman-terms`

- Dual cues in one ask → **ask** which protocol (do not auto-run both).
- Both only after the user confirms both **and** which audience wins for domain
  nouns. Default order then: `layman-terms` first, then this protocol. User order
  overrides.
- Bare spoken “simplified English” (no Technical/STE/ASD, not the hyphenated id)
  → **ask** — do not silently send to `layman-terms`.
