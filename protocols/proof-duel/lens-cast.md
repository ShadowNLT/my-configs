# Proof Duel — Lens Cast

Version: 1 — 2026-09-14

Procedure for casting per-pair lens SKUs during Proof Duel. Invoked from `SKILL.md` /
`command.md` when `lenses=on` (default). Catalog SoT: `lens-catalog.md`. Draw script:
`cast-lenses.sh`.

**Asset resolution:** protocol folder containing this file, or command sidecar
`$CONFIG_DIR/proof-duel/` after install. Never hardcode a harness home path.

**Honesty bound:** soft additive lenses diversify exploration emphasis; they do **not**
guarantee escape from same-family convergence. Model-roster diversity remains load-bearing.

---

## Knobs

| Param | Default | Meaning |
|---|---|---|
| `lenses` | `on` | Master switch. `off` = legacy model-roster cast only. |
| `lens_slots` / `slots` | `2` | `1` = primary only; `2` = primary + secondary. |
| `shared_diagnosis` | `on` | Diagnosis = `root-cause` unless Brief has `- **Shared diagnosis lens:** <axis-1-id>`. `off` → reject and ask. |
| `primary_unique` | `on` | Primaries without replacement until pool exhausted. |
| `axis_mode` / `primary_axis_mode` | `no-optimand` | Primary from axes **{2,4}**. `full` adds Axis 3 (log `scoring: optimand-lens-risk`). |
| `secondary_mode` | `stakeholder` | Secondary from axis **{5}**. `full` adds Axis 6 (log `scoring: proof-standard-lens-risk`). |
| `deck` | `full` | `full` or `core` (core-24 in catalog). |
| `sku_in_artifact` | `off` | Never put SKU/lenses in pair final artifact. |
| `catalog_version` | from catalog | Pin in header + cast table. |

Invalid knobs → reject and ask. Do not clamp silently.

---

## Cast pipeline (before any pair starts)

### 1. Seal brief + rubric (Proof Duel §2)
Unchanged. Optional Brief line: `- **Shared diagnosis lens:** <axis-1-id>`.

Emit locked header after seal; **amend** with seed/cast knobs after this cast completes:

```text
N=<n> rounds=<r> parallel=<yes|solo> rubric=locked lenses=<on|off> slots=<1|2> seed=<hex> catalog=<ver> axis_mode=<no-optimand|full> secondary_mode=<stakeholder|full>
```

### 2. Build Allowed / Legal

Start from `deck` selection in `lens-catalog.md`.

**Hard exclude** a lens only if a sealed Constraints or Out-of-scope line explicitly forbids
it via whole-word `domain_tags` match or literal lens id. Log:
`excluded: <id> :: 1 :: "<brief quote>"`.

**Advisory only** (keep in Allowed): `advisory-skip-candidate: <id> :: "no evidence of <surface>"`.

**Forbidden:** ad-hoc lenses, reweighting, excluding to steer winners.

Primary pool = Allowed ∩ axes per `axis_mode`.  
Secondary pool = Allowed ∩ axes per `secondary_mode`.

**Legal** = pool minus ids that fail the same hard-exclude predicate (Constraints/OOS only).
If `PrimaryLegal` empty → stop and ask.  
If `lens_slots=2` and `SecondaryLegal` empty → stop and ask (no auto-degrade).  
If `|PrimaryLegal| < N` and `primary_unique=on` → log `diversity: unique-impossible`.

### 3. Draw (prefer `cast-lenses.sh`; in-process OK if bit-identical)

`SEED` = 8 ASCII hex chars. Replay uses full SEED (SKU `seed4` is display-only).

Normative algorithm: see `cast-lenses.sh` header comment / script body — HMAC-SHA256,
ASCII hex key, U32_BE, without-replacement primary shuffle, set-minus bans before secondary
draw, no discarded synonym attempts.

Synonym bans: catalog table. If `SecondaryLegal \ banned(primary)` empty → drop secondary for
that pair, SKU without `+`, log `degrade: slots-1-synonym-exhausted`.

SKU: `pd-<seed4>-<primary>[+<secondary>]`.

Models: existing Proof Duel roster rules, **independent** of lens draw.

### 4. Bind (Proof Duel §4)

Each pair receives Brief, Rubric, R, role prompts, **and** its Pair Lens block (no SKU string
in the prompt — SKU stays orchestrator-private):

```markdown
## Pair Lens (do not put SKU or a lens-id label block in the Artifact)
- **Primary:** `<id>` — <one-line lean from catalog>
- **Secondary:** `<id>` — <one-line>   # omit if slots-1 / synonym-exhausted
- **Shared diagnosis:** `<id>`
- **Precedence:** Brief Constraints, Out of scope, and Success looks like — plus the Judge
  Rubric / predeclared tie-break — outrank this lens. Emphasis only; does not redefine scoring.

### Writer mandate (additive)
Pursue with this lens as emphasis. Satisfy every rubric row. If the lens fights the Brief,
obey the Brief and state that in Assumptions.

### Hater mandate (additive)
**First** attack diagnosis, proposal, and proof generally. **Then** lens kill-shots.
May not author a competing proposal. Soft lens-ignore → **nit** only (`lens: soft-noncompliance`);
must not be `block`/`serious` by itself.
```

### 5. Judge strip (Proof Duel §5)

Strip pair labels, model names, SKUs, lens ids, process diary.  
Leakage in Artifact = SKU regex `pd-[0-9a-f]{4}-[a-z0-9-]+(\+[a-z0-9-]+)?` only — not bare
catalog vocabulary. One re-request; else DISQUALIFY that pair; continue with K−1.  
Log `blinding: label-only`.

### 6. Verdict Independence notes (add when lenses on)

```text
- seed: <8 hex>
- catalog_version: <ver>
- axis_mode / secondary_mode / deck
- lenses: Pair A → <SKU> (...); ...
- excluded: ... | none
- collisions / degrades
- blinding: label-only
```

Plus live fields: N, models/diversity, parallel vs solo, judge blinding.

---

## Degradation matrix

| Situation | Behavior | Log |
|---|---|---|
| Task unavailable | solo; still assign SKUs | `independence: reduced` |
| `\|PrimaryLegal\| < N` unique on | preflight; collisions after exhaustion | `unique-impossible` / `primary-collision` |
| Secondary size 1 | may share | `secondary-degenerate` |
| SecondaryLegal empty + slots=2 | stop and ask | (no run) |
| PrimaryLegal empty | stop and ask | (no run) |
| `lenses=off` | legacy cast | `lenses: off` |
| SKU in artifact | re-request / DISQUALIFY; continue | malformed path |
| Soft ignore lens | nit only | `lens: soft-noncompliance` |
| Synonym pool empty | drop secondary | `degrade: slots-1-synonym-exhausted` |

---

## Non-goals

Opaque tokens without catalog mapping; per-pair secret facts; freestyle personas; hybrid
winners; model↔lens coupling; claiming lenses alone fix same-family convergence.
