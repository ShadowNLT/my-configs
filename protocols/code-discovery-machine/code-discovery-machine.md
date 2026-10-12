# Find the code-forced facts for one concept

Audience: a technical operator who runs this process.
Mode: Simplified Technical English (pragmatic). This text is not ASD dictionary-certified.

This process discovers. It does not teach. It does not talk to the learner.
code-concept-curriculum calls it and presents any escalated result.

## 0. Terms (define once)

- **Code concept:** one named idea that the code implements. The name is logical. The name is not a file path.
- **Fact:** a statement that follows from the code alone. A fact is true or false by reading the code. A fact is not a guess about the world outside the code.
- **Knowledge graph:** a set of nodes and edges that organise facts for teaching order.
- **Node:** one fact plus its definitions, synonyms, cases, and named holds.
- **Named hold:** a deliberate deferral. The process names the open case and points to a later node that must close it. An unnamed gap is a soft hole. Soft holes are forbidden.
- **Agent:** an independent runner of this process on the same concept.
- **Converge:** two or more agents produce curricula that match on the same code-forced fact set for the concept (same facts, same case coverage, same named holds and closers). Wording may differ. Node/chunk packaging may differ only when an explicit merge/split equivalence map shows the same fact set. If substance does not match after the retry budget, return escalated. The caller does not teach. Because the code is finite, the target fact set is unique; mismatch means discovery missed something.
- **Logical adversary:** a review that tries to refute the curriculum with real code facts and logic. The adversary may read any code needed to attack the claims; it is not limited to discovery’s explored_region. If the attack finds code discovery missed, that is a real hole: expand discovery and re-enter. The adversary does not invent outside-world counterexamples. Adversary clear means: no real hole found after that hunt. This protocol runs the graph pass of that hunt. The caller runs the hunt again after chunking.
- **Named limitation:** a known bound the process states in the open. Named limitations are not soft holes. Soft holes hide gaps. Named limitations name gaps that logic cannot close.

Chunk, use-check, curriculum, ready set, teaching order, term check, learner-facing text, internal word, stuck, and stuck-added chunk are defined in code-concept-curriculum. This process does not redefine them.

## 1. Purpose

Run this process to find the code-forced fact set for one named concept and return the graph.
The caller teaches. This process does not.

## 2. Hard gates (any breach stops the phase)

G1. Do not freeze a code scope at the start. Explore until the discovery-completion checklist (§2c) is satisfied with evidence, or until the discovery budget forces escalate with the failing checklist rows. The phrase "I do not know" about the code is forbidden as a teaching or guessing move: either keep exploring, append an open code question and continue under budget, or escalate. Never invent a fact. Never teach from a guess. Never mark discovery clear with empty evidence.
G2. Facts come from the code only.
G3. Independent agents must match on the code-forced fact set (or escalate after the retry budget). Do not average incompatible graphs. Do not teach on mismatch. The fact set is unique for a named concept over finite code; packaging differences require an explicit equivalence map.
G4. A logical adversary must not refute the curriculum without chasing a ghost (a claim the curriculum does not make, or a fact outside the code). The adversary may seek any code fact that disproves the curriculum. Adversary clear means no real code/logic hole survived the hunt (including missing facts another agent should have found).
G6. Case analysis is complete for the explored region, or each open case is a named hold with a later closer.

## 2b. Named limitations (inked)

~~L1 adversary blindness — KILLED.~~ Adversary is not limited to explored_region; it must seek real code facts that can disprove the curriculum. A hit outside the prior explored window forces discovery to expand and re-enter.

~~L2 “lists aren’t telepathy” shrug — KILLED.~~ Replaced by the discovery-completion checklist (§2c): every row needs evidence; empty evidence fails closed; adversary must attack the checklist.

~~L3 substance match ≠ uniqueness — KILLED.~~ Code is finite; the code-forced fact set for a named concept is unique. Converge means the same fact set (packaging may differ only under an explicit merge/split map). Shared wrong match is a discovery defect the adversary must catch — not a permanent limitation.

## 2c. Discovery-completion checklist (inked)

Discovery may set discovery_status to clear only when every row below is true and each true row carries evidence (fact id and explored_region citation). Any row without evidence fails closed.

| ID | Requirement | Evidence required |
|----|-------------|-------------------|
| DC1 | Every term used to explain the concept has a definition path to a fact node | term → node id → fact id |
| DC2 | Every branching condition touched for the concept has a full case list or a named hold with closer | branch → cases or hold name + closer_node_id |
| DC3 | open_code_questions is empty; each retired question has a recorded resolution fact | question → resolving fact id |
| DC4 | uncovered_branches is empty (each branch discharged by DC2) | branch id → DC2 discharge |
| DC5 | Every teaching claim in the graph cites at least one fact id | claim/node id → fact id(s) |
| DC6 | Logical adversary has hunted on the graph against this checklist and either cleared or forced expand + re-entry. The caller's chunk-level hunt does not set this row | proof backlog entries for DC1–DC5 attacks |

Fake or missing citations are a process breach: do not set discovery clear. Budget (B7) still returns escalated if the checklist cannot be completed. The caller talks to the learner.

## 3. Artifacts

The caller passes the concept name in. This process does not define that field.
The caller owns chunks and the ready set.

### 3.1 Discovery record

- explored_region: internal audit of which code was read (grows during discovery and when the adversary forces expansion; never shown in teaching prose; not a freeze gate; not a muzzle on the adversary)
- graph: the knowledge graph
- discovery_status: pending | clear | escalated
- convergence_status: pending | converged | escalated
- adversary_status: pending | clear
- open_code_questions: list (empty only if discovery_status is clear)
- uncovered_branches: list (empty only if discovery_status is clear)
- discovery_checklist: DC1–DC6 rows with evidence citations (all must pass for discovery clear)

adversary_status on this record is the graph pass. The caller sets it again after the chunk-level hunt.
Proof backlog entries from the graph pass are part of this record (E5).

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
- kind: "fact" or "solution". The caller sets "solution" on a caller-made proposal node.
- citesFactIds: list of fact ids. Required when kind is solution. The caller sets them.

### 3.3 Knowledge graph edge

- from, to
- kind: prerequisite | elaborates | case-of | hold-target

## 4. Phases (run in order)

Phase A (name the concept) belongs to the caller. This process starts at Phase B.

### Phase B — Exhaustive discovery (no scope freeze)

B1. Start from the concept. Read the code that the concept needs. Expand the explored region as new dependencies appear.
B2. Extract facts that the code forces. Do not state guesses.
B3. For every branching condition found while exploring, list every case the code distinguishes. Any branch not yet covered stays on uncovered_branches until it has a case or a named hold.
B4. If a case is not taught in this node, open a named hold and point to a later node id (or mark the later node as to-be-created).
B5. If a fact is missing, append an open code question and keep exploring related code until the fact is known or the budget ends. Do not invent a fact. Do not teach while calling the gap "unknown" without recording it.
B6. Stop discovery with discovery_status clear only when every discovery-completion checklist row (DC1–DC6 in §2c) is true with evidence. Empty evidence fails closed.
B7. Discovery budget: default max_discovery_expansions = maxRetries (same knob as converge, default 3 full expansion rounds after the first pass). If §2c is still unsatisfied when the budget is spent, set discovery_status to escalated and return result escalated with reason code B7. The record includes the failing checklist rows, open_code_questions, and uncovered_branches. Do not present them. The caller presents them and does not teach. Do not invent the concept. Do not invent facts.
B8. If the concept itself is still ambiguous after exploration, return result escalated with reason code B8. Do not ask the learner. The caller asks the learner to clarify the concept.

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
D5. If agents fail to converge after a fixed retry budget (default: 3 full re-entries), set convergence_status to escalated and return result escalated with reason code D5. Do not present the conflict. The caller presents the conflict and does not teach.
D6. Substance checklist (minimum): same fact ids (or merge/split-equivalent); same case sets; same named hold names and closer targets; prerequisite relations preserved under the equivalence map; synonym map for wording only. If the checklist cannot be evaluated, substanceEqual must fail closed (no converge).

### Phase E — Logical adversary (graph pass)

E1. Run a logical adversary against the converged graph. This is the graph pass. The pass after chunking belongs to the caller.
E2. The adversary may use any code in the repository (or relevant worktree) plus logic. It must actively seek facts that disprove the curriculum. It may not use outside-world facts unrelated to the code. When it reads new code, append that code to explored_region (audit trail).
E3. If the adversary finds a real graph hole (missing case, undefined term, false claim, soft hole, broken prerequisite, or contradicting code discovery missed), expand discovery as needed, fix the graph, and return to Phase D. That return is an internal loop, not a caller call. The re-entry converges over the hole's region and the existing graph and merges the result into the caller's graph. It does not return a fresh graph of the whole concept. A chunk hole (hold sync breach, stranded chunk risk) is not fixed here. The caller sends it back as a delta call with converge on.
E4. Set adversary_status to clear only when the graph-pass hunt finds no real hole. Do not treat a narrow explored_region as a reason to skip reading. The caller sets adversary_status again after the chunk-level hunt.
E5. Record each attack, kill, or fix in the proof backlog for this curriculum. Return those entries. The caller appends its chunk-hunt entries to the same backlog.
E6. Mandatory graph probes (not optional) are the rows below. The chunk probes belong to the caller's chunk-level hunt. That hunt does not set DC6.
E6a. Discovery-completion checklist DC1–DC5.
E6d. Prerequisite cycles.
E6g. Soft holes (C6).

## 5. Entry

One entry point. The caller saves the returned record as one file in the session.

Inputs:
- concept statement (the caller names it)
- target code
- mode: full or delta
- delta only: existing graph; region (node ids, or a missing fact); caller-made nodes; converge on or off
- adversary-only flag. Accept it only when mode is delta and converge is off. Any other combination is an error. Do no work.

full, with no saved graph: run Phases B, C, D, and the graph pass.
full, seeded with a saved graph whose discovery checklist is satisfied: run Phase D over that saved graph, then the graph pass over the whole graph. Do not discover the concept from scratch. If the discovery checklist is not satisfied, run Phase B on the whole concept first, then Phase C, Phase D, and the graph pass.

Phase D over a saved graph is two independent reads of the code that graph covers. Each read is checked against the saved graph and against the other read. When the two reads agree and differ from the saved graph, merge that agreed region into the saved graph and read again on the disputed region. When the two reads disagree, do not merge them; read again on the disputed region only. The saved graph is not replaced.

A delta call merges into the caller's graph. It never replaces that graph. A delta path that runs Phase B runs it on the region only and merges the result into the input graph. An escalated Phase B still returns that merged record.

delta, converge on: run Phase B on the region only as two independent reads inside Phase D, merge the result into the existing graph (Phase C on the merged nodes), then the graph pass over the region and the existing graph. Do not discover the whole concept.
delta, converge off, adversary-only: merge the caller-made nodes and their edges into the existing graph, run Phase C on those nodes, then run the graph pass on that list only. Do not review the rest of the record. That review does not mark DC6, adversary_status, or discovery_status clear for the whole graph.
delta, converge off, with caller-made nodes, not adversary-only: merge those nodes and their edges into the existing graph, then run Phase C and the graph pass on those nodes. Do not rebuild the graph from only those nodes. Do not run Phase D. That review does not mark DC6, adversary_status, or discovery_status clear for the whole graph.
delta, converge off, region is node ids: run Phase C on those nodes inside the existing graph, including when the region is a list of node ids. Do not keep only the region's nodes. Do not skip a node id.
delta, converge off, region is a missing fact: run Phase B on that fact only, merge the result into the existing graph, then Phase C. An escalated result returns that merged record.

Proof backlog entries from a delta call are added to the entries already on the input record (E5). They do not replace them.

Outputs are only the fields recorded today:
- graph (§3.2 and §3.3)
- explored_region, discovery_status, convergence_status, adversary_status after the graph pass, open_code_questions, uncovered_branches, discovery_checklist (§3.1)
- proof backlog entries (E5)
- result: clear, or escalated with reason code B7, B8, or D5

Do not talk to the learner. The caller presents an escalated result and does not teach.

## 6. What this process does not do

- It does not teach, chunk, or run a use-check.
- It does not talk to the learner.
- It does not edit the target code repository.
- It does not write my-configs until the user co-signs and orders a write.

## 7. Co-sign rule

Before any repository change, the user must co-sign:
1. this process in Simplified English form, and
2. the same process in algo-sketch form,
with a proof backlog that records closed attacks on logical tightness.
