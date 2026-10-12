# Algo Sketch — equivalent of code-concept-curriculum.md

```text
# Build and teach a code-concept curriculum from exhaustive code facts

// seam map
//   [name concept] → [code-discovery-machine full] → [chunk] → [teach]
//   → [chunk] → [teach] → [stuck revisit or close]
//   → (work sessions) [solution extension] → [chunk] → [teach] → [close]
//
// Work sessions: /start-work and /resume-work run Phases A–I for the picture,
// then the solution extension (piece 7, Phase S) for the solution delta.
// Gate 1 = close on the picture chunks; Gate 2 = close on the solution chunks.
// Phases B–D and the graph half of the adversary are code-discovery-machine.
// This sketch calls that process. It does not copy those rules.
// targetCode is the code the concept is about. Every code-discovery-machine call takes it.
// This process does not own session pairing, the edit walkthrough, /learn, or /new-session.
// The edit walkthrough is /start-work Phase 4: per step the learner chooses who types the change
// (learner or agent, switchable any step). An agent-typed change is replayed against the agreed
// solution (per step: one plain sentence naming the lesson it applies + 2-3 key lines with location;
// supporting edits as one line; full diff only on request). The replay ends the turn with
// "Does this match what we agreed?" and waits; only after the learner's answer (yes, or corrections
// applied and re-replayed) do tests run, then "Done" only after they pass. "just fix it" skips the
// replay and the wait, not the tests. Replay text goes through termCheck.


// --- piece 1: shapes ---

// Node, Edge, Graph, NamedHold, ExploredRegion, ChecklistRow, ProofEntry,
// and the discovery-record fields are defined in code-discovery-machine.
// This sketch reads the saved record. It does not redefine those shapes.
// L1, L2, and L3 are owned by code-discovery-machine.

record Concept
    name           // string; logical name; not a file path

record UseCheck
    mode           // "apply" or "distinguish" or "predict"
    prompt         // string
    expectedUse    // string; what correct use looks like (not a restatement)

record ChunkHolds
    opens          // list of string
    resolves       // list of string

record Chunk
    id             // string
    claim          // string
    useCheck       // UseCheck
    holds          // ChunkHolds
    nodeIds        // list of string
    predChunkIds   // list of string; predecessor chunks; empty iff initial
    definitionsRequired  // list of string
    sanityByPred   // map predChunkId → string; required key for every predChunkId
    correctivePrompt // string; UC5 — on fail, still demands use; plain hint, never the answer (G4)
    stuckAdded     // true/false; true when stuckRevisit added this chunk (H6b)
    side           // "picture" or "solution"; a stuck-added chunk takes the side of the run that added it (H8)
    headline       // string; short plain headline; the only way learner-facing text names a passed chunk (§2e)

record LessonEntry   // G5b — one record per pass; work sessions append it to the note's Lessons
    // Rendered heading: "### " + headline [+ " — added because you were stuck"] [+ " — taught again"]
    //   + " <!-- " + chunkId + " -->"   — the id is hidden; visible text passes termCheck (§2e)
    chunkId        // string; hidden link to passed_chunks — only inside the trailing HTML comment
    headline       // string; chunk.headline; the visible heading
    prose          // string; exactly as shown
    question       // string; exactly as asked
    answer         // string; learner's passing answer, verbatim
    stuckAdded     // true/false
    taughtAgain    // true/false; true when H5 dropped an earlier pass and this is the new pass.
                   // A LessonEntry is append-only: never rewrite or remove an earlier entry (G5b, H5).

// §2e internal-word denylist: never in learner-facing text; replace with the plain word.
constant INTERNAL_WORDS ← map
    "chunk"     → "part" / "step of the lesson" / what it taught
    "node"      → "fact" / "idea"
    "graph"     → "the lesson plan" (better: leave it out)
    "gate"      → "before we change any code" / "before you write the fix"
    "claim"     → "point" / "what we learned"
    "hold"      → "a question we keep open for later"
    "phase"     → "stage" / what happens now
    "use-check" → "question"
    "ready set" → "what comes next"
    <chunk or fact id, e.g. P1, S3, F2, N2b, G1> → the plain headline of what that part taught
// Exception: the code's own subject may use one of these words in its own meaning (e.g. a "hold" on an
// account); it stays, defined like any term, and never names a part of this process.
// Code words (test, loop, catch, function, request, server-side, scaffolding, ...) are NOT everyday
// words: allowed only once a passed chunk or the same text defines them (G2f).

record Curriculum
    concept            // Concept. Phase A. Input to code-discovery-machine.
    chunks             // list of Chunk
    // Read from the saved code-discovery-machine record. Contracts live there.
    exploredRegion
    graph
    discoveryStatus
    convergenceStatus
    adversaryStatus
    openCodeQuestions
    uncoveredBranches
    discoveryChecklist

record RunState
    curriculum     // Curriculum
    proofBacklog   // list of ProofEntry
    stuckRevisits  // map side → number ≥ 0 ("picture", "solution"); saved across pause as
                   // stuck_revisits: picture N, solution N; restored on resume (G0, H7), never reset
    maxStuckRevisits  // number ≥ 1; default 1
    invariant: stuckRevisits[side] ≤ maxStuckRevisits for each side


// --- piece 2: name concept + discovery ---

module Discovery
    function nameConcept(conceptName)   // → Concept
        // A1. Name the code concept in one sentence. A logical name, not a file path.
        // A2. Do not freeze a code scope. code-discovery-machine expands the explored region.
        // A3. If the name is ambiguous, stop and ask. Do not guess the concept. Do not guess facts.
        if conceptName = null or conceptName = ""
            error "concept name missing"
        concept ← blank Concept
        concept.name ← conceptName
        return concept

module Teaching
    function isRestatement(answer, claim, mode)   // answer, claim: string; mode: UseCheck.mode → true/false
        // Minimal fail-closed rule (repo draft may strengthen, not weaken):
        if answer = "" 
            return true
        if normalize(answer) = normalize(claim)
            return true
        // If a stronger grader is not available, treat uncertain answers as restatement
        // when they share no apply/distinguish/predict move markers — never auto-pass.
        if not hasMoveMarker(answer, mode)   // uncertain → restatement (fail closed)
            return true
        return false   // a move marker is present; useCheckPasses still needs expectedUse match

    function useCheckChecklistOk(chunk, proofBacklog)   // → true/false  (§2d UC1–UC5)
        uc ← chunk.useCheck
        if uc.mode ≠ "apply" and uc.mode ≠ "distinguish" and uc.mode ≠ "predict"
            return false                                    // UC1
        if uc.prompt = "" or promptIsRestateOnly(uc.prompt)
            return false                                    // UC2
        if uc.expectedUse = "" or isParaphrase(uc.expectedUse, chunk.claim)
            return false                                    // UC3
        // UC4: adversary pure restatement must fail
        if Teaching.useCheckPasses(chunk, chunk.claim) = true
            return false
        if Teaching.useCheckPasses(chunk, paraphrase(chunk.claim)) = true
            return false
        if chunk.correctivePrompt = "" or promptIsRestateOnly(chunk.correctivePrompt)
            return false                                    // UC5
        return true

    function useCheckPasses(chunk, answer)   // chunk: Chunk, answer: string → true/false
        if chunk.useCheck.expectedUse = ""
            return false
        if Teaching.isRestatement(answer, chunk.claim, chunk.useCheck.mode)
            return false
        // Compare answer to chunk.useCheck.expectedUse for the stated mode.
        return true

    function sanityOk(chunk)   // → true/false
        for each predId in chunk.predChunkIds
            if chunk.sanityByPred[predId] = null or chunk.sanityByPred[predId] = ""
                return false
        return true

    function holdsSynced(curriculum)   // → true/false
        nodeOpen ← blank list
        nodeClose ← blank map   // hold name → closerNodeId
        for each node in curriculum.graph.nodes
            for each hold in node.holdsOpened
                append(nodeOpen, hold.name)
                nodeClose[hold.name] ← hold.closerNodeId
            for each name in node.holdsResolved
                // resolved names must have been opened somewhere
                if not belongsTo(name, nodeOpen) and not earlier open
                    return false
        chunkOpen ← blank list
        chunkResolve ← blank list
        closerCovered ← blank list
        for each chunk in curriculum.chunks
            for each name in chunk.holds.opens
                append(chunkOpen, name)
            for each name in chunk.holds.resolves
                append(chunkResolve, name)
                closerId ← nodeClose[name]
                if closerId = null
                    return false
                if not belongsTo(closerId, chunk.nodeIds)
                    // closer may be on another chunk that resolves this name — check any chunk
                    covered ← false
                    for each c2 in curriculum.chunks
                        if belongsTo(closerId, c2.nodeIds) and belongsTo(name, c2.holds.resolves)
                            covered ← true
                    if covered = false
                        return false
        for each name in nodeOpen
            if not belongsTo(name, chunkOpen)
                return false
            if not belongsTo(name, chunkResolve)
                return false
        for each name in chunkOpen
            if not belongsTo(name, nodeOpen)
                return false
        return true

    function chunkGraph(curriculum)   // → Curriculum
        // F1. One chunk, one claim increment. F2. Prerequisite edges define unlocks.
        // F3. claim, use_check, holds. F4. UC1–UC5. F5. sanity_by_pred. F6. Missing sanity fails.
        // F7. Hold sync (§3.5). Gate G5. No term before its definition.
        // Gate G9. Sanity is per prerequisite edge, not one playlist.
        // Split nodes into chunks; predChunkIds from prerequisite edges (DAG).
        for each chunk in curriculum.chunks
            if not Teaching.sanityOk(chunk)
                error "sanity_by_pred missing for a predecessor"
            if not Teaching.useCheckChecklistOk(chunk, null)
                error "use-check checklist UC1–UC5 failed"
        if not Teaching.holdsSynced(curriculum)
            error "hold sync invariant breached"
        return curriculum

    function holeFixChangesGraph(kind, curriculum)   // → true/false
        // True when fixing this hole means adding or changing a node or edge.
        // A use-check or a sanity line can be fixed in the chunk text: that is a chunk hole.
        // Hold sync or a stranded chunk is a code/graph hole when the node layer is missing
        // the hold or the predecessor, and a chunk hole when those nodes are already there.
        if kind = "use-check" or kind = "sanity"
            return false
        if kind = "hold-sync"
            return a named hold is missing on the node layer
        if kind = "stranded"
            return a predecessor edge is missing on the node layer
        return false

    function chunkAdversary(curriculum, proofBacklog, pass)   // → Curriculum, proof backlog
        // F8. Chunk-level hunt after chunkGraph.
        // E6b. Use-check checklist UC1–UC5, including pure restatement must fail.
        // E6c. Hold sync (§3.5).
        // E6e. Every sanityByPred entry is non-empty and claim-relevant.
        // E6f. Stranded chunks: ready empty while unpassed chunks remain.
        // This hunt does not set the adversary row of the discovery checklist.
        // Append each attack to the same proof backlog.
        // L4 killed: the use-check checklist replaces the grader shrug.
        if pass = null
            pass ← 1
        realHole ← null
        hole ← null
        if not Teaching.holdsSynced(curriculum)
            if Teaching.holeFixChangesGraph("hold-sync", curriculum)
                realHole ← "code"
                hole ← the hold that is missing on the node layer
            else
                realHole ← "chunk"
                hole ← "hold-sync"
        for each chunk in curriculum.chunks
            if not Teaching.useCheckChecklistOk(chunk, proofBacklog)
                if realHole ≠ "code"
                    realHole ← "chunk"
                    hole ← chunk
            if not Teaching.sanityOk(chunk)
                if realHole ≠ "code"
                    realHole ← "chunk"
                    hole ← chunk
        if Teaching.readySet can be empty while an unpassed chunk remains
            if Teaching.holeFixChangesGraph("stranded", curriculum)
                realHole ← "code"
                hole ← the missing predecessor
            else if realHole ≠ "code"
                realHole ← "chunk"
                hole ← "stranded"
        if realHole = "code"
            // F8 hole test. Call code-discovery-machine (delta, region = the hole, converge on).
            record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=hole, converge="on")
            proofBacklog ← addProof(proofBacklog, record)
            showPauseLine(record, curriculum, null)
            if record.result = "escalated"
                error "escalated; present the record to the learner; do not teach"
            apply record onto curriculum
            curriculum ← Teaching.chunkGraph(curriculum)
            if pass = 1
                return Teaching.chunkAdversary(curriculum, proofBacklog, 2)
            curriculum.adversaryStatus ← "pending"
            return curriculum, proofBacklog
        if realHole = "chunk"
            // Chunk hole. Re-run Phase F. Do not call code-discovery-machine.
            curriculum ← Teaching.chunkGraph(curriculum)
            if pass = 1
                return Teaching.chunkAdversary(curriculum, proofBacklog, 2)
            curriculum.adversaryStatus ← "pending"
            return curriculum, proofBacklog
        // Second hunt included: no hole left, so set adversaryStatus on this path too.
        curriculum.adversaryStatus ← "clear"
        return curriculum, proofBacklog

    function readySet(curriculum, passedIds)   // → list of Chunk
        ready ← blank list
        for each chunk in curriculum.chunks
            if belongsTo(chunk.id, passedIds)
                continue
            allPredPassed ← true
            for each predId in chunk.predChunkIds
                if not belongsTo(predId, passedIds)
                    allPredPassed ← false
            if allPredPassed
                append(ready, chunk)
        return ready

    function allChunksPassed(curriculum, passedIds)   // → true/false
        for each chunk in curriculum.chunks
            if not belongsTo(chunk.id, passedIds)
                return false
        return true

    function graphOrderNext(ready)   // ready: list of Chunk → Chunk
        // Graph order: shallowest depth, then stable id.
        best ← ready[0]
        for each chunk in ready
            if chunk is better than best by depth then id
                best ← chunk
        return best

    function pickRuleX(ready, learnerAsked)   // ready: non-empty list of Chunk → Chunk
        // Inked X + G2c + G2e: graph order by default; no prompt to pick; all remain required.
        if length(ready) = 0
            error "pickRuleX called with empty ready set"
        if length(ready) = 1
            return ready[0]
        if learnerAsked = null
            return Teaching.graphOrderNext(ready)   // do not ask the learner
        // Learner asked to change the order (G2d surface applies)
        choice ← learnerAsked
        if not belongsTo(choice, ready)
            error "pick outside ready set"
        return choice

    function forkSurfaceOk(options, defaultChunk)   // → true/false; only when learner asks to reorder
        for each opt in options
            if opt shows use-check answer or later-hold resolution
                return false
            if opt.claimHeadline = ""
                return false
            // must not imply optional / skippable siblings (G2e)
        if defaultChunk presented as only path
            return false
        return true

    function termCheck(text, chunk, passedIds, curriculum)   // → "ok" or blocked term   (G2f)
        // Applies to: chunk prose, use-check question, corrective prompt / hint, recap (G0),
        // a pause line after a code-discovery-machine delta or escalated result,
        // stuck-added chunks, solution chunks. In a work session also: restated goal and the
        // teach-first line, pre-flight and confirm lines, resume recap and plain "what's next" line,
        // the code walkthrough (each step's reason and instructions, each replay of an agent-typed
        // change, each "Done" line), the end-of-session message.
        // Text shown before any chunk passed (restated goal): everyday words or inline definitions only.
        // A name shown in code formatting (cited path <repo>/<path>:line, branch, note file, folder,
        // command) is not a term; the words around it must pass, and a word from a name used as a
        // word must pass on its own (a name teaches nothing).
        if not Teaching.numbersCheck(text)
            return "number mismatch (G2h)"          // blocked
        // 1) Check internal words BEFORE any replacement, so the check can fire (§2e).
        for each term in termsOf(text)
            if (belongsTo(term, INTERNAL_WORDS) and namesProcessPart(term, text)) or isChunkOrFactId(term)
                return term                           // blocked: rewrite with the plain replacement, then re-check
        // 2) Then the layman-terms denylist pass. Internal words in the code's own subject
        //    (the §2e exception, e.g. a "hold" on an account) are left as they are.
        text ← apply layman-terms denylist pass (replace each hit with its plain equivalent)
        for each term in termsOf(text)
            if isShownAsName(term, text)             // code-formatted name: exempt as a name only
                continue
            if isCodeWord(term) and not definedEarlierIn(text, term) and not definedInPassedChunk(term, passedIds, curriculum)
                return term                           // code words are not everyday words
            if isEverydayWord(term)
                continue
            if definedEarlierIn(text, term)          // inline definition of a few words counts
                continue
            if definedInPassedChunk(term, passedIds, curriculum)
                continue
            return term                               // blocked
        return "ok"

    function render(chunk, passedIds, curriculum, proofBacklog)   // → prose or "teach-prerequisite-first", Curriculum  (G2g + G2f)
        prose ← chunk.claim, definitions, and holds as short full sentences; root first
        if prose is a table or a node/claim list or the graph or the checklist
            error "not teaching prose (G2g)"
        // must not add a claim that is not in the chunk
        for each paragraph in prose
            if wordCount(paragraph) > ~90 or newTermsDefinedIn(paragraph) > 3
                error "too dense (G2g); split the paragraph or the chunk"
        for each quantity in quantitiesAskedIn(chunk.useCheck.prompt)
            if not namedIn(chunk.useCheck.prompt, quantity) or not taughtIn(prose, quantity)
                error "question asks about an unnamed or untaught quantity (G2g)"
        if not Teaching.numbersCheck(prose + chunk.useCheck.prompt)
            error "number does not match the file or test output (G2h)"
        result ← Teaching.termCheck(prose + chunk.useCheck.prompt, chunk, passedIds, curriculum)
        if result ≠ "ok"
            // Step G2f. Block. Define the term inline, or call code-discovery-machine.
            // delta, region = the new prerequisite node, converge off. It runs Phase C.
            // clear: Phase F, then teach that chunk first. Do not show the blocked text.
            // escalated: do not teach. Budget spent, concept still ambiguous, or agents failed to converge.
            newNode ← the new prerequisite node for the blocked term result
            record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=newNode, converge="off")
            proofBacklog ← addProof(proofBacklog, record)
            showPauseLine(record, curriculum, passedIds)
            if record.result = "escalated"
                error "escalated; present the record to the learner; do not teach"
            apply record onto curriculum
            curriculum ← Teaching.chunkGraph(curriculum)
            return "teach-prerequisite-first", curriculum
        return prose, curriculum

    function numbersCheck(text)   // → true/false   (G2h; runs on every learner-facing text)
        for each number in lineNumbersCountsAndListSizesIn(text)
            if number does not match the actual file or test output
                return false   // blocks the text; fix and re-check
        return true

    function allHoldsResolved(curriculum)   // → true/false
        opened ← blank list
        resolved ← blank list
        for each chunk in curriculum.chunks
            for each name in chunk.holds.opens
                append(opened, name)
            for each name in chunk.holds.resolves
                append(resolved, name)
        for each name in opened
            if not belongsTo(name, resolved)
                return false
        return true

    function holdsVisibleInProse(chunk, prose)   // → true/false
        // G2b. An open hold is named in the prose, or it is a soft hole.
        for each name in chunk.holds.opens
            if name = ""
                return false
            // real run: require name appears in prose as deliberate hold
        for each name in chunk.holds.resolves
            if name = ""
                return false
        return true

    function teach(curriculum, passedIds, lessonLog, entry, proofBacklog)   // → "complete" or "stuck"
        // entry: "fresh" | "resume" | "solution"
        //   fresh    — new run (passedIds blank), or the same run continuing after stuckRevisit (no recap)
        //   resume   — G0: saved passed_chunks from a pause; the discovery call, then the recap
        //   solution — Phase S: picture passes kept in passedIds as the floor; NOT a resume, no recap (S3)
        if passedIds = null
            passedIds ← blank list
        if entry = "resume"
            // Step G0. The discovery call is first, so an escalated result shows no recap. Then the recap.
            // restore saved stuckRevisits per side (H7); never reset to 0
            if curriculum.discoveryStatus ≠ "clear"
                record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "full", existing=curriculum, seed=curriculum)
                proofBacklog ← addProof(proofBacklog, record)
                if record.result = "escalated"
                    showPauseLine(record, curriculum, passedIds)
                    error "escalated; present the record to the learner; do not teach"
                apply record onto curriculum
            recap ← plain recap of PASSED chunks only, by headline, no ids (no question)
            if Teaching.termCheck(recap, null, passedIds, curriculum) ≠ "ok"
                error "recap failed term check (G0, G2f)"
            // show recap; do not rebuild or show the graph; do not re-teach passed chunks
        while true
            ready ← Teaching.readySet(curriculum, passedIds)
            if ready = blank list
                if not Teaching.allChunksPassed(curriculum, passedIds)
                    error "stranded chunks: ready empty but unpassed remain (G11)"
                if not Teaching.allHoldsResolved(curriculum)
                    // I2. Call code-discovery-machine (delta, region = the node ids that carry the open holds, converge off). It runs Phase C.
                    holdNodeIds ← blank list
                    for each node in curriculum.graph.nodes
                        for each hold in node.holdsOpened
                            if hold.name is still open
                                append(holdNodeIds, node.id)
                    record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=holdNodeIds, converge="off")
                    proofBacklog ← addProof(proofBacklog, record)
                    showPauseLine(record, curriculum, passedIds)
                    if record.result = "escalated"
                        error "escalated; present the record to the learner; do not teach"
                    apply record onto curriculum
                    curriculum ← Teaching.chunkGraph(curriculum)
                    if not Teaching.allHoldsResolved(curriculum)
                        error "named hold still open at end"
                return "complete"
            // Fork: graph order unless the learner asked to reorder (G2c)
            chunk ← Teaching.pickRuleX(ready, learnerReorderRequest())
            prose, curriculum ← Teaching.render(chunk, passedIds, curriculum, proofBacklog)
            if prose = "teach-prerequisite-first"
                continue
            if not Teaching.holdsVisibleInProse(chunk, prose)
                error "soft hole: hold not named in prose"
            // G1. Serve the ready set. G2. Teaching prose only. G3. Then the use-check.
            // G7. Do not mention code files in teaching prose. Gate G8. The use-check must pass UC1–UC5.
            // Show prose; ask chunk.useCheck.prompt as one plain question; wait for the answer (G2g).
            // Run use-check; restatement or unimplemented grader → fail.
            // On fail: corrective prompt = plain hint naming the missing piece; never the answer;
            //   must pass Teaching.termCheck (G4, G2f).
            // Stuck trigger (G6): learner says stuck / "I don't know" → return "stuck";
            //   wrongAfterHint counts wrong answers after the first hint; wrongAfterHint = 2 → return "stuck".
            //   The count is per chunk and does not reset when the chunk is re-asked after stuckRevisit.
            // G5. Correct use marks pass. G8. Empty ready with all passed and holds resolved goes to Phase I.
            // On pass:
            append(passedIds, chunk.id)
            taughtAgain ← lessonLog has an entry with chunkId = chunk.id   // pass was dropped by H5
            append(lessonLog, LessonEntry(chunk.id, chunk.headline, prose, chunk.useCheck.prompt, answer, chunk.stuckAdded, taughtAgain))   // G5b; never rewrite old entries

    function stuckRevisit(curriculum, stuckRegion, maxStuckRevisits, stuckRevisits, side, proofBacklog)   // → Curriculum, number
        // side: "picture" or "solution" — the teach run that got stuck; each run has its own budget (H7)
        if stuckRevisits[side] ≥ maxStuckRevisits
            error "stuck after revisit budget; escalate to user"
        // Stuck = missing or wrong prerequisite (H1). Never re-serve the same chunk reworded.
        // Gate G10. Stuck reopens discovery by a code-discovery-machine call.
        if side = "solution"
            // H8. Stays under the solution close (Gate 2); never reopens Gate 1; picture passes stay.
            if gap is a missing code fact or not clearly a reasoning step   // incl. a bare "I don't know" (fail closed)
                // S4. code-discovery-machine delta, region = the missing fact, converge off.
                // Phase B on that fact only, then merge into the existing graph.
                record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=missingFact, converge="off", regionIsMissingFact=true)
            else   // reasoning step (H2 exception): no new code fact
                // Caller-made node: kind ← "solution", citesFactIds ← facts + ticket text (S2).
                // code-discovery-machine delta, adversary only, converge off.
                record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, callerNodes=[reasoningNode], converge="off", adversaryOnly=true)
            proofBacklog ← addProof(proofBacklog, record)
            showPauseLine(record, curriculum, passedIds)
            if record.result = "escalated"
                error "escalated; present the record to the learner; do not teach"
            apply record onto curriculum
            // H4. Rebuild affected chunks (Phase F).
            curriculum ← Teaching.chunkGraph(curriculum)
            // New chunk: stuckAdded ← true, side ← "solution"; its pass counts toward the solution close.
        else
            // H2 and H3 are one call: delta, region = the stuck region, converge on.
            // That call runs over the region and the existing graph.
            record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=stuckRegion, converge="on")
            proofBacklog ← addProof(proofBacklog, record)
            showPauseLine(record, curriculum, passedIds)
            if record.result = "escalated"
                error "escalated; present the record to the learner; do not teach"
            apply record onto curriculum
            // H4. Rebuild affected chunks (Phase F).
            curriculum ← Teaching.chunkGraph(curriculum)
            // New chunk: stuckAdded ← true, side ← "picture".
        // The new prerequisite chunk passes termCheck like any chunk (H6b).
        // Drop passes that depended on changed chunks (H5); their re-pass is a new taughtAgain LessonEntry.
        // H6. Do not invent a bridge outside the graph.
        // Tell the learner in one line that a piece is missing; teach the new chunk first,
        // then re-ask the chunk where the learner got stuck (H6b): repeat chunk.useCheck.prompt only,
        // not the prose; its wrongAfterHint count does not reset.
        stuckRevisits[side] ← stuckRevisits[side] + 1   // persisted by the caller (stuck_revisits)
        return curriculum, stuckRevisits


// --- piece 7: solution extension (work sessions only, Phase S) ---

module Solution
    function extend(curriculum, solutionNodes, ticketText, proofBacklog)   // → Curriculum
        // S1: runs only after the picture chunks close (Phase I)
        // S2. Caller-made solution nodes. Gate G2 still binds every fact a solution node cites.
        for each node in solutionNodes
            if node.kind ≠ "solution" or node.citesFactIds = blank list
                error "solution node must cite fact ids (S2)"
            for each factId in node.citesFactIds
                if factId not in curriculum facts
                    // S4. code-discovery-machine delta, region = the missing fact, converge off.
                    // Phase B on that fact only, then merge into the existing graph.
                    record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, region=factId, converge="off", regionIsMissingFact=true)
                    proofBacklog ← addProof(proofBacklog, record)
                    showPauseLine(record, curriculum, passedIds)
                    if record.result = "escalated"
                        error "escalated; present the record to the learner; do not teach"
                    apply record onto curriculum
        // S3. code-discovery-machine delta, caller-made nodes, converge off.
        //     Merge those nodes into the existing graph, then Phase C and the graph adversary on those nodes. No Phase D.
        record ← callCodeDiscoveryMachine(curriculum.concept, targetCode, "delta", existing=curriculum, callerNodes=solutionNodes, converge="off")
        proofBacklog ← addProof(proofBacklog, record)
        showPauseLine(record, curriculum, passedIds)
        if record.result = "escalated"
            error "escalated; present the record to the learner; do not teach"
        apply record onto curriculum
        curriculum ← Teaching.chunkGraph(curriculum)
        // Then teach. Picture passes stay the floor. Entry "solution" gives no recap (not a resume).
        // A separate teach run: its own stuck budget (H7); stuck → Teaching.stuckRevisit(..., "solution") (H8).
        return curriculum


// --- piece 6: top-level run ---

function addProof(proofBacklog, record)
    // Append the proof entries the call returned. Do not replace the backlog.
    if proofBacklog = null
        proofBacklog ← blank list
    if record = null or record.proofEntries = null
        return proofBacklog
    for each entry in record.proofEntries
        if entry not in proofBacklog
            append(proofBacklog, entry)
    return proofBacklog

function showPauseLine(record, curriculum, passedIds)
    // Delta result: one learner-facing line from record.changeList ("this is why I paused"), before teaching resumes.
    // Escalated result: one learner-facing line that says the lesson is stopping and lists what is still open, from record.changeList.
    // Run the term check (G2f) and §2e, then show the line.
    // If the term check fails, define the term inline (G2f). Do not error.
    if passedIds = null
        passedIds ← blank list
    if record.result = "escalated"
        pauseLine ← one line that says the lesson is stopping and lists what is still open, from record.changeList
    else
        pauseLine ← one line from record.changeList ("this is why I paused")
    blocked ← Teaching.termCheck(pauseLine, null, passedIds, curriculum)
    if blocked ≠ "ok"
        pauseLine ← define the term inline (G2f)
    // show pauseLine to the learner

function callCodeDiscoveryMachine(concept, targetCode, mode, delta)
    // One call. The saved record is code-discovery-machine's. This function does not restate its rules.
    // Resolve it as protocols/code-discovery-machine/, or $CONFIG_DIR/code-discovery-machine/ after a command install.
    // mode "full" or "delta". See that process for seed, region, caller-made nodes, converge, adversary-only.
    // targetCode is the code the concept is about.
    // clear: the caller continues. escalated: do not teach.
    // Discovery budget spent: failing checklist rows, open questions, uncovered branches.
    // Concept still ambiguous: ask the learner to clarify the concept (A3).
    // Agents failed to converge: present the conflict.
    return the saved record

function runTeachConcept(conceptName, maxStuckRevisits)
    if maxStuckRevisits = null
        maxStuckRevisits ← 1
    concept ← Discovery.nameConcept(conceptName)
    // A2. No code-scope freeze. The budget stays inside code-discovery-machine.
    // Full, with no saved graph. There is no existing graph on this call.
    record ← callCodeDiscoveryMachine(concept, targetCode, "full", null)
    if record.result = "escalated"
        showPauseLine(record, null, null)
        // Present the record and do not teach.
        // Discovery budget spent: failing checklist rows, open questions, uncovered branches.
        // Concept still ambiguous: ask the learner to clarify the concept (A3).
        // Agents failed to converge: present the conflict.
        error "escalated; present the record to the learner; do not teach"
    curriculum ← blank Curriculum
    curriculum.concept ← concept
    apply record onto curriculum
    proofBacklog ← addProof(blank list, record)
    curriculum ← Teaching.chunkGraph(curriculum)
    curriculum, proofBacklog ← Teaching.chunkAdversary(curriculum, proofBacklog)
    if curriculum.adversaryStatus = "pending"
        error "second hunt still found a hole; escalate; do not teach"
    stuckRevisits ← {picture: 0, solution: 0}   // on resume: the saved stuck_revisits instead (G0, H7)
    lessonLog ← blank list
    result ← Teaching.teach(curriculum, null, lessonLog, "fresh", proofBacklog)
    if result = "stuck"
        curriculum, stuckRevisits ← Teaching.stuckRevisit(curriculum, /* region */, maxStuckRevisits, stuckRevisits, "picture", proofBacklog)
        result ← Teaching.teach(curriculum, /* passedIds kept per H5 */, lessonLog, "fresh", proofBacklog)   // continues the same run; no recap
        if result = "stuck"
            error "stuck after revisit budget; escalate to user"
    if curriculum.discoveryStatus ≠ "clear"
        error "cannot close without discovery clear (saved record)"
    if curriculum.convergenceStatus ≠ "converged"
        error "cannot close without converge"
    if curriculum.adversaryStatus ≠ "clear"
        error "cannot close without adversary clear"
    if not Teaching.allChunksPassed(curriculum, /* final passedIds from teach */)
        // I1. Every chunk passed and every named hold resolved.
        error "cannot close with unpassed chunks"
    // I3. Hand control back. State completion without claiming repository changes.
    return curriculum, proofBacklog
```
