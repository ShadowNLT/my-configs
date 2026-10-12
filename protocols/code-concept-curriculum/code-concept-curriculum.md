# Teach one code concept as a knowledge-graph curriculum

Audience: a technical operator who runs this process.
Mode: Simplified Technical English (pragmatic). This text is not ASD dictionary-certified.

## 0. Terms (define once)

Code concept, fact, knowledge graph, node, named hold, logical adversary, and named limitation are defined in code-discovery-machine. CCC uses those definitions and does not copy them. The chunk half of the logical adversary is the chunk-level hunt in Phase F. Agent and converge are defined only in code-discovery-machine.

- **Chunk:** the smallest teaching unit. A chunk has three first-class fields: claim, use-check, holds.
- **Use-check:** a question that forces the learner to apply, distinguish, or predict from the last claim. A restatement of the claim fails the use-check.
- **Curriculum:** one concept bound to one graph and one chunk set (unlock order is the ready set, not a single frozen playlist).
- **Ready set:** every chunk whose predecessors are all passed (initial chunks start ready). At a fork the ready set may contain more than one chunk.
- **Teaching order:** Math-academy-style unlock. Never teach a chunk before its predecessors. Multiple unlocks may be ready at once. A fork chooses order only; every chunk must still receive a pass before close. Advance by pick rule X (see Phase G): graph order by default; the learner may ask for a different ready chunk. Stop when every chunk has a pass and all named holds are resolved.
- **Term check:** a check on every text the learner sees. Each term must be an everyday word, or defined in that text, or defined in a chunk the learner already passed. No internal word (§2e) may appear (see G2f).
- **Learner-facing text:** any text that the learner sees during a session. In a work session this is every line, not only the teaching prose (see G2f for the list).
- **Internal word:** a word that names a part of this process, such as chunk, node, or gate. §2e lists them. Internal words stay in internal records. They never appear in learner-facing text.
- **Stuck:** the learner says that they are stuck or that they do not know, or the learner answers wrong two times after the plain hint (G6).
- **Stuck-added chunk:** a prerequisite chunk that Phase H adds because the learner was stuck.

CCC names the same graph ideas with teaching words. code-discovery-machine uses neutral words.

| CCC word | CDM word |
|---|---|
| taught | covered by node |
| teaching claim | claim |
| explain term | term used in claim |

## 1. Purpose

Run this process to build and teach a curriculum for one code concept.
The teaching prose stays at a pure logical level.
The teaching prose never names a code file.

## 2. Hard gates (any breach stops the phase)

Gate G1, Gate G3, and Gate G6 are owned by code-discovery-machine. Gate G2 and Gate G4 are owned there too. S2 binds Gate G2. F8 binds Gate G4.

G5. No term appears before its definition. Synonyms are marked as synonyms.
G7. Teaching prose uses Simplified English. Teaching prose stays logical. Teaching prose names no code file. Format gates do not prove truth; truth gates are G2, G3, G4, and discovery rules.
G8. Each chunk ends with a use-check that passes the use-check checklist (§2d, UC1–UC5). Restate fails. If any UC row fails or evidence is empty, do not teach that chunk (fail closed).
G9. If a learner passed every predecessor of a chunk, that chunk must be understandable from those predecessors alone. If not, the graph is wrong. Sanity is checked per prerequisite edge in the chunk DAG, not against a single linear playlist.
G10. If the learner is stuck, call code-discovery-machine (delta, region = the missing prerequisites, converge on). Apply G1–G9 again. Do not patch with a vague explanation.
G11. Teaching must not report complete while any chunk lacks a pass, or while any named hold remains open. An empty ready set with stranded unpassed chunks is a graph defect, not completion.

## 2b. Named limitations (inked)

L1, L2, and L3 are owned by code-discovery-machine.

~~L4 use-check grader shrug — KILLED.~~ Replaced by the use-check checklist (§2d, UC1–UC5). Residual: a pair that clears the checklist and still grades wrong — run-time integrity (same class as fake citations), not a named limitation.

## 2c. Discovery-completion checklist

The discovery-completion checklist is owned by code-discovery-machine. CCC reads discovery_status from the saved record (Step G0). The chunk-level hunt (F8) never sets the adversary row of that checklist.

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

## 2e. Internal-word denylist (inked)

These words name parts of this process. They are for internal records only. The term check (G2f) blocks each of them in learner-facing text. Replace each hit with its plain replacement. Do not define the internal word for the learner instead; the learner never needs it. Exception: when the code's own subject uses one of these words with its own meaning (for example, a "hold" on a bank account), the word may stay in that meaning, defined like any other term. It must never name a part of this process.

| Internal word | Plain replacement |
|---|---|
| chunk | "part" or "step of the lesson", or say what it taught ("the part about <its headline>") |
| node | "fact" or "idea" |
| graph | "the lesson plan" (better: leave it out) |
| gate (Gate 1, Gate 2) | "before we change any code" or "before you write the fix" |
| claim | "point" or "what we learned" |
| hold (named hold) | "a question we keep open for later" |
| phase (Phase A–I, Phase S, Phase 1–4) | "stage", or say what happens ("now you write the code") |
| use-check | "question" |
| ready set | "what comes next" |
| a chunk id or fact id (P1, S3, F2, N2b, G1, G2) | the plain headline of what that part taught, in words |

Code words are a different case. A code word (for example test, loop, catch, function, request, server-side, scaffolding) is not an everyday word. It may appear in learner-facing text only after a passed chunk defines it, or after the same text defines it in one short sentence.

## 3. Artifacts

### 3.1 Curriculum

- concept: logical name. Phase A sets it and passes it to code-discovery-machine as input.
- chunks: the chunk set bound to the graph
- ready_set: derived at teach time (not a frozen playlist)
- explored_region, the graph, discovery_status, convergence_status, adversary_status, open_code_questions, uncovered_branches, and the discovery checklist are owned by code-discovery-machine. CCC reads them from the saved record. CCC sets adversary_status again after the chunk-level hunt (F8). The graph-pass proof backlog comes back in that record. F8 appends its entries to the same backlog.

### 3.2 Knowledge graph node

The node shape is owned by code-discovery-machine. CCC points at it. Chunks read node_ids (§3.4).

### 3.3 Knowledge graph edge

The edge shape is owned by code-discovery-machine. CCC points at it.

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
A2. Do not freeze a code scope. code-discovery-machine expands the explored region until the concept is clear or the budget forces escalate.
A3. If the concept name is ambiguous, stop and ask the user. Do not guess the concept. Do not guess facts.

### Discovery — call code-discovery-machine

Phases B, C, and D, and the graph half of the logical adversary, are code-discovery-machine. CCC does not copy them.

After Phase A, call code-discovery-machine in full mode with the concept statement and the target code. Resolve that process as `protocols/code-discovery-machine/`, or as `$CONFIG_DIR/code-discovery-machine/` after a command install. Save the returned record as one file in the session record. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f).

If the result is escalated, do not teach. code-discovery-machine does not talk to the learner.
- When the discovery budget is spent, present the failing checklist rows, the open code questions, and the uncovered branches to the learner.
- When the concept is still ambiguous, ask the learner to clarify the concept (as in A3).
- When the agents failed to converge, present the conflict to the learner.

Then continue at Phase F.

### Phase F — Chunk the graph

F1. Split nodes into chunks. One chunk teaches one claim increment.
F2. Do not freeze a single total-order playlist as the only surface. Build chunks so prerequisite edges define unlocks. A chunk enters the ready set only when every predecessor chunk has a pass.
F3. For each chunk, write claim, use_check, and holds (opens/resolves).
F4. For each use_check, satisfy §2d UC1–UC5 (mode, prompt, expected_use, adversary restatement-fail, corrective still demands use).
F5. For each pred_chunk_id, write sanity_by_pred[pred]: why a learner who passed that predecessor can take this chunk.
F6. If any required sanity_by_pred entry is missing or empty, revise the graph or the split. Do not proceed.
F7. Enforce hold sync invariant (§3.5). Fail if breached.
F8. Re-run the logical adversary on the chunked curriculum. This chunk-level hunt checks:
E6b. The use-check checklist (UC1–UC5), including that a pure restatement must fail.
E6c. Hold sync (§3.5).
E6e. Every sanity_by_pred entry is non-empty and claim-relevant.
E6f. Stranded-chunk impossibility under the predecessor graph.
This hunt does not set the adversary row of the discovery checklist. When it finds no real hole, set adversary_status to clear again. Append each attack, kill, or fix to the same proof backlog.
A hole is a code/graph hole when fixing it means adding or changing a node or edge; then call code-discovery-machine (delta, region = the hole, converge on). After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). Any other hole is a chunk hole; CCC re-runs Phase F. After that fix, run this hunt again. When the second hunt finds no hole, set adversary_status to clear again. If the result is clear, continue into that second hunt. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. If the second hunt still finds a hole, stop and escalate. Do not teach.

### Phase G — Teach

G0. Resume. If a saved chunk list and a saved passed-chunk list exist, do not rebuild the graph, do not show it, and do not re-teach passed chunks. If discovery_status is not clear, call code-discovery-machine in full mode, seeded with the saved graph. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. Otherwise, give a short recap of the passed chunks in plain prose, with no question. The recap covers passed chunks only. It names them by their plain headlines, never by id, and it never previews an unpassed chunk. The recap passes the term check (G2f). G0 applies only to a resume after a pause. Moving from the picture chunks to the solution chunks (Phase S) is not a resume. Restore the saved stuck revisit counts for each run (H7). Then rebuild the ready set from the saved lists and continue at G1.
G1. Start with the ready set (all initial chunks). At each step, if the ready set has one chunk, serve it. If the ready set has more than one chunk (a fork), apply pick rule X (locked below). Never serve a chunk outside the ready set.
G2. Deliver only teaching prose that obeys G5–G7.
G2b. If the chunk's holds.opens list is not empty, the teaching prose must name each open hold as a deliberate "comes later" hold. If holds.resolves is not empty, the teaching prose must name what just closed. If both lists are empty, say nothing about holds. An open hold that stays only in the chunk fields and never appears in prose is a soft hole. Soft holes are forbidden.
G2c. Pick rule X (fork): **inked.** When more than one chunk is ready, serve the next chunk in graph order (shallowest depth, then stable id). Do not ask the learner to pick. Change the order only when the learner asks for a different ready chunk; then serve the chunk they ask for. When exactly one chunk is ready, serve it.
G2d. Fork surface gates (only when the learner asks to change the order): each ready option shows a short claim headline only. Do not show the use-check answer. Do not resolve or spoil holds that open later. Label the graph-order chunk as the default. Never present it as the only path.
G2e. Fork means order only: every chunk in the curriculum must still receive a pass before close (G11 / I1). Choosing one ready chunk does not abandon the other ready chunks. They remain required and return to the ready set until passed.
G2f. Term check (every learner-facing text). Before you show any text to the learner, check every term in it. This applies to a teaching chunk, its use-check question, a corrective prompt or hint, a recap (G0), a pause line after a code-discovery-machine delta or escalated result, a chunk that Phase H added, and a solution chunk (Phase S). In a work session it also applies to every other line that the learner sees: the restated goal and the line that says teaching comes first, the pre-flight line and the confirm lines, the resume recap and the plain "what's next" line, the code walkthrough (each step's reason and instructions, each replay of a change the agent typed with its closing question, and each "Done" line), and the end-of-session message. Text shown before the first chunk passes (for example the restated goal) can use only everyday words and terms that it defines itself. A name is not a term when the text shows it as a name in code formatting: a file path cited as `<repo>/<path>:line`, a branch name, a note file name, a folder name, or a command name. The words around it must pass. A name does not teach the words inside it: if the text uses a word from a name as a word, that word must pass on its own. A term passes only when one of these is true: (a) it is an everyday word that an adult with no background in this code knows; (b) the same text defines it before it is used; (c) a chunk that the learner already passed defines it. Run the layman-terms denylist pass on the text (`denylist.txt` in the layman-terms protocol): replace each hit with its plain equivalent. Then run the internal-word denylist pass (§2e): replace each internal word and each chunk or fact id with its plain replacement. An internal word never passes, even when a chunk defined it. If a technical term must stay, define it inline in a few words at its first use. If a term still fails, block the text. Then do one of two things: define the term inline, or call code-discovery-machine (delta, region = the new prerequisite node for the term, converge off). It runs Phase C. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, CCC runs Phase F and teaches that chunk first. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. Do not show a blocked text. The check must not add a claim that is not in the chunk. This is the prose-level check. The graph-level checks are owned by code-discovery-machine; both levels apply.
G2g. Chunk form. Deliver one chunk per turn as short full prose: short sentences, one idea each, active voice, named subjects, root chunks first. A table, a node list, a claim list, the graph, or the discovery checklist is never teaching prose. They are internal records; do not show them as the lesson. Keep each paragraph to about 90 words or fewer, and define at most 3 new terms in one paragraph; split a longer chunk into paragraphs, or into more chunks. End the turn with exactly one question: the use-check prompt, in plain words. The question names every quantity that it asks about (for example a total, a count, or a time), and the chunk taught that quantity before the question. A question that needs a quantity the chunk did not teach is blocked like a failed term. Then wait for the answer.
G2h. Fact check on numbers. Before you show a line number, a count, or a list size, check it against the actual file or test output. A mismatch blocks the text (for example, "six tests" with five listed, or two line numbers for one place that do not agree). Fix it, then check again.
G3. After each chunk, run the use-check.
G4. If the learner restates the claim or answers wrong, mark fail. Give a corrective prompt that still demands use. The corrective prompt is a plain hint: it names the specific missing piece in plain words. It is never cryptic. It never gives the answer, and it never gives a hint before the first attempt. It passes the term check (G2f). Do not advance. If restatement detection is unimplemented, do not mark pass.
G5. If the learner uses the claim correctly, mark pass and advance the ready set.
G5b. Record each pass for the caller: the chunk prose exactly as shown, the question exactly as asked, the learner's passing answer verbatim, the stuck-added marker when Phase H added the chunk, and the taught-again marker when H5 taught the chunk again. A work session appends this record to the session note's Lessons section. The learner rereads that section, so the record's visible heading is the chunk's plain headline plus the markers in plain words ("added because you were stuck", "taught again"). The chunk id goes only in a hidden comment at the end of the heading line (`<!-- P1 -->`), which links the record to the saved passed-chunk list. The visible text passes the term check, including the internal-word pass (§2e). A record is never rewritten. A second pass of the same chunk is a new record.
G6. Stuck trigger. The learner is stuck when one of these is true: (a) the learner says that they are stuck or that they do not know; (b) the learner answers wrong two times after the plain hint (G4); (c) the learner cannot follow a newly unlocked chunk despite prior passes. The first wrong answer gets the plain hint. A wrong answer after the hint gets the hint again in more direct words, still without the answer. The second wrong answer after the hint is stuck. When the learner is stuck, stop teaching. Enter Phase H.
G7. Do not mention code files in teaching prose.
G8. After each pass, if ready is empty: if any chunk is still unpassed, error (stranded chunks / G11). If all chunks passed and all holds resolved, go to Phase I.

### Phase H — Stuck revisit

H1. Treat stuck as evidence of a missing or wrong prerequisite. Do not repeat the same chunk in other words.
H2. On a picture chunk, call code-discovery-machine once (delta, region = the stuck region, converge on). That one call re-runs converge and the adversary on the region and the existing graph. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, continue at H4. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. Exception: when the learner is stuck on a solution chunk and the gap is a reasoning step, not a missing code fact (for example, why waiting before a new try helps), no new code fact is needed. Add a solution-side prerequisite node (H8).
H3. The converge and adversary re-run on the region and the existing graph is the H2 call. Do not make a second call.
H4. Rebuild affected chunks (Phase F).
H5. Resume teaching at the earliest chunk that changed (drop passes that depended on changed chunks). When a chunk whose pass was dropped passes again, record the new pass as a new Lessons record with the taught-again marker in plain words (G5b). Do not rewrite or remove the old record.
H6. Do not invent a bridging explanation that is not in the graph. A solution-side prerequisite node that H8 adds is in the graph; it is not an invented bridge.
H6b. Tell the learner in one line that a piece is missing. Teach the new prerequisite chunk first. It is a stuck-added chunk: it passes the term check (G2f) like any chunk, and its pass is recorded with the stuck-added marker (G5b). Then re-ask the chunk where the learner got stuck: repeat its question only, word for word. Do not show its prose again. Its wrong-answer count (G6) does not reset.
H7. Stuck revisit budget: default max_stuck_revisits = 1 per teach run (same fail-closed spirit as converge). The picture and the solution are separate teach runs. Each run allows one stuck revisit. The caller saves the count used in each run across a pause (a work session saves it as `stuck_revisits: picture N, solution N`). A resume (G0) restores the saved counts. It never resets them to zero. If still stuck after that budget, escalate to the user. Do not loop forever.
H8. Stuck during the solution chunks (Phase S). The revisit stays under the solution close (Gate 2). It does not reopen the picture close (Gate 1), and it does not drop picture passes. If the gap is a missing code fact, call code-discovery-machine as in S4 (delta, region = the missing fact, converge off). After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, add the fact as a prerequisite node and teach it as a stuck-added chunk that belongs to the solution chunk set. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. If the gap is a reasoning step, add a solution-side prerequisite node: mark its kind as solution, cite the fact ids and the ticket text that it rests on (S2), and call code-discovery-machine (delta, adversary only on that reasoning node, converge off). The adversary-only flag is accepted only with mode = delta and converge off. Any other combination is an error and code-discovery-machine does no work. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, teach the node as a stuck-added chunk that belongs to the solution chunk set. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. In both clear cases, its pass counts toward the solution close. If the learner only says that they do not know, and the gap is not clearly a reasoning step, take the missing-code-fact branch (S4 first, fail closed).

### Phase I — Close

I1. Teaching is complete when every chunk has a pass, and every named hold opened in the curriculum is resolved by a later chunk.
I2. If any named hold remains open at the end, the curriculum fails. Call code-discovery-machine (delta, region = the node ids that carry the open holds, converge off). It runs Phase C on those nodes. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, continue. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge.
I3. Hand control back. State completion without claiming repository changes. Completion means this curriculum covers the unique code-forced fact set for the concept (packaging may vary under an equivalence map).

### Phase S — Solution extension (work sessions only)

S1. After the picture chunks pass (Phase I), a work session adds solution nodes on top of the same graph.
S2. A solution node is a proposed change, not a code fact. Mark its kind as solution. Each solution node cites the fact ids it depends on and the ticket text that asks for it. These nodes are caller-made inputs to code-discovery-machine. Gate G2 still binds every fact node and every fact that a solution node cites.
S3. Call code-discovery-machine (delta, caller-made solution nodes, converge off). It merges those nodes into the existing graph, then runs Phase C and the graph adversary on those nodes. It does not run Phase D. Phase D is not required for solution nodes, because more than one valid change can exist. The user owns that choice. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, run Phases F, G, H, and I on the solution nodes. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge. Passed picture chunks stay passed; they are the floor for the solution chunks. Starting the solution chunks is not a resume: give no recap (Step G0) at that point. A learner who is stuck on a solution chunk follows H8.
S4. If a solution node needs a code fact that the graph does not hold, call code-discovery-machine (delta, region = the missing fact, converge off). It runs Phase B on that fact only, merges the result into the existing graph, then runs Phase C. After a delta result, before teaching resumes, write a one-line learner-facing pause line from the change list (this is why I paused). After an escalated result, write a one-line learner-facing line that says the lesson is stopping and lists what is still open, from the change list. Run the term check (G2f) and §2e on that line, and show it. If the term check fails, define the term inline (G2f). If the result is clear, continue. If the result is escalated, do not teach: present the failing checklist rows, the open code questions, and the uncovered branches when the discovery budget is spent; ask the learner to clarify the concept when it is still ambiguous; present the conflict when the agents failed to converge.

## 5. What this process does not do

- It does not edit the target code repository.
- It does not write my-configs until the user co-signs and orders a write.
- Work sessions (`/start-work`, `/resume-work`) run this whole process, Phases A→I, for the picture, then Phase S for the solution delta. Gate 1 is Phase I on the picture chunks. Gate 2 is Phase I on the solution chunks. This process does not own session pairing, the edit walkthrough, `/learn`, or `/new-session`. The edit walkthrough is `/start-work` Phase 4: after the solution is agreed, the learner chooses for each step whether to type the change or have the agent type it, and can switch at any step. A change the agent typed is replayed against the agreed solution: one plain sentence per step that names the lesson it applies, plus the 2–3 key lines with their location; small supporting changes get one line; the full set of changed lines only on request. The replay ends the agent's turn with "Does this match what we agreed?" and the agent waits. Only after the learner answers do the tests run, and the agent says "Done" only after they pass. "Just fix it" skips the replay and the wait, not the tests. The replay sentences pass G2f and G2h.
- It does not replace /learn for mid-work JIT unblocks.
- It does not claim omniscience; it requires the discovery-completion checklist in code-discovery-machine (§2c) with evidence plus an unbounded-in-code adversary hunt.

## 6. Co-sign rule

Before any repository change, the user must co-sign:
1. this process in Simplified English form, and
2. the same process in algo-sketch form,
with a proof backlog that records closed attacks on logical tightness.
