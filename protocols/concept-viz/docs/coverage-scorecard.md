# Coverage scorecard

Post-change verification for visual-form coverage. Counts are live against `catalog/general.json`, `catalog/diagram_modules.json`, and `seeds/`.

**Structure types: 20 / 20 COVERED**  
**Knowledge areas: 9 / 9 COVERED**

Protocol locks unchanged: local HTML serve, beat atomicity, closed-world retrieval, evidence/catalog-driven selection, assumption graph only on split, stoppable server. No lieflat assets or names.

`header-triptych` remains registered for header anatomy beats only. It is not a magnitude encoding.

---

## Structure-type taxonomy (20)

Every row is COVERED: a dedicated `diagram_module`, a matching HTML fragment under `skeletons/modules/`, and a catalog archetype bound to that module.

| Form | Status | Module | Archetype | Baseline |
|------|--------|--------|-----------|----------|
| nested-containment | COVERED | nested-layers | nested-layers | COVERED |
| node-link-tree | COVERED | node-link-tree | node-link-tree | COVERED |
| node-link-graph | COVERED | node-link-graph | node-link-graph | MISSING |
| flow-sequence | COVERED | flow-sequence | flow-sequence | COVERED |
| cycle-return | COVERED | cycle-return | cycle-loop | THIN (wired to flow-sequence) |
| state-machine | COVERED | state-machine | state-steps | COVERED |
| indexed-tape | COVERED | cell-tape | pipeline-stages | COVERED |
| stack-frames | COVERED | stack-frames | stack-frames | MISSING |
| side-by-side | COVERED | side-by-side-frames | side-by-side | COVERED |
| before-after | COVERED | before-after-panels | before-after | COVERED |
| matrix-grid | COVERED | matrix-grid | shared-grid | THIN (wired to side-by-side-frames) |
| common-scale-bars | COVERED | common-scale-bars | magnitude-scale | THIN (wired to header-triptych) |
| part-whole-bars | COVERED | part-whole-bars | part-of-whole-share | THIN (wired to nested-layers) |
| bound-region | COVERED | bound-region | bound-region | COVERED |
| overflow-spill | COVERED | overflow-spill | overflow-spill | COVERED |
| analogy-map | COVERED | analogy-map | analog-carry | THIN (wired to side-by-side-frames) |
| number-line | COVERED | number-line | number-line | MISSING |
| timeline | COVERED | timeline | timeline | MISSING |
| free-body | COVERED | free-body | free-body | MISSING |
| coordinate-figure | COVERED | coordinate-figure | coordinate-figure | MISSING |

Former THIN → COVERED: cycle-return, matrix-grid, common-scale-bars, part-whole-bars, analogy-map.  
Former MISSING → COVERED: node-link-graph, stack-frames, number-line, timeline, free-body, coordinate-figure, plus the seven MISSING taxonomy rows above.

Tree ≠ graph: `node-link-tree` stays rooted; `node-link-graph` carries a shared child and a cross edge.  
Stack ≠ tape: `stack-frames` is LIFO geometry; `cell-tape` stays an index row.

---

## Knowledge-area scorecard (9)

Every area is COVERED. Unlocking modules exist and are bound. Seeds prefer those modules.

| Area id | Title | Status | Seed | Unlocking modules |
|---------|-------|--------|------|-------------------|
| cs-software | Computer science / software | COVERED | cs-se | stack-frames, node-link-tree, nested-layers, state-machine, flow-sequence |
| discrete-math | Discrete mathematics | COVERED | discrete-cs-math | node-link-graph, matrix-grid, bound-region |
| systems-infra | Systems and infrastructure | COVERED | systems-infra | cell-tape, overflow-spill, cycle-return, common-scale-bars |
| spatial-geometry | Spatial geometry | COVERED | spatial-geometry | coordinate-figure, number-line, matrix-grid |
| quantitative-stats | Quantitative statistics | COVERED | quantitative-stats | common-scale-bars, distribution-strip, part-whole-bars |
| social-narrative | Social narrative | COVERED | social-narrative | timeline, flow-sequence, analogy-map |
| physics-mechanics | Physics / mechanics | COVERED | natural-science | free-body, before-after-panels, state-machine |
| bio-chem-mechanism | Biology / chemistry mechanism | COVERED | natural-science | pathway-map, flow-sequence, before-after-panels |
| formal-proof | Formal proof / justification | COVERED | discrete-cs-math | proof-steps, bound-region |

Baseline was COVERED 3 · PARTIAL 4 · GAP 2. Extra unlock modules (not in the 20-form table, required for area coverage): `distribution-strip`, `pathway-map`, `proof-steps`.

Interference notes enforced on the original three seeds: `graph versus tree` (discrete-cs-math), `stack versus tape` (cs-se and systems-infra).

---

## Verification

Run:

```text
python -m unittest tests.test_coverage tests.test_diagram_modules tests.test_catalog -v
```

`tests/test_coverage.py` checks:

1. All 20 taxonomy forms bind archetype → module → HTML fragment.
2. Forbidden wires are absent (`magnitude-scale` ↛ `header-triptych`, `shared-grid` ↛ `side-by-side-frames`, `cycle-loop` ↛ `flow-sequence`, `analog-carry` ↛ `side-by-side-frames`, `part-of-whole-share` ↛ `nested-layers`, `node-link-graph` ↛ `node-link-tree`, `stack-frames` ↛ `cell-tape`).
3. All 9 knowledge areas have a seed whose preferred archetypes include every unlocking module.
4. Each of the 14 new modules has a sample series-plan binding under `tests/fixtures/bindings/`.
5. This file reports 20 / 20 COVERED and 9 / 9 COVERED.

Sample contracts: `tests/fixtures/bindings/<module-id>.json`. Taxonomy source: `tests/fixtures/coverage/taxonomy.json`.
