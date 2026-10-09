# Algo Sketch — equivalent of code-concept-curriculum.md

```text
# Build and teach a code-concept curriculum from exhaustive code facts

// seam map
//   [name concept] → [discover facts] → [build graph] → [converge + adversary]
//   → [chunk] → [teach] → [stuck revisit or close]
//   → (work sessions) [solution extension] → [chunk] → [teach] → [close]
//
// Work sessions: /start-work and /resume-work run Phases A–I for the picture,
// then the solution extension (piece 7, Phase S) for the solution delta.
// Gate 1 = close on the picture chunks; Gate 2 = close on the solution chunks.
// This process does not own session pairing, the edit walkthrough, /learn, or /new-session.


// --- piece 1: shapes ---

record ExploredRegion
    description    // string; grows during discovery and adversary hunt; audit only; never teaching prose

record Concept
    name           // string; logical name; not a file path

record NamedHold
    name           // string
    closerNodeId   // string; node that must resolve this hold

record Node
    id             // string
    claim          // string; one logical fact
    kind           // "fact" or "solution"; solution nodes are proposals (piece 7, S2)
    citesFactIds   // list of string; required when kind = "solution"
    definitions    // list of string
    synonyms       // list of string; each item marks an explicit synonym pair in words
    cases          // list of string; complete case set, or blank list if not applicable
    holdsOpened    // list of NamedHold
    holdsResolved  // list of string; hold names closed here
    predecessors   // list of string; node ids; empty only if initial
    followers      // list of string; node ids; empty only if final

record Edge
    fromId         // string
    toId           // string
    kind           // "prerequisite" or "elaborates" or "case-of" or "hold-target"

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

record Graph
    nodes          // list of Node
    edges          // list of Edge

record Curriculum
    concept            // Concept
    exploredRegion     // ExploredRegion
    graph              // Graph
    chunks             // list of Chunk
    discoveryStatus    // "pending" or "clear" or "escalated"
    convergenceStatus  // "pending" or "converged" or "escalated"
    adversaryStatus    // "pending" or "clear"
    openCodeQuestions  // list of string
    uncoveredBranches  // list of string
    discoveryChecklist // list of ChecklistRow (DC1–DC6)

record ChecklistRow
    id             // "DC1" .. "DC6"
    satisfied      // true/false
    evidence       // string; fact ids + explored_region citations; empty ⇒ fail closed

record ProofEntry
    attack         // string
    outcome        // "killed" or "fixed" or "escalated" or "named-limitation" or "killed-limitation"
    note           // string

record RunState
    curriculum     // Curriculum
    proofBacklog   // list of ProofEntry
    retryCount     // number ≥ 0
    maxRetries     // number ≥ 1
    stuckRevisits  // number ≥ 0
    maxStuckRevisits  // number ≥ 1; default 1
    invariant: retryCount ≤ maxRetries
    invariant: stuckRevisits ≤ maxStuckRevisits


// --- piece 2: name concept + discovery ---

module Discovery
    function nameConcept(conceptName)   // → Concept
        if conceptName = null or conceptName = ""
            error "concept name missing"
        concept ← blank Concept
        concept.name ← conceptName
        return concept

    function checklistSatisfied(rows)   // rows: list of ChecklistRow → true/false
        // DC1–DC6 must all be present, satisfied, and evidence non-empty.
        required ← ["DC1", "DC2", "DC3", "DC4", "DC5", "DC6"]
        for each id in required
            row ← find rows where row.id = id
            if row = null
                return false
            if row.satisfied = false
                return false
            if row.evidence = ""
                return false
        return true

    function discoveryComplete(curriculum)
        if curriculum.openCodeQuestions ≠ blank list
            return false
        if curriculum.uncoveredBranches ≠ blank list
            return false
        if not Discovery.checklistSatisfied(curriculum.discoveryChecklist)
            return false
        return true

    function discoverFacts(concept, maxExpansions)   // → Curriculum fragment fields
        // No scope freeze. Expand explored region until B6 or budget.
        explored ← blank ExploredRegion
        explored.description ← ""
        facts ← blank list
        openCodeQuestions ← blank list
        uncoveredBranches ← blank list
        expansions ← 0
        checklist ← blank list   // fill DC1–DC5 evidence as facts grow; DC6 after adversary
        while true
            // Read more related code; append facts; update explored.description
            // Missing fact → append openCodeQuestions; never invent
            // New branch → append uncoveredBranches until case or named hold
            // Update checklist rows with evidence citations; empty evidence never counts as satisfied
            cur ← blank Curriculum
            cur.openCodeQuestions ← openCodeQuestions
            cur.uncoveredBranches ← uncoveredBranches
            cur.discoveryChecklist ← checklist
            // DC6 may stay unsatisfied until Phase E; discovery "clear" for converge needs DC1–DC5;
            // full discovery_status clear for teach requires DC6 after adversaryClear.
            if openCodeQuestions = blank list and uncoveredBranches = blank list and Discovery.checklistSatisfied(filter checklist where id ≠ "DC6") 
                return facts, explored, openCodeQuestions, uncoveredBranches, checklist, "clear-pending-adversary"
            expansions ← expansions + 1
            if expansions > maxExpansions
                return facts, explored, openCodeQuestions, uncoveredBranches, checklist, "escalated"
            // if concept name ambiguous → error "clarify concept with user"


// --- piece 3: build graph ---

module Graph
    function hasPrerequisiteCycle(edges)   // edges: list of Edge → true/false
        // REQUIRED: real cycle detect on kind = "prerequisite" only.
        // Forbidden: return false without checking (that was the old happy-path lie).
        prereq ← filter edges where kind = "prerequisite"
        return detectDirectedCycle(prereq)   // standard DFS/topo; must be real in repo draft

    function hasSoftHole(nodes)   // nodes: list of Node → true/false
        for each node in nodes
            for each hold in node.holdsOpened
                if hold.name = "" or hold.closerNodeId = ""
                    return true
        return false

    function buildGraph(facts)   // facts: list of string → Graph
        graph ← blank Graph
        graph.nodes ← blank list
        graph.edges ← blank list
        // Create one node per atomic fact; add definitions, synonyms, cases, holds.
        // Add edges; every deferred case must be a NamedHold with hold-target edge.
        if Graph.hasPrerequisiteCycle(graph.edges)
            error "prerequisite cycle"
        if Graph.hasSoftHole(graph.nodes)
            error "soft hole: deferred case without named hold and closer"
        // Set predecessors/followers from edges.
        return graph


// --- piece 4: converge + adversary ---

module Validation
    function substanceEqual(a, b)   // a, b: Curriculum → true/false
        // Unique code-forced fact set (L3 killed). Packaging may differ only under merge/split map.
        // Every clause must run; if any clause cannot be evaluated, return false.
        if not sameFactSetUnderEquivalenceMap(a.graph, b.graph)
            return false
        if not sameCaseSets(a.graph, b.graph)
            return false
        if not sameNamedHoldsAndClosers(a.graph, b.graph)
            return false
        if not prerequisitesPreservedUnderMap(a.graph, b.graph)
            return false
        return true

    function converge(concept, maxRetries)   // → Curriculum
        retryCount ← 0
        while retryCount ≤ maxRetries
            facts1, explored1, oq1, ub1, cl1, dstat1 ← Discovery.discoverFacts(concept, maxRetries)
            facts2, explored2, oq2, ub2, cl2, dstat2 ← Discovery.discoverFacts(concept, maxRetries)
            if dstat1 = "escalated" or dstat2 = "escalated"
                error "discovery escalated; present failing checklist rows to user; do not teach"
            graph1 ← Graph.buildGraph(facts1)
            graph2 ← Graph.buildGraph(facts2)
            c1 ← blank Curriculum
            c1.concept ← concept
            c1.exploredRegion ← explored1
            c1.graph ← graph1
            c1.openCodeQuestions ← oq1
            c1.uncoveredBranches ← ub1
            c1.discoveryChecklist ← cl1
            c1.discoveryStatus ← dstat1
            c1.convergenceStatus ← "pending"
            c1.adversaryStatus ← "pending"
            c2 ← blank Curriculum
            c2.concept ← concept
            c2.exploredRegion ← explored2
            c2.graph ← graph2
            c2.openCodeQuestions ← oq2
            c2.uncoveredBranches ← ub2
            c2.discoveryChecklist ← cl2
            c2.discoveryStatus ← dstat2
            c2.convergenceStatus ← "pending"
            c2.adversaryStatus ← "pending"
            if Validation.substanceEqual(c1, c2)
                c1.convergenceStatus ← "converged"
                // Union explored regions for adversary window (both agents' reads)
                c1.exploredRegion.description ← explored1.description + "\n" + explored2.description
                return c1
            retryCount ← retryCount + 1
            // Re-enter discovery on disputed region only; do not average away.
        error "agents failed to converge; escalate to user; do not teach"

    function adversaryClear(curriculum, proofBacklog)   // → Curriculum, list of ProofEntry
        // Adversary may read any code needed to attack claims (not limited to exploredRegion).
        // New reads append to exploredRegion (audit). Outside-world attacks are ghosts.
        append(proofBacklog, ProofEntry("L1 adversary blindness", "killed",
            "adversary seeks disproof in any code; miss forces discovery expand"))
        realHoleFound ← false
        // Hunt + mandatory probes: hold sync, cycles, use-checks, sanityByPred, stranded risk, soft holes,
        // and contradicting code outside the prior explored window.
        // For each attack: append ProofEntry; if real hole, set realHoleFound.
        if realHoleFound
            error "adversary found a real hole; expand discovery, return to converge"
        // Mark DC6 satisfied with proof backlog citations; then discovery may be fully clear.
        setChecklistRow(curriculum.discoveryChecklist, "DC6", true, proofBacklogEvidence)
        curriculum.adversaryStatus ← "clear"
        if Discovery.checklistSatisfied(curriculum.discoveryChecklist)
            curriculum.discoveryStatus ← "clear"
        return curriculum, proofBacklog


// --- piece 5: chunk + teach + stuck ---

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
        // Split nodes into chunks; predChunkIds from prerequisite edges (DAG).
        for each chunk in curriculum.chunks
            if not Teaching.sanityOk(chunk)
                error "sanity_by_pred missing for a predecessor"
            if not Teaching.useCheckChecklistOk(chunk, null)
                error "use-check checklist UC1–UC5 failed"
        if not Teaching.holdsSynced(curriculum)
            error "hold sync invariant breached"
        return curriculum

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
        // stuck-added chunks, solution chunks. In a work session also: restated goal and the
        // teach-first line, pre-flight and confirm lines, resume recap and plain "what's next" line,
        // the code walkthrough (each step's reason and instructions), the end-of-session message.
        // Text shown before any chunk passed (restated goal): everyday words or inline definitions only.
        // A cited path <repo>/<path>:line is a name, not a term; the words around it must pass.
        text ← apply layman-terms denylist pass (replace each hit with its plain equivalent)
        text ← apply INTERNAL_WORDS pass (§2e: replace each internal word and each chunk/fact id)
        for each term in termsOf(text)
            if (belongsTo(term, INTERNAL_WORDS) and namesProcessPart(term, text)) or isChunkOrFactId(term)
                return term                           // blocked even if a chunk "defined" it
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

    function render(chunk, passedIds, curriculum)   // → string prose  (G2g + G2f)
        prose ← chunk.claim, definitions, and holds as short full sentences; root first
        if prose is a table or a node/claim list or the graph or the checklist
            error "not teaching prose (G2g)"
        // must not add a claim that is not in the chunk
        result ← Teaching.termCheck(prose + chunk.useCheck.prompt, chunk, passedIds, curriculum)
        if result ≠ "ok"
            // Block: define inline, or add a prerequisite node + chunk (Phase C, then F) and teach it first
            error "term check failed: " + result + "; define inline or add prerequisite chunk"
        return prose

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
        for each name in chunk.holds.opens
            if name = ""
                return false
            // real run: require name appears in prose as deliberate hold
        for each name in chunk.holds.resolves
            if name = ""
                return false
        return true

    function teach(curriculum, passedIds, lessonLog, entry)   // → "complete" or "stuck"
        // entry: "fresh" | "resume" | "solution"
        //   fresh    — new run (passedIds blank), or the same run continuing after stuckRevisit (no recap)
        //   resume   — G0: saved passed_chunks from a pause; recap first
        //   solution — Phase S: picture passes kept in passedIds as the floor; NOT a resume, no recap (S3)
        if passedIds = null
            passedIds ← blank list
        if entry = "resume"
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
                    error "named hold still open at end"
                return "complete"
            // Fork: graph order unless the learner asked to reorder (G2c)
            chunk ← Teaching.pickRuleX(ready, learnerReorderRequest())
            prose ← Teaching.render(chunk, passedIds, curriculum)
            if not Teaching.holdsVisibleInProse(chunk, prose)
                error "soft hole: hold not named in prose"
            // Show prose; ask chunk.useCheck.prompt as one plain question; wait for the answer (G2g).
            // Run use-check; restatement or unimplemented grader → fail.
            // On fail: corrective prompt = plain hint naming the missing piece; never the answer;
            //   must pass Teaching.termCheck (G4, G2f).
            // Stuck trigger (G6): learner says stuck / "I don't know" → return "stuck";
            //   wrongAfterHint counts wrong answers after the first hint; wrongAfterHint = 2 → return "stuck".
            // On pass:
            append(passedIds, chunk.id)
            taughtAgain ← lessonLog has an entry with chunkId = chunk.id   // pass was dropped by H5
            append(lessonLog, LessonEntry(chunk.id, chunk.headline, prose, chunk.useCheck.prompt, answer, chunk.stuckAdded, taughtAgain))   // G5b; never rewrite old entries

    function stuckRevisit(curriculum, stuckRegion, maxStuckRevisits, stuckRevisits, side)   // → Curriculum, number
        // side: "picture" or "solution" — the teach run that got stuck; each run has its own budget (H7)
        if stuckRevisits ≥ maxStuckRevisits
            error "stuck after revisit budget; escalate to user"
        // Stuck = missing or wrong prerequisite (H1). Never re-serve the same chunk reworded.
        if side = "solution"
            // H8: stays under the solution close (Gate 2); never reopens Gate 1; picture passes stay.
            if gap is a missing code fact
                // S4 → Discovery on region; new fact node; Graph.buildGraph
            else   // gap is a reasoning step (e.g. why waiting helps): no new code fact (H2 exception)
                // new node: kind ← "solution", citesFactIds ← facts + ticket text it rests on (S2)
            // Validation.adversaryClear on the delta only; Teaching.chunkGraph on the delta
            // New chunk: stuckAdded ← true, side ← "solution"; its pass counts toward the solution close.
        else
            // Re-run Discovery on region, Graph.buildGraph, Validation.converge,
            // Validation.adversaryClear, Teaching.chunkGraph.
            // New chunk: stuckAdded ← true, side ← "picture".
        // The new prerequisite chunk passes termCheck like any chunk (H6b).
        // Drop passes that depended on changed chunks (H5); their re-pass is a new taughtAgain LessonEntry.
        // Do not invent a bridge outside the graph.
        // Tell the learner in one line that a piece is missing; teach the new chunk first,
        // then re-ask the chunk where the learner got stuck (H6b).
        return curriculum, stuckRevisits + 1


// --- piece 7: solution extension (work sessions only, Phase S) ---

module Solution
    function extend(curriculum, solutionNodes, ticketText)   // → Curriculum
        // S1: runs only after the picture chunks close (Phase I)
        for each node in solutionNodes
            if node.kind ≠ "solution" or node.citesFactIds = blank list
                error "solution node must cite fact ids (S2)"
            for each factId in node.citesFactIds
                if factId not in curriculum facts
                    error "missing code fact; return to Phase B (S4)"
        // S3: Graph.buildGraph on picture + delta; Validation.adversaryClear on delta only;
        //     no converge for solution nodes; Teaching.chunkGraph on delta;
        //     then Teaching.teach(curriculum, picturePassedIds, lessonLog, "solution")
        //     — picture passes kept as the floor; entry "solution" gives no recap (not a resume).
        //     A separate teach run: its own stuck budget (H7); stuck → Teaching.stuckRevisit(..., "solution") (H8).
        return curriculum


// --- piece 6: top-level run ---

function runTeachConcept(conceptName, maxRetries, maxStuckRevisits)
    if maxStuckRevisits = null
        maxStuckRevisits ← 1
    concept ← Discovery.nameConcept(conceptName)
    // No code-scope freeze.
    curriculum ← Validation.converge(concept, maxRetries)
    proofBacklog ← blank list
    curriculum, proofBacklog ← Validation.adversaryClear(curriculum, proofBacklog)
    curriculum ← Teaching.chunkGraph(curriculum)
    curriculum, proofBacklog ← Validation.adversaryClear(curriculum, proofBacklog)
    stuckRevisits ← 0
    lessonLog ← blank list
    result ← Teaching.teach(curriculum, null, lessonLog, "fresh")
    if result = "stuck"
        curriculum, stuckRevisits ← Teaching.stuckRevisit(curriculum, /* region */, maxStuckRevisits, stuckRevisits, "picture")
        result ← Teaching.teach(curriculum, /* passedIds kept per H5 */, lessonLog, "fresh")   // continues the same run; no recap
        if result = "stuck"
            error "stuck after revisit budget; escalate to user"
    if curriculum.discoveryStatus ≠ "clear"
        error "cannot close without discovery clear (checklist DC1–DC6)"
    if not Discovery.checklistSatisfied(curriculum.discoveryChecklist)
        error "cannot close with incomplete discovery checklist"
    if curriculum.convergenceStatus ≠ "converged"
        error "cannot close without converge"
    if curriculum.adversaryStatus ≠ "clear"
        error "cannot close without adversary clear"
    if not Teaching.allChunksPassed(curriculum, /* final passedIds from teach */)
        error "cannot close with unpassed chunks"
    return curriculum, proofBacklog
```
