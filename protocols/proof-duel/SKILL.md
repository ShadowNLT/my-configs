---
name: proof-duel
description: >
  Compete independent writer/hater pairs on one problem until each pair lands a proposal plus
  a proof that it solves the problem best; one blinded final judge scores the sealed artifacts
  against a predeclared rubric. Protocol owns pair count (default 3); the orchestrator does not
  invent N mid-run. Use when you need the strongest fix proposal under adversarial pressure, not
  a single agent's first idea.
  Trigger on: "/proof-duel", "proof duel", "duel this problem", "compete proposals", "writer vs
  hater", "independent pairs then judge".
---

# Proof Duel

Version: 1 — 2026-09-10 (bump on every edit; a mirror whose version differs from the repo copy is stale)

You are the **orchestrator** of a sealed competition. The question you answer: **which proposal
best solves this problem, after adversarial pressure inside independent pairs?**

You do not write a winning proposal yourself. You seal the brief, spawn independent pairs, collect
their final artifacts, then hand a blinded packet to one judge. Two failures are equally bad:
rubber-stamping the first clever write-up, and letting pairs cross-contaminate so "independence"
is theater.

**Cost profile:** default 3 pairs × (writer + hater, up to the stated revise cycles) + 1 judge.
That is the price of contested selection — do not silently drop a pair or skip the hater to save
tokens. If the budget is unacceptable, stop and ask before starting.

**Layman-terms rule (every user decision point):** stop-and-ask moments (missing problem, invalid
parameters, budget refusal) go through the `layman-terms` skill when available; otherwise apply
its standard: one-read plain language, jargon defined or replaced, no substance dropped.

**Lane:** this owns **problem → competing fix proposals → judged winner**. Plan/doc hardening
without a competition → `/adversarial-review`. Runtime breakage of a concrete artifact →
`/app-breaker`. Blast radius of an already-chosen change → `/code-pi`. Minimality of an
already-chosen plan → `/ponytail`.

---

## 1. Infer target and parameters

There is no argument string to parse. Infer from the conversation:

| Parameter | Default | Meaning |
|---|---|---|
| `pairs` (N) | `3` | Number of independent pairs. Protocol default; user may state an override. |
| problem | required | The problem / fix target. Prefer the most recent substantive problem the user is deciding on. **State which you picked.** Ambiguity → ask, don't guess. |
| `rounds` (R) | `2` | Max writer↔hater revise cycles per pair after the opening draft (integer ≥ 1). |
| `solo` | off | Forbid real parallel sub-agents; run pairs sequentially in one mind and **log reduced independence**. |

**Who decides N:** the protocol (`3`) or an explicit user override. The orchestrator never
chooses N from vibes, stakes, or "how hard this feels." Reject invalid N or R rather than
guessing. Cap N at 5; if the user wants more, ask them to confirm the spend.

---

## 2. Seal the brief (before any pair runs)

Write a **Problem Brief** once. Every pair and the judge get this exact text — no later
enrichment for one pair only.

```markdown
## Problem Brief
- **Problem:** <one crisp statement>
- **Constraints:** <hard limits, non-negotiables>
- **Out of scope:** <explicit>
- **Success looks like:** <checkable outcomes>
- **Context refs:** <paths / facts every pair may use — same list for all>
```

If the problem is too vague to fill this, ask targeted questions first. Do not start pairs on a
fuzzy brief.

Then lock the **Judge Rubric** (immutable for this run — publish it in the run header before
pairs start):

| Criterion | What the judge scores |
|---|---|
| **Diagnosis** | Did they name the real problem (not a symptom stand-in)? |
| **Correctness** | Would the proposal actually solve it under the stated constraints? |
| **Completeness** | Material failure modes / edge cases addressed, or honestly deferred? |
| **Blast radius** | How much else moves; smaller preferred when correctness ties. |
| **Proof quality** | Is the "why best" argument falsifiable and specific, not vibes? |
| **Objection handling** | Did surviving objections get real answers (or honest residuals)? |

**Predeclared tie-break (in order):** (1) higher rubric total → (2) smaller blast radius →
(3) clearer falsifiable proof → (4) fewer unanswered residuals. Never "I like this voice."

State in one line: `N=<n> rounds=<r> parallel=<yes|solo> rubric=locked` and proceed.

---

## 3. Cast the pairs (anti-bias roster)

Spawn **N independent pairs**. Each pair has exactly two roles:

| Role | Mandate |
|---|---|
| **Writer** | Restate the problem, propose a fix, and write a proof that this proposal solves it best under the rubric. |
| **Ethical Hater** | Attack diagnosis, proposal, and proof. Find flaws, hidden costs, false "best" claims, missing constraints. Ethical = kill weak reasoning, not sneer. **May not author a competing proposal.** |

**Model assignment (when the harness supports choosing models):**
1. Prefer distinct model families across pairs when a pool is available (e.g. pstack / arena
   runners). Same-family clones across all pairs are allowed only if the pool is too small —
   log `diversity: degraded`.
2. Within a pair, Writer and Hater should be **different models** when two are available.
3. Assign by a fixed roster order (pool list order, cycling), or one shuffle at cast time.
   Do not assign "who seems good for this problem."
4. The **Judge** must not be a Writer or Hater model used in this run when another model is
   available; otherwise log `judge: pool-exhausted, independence reduced`.

**If the Agent / Task tool is unavailable:** degrade to sequential single-mind role-play, label
every section `independence: reduced`, and still keep pair outputs sealed from each other in
the write-up (no cross-references while drafting).

Label pairs `A`, `B`, `C`, … only in orchestrator-private notes. Pairs never see other pairs'
labels, models, or drafts.

---

## 4. Run each duel (pairs sealed)

Run all pairs **in parallel** unless the user asked for solo. Each pair receives **only**: the
Problem Brief, the Judge Rubric, the revise-cycle limit, and its role prompts. No other pair's
output. No judge hints.

### 4.1 Opening (Writer)
Writer produces the draft artifact sections: Diagnosis, Proposal, Proof, Assumptions.

### 4.2 Attack (Hater)
Hater returns a numbered objection list. Each objection needs: **claim**, **why it matters**,
**severity** (`block` | `serious` | `nit`). Nits may be listed; they do not force a rewrite alone.
Empty attack with "looks fine" is a failure — the hater must try; if nothing real lands, they
say what they attacked and why it held.

### 4.3 Revise (Writer), up to `R` cycles
Writer may change the proposal **only** to answer named objections. Each revise cycle:
- map each `block`/`serious` objection → addressed / partially addressed / rejected-with-reason
- update Proposal + Proof
- Hater re-attacks the **diff** (what changed + whether old objections still hold)

Stop early for a pair when the Hater returns zero `block`/`serious` survivors, or when `R` is
hit. Unresolved `block`/`serious` items become **Residuals** in the final artifact (not silently
dropped).

### 4.4 Pair final artifact (exact shape — required)

Every pair emits **only** this shape (no model names, no pair ids, no process diary):

```markdown
## Artifact
### Diagnosis
<what the real problem is>

### Proposal
<the fix — concrete enough to act on>

### Proof
<why this solves it best under the rubric; falsifiable where possible>

### Objections answered
- <objection> → <how addressed or why rejected>

### Residuals
- <unresolved block/serious items, or "none">

### Assumptions
- <load-bearing assumptions>
```

Orchestrator validates shape before the artifact enters the judge packet. Malformed → one
re-request to that pair; still bad → that pair is `DISQUALIFIED` and excluded from judging
(state that in the run summary). Do not repair their substance yourself.

---

## 5. Blind judge

Build a judge packet:

1. Problem Brief (verbatim)
2. Judge Rubric + tie-break rules (verbatim)
3. Artifacts labeled **Candidate 1..K** in **randomized order** (not A/B/C order). Keep a
   private map Candidate→pair; the judge never sees it.
4. Strip model names, pair ids, and any "we are pair B" leakage.

Judge mandate:

- Score each candidate on every rubric row (use 1–5 integers; state one-line evidence per row).
- Pick a **Winner** by total then tie-break.
- Optionally name a **Runner-up**.
- May declare **NO WINNER** only if every candidate fails Correctness or Diagnosis at a blocking
  level — then state what a viable proposal would still need.
- Must not rewrite proposals or merge them into a new hybrid "winner." Synthesis is a different
  command; this command selects.

Prefer the Judge as a **fresh sub-agent** with only the packet. Orchestrator-as-judge is a last
resort under solo mode or tool failure — log `judge: orchestrator-fallback`.

---

## 6. Present the verdict

Return to the user:

```markdown
## Proof Duel — Verdict
- **Winner:** Candidate <k> (Pair <id>) — one-line why
- **Runner-up:** … or none
- **Scores:** table of candidates × rubric rows + totals
- **Tie-break used:** <none | which rule>
- **Residuals on winner:** …
- **Disqualified:** … or none
- **Independence notes:** N, models/diversity, parallel vs solo, judge blinding

## Winning artifact
<paste winner's artifact verbatim>

## Other candidates (short)
- Candidate <k>: one-line summary + total score
```

Do **not** implement the winning proposal unless the user explicitly asks after the verdict.
The deliverable of this skill is the judged selection, not the patch.

---

## 7. Behaviour notes

- **Protocol owns N** — default 3; user override only; never mid-run invention.
- **Sealed pairs** — no cross-talk, no shared discoveries, identical brief.
- **Hater does not write the fix** — attack only.
- **Rubric before combat** — immutable for the run.
- **Blind judge** — randomized candidate order; no model/pair labels.
- **No hybrid winner** — select, don't Frankenstein.
- **Auditable, not vibes** — roster, scores, residuals, and independence degradations must be
  visible in the verdict.
- **Be terse** — tables and bullets; a pair with nothing left to fight gets a short close, not
  padding.
