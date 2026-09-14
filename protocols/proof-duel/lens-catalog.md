# Proof Duel — Lens Catalog

`catalog_version: 1`

Sole source of truth for lens ids, axes, kill-shots, `domain_tags`, synonym bans, and core-24.
Cast algorithm: `lens-cast.md`. Draw script: `cast-lenses.sh`. Do not duplicate this body into
`SKILL.md` / `command.md`.

Reject any catalog file missing `catalog_version` or any id missing `domain_tags`.

Match rule for hard exclude / Legal (Constraints / Out of scope quotes only): whole-word ASCII
match of a `domain_tags` token, or literal lens id in the quote. No stemming.

---

## Axis 1 — Diagnosis (shared only; not per-pair draw)

| id | domain_tags | Writer leans | Hater attacks |
|---|---|---|---|
| `root-cause` | root, cause, causal | deepest causal cut | symptom theater |
| `symptom-triage` | symptom, triage, bleed | stop the bleed first | band-aid sold as fix |
| `boundary-owner` | boundary, ownership, layer | wrong layer / wrong owner | local patch in wrong system |
| `temporal-regression` | regression, bisect, changelog | what changed when | ahistorical redesign |
| `data-vs-control` | schema, state, controlplane | state/schema vs logic plane | fixing the wrong plane |
| `human-process` | runbook, process, ops | runbook/process as root | code-only when ops is broken |
| `incentive-misalign` | incentive, metrics, reward | system rewards bad behavior | blaming people / ignoring incentives |

## Axis 2 — Solution strategy (PRIMARY when `axis_mode` includes 2)

| id | domain_tags | Writer leans | Hater kill shot |
|---|---|---|---|
| `min-diff` | minimal, patch, diff | smallest correct change | clever rewrite / drive-by refactor |
| `delete-first` | delete, simplify, remove | remove complexity | additive framework fixes |
| `contract-first` | api, schema, types, contract | API/schema/types before impl | silent behavioral drift |
| `migrate-first` | migration, backfill, dualwrite | data/backfill/compat path | code assuming clean state |
| `flag-rollout` | flag, rollout, canary | gated / gradual / kill-switch | big-bang deploy |
| `instrument-first` | metrics, logs, traces, measure | measure → then fix | guessing without signals |
| `defense-in-depth` | defense, guard, validate | multiple guards | single brittle check |
| `rewrite-island` | rewrite, seam, isolate | isolate + replace a seam | rewrite-the-world |
| `workaround-honest` | workaround, temporary, expiry | explicit temporary + expiry | permanent hack as design |

## Axis 3 — Optimand (PRIMARY only if `axis_mode=full`)

| id | domain_tags | Favors | Hater kill shot |
|---|---|---|---|
| `correctness-max` | correctness, invariant, total | invariants, total cases | mostly works |
| `blast-min` | blast, surface, touch | fewest modules / surfaces | drive-by refactors |
| `latency-perf` | latency, perf, hotspot | hot path / complexity class | correct but O(doom) |
| `security-abuse` | security, authz, injection | threat model, authz, injection | trust-the-client |
| `ops-oncall` | oncall, alert, runbook | alerts, runbooks, containment | works in staging |
| `observability` | observability, telemetry | logs/metrics/traces that prove it | silent success |
| `maintainability` | maintainability, readability | future reader / seam clarity | clever density |
| `ux-symptom` | ux, ui, user-visible | user-visible pain gone | elegant internals, same pain |
| `compat-stable` | compat, semver, breaking | back-compat, semver, callers | breaking cleanup |
| `cost-ship` | ship, deadline, cost | time/risk to land | gold-plated delay |
| `testability` | test, ci, deterministic | deterministic proof in CI | untestable manual faith |
| `compliance-audit` | compliance, audit, policy | evidence trail, policy | document later |

## Axis 4 — Failure physics (PRIMARY when `axis_mode` includes 4)

| id | domain_tags | Stresses | Typical miss |
|---|---|---|---|
| `happy-path-skeptic` | empty, null, zero, edge | empty, null, zero, first/last | assumed populated world |
| `concurrency-race` | race, lock, concurrent, idempotent | ordering, locks, idempotency | single-threaded mind |
| `partial-failure` | timeout, retry, partial | timeouts, retries, half-commits | all-or-nothing fantasy |
| `scale-load` | scale, load, cardinality, hotspot | volume, cardinality, hot keys | laptop-scale thinking |
| `time-clock` | clock, ttl, timezone, dst | DST, skew, TTL, replay | now is simple |
| `locale-encoding` | i18n, encoding, locale, currency, unicode | unicode, TZ, money, RTL | ASCII assumptions |
| `resource-exhaust` | memory, disk, fd, quota | disk, FD, memory, quotas | unbounded growth |
| `adversary` | adversary, abuse, malice | malice, confused deputy | benevolent users only |
| `rollback-migrate` | rollback, migrate, dualwrite | forward+back, dual-write | one-way door |
| `multi-tenant` | tenant, isolation, noisy | isolation, noisy neighbor | single-tenant demo |
| `offline-partition` | offline, partition, queue | split brain, queue lag | always-connected |

## Axis 5 — Stakeholder (SECONDARY; default `secondary_mode=stakeholder`)

| id | domain_tags | Proof must satisfy | Hater speaks for |
|---|---|---|---|
| `end-user` | user, customer, visible | visible outcome | product theater |
| `caller-api` | caller, consumer, api | downstream contracts | breaking consumers |
| `oncall-sre` | sre, oncall, pager | 3am operability | heroics required |
| `sec-reviewer` | security, reviewer, authz | abuse cases | trusted path |
| `future-maintainer` | maintainer, discoverability | discoverability | tribal knowledge |
| `platform-team` | platform, shared, infra | shared infra cost | app-local cleverness |
| `business-risk` | business, legal, revenue | revenue/legal/reputation | eng aesthetics |
| `accessibility` | a11y, accessibility | a11y / inclusive failure | happy visual path |

## Axis 6 — Proof standard (SECONDARY only if `secondary_mode=full`)

| id | domain_tags | Acceptable proof | Rejects |
|---|---|---|---|
| `falsifiable` | falsifiable, disprove | claim + how to disprove | vibes |
| `comparative` | comparative, alternatives | why not top 2 alternatives | lone proposal |
| `invariant` | invariant, never | never happens because | example-only |
| `empirical` | empirical, experiment, metric | metric/experiment plan | unaudited intuition |
| `precedent` | precedent, pattern, prior | matches local patterns | NIH rewrite |
| `threat-model` | threat, attacker, asset | assets, attackers, controls | checklist security |
| `repro-first` | repro, reproduce, failing-case | failing case → green case | abstract architecture |

---

## Synonym co-draw bans (primary × secondary)

| Primary | Banned secondaries | When |
|---|---|---|
| `adversary` | `sec-reviewer`, `threat-model` | always |
| `security-abuse` | `sec-reviewer`, `threat-model` | `axis_mode=full` only |
| `ops-oncall` | `oncall-sre` | `axis_mode=full` only |
| `ux-symptom` | `end-user` | `axis_mode=full` only |
| `maintainability` | `future-maintainer` | `axis_mode=full` only |

---

## Core deck (`deck=core`) — exactly 24

Axis1: `root-cause`, `boundary-owner`, `temporal-regression`, `data-vs-control`  
Axis2: `min-diff`, `contract-first`, `delete-first`, `instrument-first`  
Axis3: `blast-min`, `correctness-max`, `security-abuse`, `testability`  
Axis4: `happy-path-skeptic`, `concurrency-race`, `partial-failure`, `rollback-migrate`  
Axis5: `end-user`, `caller-api`, `oncall-sre`, `future-maintainer`  
Axis6: `falsifiable`, `comparative`, `repro-first`, `invariant`

---

## Counts

54 lenses / 6 axes (7+9+12+11+8+7). Bump `catalog_version` on any id/tag/ban/core change.
