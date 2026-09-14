---
name: proof-duel
version: 2 — 2026-09-14 (bump on every edit; a mirror whose version differs from the repo copy is stale)
description: >
  Compete independent writer/hater pairs on one problem until each pair lands a proposal plus
  a proof that it solves the problem best; one blinded final judge scores the sealed artifacts
  against a predeclared rubric. Default cast also assigns per-pair lens SKUs (exploration
  emphasis) from a sealed catalog — `--lenses off` restores model-roster-only diversity.
  Protocol owns pair count (default 3); the orchestrator does not invent N mid-run. Use when
  you need the strongest fix proposal under adversarial pressure, not a single agent's first idea.

  Trigger on: "/proof-duel", "proof duel", "duel this problem", "compete proposals", "writer vs
  hater", "independent pairs then judge", "lens cast", "proof duel lenses".
argument-hint: ["N"] <problem or fix target> [--pairs N] [--rounds R] [--solo] [--lenses on|off] [--slots 1|2] [--axis-mode no-optimand|full] [--secondary-mode stakeholder|full] [--deck full|core] [--exclude id,id]
---

# Proof Duel

**Lens assets** (resolve beside this protocol, or `$CONFIG_DIR/proof-duel/` after command install):
`lens-catalog.md`, `lens-cast.md`, `cast-lenses.sh`.
You are the **orchestrator** of a sealed competition. The question you answer: **which proposal
best solves this problem, after adversarial pressure inside independent pairs?**

You do not write a winning proposal yourself. You seal the brief, spawn independent pairs, collect
their final artifacts, then hand a blinded packet to one judge. Two failures are equally bad:
rubber-stamping the first clever write-up, and letting pairs cross-contaminate so "independence"
is theater.

**Cost profile:** default 3 pairs × (writer + hater, up to `--rounds` revise cycles) + 1 judge.
That is the price of contested selection — do not silently drop a pair or skip the hater to save
tokens. If the budget is unacceptable, stop and ask before starting.

**Layman-terms rule (every user decision point):** stop-and-ask moments (missing problem, invalid
flags, budget refusal) go through the `layman-terms` skill when available; otherwise apply its
standard: one-read plain language, jargon defined or replaced, no substance dropped.

**Lane:** this owns **problem → competing fix proposals → judged winner**. Plan/doc hardening
without a competition → `/adversarial-review`. Runtime breakage of a concrete artifact →
`/app-breaker`. Blast radius of an already-chosen change → `/code-pi`. Minimality of an
already-chosen plan → `/ponytail`.

---

## 1. Parse arguments

`$ARGUMENTS` is: `["N"] <problem...> [flags]`.

| Token / flag | Default | Meaning |
|---|---|---|
| leading integer `N`, or `--pairs N` | `3` | Number of independent pairs. Protocol default; user override only. |
| problem text (remainder) | required | The problem / fix target. If empty, infer the most recent substantive problem in the conversation and **state which you picked**. Ambiguity → ask, don't guess. |
| `--rounds R` | `2` | Max writer↔hater revise cycles per pair after the opening draft (integer ≥ 1). |
| `--solo` | off | Forbid real parallel sub-agents; run pairs sequentially in one mind and **log reduced independence**. |
| `--lenses on\|off` | `on` | Per-pair lens SKUs via `lens-cast.md`. `off` = model-roster only. |
| `--slots 1\|2` | `2` | Primary only or primary+secondary. |
| `--axis-mode no-optimand\|full` | `no-optimand` | Primary axes {2,4}; `full` adds Axis 3. |
| `--secondary-mode stakeholder\|full` | `stakeholder` | Secondary {5}; `full` adds Axis 6. |
| `--deck full\|core` | `full` | Catalog subset. |
| `--exclude id,id` | empty | Hard-exclude ids (must still satisfy rule-1 at seal; passed into `cast-lenses.sh`). |

**Who decides N:** the protocol (`3`) or an explicit user override. The orchestrator never
chooses N from vibes, stakes, or "how hard this feels." Reject non-integer / `< 1` / `> 5` for N
or R, and reject invalid lens knobs — stop and report rather than clamping silently. Cap at 5
keeps cost bounded; if the user wants more, ask them to confirm the spend. Full lens table:
`lens-cast.md`.

Unknown flags → stop and report.

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
- **Shared diagnosis lens:** <axis-1-id>   # optional; default root-cause when lenses on
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

State in one line: `N=<n> rounds=<r> parallel=<yes|solo> rubric=locked` then, after lens cast
(when lenses on), amend with `lenses=… slots=… seed=… catalog=… axis_mode=… secondary_mode=…`.

---

## 3. Cast the pairs (anti-bias roster)

Spawn **N independent pairs**. Each pair has exactly two roles:

| Role | Mandate |
|---|---|
| **Writer** | Restate the problem, propose a fix, and write a proof that this proposal solves it best under the rubric. |
| **Ethical Hater** | Attack diagnosis, proposal, and proof. Find flaws, hidden costs, false "best" claims, missing constraints. Ethical = kill weak reasoning, not sneer. **May not author a competing proposal.** |

**Lens cast (default `--lenses on`):** before any pair starts, follow `lens-cast.md` end-to-end
(prefer `cast-lenses.sh --catalog lens-catalog.md --n N …` with matching flags). Lenses are
exploration emphasis only; sealed rubric + tie-break remain the only scoring order.
`--lenses off` skips this block and logs `lenses: off`.

**Model assignment (when the harness supports choosing models):**
1. Prefer distinct model families across pairs when a pool is available (e.g. pstack / arena
   runners). Same-family clones across all pairs are allowed only if the pool is too small —
   log `diversity: degraded`.
2. Within a pair, Writer and Hater should be **different models** when two are available.
3. Assign by a fixed roster order (pool list order, cycling), or one shuffle at cast time.
   Do not assign "who seems good for this problem."
4. The **Judge** must not be a Writer or Hater model used in this run when another model is
   available; otherwise log `judge: pool-exhausted, independence reduced`.
5. Model roster and lens draw are **independent** — do not couple model family to lens id.

**If the Agent / Task tool is unavailable:** degrade to sequential single-mind role-play, label
every section `independence: reduced`, and still keep pair outputs sealed from each other in
the write-up (no cross-references while drafting). Still assign SKUs when lenses on.

Label pairs `A`, `B`, `C`, … only in orchestrator-private notes. Pairs never see other pairs'
labels, models, drafts, or SKUs.

---

## 4. Run each duel (pairs sealed)

Run all pairs **in parallel** unless `--solo`. Each pair receives **only**: the Problem Brief,
the Judge Rubric, `--rounds R`, its role prompts, and (when lenses on) its Pair Lens block from
`lens-cast.md` (no SKU string in the prompt). No other pair's output. No judge hints.

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
4. Strip model names, pair ids, SKUs, lens ids, and any "we are pair B" leakage. Artifact SKU
   leakage = regex `pd-[0-9a-f]{4}-[a-z0-9-]+(\+[a-z0-9-]+)?` only — one re-request then
   DISQUALIFY that pair; continue with remaining candidates.

Judge mandate:

- Score each candidate on every rubric row (use 1–5 integers; state one-line evidence per row).
- Pick a **Winner** by total then tie-break.
- Optionally name a **Runner-up**.
- May declare **NO WINNER** only if every candidate fails Correctness or Diagnosis at a blocking
  level — then state what a viable proposal would still need.
- Must not rewrite proposals or merge them into a new hybrid "winner." Synthesis is a different
  command; this command selects.

Prefer the Judge as a **fresh sub-agent** with only the packet. Orchestrator-as-judge is a last
resort under `--solo` or tool failure — log `judge: orchestrator-fallback`.

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
- **Independence notes:** N, models/diversity, parallel vs solo, judge blinding; when lenses on
  also seed, catalog_version, axis_mode, secondary_mode, deck, Pair→SKU map, excluded,
  collisions/degrades, `blinding: label-only` (see `lens-cast.md`)

## Winning artifact
<paste winner's artifact verbatim>

## Other candidates (short)
- Candidate <k>: one-line summary + total score
```

Do **not** implement the winning proposal unless the user explicitly asks after the verdict.
The deliverable of this command is the judged selection, not the patch.

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
- **Lenses emphasize, rubric scores** — brief + sealed rubric outrank lenses; hater is general
  first, lens second; soft lens-ignore is a nit only.
