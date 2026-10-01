# Teach one code concept as a knowledge-graph curriculum

Audience: a technical operator who runs this process.
Mode: Simplified Technical English (pragmatic). This text is not ASD dictionary-certified.

## 0. Terms (define once)

- **Code concept:** one named idea that the code implements. The name is logical. The name is not a file path.
- **Fact:** a statement that follows from the code alone. A fact is true or false by reading the code. A fact is not a guess about the world outside the code.
- **Knowledge graph:** a set of nodes and edges that organise facts for teaching order.
- **Node:** one fact plus its definitions, synonyms, cases, and named holds.
- **Named hold:** a deliberate deferral. The process names the open case and points to a later node that must close it. An unnamed gap is a soft hole. Soft holes are forbidden.
- **Chunk:** the smallest teaching unit. A chunk has three first-class fields: claim, use-check, holds.
- **Use-check:** a question that forces the learner to apply, distinguish, or predict from the last claim. A restatement of the claim fails the use-check.
- **Curriculum:** one concept bound to one graph and one chunk set (unlock order is the ready set, not a single frozen playlist).
- **Agent:** an independent runner of this process on the same concept.
- **Converge:** two or more agents produce curricula that match on the same code-forced fact set for the concept (same facts, same case coverage, same named holds and closers). Wording may differ. Node/chunk packaging may differ only when an explicit merge/split equivalence map shows the same fact set. If substance does not match after the retry budget, escalate to the user and do not teach. Because the code is finite, the target fact set is unique; mismatch means discovery missed something.
- **Logical adversary:** a review that tries to refute the curriculum with real code facts and logic. The adversary may read any code needed to attack the claims; it is not limited to discovery’s explored_region. If the attack finds code discovery missed, that is a real hole: expand discovery and re-enter. The adversary does not invent outside-world counterexamples. Adversary clear means: no real hole found after that hunt.
- **Ready set:** every chunk whose predecessors are all passed (initial chunks start ready). At a fork the ready set may contain more than one chunk.
- **Teaching order:** Math-academy-style unlock. Never teach a chunk before its predecessors. Branching is live on the learner surface: multiple unlocks may be ready at once. A fork chooses order only; every chunk must still receive a pass before close. Advance by pick rule X (see Phase G). Stop when every chunk has a pass and all named holds are resolved.
- **Named limitation:** a known bound the process states in the open. Named limitations are not soft holes. Soft holes hide gaps. Named limitations name gaps that logic cannot close.

## 1. Purpose

Run this process to build and teach a curriculum for one code concept.
The teaching prose stays at a pure logical level.
The teaching prose never names a code file.

## 2. Hard gates (any breach stops the phase)

G1. Do not freeze a code scope at the start. Explore until the discovery-completion checklist (§2c) is satisfied with evidence, or until the discovery budget forces escalate with the failing checklist rows. The phrase "I do not know" about the code is forbidden as a teaching or guessing move: either keep exploring, append an open code question and continue under budget, or escalate. Never invent a fact. Never teach from a guess. Never mark discovery clear with empty evidence.
G2. Facts come from the code only.
G3. Independent agents must match on the code-forced fact set (or escalate after the retry budget). Do not average incompatible graphs. Do not teach on mismatch. The fact set is unique for a named concept over finite code; packaging differences require an explicit equivalence map.
G4. A logical adversary must not refute the curriculum without chasing a ghost (a claim the curriculum does not make, or a fact outside the code). The adversary may seek any code fact that disproves the curriculum. Adversary clear means no real code/logic hole survived the hunt (including missing facts another agent should have found).
G5. No term appears before its definition. Synonyms are marked as synonyms.
G6. Case analysis is complete for the explored region, or each open case is a named hold with a later closer.
G7. Teaching prose uses Simplified English. Teaching prose stays logical. Teaching prose names no code file. Format gates do not prove truth; truth gates are G2, G3, G4, and discovery rules.
G8. Each chunk ends with a use-check that passes the use-check checklist (§2d, UC1–UC5). Restate fails. If any UC row fails or evidence is empty, do not teach that chunk (fail closed).
G9. If a learner passed every predecessor of a chunk, that chunk must be understandable from those predecessors alone. If not, the graph is wrong. Sanity is checked per prerequisite edge in the chunk DAG, not against a single linear playlist.
G10. If the learner is stuck, reopen discovery on missing prerequisites. Apply G1–G9 again. Do not patch with a vague explanation.
G11. Teaching must not report complete while any chunk lacks a pass, or while any named hold remains open. An empty ready set with stranded unpassed chunks is a graph defect, not completion.

Teaching Standard is not a default dependency. Do not run Teaching Standard §Procedure as this process.

## 2b. Named limitations (inked)

~~L1 adversary blindness — KILLED.~~ Adversary is not limited to explored_region; it must seek real code facts that can disprove the curriculum. A hit outside the prior explored window forces discovery to expand and re-enter.

~~L2 “lists aren’t telepathy” shrug — KILLED.~~ Replaced by the discovery-completion checklist (§2c): every row needs evidence; empty evidence fails closed; adversary must attack the checklist.

~~L3 substance match ≠ uniqueness — KILLED.~~ Code is finite; the code-forced fact set for a named concept is unique. Converge means the same fact set (packaging may differ only under an explicit merge/split map). Shared wrong match is a discovery defect the adversary must catch — not a permanent limitation.

~~L4 use-check grader shrug — KILLED.~~ Replaced by the use-check checklist (§2d, UC1–UC5). Residual: a pair that clears the checklist and still grades wrong — run-time integrity (same class as fake citations), not a named limitation.

## 2c. Discovery-completion checklist (inked)

Discovery may set discovery_status to clear only when every row below is true and each true row carries evidence (fact id and explored_region citation). Any row without evidence fails closed.

| ID | Requirement | Evidence required |
|----|-------------|-------------------|
| DC1 | Every term used to explain the concept has a definition path to a fact node | term → node id → fact id |
| DC2 | Every branching condition touched for the concept has a full case list or a named hold with closer | branch → cases or hold name + closer_node_id |
| DC3 | open_code_questions is empty; each retired question has a recorded resolution fact | question → resolving fact id |
| DC4 | uncovered_branches is empty (each branch discharged by DC2) | branch id → DC2 discharge |
| DC5 | Every teaching claim in the graph cites at least one fact id | claim/node id → fact id(s) |
| DC6 | Logical adversary has hunted (Phase E) against this checklist and either cleared or forced expand + re-entry | proof backlog entries for DC1–DC5 attacks |

Fake or missing citations are a process breach: do not set discovery clear. Budget (B7) still escalates to the user if the checklist cannot be completed.

## 2d. Use-check checklist (inked)

Before teach, every chunk’s use-check must pass every row. Empty or failing row → do not teach that chunk.

| ID | Requirement |
|----|-------------|
| UC1 | `mode` is apply, distinguish, or predict |
| UC2 | prompt forces that mode (not “restate the claim”) |
| UC3 | `expected_use` is not a paraphrase of `claim` |
| UC4 | adversary must try a pure restatement and must fail |
| UC5 | fail-path corrective prompt still demands use |

A pair that clears UC1–UC5 and still grades wrong at runtime is an integrity residual (like forged discovery citations), not a standing named limitation.

## 3. Artifacts

### 3.1 Curriculum

- concept: logical name
- explored_region: internal audit of which code was read (grows during discovery and when the adversary forces expansion; never shown in teaching prose; not a freeze gate; not a muzzle on the adversary)
- graph: the knowledge graph
- chunks: the chunk set bound to the graph
- ready_set: derived at teach time (not a frozen playlist)
- discovery_status: pending | clear | escalated
- convergence_status: pending | converged | escalated
- adversary_status: pending | clear
- open_code_questions: list (empty only if discovery_status is clear)
- uncovered_branches: list (empty only if discovery_status is clear)
- discovery_checklist: DC1–DC6 rows with evidence citations (all must pass for discovery clear)

### 3.2 Knowledge graph node

- id
- claim
- definitions (terms introduced here)
- synonyms (explicit pairs)
- cases (complete set for this claim, or empty if not applicable)
- holds_opened (NamedHold list: name + closer_node_id)
- holds_resolved (hold names closed here)
- predecessors: nodes that must come before this node (empty only if this node is initial)
- followers: nodes that may come after this node (empty only if this node is final)

A node that is neither initial nor final may have predecessors and followers. An initial node has no predecessors. A final node has no followers.

### 3.3 Knowledge graph edge

- from, to
- kind: prerequisite | elaborates | case-of | hold-target

### 3.4 Chunk (first-class fields)

1. claim — the one logical increment taught now
2. use_check — mode (apply | distinguish | predict), prompt, expected_use
3. holds — opens (list), resolves (list)

Supporting fields: id, node_ids, pred_chunk_ids, definitions_required, sanity_by_pred (map: predecessor chunk id → why a learner who passed that predecessor can take this chunk; required for every pred_chunk_id).

### 3.5 Hold sync invariant

Every name in any node's holds_opened must appear in some chunk's holds.opens.
Every closer_node_id must belong to a node that appears in some chunk's node_ids, and that chunk must list the hold name in holds.resolves (or a later chunk that includes the closer must).
Every name in any chunk's holds.opens / holds.resolves must exist on the node layer.
Breach of this invariant is a soft-hole-class defect: fail before teach.

## 4. Phases (run in order)

### Phase A — Name the concept

A1. Name the code concept in one sentence.
A2. Do not freeze a code scope. Discovery will expand the explored region until the concept is clear or the budget forces escalate.
A3. If the concept name is ambiguous, stop and ask the user. Do not guess the concept. Do not guess facts.
A4. Record that Teaching Standard is off the default path for this run.

### Phase B — Exhaustive discovery (no scope freeze)

B1. Start from the concept. Read the code that the concept needs. Expand the explored region as new dependencies appear.
B2. Extract facts that the code forces. Do not state guesses.
B3. For every branching condition found while exploring, list every case the code distinguishes. Any branch not yet covered stays on uncovered_branches until it has a case or a named hold.
B4. If a case is not taught in this node, open a named hold and point to a later node id (or mark the later node as to-be-created).
B5. If a fact is missing, append an open code question and keep exploring related code until the fact is known or the budget ends. Do not invent a fact. Do not teach while calling the gap "unknown" without recording it.
B6. Stop discovery with discovery_status clear only when every discovery-completion checklist row (DC1–DC6 in §2c) is true with evidence. Empty evidence fails closed.
B7. Discovery budget: default max_discovery_expansions = maxRetries (same knob as converge, default 3 full expansion rounds after the first pass). If §2c is still unsatisfied when the budget is spent, set discovery_status to escalated, present the failing checklist rows (plus open_code_questions and uncovered_branches) to the user, and do not teach. Do not invent the concept. Do not invent facts.
B8. If the concept itself is still ambiguous after exploration, stop and ask the user to clarify the concept.

### Phase C — Build the knowledge graph

C1. Create one node per atomic fact needed for the concept.
C2. Add prerequisite edges so no node needs an undefined term.
C3. Attach definitions and synonyms on the node that introduces them.
C4. Attach cases or named holds per G6.
C5. Reject cycles in prerequisite edges. If a cycle appears, split nodes or revise claims until the cycle is gone. A cycle check that is not implemented must error (fail closed), not return "no cycle."
C6. Reject soft holes: any deferred case without a named hold and a hold-target edge fails.
C7. Set predecessors and followers from prerequisite (and related) edges. An initial node must have no predecessors. A final node must have no followers. Any other node may have predecessors and followers.

### Phase D — Multi-agent converge

D1. Run at least two independent agents on the same concept through Phases B–C (each may expand exploration until clear or escalate).
D2. Compare curricula on the code-forced fact set: facts, cases, named holds and closers (see substance checklist below). Packaging (node/chunk cuts) may differ only with an explicit merge/split map that preserves the fact set.
D3. If the fact set differs, treat the difference as an open discovery defect. Re-enter Phase B on the disputed region. Do not average the differences away. Do not treat two different fact sets as “both valid.”
D4. Set convergence_status to converged only when fact sets match (under equivalence map if packaging differs) and both agents have discovery checklist DC1–DC5 ready for adversary.
D5. If agents fail to converge after a fixed retry budget (default: 3 full re-entries), set convergence_status to escalated, stop, and present the conflict to the user. Do not teach.
D6. Substance checklist (minimum): same fact ids (or merge/split-equivalent); same case sets; same named hold names and closer targets; prerequisite relations preserved under the equivalence map; synonym map for wording only. If the checklist cannot be evaluated, substanceEqual must fail closed (no converge).

### Phase E — Logical adversary

E1. Run a logical adversary against the converged curriculum (graph, then again after chunking).
E2. The adversary may use any code in the repository (or relevant worktree) plus logic. It must actively seek facts that disprove the curriculum. It may not use outside-world facts unrelated to the code. When it reads new code, append that code to explored_region (audit trail).
E3. If the adversary finds a real hole (missing case, undefined term, false claim, soft hole, broken prerequisite, hold sync breach, stranded chunk risk, or contradicting code discovery missed), expand discovery as needed, fix the graph, and return to Phase D.
E4. Set adversary_status to clear only when the adversary finds no real hole after that hunt. Do not treat a narrow explored_region as a reason to skip reading.
E5. Record each attack, kill, or fix in the proof backlog for this curriculum.
E6. Mandatory adversary probes (not optional): discovery-completion checklist DC1–DC5; use-check checklist UC1–UC5 (including pure-restatement must fail); hold sync; prerequisite cycles; every sanity_by_pred entry non-empty and claim-relevant; stranded-chunk impossibility under the pred graph; soft holes.

### Phase F — Chunk the graph

F1. Split nodes into chunks. One chunk teaches one claim increment.
F2. Do not freeze a single total-order playlist as the only surface. Build chunks so prerequisite edges define unlocks. A chunk enters the ready set only when every predecessor chunk has a pass.
F3. For each chunk, write claim, use_check, and holds (opens/resolves).
F4. For each use_check, satisfy §2d UC1–UC5 (mode, prompt, expected_use, adversary restatement-fail, corrective still demands use).
F5. For each pred_chunk_id, write sanity_by_pred[pred]: why a learner who passed that predecessor can take this chunk.
F6. If any required sanity_by_pred entry is missing or empty, revise the graph or the split. Do not proceed.
F7. Enforce hold sync invariant (§3.5). Fail if breached.
F8. Re-run Phase E on the chunked curriculum. If a real hole appears, fix and return to Phase D or F as needed.

### Phase G — Teach

G1. Start with the ready set (all initial chunks). At each step, if the ready set has one chunk, serve it. If the ready set has more than one chunk (a fork), apply pick rule X (locked below). Never serve a chunk outside the ready set.
G2. Deliver only teaching prose that obeys G5–G7.
G2b. If the chunk's holds.opens list is not empty, the teaching prose must name each open hold as a deliberate "comes later" hold. If holds.resolves is not empty, the teaching prose must name what just closed. If both lists are empty, say nothing about holds. An open hold that stays only in the chunk fields and never appears in prose is a soft hole. Soft holes are forbidden.
G2c. Pick rule X (fork): **inked.** When more than one chunk is ready, the learner picks among the ready set. The agent may suggest one candidate (shallowest depth, then stable id) but must never auto-advance when multiple are ready. When exactly one chunk is ready, serve it.
G2d. Fork surface gates: each ready option shows a short claim headline only. Do not show the use-check answer. Do not resolve or spoil holds that open later. If the agent shows a suggestion, label it as a suggestion. Never present the suggestion as the only path.
G2e. Fork means order only: every chunk in the curriculum must still receive a pass before close (G11 / I1). Choosing one ready chunk does not abandon the other ready chunks. They remain required and return to the ready set until passed.
G3. After each chunk, run the use-check.
G4. If the learner restates the claim, mark fail. Give a corrective prompt that still demands use. Do not advance. If restatement detection is unimplemented, do not mark pass.
G5. If the learner uses the claim correctly, mark pass and advance the ready set.
G6. If the learner is stuck (cannot use the claim after corrective attempts, or cannot follow a newly unlocked chunk despite prior passes), stop teaching. Enter Phase H.
G7. Do not mention code files in teaching prose.
G8. After each pass, if ready is empty: if any chunk is still unpassed, error (stranded chunks / G11). If all chunks passed and all holds resolved, go to Phase I.

### Phase H — Stuck revisit

H1. Treat stuck as evidence of a missing or wrong prerequisite.
H2. Re-open discovery on the stuck region (Phase B) under G1–G11.
H3. Re-run converge (Phase D) and adversary (Phase E) on the changed subgraph.
H4. Rebuild affected chunks (Phase F).
H5. Resume teaching at the earliest chunk that changed (drop passes that depended on changed chunks).
H6. Do not invent a bridging explanation that is not in the graph.
H7. Stuck revisit budget: default max_stuck_revisits = 1 per teach run (same fail-closed spirit as converge). If still stuck after that budget, escalate to the user. Do not loop forever.

### Phase I — Close

I1. Teaching is complete when every chunk has a pass, and every named hold opened in the curriculum is resolved by a later chunk.
I2. If any named hold remains open at the end, the curriculum fails. Return to Phase C.
I3. Hand control back. State completion without claiming repository changes. Completion means this curriculum covers the unique code-forced fact set for the concept (packaging may vary under an equivalence map).

## 5. What this process does not do

- It does not edit the target code repository.
- It does not write my-configs until the user co-signs and orders a write.
- It does not change start-work, session pairing, or sandbox rules (deferred).
- It does not use Teaching Standard as the runner.
- It does not replace /learn for mid-work JIT unblocks.
- It does not claim omniscience; it requires the discovery-completion checklist with evidence plus an unbounded-in-code adversary hunt.

## 6. Co-sign rule

Before any repository change, the user must co-sign:
1. this process in Simplified English form, and
2. the same process in algo-sketch form,
with a proof backlog that records closed attacks on logical tightness.
