---
description: Understand the blast radius of a proposed change before implementing it — read and reason about callers, downstream effects, and pattern-fit, not just grep for symbol occurrences
argument-hint: [the change or surface to analyze, or leave blank to target the most recently proposed change]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> harness config root, {{AGENT_COMMANDS_DIR}} -> harness command dir, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# Code Pi

Target: $ARGUMENTS — or, if empty, the most recently proposed change in this conversation (a function, endpoint, schema field, or config key someone is about to modify). If it's ambiguous which change that is, ask rather than guess.

## Scope note
This analyzes blast radius of changes to *existing* code. A new function/endpoint that will *become* a shared surface is a forward-looking design-correctness question, not a blast-radius one — out of scope by design, not a silent omission.

## When to use
Before implementing a change, especially one touching a shared module, an API, a schema, or config with unclear downstream reach. If you're about to make the first edit to a shared-module/schema/config file without having run this first, run it now — treat the edit already made as the analysis subject and pause for confirmation before making any further edits.

## Process

**1. Identify the exact surface being changed** (a function, an endpoint, a schema field, a config key). Scope one surface per coherent contract change — if the change bundles multiple independent contract changes, treat each separately. For a config key, "surface" means the key/env-var name itself, not a function signature.

**2. Find every caller or consumer, then actually read each call site.** Use search tooling (grep/Explore) to find candidates — that's the mechanical part. Reading and reasoning about each one is the actual job here: what shape does it expect back, how does it handle errors, does it assume a particular ordering or timing, does it rely on a side effect, and does this change alter the site's complexity, resource pattern, or per-call cost (a lookup becoming a scan, a cache disappearing, an allocation added inside a loop, a new billed third-party call that's cheap in code but expensive at scale). For a config key, "consumer" means every reference to the key/env-var name across code and deploy config, not a call site. For event/queue/pubsub systems, also search for the event/topic/message-schema name — subscribers don't call the changed code, they consume a payload shape, so a call-site search alone will miss them. If the caller count is large, prioritize by centrality and *disclose the sampling* in the final report — never let partial coverage read as a full sweep.

**3. Trace one hop further downstream**: what do those callers feed into, who reads what they produce. One hop is a floor, not a ceiling — for a high-centrality surface (many callers, or callers that are themselves widely depended on), keep tracing until you reach a boundary (a persisted store, an external service, a UI) or a clear dead-end. If tracing re-enters a node you've already read, treat that as a dead-end, not a fresh branch. If depth becomes impractical before reaching a boundary, stop and disclose how many hops you actually traced and why — the same way you disclose sampling in step 2. Also check non-call-edge readers: a shared mutable value (module-level state, a cache, a database row) is read by consumers that never call the writer — find those by searching for other readers/writers of the same resource, not by following call edges. Also check text-coupled, non-code consumers: a log line, field name, or metric name referenced by a dashboard, alert rule, or log-parser config won't show up in a call-graph trace — search for it by name if such config exists in the repo.

**Also trace upstream, bounded.** Separately from downstream tracing: check what happens *above* the surface — a middleware, decorator, or gateway that enforces something (authorization, rate limiting, sanitization, request context) that the surface or its callers rely on existing. A caller can look completely safe downstream while silently depending on an upstream check that this change removes or bypasses. Trace upward only as far as the nearest enforcement point — don't trace exhaustively to the network edge. If no enforcement point turns up within that bound, say so rather than assuming none exists.

**4. Check how similar changes were made elsewhere** in the codebase (naming, error handling, validation style), and note whether this change matches that pattern or deviates from it, and whether the deviation looks deliberate. Before declaring "no established pattern," search by both name and structural shape, across the immediate module and at least one sibling module chosen for structural similarity, not convenience. If the existing pattern itself has a known weakness, note the weakness — but only when it's a correctness or security concern, not a style preference — rather than passing it through as "matches convention."

**5. Surface the non-obvious risks.** If you're constrained on time or context, the security and schema/persisted-data checks below are mandatory; the rest are best-effort — say explicitly which ones you skipped rather than silently dropping them.
- Shared mutable state, implicit ordering, a dropped lock/mutex, or single-item calls batched into bulk with new partial-failure interleaving — concurrency hazards the change itself introduces, not just pre-existing shared state it touches.
- Feature flags gating behavior — state explicitly whether the flag's current rollout state is knowable from the code/config you can see; if not, say so rather than omitting it.
- Deploy-independence and rollback-safety — can this deploy without lockstep with a caller, and can it be reverted once live, especially if it's already written data in a new format, or if long-tailed clients (older app versions, external integrators) will keep calling the old contract regardless of how fast the server rolls back.
- Tests that encode assumptions about the old behavior — also note call sites with *no* test coverage at all, since that's a blast-radius fact in its own right.
- For a schema-field surface specifically: compatibility with data already persisted under the old schema (nullable-to-required, type narrowing) — this can't be caught by caller/shape analysis alone, since it's a fact about existing data, not about any consumer's code.
- Security: does any caller rely on the changed surface having already enforced a permission/authz check (cross-reference the upstream trace above); does a validation/sanitization assumption shift (a field validated upstream becomes unvalidated, or vice versa); does traced data reach a new sink (a log, an external call) that could expose something sensitive; does a hop cross a privilege boundary (e.g., a user-authenticated path into an admin-only path) — list these first in Open Risks, ahead of routine findings.
- Multi-tenancy: can shared logic leak or merge data across tenants (e.g., a cache key missing a tenant qualifier) — a distinct failure mode from generic authz.

Consciously out of scope, not silently omitted: dependency licensing/compliance implications (relevant only when the change itself swaps or upgrades a dependency) and locale/i18n breakage beyond what step 2's "shape returned" check already surfaces for format changes.

## Output

Deliver a blast-radius report:
- **Surface** — what's being analyzed, and its trust/exposure level if relevant (public / authenticated / internal-only), labeled as inferred from code, not verified against infra or network config.
- **Call Sites** — shape/error/ordering/side-effect/complexity/cost findings from step 2, and whether each was fully read or sampled.
- **Downstream Effects** — one-hop-plus findings from step 3, tagged as call-edge or non-call-edge, including how far tracing actually went and why it stopped.
- **Upstream Enforcement** — what was found (or not found) tracing upward to the nearest enforcement boundary.
- **Pattern-Fit Verdict** — match / deviation / unclear, with the evidence it's based on.
- **Open Risks** — each tagged by category (security, data-migration, deploy/rollback, performance, other — untested call sites tag as deploy/rollback), listed in rough severity order with privilege-boundary crossings and other security-critical findings first.
- **Not Checked** — sampled-not-exhaustive call sites, rollout state that couldn't be determined from code, consumers outside this repo/workspace, externally-hosted contract docs (a docs portal, external registry) describing this surface, anything else explicitly out of scope.

Every section distinguishes "checked, found nothing" from "not examined" — a blank section never implies a clean bill if it just wasn't looked at.

## Constraints
- End your turn with this report and wait for explicit confirmation before proceeding to implementation. Don't self-authorize continuing into the change based on your own report.
- This is the reasoning/synthesis layer on top of raw search (Explore/grep) — not a replacement for search, and not a replacement for migration planning, security review, or performance testing when those are substantial enough to need their own dedicated pass. Flag when one is likely needed rather than trying to fully execute it here.
