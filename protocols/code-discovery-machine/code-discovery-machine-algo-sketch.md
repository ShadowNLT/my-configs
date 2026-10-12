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

    function discoverFacts(concept, maxExpansions, region)   // → Curriculum fragment fields
        // region null: the whole concept. region set: that region only. Do not widen a region call to the whole concept.
        // Gate G1. No scope freeze. Gate G2. Facts come from the code only.
        // B1. Start from the concept, or from the region when the caller passed one. Read that code. Expand the explored region inside that scope.
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
            // Read more related code inside the scope (the region, or the whole concept when region is null).
            // Append facts; update explored.description. Do not leave a region scope.
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

    function replaceNode(graph, node)   // Graph, Node → Node
        // A fixed node replaces the node with the same id. A new id is appended.
        for each i in graph.nodes
            if graph.nodes[i].id = node.id
                graph.nodes[i] ← node
                return graph.nodes[i]
        append(graph.nodes, node)
        return node

    function replaceEdges(graph, node)   // keep this node's edges; replace them when they changed
        kept ← blank list
        for each edge in graph.edges
            if edge.fromId ≠ node.id and edge.toId ≠ node.id
                append(kept, edge)
        graph.edges ← kept
        for each predId in node.predecessors
            edge ← blank Edge
            edge.fromId ← predId
            edge.toId ← node.id
            edge.kind ← "prerequisite"
            append(graph.edges, edge)
        for each followerId in node.followers
            edge ← blank Edge
            edge.fromId ← node.id
            edge.toId ← followerId
            edge.kind ← "prerequisite"
            append(graph.edges, edge)
        for each hold in node.holdsOpened
            if hold.closerNodeId ≠ ""
                edge ← blank Edge
                edge.fromId ← node.id
                edge.toId ← hold.closerNodeId
                edge.kind ← "hold-target"
                append(graph.edges, edge)
        return graph

    function mergeGraphs(base, addition)   // Graph, Graph → Graph
        // Keep every node and edge already in base. Replace a node when its id already exists, and replace its edges when they changed.
        if base = null
            base ← blank Graph
            base.nodes ← blank list
            base.edges ← blank list
        if addition = null
            return base
        for each node in addition.nodes
            Graph.replaceNode(base, node)
            kept ← blank list
            for each edge in base.edges
                if edge.fromId ≠ node.id and edge.toId ≠ node.id
                    append(kept, edge)
            base.edges ← kept
            for each edge in addition.edges
                if edge.fromId = node.id or edge.toId = node.id
                    append(base.edges, edge)
        for each edge in addition.edges
            if edge not in base.edges
                append(base.edges, edge)
        return base

    function mergeNodes(graph, nodes)   // Graph, list of Node → Graph
        // Caller-made nodes join the existing graph. An existing id is replaced, not dropped. Edges stay, then Phase C runs.
        if graph = null
            graph ← blank Graph
            graph.nodes ← blank list
            graph.edges ← blank list
        for each node in nodes
            Graph.replaceNode(graph, node)
        return Graph.phaseCOnRegion(graph, nodes)

    function phaseCOnRegion(graph, regionNodes)   // Graph, nodes or node ids → Graph
        // Phase C for those nodes, inside the existing graph. Do not return a graph of only the region's nodes.
        // A plain node id is looked up and still gets Phase C. It is not skipped.
        if graph = null
            graph ← blank Graph
            graph.nodes ← blank list
            graph.edges ← blank list
        for each item in regionNodes
            if item is an id
                node ← find graph.nodes where node.id = item
                if node = null
                    error "region node id is not in the graph"
            else
                node ← Graph.replaceNode(graph, item)
                Graph.replaceEdges(graph, node)
            // C2. Prerequisite edges so this node needs no undefined term.
            for each predId in node.predecessors
                if no prerequisite edge predId → node.id is in graph.edges
                    edge ← blank Edge
                    edge.fromId ← predId
                    edge.toId ← node.id
                    edge.kind ← "prerequisite"
                    append(graph.edges, edge)
            // C7. Predecessors and followers come from the edges that touch this node.
            node.predecessors ← fromIds of prerequisite edges whose toId = node.id
            node.followers ← toIds of prerequisite edges whose fromId = node.id
        // C5. Fail closed on a prerequisite cycle. C6. Fail closed on a soft hole.
        if Graph.hasPrerequisiteCycle(graph.edges)
            error "prerequisite cycle"
        if Graph.hasSoftHole(graph.nodes)
            error "soft hole: deferred case without named hold and closer"
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

    function mergePartial(base, facts, explored, openCodeQuestions, uncoveredBranches, checklist)   // → DiscoveryRecord
        // Merge a Phase B fragment into the caller's record. Never drop the caller's graph.
        if base = null
            base ← blank DiscoveryRecord
        if facts ≠ null and facts ≠ blank list
            base.graph ← Graph.mergeGraphs(base.graph, Graph.buildGraph(facts))
        if explored ≠ null
            if base.exploredRegion = null
                base.exploredRegion ← explored
            else
                base.exploredRegion.description ← base.exploredRegion.description + "\n" + explored.description
        for each q in openCodeQuestions
            if q not in base.openCodeQuestions
                append(base.openCodeQuestions, q)
        for each b in uncoveredBranches
            if b not in base.uncoveredBranches
                append(base.uncoveredBranches, b)
        for each row in checklist
            setChecklistRow(base.discoveryChecklist, row.id, row.satisfied, row.evidence)
        return base

    function copyRecord(saved)   // → DiscoveryRecord
        // A real copy. Later merges must not alias the saved graph.
        copy ← blank DiscoveryRecord
        copy.concept ← saved.concept
        copy.graph ← blank Graph
        copy.graph.nodes ← a copy of saved.graph.nodes
        copy.graph.edges ← a copy of saved.graph.edges
        copy.exploredRegion ← saved.exploredRegion
        copy.openCodeQuestions ← a copy of saved.openCodeQuestions
        copy.uncoveredBranches ← a copy of saved.uncoveredBranches
        copy.discoveryChecklist ← a copy of saved.discoveryChecklist
        copy.proofEntries ← a copy of saved.proofEntries
        copy.discoveryStatus ← saved.discoveryStatus
        copy.convergenceStatus ← saved.convergenceStatus
        copy.adversaryStatus ← saved.adversaryStatus
        return copy

    function convergeSaved(saved, maxRetries, region)   // → DiscoveryRecord
        // Phase D over the saved graph. Two fresh reads. Do not start from a blank concept, and do not return a fresh graph.
        // region null: the code the saved graph covers. region set: that region only.
        // D1. Two independent discoverFacts calls. They are not copies of saved and not the same call.
        // D2 and D6. Check each read against saved and against the other read.
        // D3. When the two reads agree and differ from saved, merge that agreed region and read again. When they disagree, do not merge them. Do not average and do not replace saved.
        // D4. Match, and DC1–DC5 ready: convergenceStatus converged, result clear.
        // D5. Budget spent: return this same saved record escalated.
        if region = null
            region ← saved.graph
        retryCount ← 0
        current ← saved
        while retryCount ≤ maxRetries
            facts1, explored1, oq1, ub1, cl1, dstat1, reason1 ← Discovery.discoverFacts(current.concept, maxRetries, region)
            facts2, explored2, oq2, ub2, cl2, dstat2, reason2 ← Discovery.discoverFacts(current.concept, maxRetries, region)
            if dstat1 = "escalated" or dstat2 = "escalated"
                if dstat1 = "escalated"
                    current ← Validation.mergePartial(current, facts1, explored1, oq1, ub1, cl1)
                    current.reason ← reason1
                else
                    current ← Validation.mergePartial(current, facts2, explored2, oq2, ub2, cl2)
                    current.reason ← reason2
                current.result ← "escalated"
                current.discoveryStatus ← "escalated"
                return current
            left ← Validation.mergePartial(Validation.copyRecord(current), facts1, explored1, oq1, ub1, cl1)
            right ← Validation.mergePartial(Validation.copyRecord(current), facts2, explored2, oq2, ub2, cl2)
            // D4. DC1–DC5 ready. DC6 is the later graph pass, so it is not required here.
            ready ← every DC1–DC5 row on left and on right is satisfied and has evidence
            if Validation.substanceEqual(left, right) and Validation.substanceEqual(left, current) and Validation.substanceEqual(right, current) and ready
                // Merge into the saved graph so a fixed node replaces the old one. Return current, not left or right.
                current ← Validation.mergePartial(current, facts1, explored1, oq1, ub1, cl1)
                current ← Validation.mergePartial(current, facts2, explored2, oq2, ub2, cl2)
                current.convergenceStatus ← "converged"
                current.result ← "clear"
                current.reason ← ""
                return current
            disputed ← nodes where left, right, or current differ
            if Validation.substanceEqual(left, right) and ready
                // The two reads agree and differ from saved. Merge that agreed region. Do not average two different reads.
                current ← Validation.mergePartial(current, facts1, explored1, oq1, ub1, cl1)
                current ← Validation.mergePartial(current, facts2, explored2, oq2, ub2, cl2)
            // D3. Next reads stay on the disputed region. Two reads that disagree are not merged.
            region ← disputed
            retryCount ← retryCount + 1
        current.result ← "escalated"
        current.reason ← "D5"
        current.convergenceStatus ← "escalated"
        return current

    function adversaryClear(curriculum, proofBacklog, expandCount, maxRetries, onlyNode)   // → DiscoveryRecord, list of ProofEntry
        if expandCount = null
            expandCount ← 0
        if maxRetries = null
            maxRetries ← 3
        // Gate G4. The adversary must not refute the graph by chasing a ghost.
        // E1. Graph pass against the converged graph. When onlyNode is set, review that node only. Do not review the rest of the record.
        // E2. Any code may be read. New reads append to exploredRegion. Outside-world attacks are ghosts.
        // E6. Graph probes only. The chunk probes belong to the caller. The caller does not set DC6.
        // E6a. Checklist rows DC1–DC5. E6d. Prerequisite cycles. E6g. Soft holes (C6).
        // L1 killed: the adversary seeks disproof in any code.
        append(proofBacklog, ProofEntry("L1 adversary blindness", "killed",
            "adversary seeks disproof in any code; miss forces discovery expand"))
        realHoleFound ← false
        huntNodes ← curriculum.graph.nodes
        if onlyNode ≠ null
            huntNodes ← onlyNode
        // Hunt graph probes only, on huntNodes: DC1–DC5 (E6a), cycles (E6d), soft holes (E6g),
        // and contradicting code outside the prior explored window.
        // E5. For each attack: append ProofEntry onto proofBacklog. Do not replace entries already there.
        // Chunk probes (hold sync, use-checks, sanityByPred, stranded) are not run here.
        if realHoleFound
            // E3. Graph hole. Internal loop: expand discovery and re-enter converge. Not a caller call.
            expandCount ← expandCount + 1
            if expandCount > maxRetries
                curriculum.result ← "escalated"
                curriculum.reason ← "D5"
                curriculum.convergenceStatus ← "escalated"
                return curriculum, proofBacklog
            if onlyNode ≠ null
                // Stay on this node. Phase B on that node only, merged back. Do not converge the whole concept.
                facts, explored, oq, ub, checklist, dstat, reason ← Discovery.discoverFacts(curriculum.concept, maxRetries, onlyNode)
                if dstat = "escalated"
                    curriculum ← Validation.mergePartial(curriculum, facts, explored, oq, ub, checklist)
                    curriculum.result ← "escalated"
                    curriculum.reason ← reason
                    curriculum.discoveryStatus ← "escalated"
                    return curriculum, proofBacklog
                curriculum ← Validation.mergePartial(curriculum, facts, explored, oq, ub, checklist)
                return Validation.adversaryClear(curriculum, proofBacklog, expandCount, maxRetries, onlyNode)
            // No single node named. Converge over the hole's region and the existing graph, then merge.
            // Do not call converge on the whole concept. Do not return a fresh graph.
            holeRegion ← the nodes in curriculum.graph that the hole touches
            curriculum ← Validation.convergeSaved(curriculum, maxRetries, holeRegion)
            if curriculum.result = "escalated"
                return curriculum, proofBacklog
            return Validation.adversaryClear(curriculum, proofBacklog, expandCount, maxRetries, null)
        // DC6 and the clear statuses are for a whole-graph pass only.
        // A review of named nodes leaves DC6, adversaryStatus, and discoveryStatus unchanged.
        if onlyNode = null
            // DC6. Set only by this graph hunt. E4. adversaryStatus clear for the graph pass.
            setChecklistRow(curriculum.discoveryChecklist, "DC6", true, proofBacklogEvidence)
            curriculum.adversaryStatus ← "clear"
            if Discovery.checklistSatisfied(curriculum.discoveryChecklist)
                curriculum.discoveryStatus ← "clear"
        return curriculum, proofBacklog

// --- piece 5: entry ---

function addProof(curriculum, proof)
    // E5. Add entries. Do not replace the entries already on the record.
    if curriculum.proofEntries = null
        curriculum.proofEntries ← blank list
    for each entry in proof
        if entry not in curriculum.proofEntries
            append(curriculum.proofEntries, entry)
    return curriculum

function run(concept, targetCode, mode, delta, maxRetries)
    // One entry point. Outputs are the DiscoveryRecord fields recorded today, saved as one file by the caller.
    // targetCode is the code the concept is about.
    if maxRetries = null
        maxRetries ← 3
    adversaryOnly ← false
    convergeFlag ← "on"
    if delta ≠ null
        adversaryOnly ← delta.adversaryOnly
        convergeFlag ← delta.converge
        if delta.regionNodes = null and delta.region ≠ null and not delta.regionIsMissingFact
            delta.regionNodes ← delta.region
    if adversaryOnly and not (mode = "delta" and convergeFlag = "off")
        error "adversary-only flag rejected; do no work"
    if mode = "full"
        // No seed, or the checklist is not satisfied: Phases B, C, D, and the graph pass.
        // Seeded saved graph whose checklist is already satisfied: Phase D over that saved graph,
        // then the graph pass over the WHOLE graph. Do not discover the concept from scratch.
        if delta ≠ null and delta.seed ≠ null and Discovery.discoveryComplete(delta.seed)
            curriculum ← Validation.convergeSaved(delta.seed, maxRetries)
            if curriculum.result = "escalated"
                return curriculum
        else
            curriculum ← Validation.converge(concept, maxRetries)
            if curriculum.result = "escalated"
                return curriculum
        prior ← curriculum.proofEntries
        if prior = null
            prior ← blank list
        curriculum, proof ← Validation.adversaryClear(curriculum, prior, 0, maxRetries, null)
        curriculum ← addProof(curriculum, proof)
        return curriculum
    // mode = delta. Merge into the caller's graph. Never replace it.
    // A path that runs Phase B runs it on the region only, then merges.
    // Converge on, and a missing fact, run Phase B. Adversary-only, caller-made nodes,
    // and a region of node ids do not: those paths are Phase C or a scoped graph pass.
    if delta = null or delta.existing = null
        error "delta requires the caller's graph"
    if convergeFlag = "on"
        // Converge on. Phase B on the region only, as two independent reads inside Phase D.
        // Merge into the existing graph (Phase C on the merged nodes). The graph pass then covers
        // the region and the existing graph. Not one discoverFacts call, and not the whole concept.
        base ← delta.existing
        base ← Validation.convergeSaved(base, maxRetries, delta.region)
        if base.result = "escalated"
            return base
        prior ← base.proofEntries
        if prior = null
            prior ← blank list
        base, proof ← Validation.adversaryClear(base, prior, 0, maxRetries, null)
        base ← addProof(base, proof)
        return base
    if adversaryOnly
        // Adversary-only. Merge the caller-made nodes into the existing graph, then review that list only.
        base ← delta.existing
        if delta.callerNodes = null or length(delta.callerNodes) = 0
            error "adversary-only requires caller-made nodes; do no work"
        base.graph ← Graph.mergeNodes(base.graph, delta.callerNodes)
        prior ← base.proofEntries
        if prior = null
            prior ← blank list
        base, proof ← Validation.adversaryClear(base, prior, 0, maxRetries, delta.callerNodes)
        base ← addProof(base, proof)
        return base
    if delta.callerNodes ≠ null
        // Caller-made nodes, not adversary-only. Merge them into the existing graph. Phase C and the graph pass on those nodes.
        // Do not rebuild the graph from only those nodes. Do not run Phase D.
        base ← delta.existing
        base.graph ← Graph.mergeNodes(base.graph, delta.callerNodes)
        prior ← base.proofEntries
        if prior = null
            prior ← blank list
        base, proof ← Validation.adversaryClear(base, prior, 0, maxRetries, delta.callerNodes)
        base ← addProof(base, proof)
        return base
    if delta.regionIsMissingFact
        // Missing fact. Phase B on that fact only, then Phase C via the merge. Not discovery of the whole concept.
        base ← delta.existing
        facts, explored, oq, ub, checklist, dstat, reason ← Discovery.discoverFacts(concept, maxRetries, delta.region)
        base ← Validation.mergePartial(base, facts, explored, oq, ub, checklist)
        if dstat = "escalated"
            // Return the merged record. Do not return an empty one.
            base.result ← "escalated"
            base.reason ← reason
            base.discoveryStatus ← "escalated"
            return base
        base.result ← "clear"
        base.reason ← ""
        return base
    // Region is node ids. Phase C on that region, merged into the existing graph.
    base ← delta.existing
    base.graph ← Graph.phaseCOnRegion(base.graph, delta.regionNodes)
    base.result ← "clear"
    base.reason ← ""
    return base
```
