---
name: app-breaker
description: >
  Adversarial "how does this break?" pass over whatever concrete artifact is in front of you.
  Its first move is always to infer the context from the conversation, then hunt for runtime
  and concrete failure modes specific to that context: a code diff (how the change breaks, and
  how it breaks its callers), a live browser/app session being tested (how the running flow
  breaks right now), a config/infra file, an API or data contract, or a data transform. Reports
  a severity-ranked list of failure modes with concrete repro conditions by default; with
  --prove it attempts to actually trigger the top findings. Owns runtime/concrete breakage only:
  defers plan and decision critique to /adversarial-review and general line-by-line bug review
  to /code-review.

  Trigger on: "/app-breaker", "app breaker", "break this", "how could this break", "what breaks
  this", "find the failure modes", "how does this fail", "try to break the app", "stress the
  running app", or any pipe like "<thing> | app-breaker".
argument-hint: [the diff/artifact to break, or leave blank to infer from context] [--prove] [--live] [--diff]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> ~/.claude|~/.cursor|~/.codex|~/.config/opencode, {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# App Breaker

You are running an adversarial failure-hunt. The single question you answer: **how does the
concrete thing in front of me break in practice?** Not "is this a good idea" (that is
`/adversarial-review`), not "line-by-line, is this code correct" (that is `/code-review`). You
hunt runtime and concrete failure modes, rank them by severity, and by default report them; on
`--prove` you go further and try to make the top ones actually happen.

Two failures are equally bad: a padded list of theoretical breaks that can't actually occur, and
missing a real break that a user would hit in the first hour. Default posture is **a hostile
user and a bad network, not a reviewer being polite**.

---

## 1. Parse arguments and infer the context

`$ARGUMENTS` is a free-form string: `["<target>"] [flags]`. The target may be empty.

**Flags:**
- `--prove` — after reporting, attempt to actually trigger the top findings (see §5). Off by
  default because triggering is side-effecting and slower.
- `--live` — force LIVE context (a running app/browser session is the target).
- `--diff` — force DIFF context (a code change is the target). To force any of the other
  families, name it in the target (e.g. "treat this as config"); only LIVE and DIFF get flags
  because they're the two most easily confused.

**Target resolution:** if a target is given, break that. If empty, infer it from the
conversation, newest signal first. If it is genuinely ambiguous which of two artifacts is the
target, ask rather than guess, one short question.

**Context inference** — pick the family that fits what you're pointed at. These are lenses, not
rigid modes; a change can span two (e.g. a diff you are also testing live), in which case run
both lenses and say so.

| Signal in context | Context family | §4 lens |
|---|---|---|
| A code change: `git diff`, recent edits this session, a pasted patch | **DIFF** | 4.1 |
| A running app: preview/browser tools used this session, a dev server up, a flow being tested | **LIVE** | 4.2 |
| A config, IaC, env, CI, or deployment file | **CONFIG** | 4.3 |
| An API surface, schema, type, or wire/data contract | **CONTRACT** | 4.4 |
| A data transform, pipeline, query, or migration | **DATA** | 4.5 |
| None of the above cleanly | **GENERIC** | 4.6 |

State which family (or families) you picked and why in one line before you start hunting. If you
picked GENERIC, say what you fell back from.

## 2. Scope: what you own, what you hand off

You own **concrete runtime breakage** of the artifact in front of you. Stay in that lane so the
findings are actionable and don't duplicate the other tools:

- A weakness in the *plan or decision* behind the artifact → note it in one line and point to
  `/adversarial-review`. Do not expand it into a plan critique here.
- A general correctness bug unrelated to a specific failure mode (style, a cleaner refactor, a
  latent bug with no triggering condition you can name) → point to `/code-review`. Do not turn
  this into a full code review.
- Everything that is "under condition X, this breaks / errors / corrupts / hangs / misleads the
  user" is yours. If you can't name condition X, it's probably a `/code-review` finding, not an
  app-breaker one.

## 3. The hunt

For each candidate failure, you need three things or it doesn't make the list:

1. **The break** — what actually goes wrong (crash, wrong result, data loss, hang, silent
   corruption, security exposure, confusing dead-end for the user).
2. **The trigger** — the concrete condition that causes it. "Null input" is weak; "the `items`
   array is empty because the upstream filter removed everything, and line 42 does `items[0]`"
   is a finding. If you cannot state a trigger a real user or system could produce, cut it.
3. **Severity** — assign P1–P4 (see §6). Likelihood is part of severity, not a separate axis: a
   catastrophic break that literally cannot be triggered is not a P1, it's cut.

Generate candidates using the relevant §4 lens as a *prompt*, not a checklist to tick.
The lens exists to make you think of the class of break; the finding has to be real for *this*
artifact. Then run the kill pass (§4.7) on every candidate before it survives.

## 4. Context lenses

Each lens is a set of question-families to provoke real findings. Adapt them; don't recite them.

### 4.1 DIFF — how the change breaks, and how it breaks its callers
- **The change's own inputs:** empty/null/huge/malformed/unicode/negative/zero, boundary values,
  the input the old code handled but the new code no longer does.
- **Blast radius on callers:** who calls the changed symbol? Does the new signature, return
  shape, thrown-error set, or null-behavior break any of them? (If blast radius isn't already in
  hand, this is where you actually go look — grep the symbol, don't assume.)
- **Backward/forward compatibility:** old persisted data, in-flight requests, cached values,
  serialized state, a rolling deploy where old and new run at once.
- **Removed handling:** a branch, guard, validation, or catch that the diff deleted — what now
  reaches the unprotected path?
- **Concurrency & ordering:** two of these running at once, a retry, an out-of-order event, a
  partial failure halfway through.
- **Error paths:** the failure branch that never gets exercised in the happy-path demo.

### 4.2 LIVE — how the running flow breaks right now
Use the live tools to actually look; don't theorize about a running app you can inspect.
- **Inputs into the flow:** empty submit, double-submit / double-click, paste of huge or
  script-y text, wrong type, back-button mid-flow, refresh mid-flow, deep-link into a state that
  assumes prior steps.
- **State & session:** expired auth/token, logged-out mid-action, stale tab, two tabs open,
  a state the UI can reach but the backend rejects.
- **Network reality:** slow response, timeout, 500, 429, dropped connection mid-request, the
  request that succeeds on the server but the response never arrives.
- **Data shape:** zero results, one result, thousands of results, missing optional fields, a
  field that's null where the UI assumes a string.
- **Check what actually happened:** read console errors, network failures, and server logs, not
  just the rendered screen. A green screen with a red console is still a break.

### 4.3 CONFIG — how the config breaks the system
- Missing/empty/misspelled key; wrong type (string where int expected); env var unset in one
  environment but not another.
- Values that parse but are wrong: a timeout of 0, a pool size of 1, a path that doesn't exist,
  a secret that's the dev default.
- Precedence & override order: which layer wins, and does the surprising one win?
- Blast radius across environments: this is fine in dev and catastrophic in prod (or the
  reverse). Secrets committed, ports collided, a feature flag defaulting the dangerous way.

### 4.4 CONTRACT — how the API/schema/type breaks its consumers
- Every optional field a consumer might treat as required, and vice versa.
- Enum/union growth: a new variant an old consumer doesn't handle.
- Nullability, empty vs absent, empty-array vs null, `0`/`""`/`false` vs missing.
- Pagination, ordering, and limit edge cases; the response for "no results" and "too many".
- Versioning: an old client against the new contract and a new client against the old data.
- Error contract: undocumented error shapes, a 200 with an error body, partial success.

### 4.5 DATA — how the transform/query/migration breaks
- Empty input set; a single row; duplicates; nulls in a join key; encoding/locale/timezone.
- Numeric: overflow, precision loss, division by zero, off-by-one on ranges/boundaries.
- Idempotency & partial failure: run twice, run on already-migrated data, fail halfway and
  resume, rollback.
- Scale: the query that's fine on 1k rows and dies on 10M; a full-table scan; a lock held too
  long.
- Silent corruption is worse than a crash — hunt for the transform that produces *plausible
  wrong output* nobody notices.

### 4.6 GENERIC — fallback runtime lens
When nothing above fits, fall back to the universal axes: bad/edge inputs, failure/error paths,
concurrency and ordering, resource exhaustion (memory/disk/handles/rate limits), state and
lifecycle assumptions, and the trust boundary (anything from outside is hostile until validated).

### 4.7 The kill pass (run on every candidate)
Before a candidate survives, try hard to kill it. A candidate dies if:
- You cannot name a trigger a real user or system could actually produce.
- Existing code, validation, a type, or a framework guarantee already prevents it (go check;
  don't assume it's unguarded).
- It's the same underlying break as another finding (merge them; don't inflate the count).
- It's a plan weakness or a general bug with no runtime trigger (hand off per §2).

Surviving the kill pass is the bar for the list. Killing a plausible-looking candidate is a
*good* outcome, not a failure — it's what keeps the list honest.

## 5. --prove: try to actually trigger the top findings

Only with `--prove`. Take the top findings (every P1, then P2s until the cost of proving outweighs the value, usually
the top three to five) and attempt to make them actually happen, strongest evidence first:
- **LIVE:** drive the app with the tools — submit the empty form, throttle the network, feed the
  huge input — and capture the console error / failed request / broken screen as proof.
- **DIFF / DATA / GENERIC:** exercise the code path with the triggering input (a quick script, a
  test, a REPL) and capture the actual failure.
- **CONFIG / CONTRACT:** construct the offending config/payload and show the concrete rejection
  or misbehavior.

Respect the environment and the safety rules. Safe, reversible test actions against a
dev/preview/local target on test data (submitting a throwaway form, throttling the network,
feeding a large input) are the intended prove path, so do them. Stop at the line the safety rules
draw: never do anything destructive, and never perform an action that is prohibited or requires
the user's permission (a real send, purchase, deletion, submission of real user data, or any
irreversible control in a production or shared environment) just to prove a point. When proving a
finding would cross that line, build a safe equivalent if you can; otherwise describe the repro
precisely and mark it **unproven**. Report each top finding as **proven** (with the evidence) or
**unproven** (with why).

## 6. Severity scale

- **P1 — will break in normal use, high impact.** Data loss, crash on a common path, security
  exposure, silent wrong output a user relies on. A real user or system hits this soon.
- **P2 — breaks under a plausible-but-not-constant condition, real impact.** A common edge (empty
  set, slow network, expired session, second concurrent request).
- **P3 — breaks under a narrow or uncommon condition, or impact is contained/recoverable.** Real,
  worth knowing, not urgent.
- **P4 — theoretical, cosmetic, or already-mitigated-but-worth-noting.** True, but you had to
  reach; or fully recoverable with clear feedback; or a nitpick.

If likelihood and impact pull in opposite directions, name both and pick the level the *user*
would triage it as. Never inflate to look thorough; never soften a real P1.

## 7. Output

Lead with a one-line context call (§1) and a one-line verdict (e.g. "3 real breaks, 1 of them
P1: the empty-cart checkout"). Then the ranked list, most severe first:

```
### P1 — <short name of the break>
**Breaks:** <what goes wrong>
**Trigger:** <the concrete condition; file:line or the exact user action>
**Proof:** <only with --prove: proven + evidence, or unproven + why>
**Fix direction:** <one line, the smallest thing that closes it — not a full patch>
```

Rules for the output:
- Order strictly by severity. If there are zero findings above P4, say so plainly and list the
  P4s (or state there are none) — an honest empty result beats a padded one.
- One finding per real break. Merge duplicates.
- If the artifact was too big to cover fully, say what you focused on and what you left out.
  Silent partial coverage reads as "all clear" when it isn't.
- Keep each finding tight enough to act on without re-reading the whole artifact.
- End with any §2 hand-offs in one line each ("Plan-level concern for /adversarial-review: …";
  "For /code-review: …") — don't expand them here.
- Do not edit the artifact. app-breaker finds breaks; fixing them is a separate, explicit step.
