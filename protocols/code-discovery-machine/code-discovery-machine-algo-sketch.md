# Algo Sketch — equivalent of code-discovery-machine.md

```text
# Find the code-forced fact set for one concept

// seam map
//   [concept from caller] → [discover facts] → [build graph] → [converge + graph adversary]
//   → return one record
//
// This process does not teach and does not talk to the learner.
// Chunk probes and teaching are code-concept-curriculum.
// concept is the Concept record defined in code-concept-curriculum. This sketch does not redefine it.


// --- piece 1: shapes ---

record ExploredRegion
    description    // string; grows during discovery and adversary hunt; audit only; never teaching prose

record NamedHold
    name           // string
    closerNodeId   // string; node that must resolve this hold

record Node
    id             // string
    claim          // string; one logical fact
    kind           // "fact" or "solution"; the caller sets "solution" on a proposal node
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

record Graph
    nodes          // list of Node
    edges          // list of Edge

record DiscoveryRecord
    concept            // input; the Concept record is owned by code-concept-curriculum
    exploredRegion     // ExploredRegion
    graph              // Graph
    discoveryStatus    // "pending" or "clear" or "escalated"
    convergenceStatus  // "pending" or "converged" or "escalated"
    adversaryStatus    // "pending" or "clear"
    openCodeQuestions  // list of string
    uncoveredBranches  // list of string
    discoveryChecklist // list of ChecklistRow (DC1–DC6)
    proofEntries      // list of ProofEntry (E5)
    result            // "clear" or "escalated"
    reason            // "" or "B7" or "B8" or "D5"

record ChecklistRow
    id             // "DC1" .. "DC6"
    satisfied      // true/false
    evidence       // string; fact ids + explored_region citations; empty ⇒ fail closed

record ProofEntry
    attack         // string
    outcome        // "killed" or "fixed" or "escalated" or "named-limitation" or "killed-limitation"
    note           // string

record RunState
    retryCount     // number ≥ 0
    maxRetries     // number ≥ 1; default 3. B7 and D5 share this knob.
    invariant: retryCount ≤ maxRetries


// --- piece 2: discovery ---

module Discovery
    // L2. Every checklist row needs evidence. Empty evidence fails closed.
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
        // Gate G1. No scope freeze. Gate G2. Facts come from the code only.
        // B1. Start from the concept. Read the code the concept needs. Expand the explored region.
        // B2. Extract facts that the code forces. Do not state guesses.
        // B3. For every branch, list every case, or leave it on uncovered branches.
        // B4. A case not in this node opens a named hold and points to a later node id.
        // B5. A missing fact appends an open code question. Never invent a fact.
        // B6. Stop clear only when every checklist row has evidence. Empty evidence fails closed.
        // B7. Budget equals maxRetries (default 3). Return escalated with reason code B7. Do not present to the learner.
        // B8. If the concept is still ambiguous, return escalated with reason code B8. Do not ask the learner.
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
            cur ← blank DiscoveryRecord
            cur.openCodeQuestions ← openCodeQuestions
            cur.uncoveredBranches ← uncoveredBranches
            cur.discoveryChecklist ← checklist
            // DC6 may stay unsatisfied until Phase E; discovery "clear" for converge needs DC1–DC5;
            // full discovery_status clear for teach requires DC6 after adversaryClear.
            if the concept name is still ambiguous
                // B8. Return escalated. Do not ask the learner.
                return facts, explored, openCodeQuestions, uncoveredBranches, checklist, "escalated", "B8"
            if openCodeQuestions = blank list and uncoveredBranches = blank list and Discovery.checklistSatisfied(filter checklist where id ≠ "DC6") 
                return facts, explored, openCodeQuestions, uncoveredBranches, checklist, "clear-pending-adversary", ""
            expansions ← expansions + 1
            if expansions > maxExpansions
                // B7. Do not present the rows to the learner.
                return facts, explored, openCodeQuestions, uncoveredBranches, checklist, "escalated", "B7"

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
        // C1. One node per atomic fact. C2. Prerequisite edges so no node needs an undefined term.
        // C3. Definitions and synonyms on the node that introduces them.
        // C4. Cases or named holds (Gate G6). C7. Predecessors and followers from the edges.
        // Create one node per atomic fact; add definitions, synonyms, cases, holds.
        // Add edges; every deferred case must be a NamedHold with hold-target edge.
        if Graph.hasPrerequisiteCycle(graph.edges)
            error "prerequisite cycle"   // C5. Fail closed. Never return "no cycle" without a real check. E6d.
        if Graph.hasSoftHole(graph.nodes)
            error "soft hole: deferred case without named hold and closer"   // C6. E6g.
        // Set predecessors/followers from edges.
        return graph

// --- piece 4: converge + adversary ---

module Validation
    function substanceEqual(a, b)   // a, b: DiscoveryRecord → true/false
        // L3. The code-forced fact set is unique. D2. Compare fact sets. D6. Substance checklist.
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

    function converge(concept, maxRetries)   // → DiscoveryRecord
        // Gate G3. Agents must match the fact set. D1. At least two agents through Phases B–C.
        retryCount ← 0
        while retryCount ≤ maxRetries
            facts1, explored1, oq1, ub1, cl1, dstat1, reason1 ← Discovery.discoverFacts(concept, maxRetries)
            facts2, explored2, oq2, ub2, cl2, dstat2, reason2 ← Discovery.discoverFacts(concept, maxRetries)
            if dstat1 = "escalated" or dstat2 = "escalated"
                // B7 or B8. Return escalated. Do not present to the learner.
                c1 ← blank DiscoveryRecord
                c1.concept ← concept
                c1.exploredRegion ← explored1
                c1.openCodeQuestions ← oq1
                c1.uncoveredBranches ← ub1
                c1.discoveryChecklist ← cl1
                c1.result ← "escalated"
                c1.reason ← reason1 if dstat1 = "escalated" else reason2
                c1.discoveryStatus ← "escalated"
                return c1
            graph1 ← Graph.buildGraph(facts1)
            graph2 ← Graph.buildGraph(facts2)
            c1 ← blank DiscoveryRecord
            c1.concept ← concept
            c1.exploredRegion ← explored1
            c1.graph ← graph1
            c1.openCodeQuestions ← oq1
            c1.uncoveredBranches ← ub1
            c1.discoveryChecklist ← cl1
            c1.discoveryStatus ← dstat1
            c1.convergenceStatus ← "pending"
            c1.adversaryStatus ← "pending"
            c2 ← blank DiscoveryRecord
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
                // D4. Fact sets match and DC1–DC5 are ready for the adversary.
                c1.result ← "clear"
                c1.reason ← ""
                return c1
            retryCount ← retryCount + 1
            // D3. Re-enter discovery on the disputed region only. Internal loop. Do not average away.
        // D5. Return escalated. Do not present the conflict.
        c1.result ← "escalated"
        c1.reason ← "D5"
        c1.convergenceStatus ← "escalated"
        return c1

    function adversaryClear(curriculum, proofBacklog, expandCount, maxRetries)   // → DiscoveryRecord, list of ProofEntry
        if expandCount = null
            expandCount ← 0
        if maxRetries = null
            maxRetries ← 3
        // Gate G4. The adversary must not refute the graph by chasing a ghost.
        // E1. Graph pass against the converged graph.
        // E2. Any code may be read. New reads append to exploredRegion. Outside-world attacks are ghosts.
        // E6. Graph probes only. The chunk probes belong to the caller. The caller does not set DC6.
        // E6a. Checklist rows DC1–DC5. E6d. Prerequisite cycles. E6g. Soft holes (C6).
        // L1 killed: the adversary seeks disproof in any code.
        append(proofBacklog, ProofEntry("L1 adversary blindness", "killed",
            "adversary seeks disproof in any code; miss forces discovery expand"))
        realHoleFound ← false
        // Hunt graph probes only: DC1–DC5 (E6a), cycles (E6d), soft holes (E6g),
        // and contradicting code outside the prior explored window.
        // E5. For each attack: append ProofEntry.
        // Chunk probes (hold sync, use-checks, sanityByPred, stranded) are not run here.
        if realHoleFound
            // E3. Graph hole. Internal loop: expand discovery and re-enter converge. Not a caller call.
            expandCount ← expandCount + 1
            if expandCount > maxRetries
                curriculum.result ← "escalated"
                curriculum.reason ← "D5"
                curriculum.convergenceStatus ← "escalated"
                return curriculum, proofBacklog
            again ← Validation.converge(curriculum.concept, maxRetries)
            if again.result = "escalated"
                return again, proofBacklog
            return Validation.adversaryClear(again, proofBacklog, expandCount, maxRetries)
        // DC6. Set only by this graph hunt. E4. adversaryStatus clear for the graph pass.
        setChecklistRow(curriculum.discoveryChecklist, "DC6", true, proofBacklogEvidence)
        curriculum.adversaryStatus ← "clear"
        if Discovery.checklistSatisfied(curriculum.discoveryChecklist)
            curriculum.discoveryStatus ← "clear"
        return curriculum, proofBacklog

// --- piece 5: entry ---

function run(concept, targetCode, mode, delta, maxRetries)
    // One entry point. Outputs are the DiscoveryRecord fields recorded today, saved as one file by the caller.
    if maxRetries = null
        maxRetries ← 3
    adversaryOnly ← false
    convergeFlag ← "on"
    if delta ≠ null
        adversaryOnly ← delta.adversaryOnly
        convergeFlag ← delta.converge
    if adversaryOnly and not (mode = "delta" and convergeFlag = "off")
        error "adversary-only flag rejected; do no work"
    if mode = "full"
        // No seed, or the checklist is not satisfied: Phases B, C, D, and the graph pass.
        // Seeded saved graph whose checklist is already satisfied: Phase D and the graph pass
        // over the WHOLE graph, not only the new parts.
        if delta ≠ null and delta.seed ≠ null and Discovery.discoveryComplete(delta.seed)
            fresh ← Validation.converge(concept, maxRetries)
            if fresh.result = "escalated"
                return fresh
            if not Validation.substanceEqual(delta.seed, fresh)
                curriculum ← fresh
            else
                curriculum ← delta.seed
                curriculum.convergenceStatus ← "converged"
                curriculum.result ← "clear"
                curriculum.reason ← ""
        else
            curriculum ← Validation.converge(concept, maxRetries)
            if curriculum.result = "escalated"
                return curriculum
        curriculum, proof ← Validation.adversaryClear(curriculum, blank list, 0, maxRetries)
        curriculum.proofEntries ← proof
        return curriculum
    // mode = delta
    if convergeFlag = "on"
        // Phase B on the region, then C, D, and the graph pass.
        curriculum ← Validation.converge(concept, maxRetries)
        if curriculum.result = "escalated"
            return curriculum
        curriculum, proof ← Validation.adversaryClear(curriculum, blank list, 0, maxRetries)
        curriculum.proofEntries ← proof
        return curriculum
    if adversaryOnly
        // Graph pass only, on the caller-made node.
        curriculum ← delta.existing
        curriculum, proof ← Validation.adversaryClear(curriculum, blank list, 0, maxRetries)
        curriculum.proofEntries ← proof
        return curriculum
    if delta.callerNodes ≠ null
        // Phase C and the graph pass on the caller-made nodes. Do not run Phase D.
        curriculum ← delta.existing
        curriculum.graph ← Graph.buildGraph(delta.callerNodes)
        curriculum, proof ← Validation.adversaryClear(curriculum, blank list, 0, maxRetries)
        curriculum.proofEntries ← proof
        return curriculum
    if delta.regionIsMissingFact
        // Phase B on the missing fact, then Phase C.
        facts, explored, oq, ub, checklist, dstat, reason ← Discovery.discoverFacts(concept, maxRetries)
        if dstat = "escalated"
            curriculum ← blank DiscoveryRecord
            curriculum.result ← "escalated"
            curriculum.reason ← reason
            curriculum.discoveryStatus ← "escalated"
            return curriculum
        curriculum ← delta.existing
        curriculum.graph ← Graph.buildGraph(facts)
        curriculum.exploredRegion ← explored
        curriculum.result ← "clear"
        return curriculum
    // Region is node ids: Phase C only.
    curriculum ← delta.existing
    curriculum.graph ← Graph.buildGraph(delta.regionNodes)
    curriculum.result ← "clear"
    return curriculum
```
