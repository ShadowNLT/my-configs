---
description: >
  Write and review automated tests using Google Testing Blog practice (TotT plus
  the non-TotT posts that teach how to write or choose tests). Applies a
  nine-step decision order: cost, one behavior, smallest sufficient size, public
  state not implementation, real/fake/stub/mock, inspectable body, values that
  can fail, determinism, then testable production code. Reports violations by
  rule name with a rewrite sketch.
argument-hint: [path, test file, diff, or leave blank for the tests under discussion]
---

# Write Tests

Target: $ARGUMENTS — or, if empty, the tests (or missing tests) most recently under
discussion: a file, a diff, a feature being implemented, or a testing strategy. If it is
ambiguous which target that is, ask rather than guess.

Do not install this protocol anywhere else; running it means applying the procedure to the
target. Read `references.md` in this protocol folder (sidecar after a command install — see
`protocols/README.md`; never hardcode a harness home path) when you need the source URL
for a rule. Cite the episode name in findings.

Source: [testing.googleblog.com](https://testing.googleblog.com/). This is the full write-tests
procedure. Do not drop a step because it feels redundant with another.

## Modes

Infer from the target; state which you picked.

- **Write** — the user is adding or changing tests, or implementing a feature that needs tests.
  Produce the tests (or the test plan plus tests) that pass the decision order.
- **Review** — the user points at existing tests or a PR. Do not rewrite until asked. Report
  violations using the output format below.
- **Strategy** — “is this tested enough,” E2E-only, coverage targets, pyramid vs hourglass.
  Apply §How much is enough and §Suite shape. Do not invent a coverage number.

If the target is production-only and the change is a testability smell (new `static` mutable,
singleton, `new` in application logic, work in a constructor, god context), run **Write** or
**Review** on the missing tests *and* name the production seam that is blocking Small tests.
Do not drive-by refactor production unless the user asked to implement.

## What a test is for

A test’s job is to keep bugs out of production and to give a clear signal when behavior
breaks. Coverage, a mock-heavy green CI, or satisfying a percentage policy is not the job.

Maximize three properties that pull against each other:

| Property | Meaning |
|---|---|
| **Fidelity** | If production is wrong, the test fails. |
| **Resilience** | If production behavior is unchanged, the test stays green (refactors, extra fields, new helpers). |
| **Precision** | Failure tells you *where*, from the test name plus the failure message, without a rerun. |

Clarity: the test documents the public API; it does not name implementation details.
Completeness: the body contains everything needed to understand it.
Conciseness: it contains no distracting noise.
Operational rule on top of all of this: **a failure must be actionable from the test name and
the failure output alone.**

Benefit of a test = bugs kept out of production, not lines covered. A test has a cost: time to
write, time to run on every engineer’s critical path, machines, and time spent diagnosing
failures. Refuse or delete tests whose cost exceeds that benefit.

## Sizes (enforceable constraints)

Google’s working names are Small / Medium / Large. “Unit / integration / E2E” are fuzzy; use
them only as a gloss.

| Constraint | Small | Medium | Large |
|---|---|---|---|
| Network | No | localhost only | Yes |
| Database | No | Yes | Yes |
| Filesystem | No | Yes | Yes |
| External systems | No | Discouraged | Yes |
| Multiple threads | No | Yes | Yes |
| Sleep | No | Yes (still discouraged) | Yes (still discouraged) |
| System properties | No | Yes | Yes |
| Time budget | ~60s | ~300s | 900s+ |

Small ≈ unit. Medium ≈ two tiers talking (often called integration). Large ≈ end-to-end or
system. Tests of any size must be **order-independent** and isolated so they can run in
parallel. You cannot rely on another test leaving data behind.

When choosing size, score **SMURF**. Farther from the center is better; the axes trade off.

- **S**peed: smaller tests run more often, catch problems sooner.
- **M**aintainability: larger SUT means more dependency churn and requirement drift.
- **U**tilization: CPU, memory, disk. Unit tests usually win because they use doubles or a
  thin slice of the system.
- **R**eliability: fails only when something is actually wrong. Size lets in non-determinism.
- **F**idelity: how close to production (real DBs, real traffic). Large tests usually win.

If you can improve one axis without harming the others, do it. Prefer the smallest size that
still has enough fidelity for the bug this test is meant to catch.

## Decision order

Stop at the first “no” and fix that before going on. Apply every step to every test you write
or review.

### 1. Is this test worth its cost?

Benefit = bugs it would catch. Delete or refuse:

- Calling `main()` (or the whole app) with no meaningful asserts.
- `except: pass` / catching all exceptions so the test cannot fail.
- Change-detectors: a mechanical copy of the production call graph (mock A, mock B, verify A
  then B) with no check of user-visible behavior.
- Tests that have been broken and ignored (broken-window).
- Tests that only assert that three slow helpers were called in order, with no insight into
  results.
- A second test that restates the same behavior without a new risk.

A test that never fails when the code is wrong, and often fails when the code is right, has
negative value. Rewrite or delete.

### 2. What one behavior is this asserting?

One sentence. If you need “and,” split. A single method can have several behaviors (show
purchase notification *and* send low-balance email). A single behavior can span methods.

Name the test after the behavior (`CanWithdrawWithinBalance`, `CannotOverdraw`,
`sendsEmailWhenBalanceIsLow`), not after the method (`testProcessTransaction`). Method-mirroring
names are a smell.

After asserting one outcome, another call to the system under test is usually a second
scenario. Split so: setup stays simple, side effects cannot mask a later case, one failure does
not skip the rest, and the suite documents which scenarios exist.

### 3. Can this be a smaller test without losing the bug it is meant to catch?

Prefer Small. Use Medium when two units must actually talk (contracts, wiring, serialization).
Use Large only for a **Critical User Journey** that smaller tests cannot see: a critical user
goal plus the path of tasks to achieve it.

Do not automate the manual script through the UI if the same behavior is available on an API
or can be checked against a DB. Use the UI only to prove the UI talks to that seam. Boundary
cases belong on the API, not in Selenium.

Thought experiment for strategy mode: if you could only keep **10** Large tests, where would
they go?

Suite shape: many Small, some Medium, few Large. The failure mode is an **hourglass** (lots of
unit, lots of E2E, no middle). Fix the hourglass with hermetic local stacks and real seams, not
with RPC hooks inside an E2E test.

E2E-first fails in practice even when it sounds user-focused: overnight loops, partner/lab
outages, big bugs hiding small ones, flakes, day-long diagnosis, week-late milestones.
Developers waiting until tomorrow to know if a fix worked is a process smell caused by too
many Large tests.

Good Large tests: few, journey-sized, hermetic, independent, last step clear on failure.

UI tests follow the user, not the widget tree. Stable debug IDs, not CSS soup.

**Hermetic servers:** bring the stack up on localhost with flags pointing at local siblings,
not production. Isolation of the environment beats “it works on my machine.”

### 4. Are we testing public behavior / state, or implementation?

Assert return values and visible state. Tests should survive a swap of internals (new adder
library, extracted helper, extra constructor dependency in *setup* only).

Interaction tests (verify this call happened) only when there is no other signal (for example
“read disk once”). If you verify interactions: only state-changing calls, only relevant
arguments.

Prefer the public API over tests of implementation-detail classes. Adding a feature should add
tests, not rewrite old ones.

**Change-detector:** production `process` calls `firstPart.process` then `secondPart.process`;
the test mocks both and verifies order. That is a checksum of the source. It fails on every
refactor and catches almost no defects. Rewrite to assert the work’s result, or delete.

Tests as **stories** about the component’s contract. Internals can change as long as the
stories still hold.

Coverage finds untested *code*, not untested *behavior*. Empty tests and tautological asserts
inflate coverage. Cover distinct logic paths, empty/null, boundaries, and error paths. Fuzz
when the input domain is large. There is **no universal coverage target**. “80% and no less”
is a punchline for people who demand a number; the real answer is that it depends on
criticality, change rate, lifetime, and complexity. Low coverage *does* prove large untested
areas. High coverage does *not* prove good asserts. Mutation testing is how you check that
tests would actually catch bugs. Treat coverage as a gap detector in conjunction with other
techniques, never as the only source of truth. Do not copy-paste tests to chase a number.

### 5. Collaborator: real, then fake, then stub, then mock

**Stub:** no logic; returns what you tell it. Use to get the SUT into a state.

**Mock:** expectations on how it is called. Use when there is no visible state change. Created
by a mocking framework. Do not stub a web of mocks that return other mocks.

**Fake:** lightweight implementation of the API that behaves like production but is not
suitable for production (in-memory DB, in-memory blog service). The owner of the real
implementation writes, tests, and maintains the fake so it cannot drift from the contract.
Keep fakes simple.

**Real:** highest fidelity. Use when it is not slow, non-deterministic, or impossible to
instantiate.

Preference order in a test: **real → fake → stub → mock**.

**Do not mock types you do not own.** Third-party mocks go stale on upgrades and keep passing
when the real contract changed. Use real, a vendor-provided fake, or a thin wrapper you *do*
own (and can fake).

Somewhere in the suite, **exercise the real service-call contract**: serialization, error
codes, optional fields. A mock that returns a hand-built object never proves you speak the
wire format.

Over-mocking: tests encode implementation, become unreadable, and give false confidence
(credit-card example: verify `pay` was called vs assert the charge amount on a fake/real
server).

### 6. Can a human inspect this test without a debugger?

Tests are not tested. Simplicity beats DRY.

**DAMP** (Descriptive and Meaningful Phrases) over DRY. Inline the users, the register calls,
and the asserts. Do not hide them in `setUp` + `_RegisterAllUsers` + a for-loop. Shared helpers
are fine for *noise* (BankSettings unused by this case), not for the values the assertion cares
about.

**Include only relevant details.** Creating `Account(settings, ID, BALANCE, ADDRESS, NAME,
EMAIL, PHONE)` when you only assert `GetBalance()` is noise. `_create_account()` with BALANCE
hidden inside is the other extreme. `_create_account(BALANCE)` makes cause and effect visible.

**No logic in tests.** No `if`/`switch`/loops that *compute* expected values. State inputs and
expected outputs as literals. Concatenating a “shared prefix” hid a double-slash URL bug: the
test and production shared the same bug. Production code is a general strategy; a test is a
specific example.

**Data-driven / parameterized tests:** good for many similar inputs of the *same* behavior;
bad when a failing row is unreadable or rows mix unrelated behaviors.

Fluent matchers / Truth-style APIs exist so failures contain actual vs expected without extra
logging. `EXPECT_OK(LoadMetadata())` beats `EXPECT_TRUE(LoadMetadata().ok())`.

### 7. Would a wrong implementation still pass?

**Values that can fail.** Never use the type default as the interesting value (`insert(1, 0)`
passes if insert is a no-op and the map default is 0). Use non-zero, non-empty, non-first-enum.
Use **different** values per argument so swapped args cannot pass. Parameterize when you need
many inputs; still keep each case readable.

Cover empty/missing/null, numerical boundaries, and branches that trigger complex logic.

**Narrow assertions.** `EXPECT_EQ(account, kExpected)` breaks when you add `CREATION_DATE` to
an unrelated withdraw test. Assert `account.balance`. At most one full-equality or screenshot
test for the common snapshot; everything else is narrow. Frontend: one screenshot for layout,
DOM asserts for behavior.

**ASSERT vs EXPECT.** ASSERT aborts the test; EXPECT continues. ASSERT only when later checks
are meaningless (failed setup).

**Floats:** explicit tolerance, never exact equality.

### 8. Is it deterministic?

Do not `sleep` to wait for async work. Wait on a condition or inject a clock / virtual time.

Time, randomness, locale, timezone, network, and shared filesystems are inputs. Inject them.

Isolate state: no leftover users, no shared temp files, no order dependence. Builder-create
data inside the test. If the app requires login, do not share one user across tests without a
lock; prefer dedicated accounts or per-test users.

Do not rely on flaky third-party services in Small/Medium tests.

Flakiness can sit in the test, the runner, the SUT, *or* OS/hardware. Typical test-side causes:
bad init/cleanup, invalid assumptions about data or system time, timing, order dependence.

Measured drag at Google (order of magnitude, **not** a target for this repo): about 1.5% of
*runs* flaky; about 16% of *tests* flaky at some point; about 84% of pass→fail transitions were
flakes. Larger tests (binary size, RAM, libraries) correlate with flakes. A persistently failing
test is a better signal than a flake. Rerun, “fail 3× then report,” and quarantine are
**infrastructure mitigations**, not a writing strategy. Do not mark a test flaky instead of
fixing isolation.

### 9. Is the production code even testable this way?

If you needed a forest of mocks, fix the code (when the user asked to implement) or report the
seam (in Review).

- **Functional core, imperative shell:** pure logic with no I/O; the shell does DB, email,
  network. The core is trivial to unit-test.
- **Construct with collaborators, call with work:** inject lifetime dependencies in the
  constructor; pass per-call data (date range, file path) to methods. Collaborator vs work
  depends on the object’s identity.
- **Two kinds of classes:** factories full of `new` that build the graph and do no work;
  application classes with almost no `new` that do the work.
- **Ask, don’t look:** pass `Fuel`, not `FuelTank` then `.getFuel()`. Do not pass a
  context/registry/service-locator. LoginPage asks for User and Authenticator, not UserContext.
- **Constructors assign fields.** No disk, no network, no “secure the house” in `new House(...)`.
  Every test instantiates; work in constructors is paid on every test.
- **No process-global state** that survives from test to test: singletons, static mutable,
  hidden flags. Globals make test order matter and make failures unreproducible in isolation.
- **Static methods** cannot be substituted in a test. Prefer instance methods on an injected
  collaborator.
- **Wrap third-party types** you do not own so tests never mock the vendor.
- **Law of Demeter:** do not reach through `a.getB().getC().doWork()`. Ask for C.
- **Don’t pad constructors with Assert.notNull on every unused collaborator** if that blocks
  passing `null` for a focused test of one method. Prefer optional unused deps or a test factory
  that supplies cheap fakes. Defensive programming that exists only to reject test doubles is
  hostile to Small tests.
- **Depend on interfaces** (or the language’s equivalent) where substitution is needed.
- **Extract methods** to make a branch testable without standing up the world.
- **Domain objects** over a pile of one-off methods (`deliverPizza`, then `deliverWithDrinks`).
  Model the stable idea (send the customer their order).
- **TDD** (red / green / refactor) is useful, not mandatory, not a silver bullet. Do not
  “fix” tests while they are red in a way that makes a never-true test go green.
- **Prefactor** production so the feature fits; keep test changes aligned with behavior
  changes. Read tests first in review when they specify the change (test-driven code review).

Untestable-code smells (the 3v1L list, inverted): `new` in the middle of methods; heavy
constructors; concrete-only types with no seam; deep conditional slalom instead of
polymorphism; giant context objects; statics; global flags; singletons; primitive obsession
that forces re-parsing in every caller.

## How much testing is enough (strategy mode)

There is no single number. Rubric:

1. Document the process or strategy (and the product design it belongs to).
2. Solid base of Small tests with code changes. Mocks for narrow expectations; fakes owned by
   the dependency’s team.
3. Do not skip Medium / integration. They have fewer dependencies than E2E, so they are faster
   and less flaky, and they catch what unit tests miss.
4. Large tests for Critical User Journeys, not for every feature combination.
5. Know coverage of *code* and of *functionality* (user-facing). Use coverage to see gaps.
6. Feed production bugs back into the suite.
7. Pair Small tests (fast regression) with a *small* amount of Large tests (closest to the
   customer). Neither diet alone is enough. System tests are like carbohydrates: required, in
   the right amount.

Inquiry / 10-minute test plan: when the question is “what should we test for this feature,”
list risks and journeys first, then map each to a size. Do not start by listing every method.

## Output

### Write mode

- Tests (or a patch) that pass the decision order.
- Size of each test (Small / Medium / Large) and why.
- Any production seam you had to add (injection, fake, wrapper) called out in one sentence.
- Behaviors you explicitly did *not* cover and why (out of scope, needs a Medium/Large you did
  not add, unconfirmed).

### Review mode

A findings list. Each finding:

- **Rule** — episode or section name from this file.
- **Where** — file and test name.
- **What** — the violation in one or two sentences.
- **Rewrite sketch** — what the test (or production seam) should look like. Do not implement
  unless asked.

Group by decision-order step. Do not pad. “Checked, no violation” for a step is allowed; a
blank step never means you skipped it. If you skipped a step, say so under **Not checked**.

End with: overall suite shape (pyramid / hourglass / unknown), flake risks, coverage-as-gaps
(not a percentage target).

### Strategy mode

Answer: what Small / Medium / Large exist, where the hourglass is, which 10 Large tests you
would keep, what is untested that production bugs would care about. No invented coverage quota.

## Out of scope as write-time checks

Do not report these as test-writing violations: GTAC logistics, hiring, April Fools, Whittaker
SWE/SET/TE career series, comment policy, keep-sorted, small PRs, review etiquette, flag
safe-defaults, tool changelogs. They are catalogued in `references.md` so they are not
forgotten; they do not belong on a test review.

## Do not

- Add tests that only exist to raise coverage.
- Mock types the repo does not own.
- Use `sleep` as synchronization.
- Put `if`/`switch` in a test to compute the expected value.
- Leave a flaky test in the critical path with a comment instead of isolation.
- Silently skip a decision-order step.
