---
name: algo-sketch
version: 4 — 2026-09-14 (bump on every edit; a mirror whose version differs from the repo copy is stale)
description: >
  Present logic as an Algo Sketch — Algorithm-101 pseudo-code with just-in-time
  records, soft invariants, and puzzle-piece composition across functions and
  modules. Human first, still code-shaped; hard-rejects real-language syntax.
  Infers the target from conversation when none is named. Also the Teaching
  Standard hybrid-P5 mechanism form when start-work (and later opt-ins) invoke it.
  Trigger on: "/algo-sketch", "algo sketch", "sketch this algorithm",
  "pseudo-code this", "present as algorithm 101", "human code this".
---

# Algo Sketch

Present the target as readable Algorithm-101 pseudo-code: human first, still
code-shaped enough for functions, modules, and composition.

## Target

Infer the target from the conversation: the algorithm, design, or code the user
wants sketched. Prefer the most recent substantive algorithm / design / code
explanation. If it is ambiguous which that is, or none is present, ask what to
present — do not invent a domain.

If the user pastes real code, **translate** into Algo Sketch (behavior +
structure), do not line-preserve syntax. Strip language tokens per the dialect
hard-reject rules below.

When executed **inline from a teaching command** (e.g. `start-work` hybrid P5),
do not re-ask for a target — sketch the mechanism/solution that command already
named.

## Process

1. **Name the behavior** in one full sentence — that sentence **is** the
   artifact’s `# title` (required). Prefer a verb phrase (“Charge a wallet…”),
   not a noun label (“Checkout path”).
2. **Cut into puzzle pieces** — list the seam map (2+ pieces) before writing
   dialect.
3. **Decide modules** — only if 2+ groupings per Modules below; else flat functions.
4. **Emit pieces in reading order** — for each piece: JIT `record`(s) →
   `function`(s) → optional `// handoff: name (Record)` when the seam is not
   obvious from the next piece’s args.
5. **Self-check** (fail closed — fix before return) — see checklist below.
6. **Return only the Algo Sketch artifact** (title + optional seam map + pieces),
   **always inside one fenced code block** — see Output envelope. Never emit the
   dialect as bare chat markdown (that collapses indentation and turns `# title`
   into a heading).

### Iteration mode

When the user says the format feels off (too code-like, too prose, seams
unclear): adjust **one** dial per turn and re-emit — do not silently rewrite
the whole dialect.

Map complaints to dials:
- “too code-like / too dense” → **piece size** (split) or **invariant density** (fewer)
- “too prose / mushy” → **invariant density** (add field notes) or tighter piece titles
- “seams unclear” → **piece size** (re-cut) and/or seam map labels
- “should this be modular?” → **module explicitness** only if 2+ groupings exist
- “looks like plain text / lost indentation / title became a heading” → **fence**
  (wrap the whole artifact; dials above are content, this is rendering)

| Dial | Range |
|------|--------|
| piece size | fewer larger pieces vs more smaller pieces |
| invariant density | none / field-only / multi-field `invariant:` |
| module explicitness | flat (default when <2 groups) vs `module` when 2+ |

`←` assign, unicode operators (`×` `≠` `≤` `≥`), and hard language-reject are
**not** dials — they stay fixed. Do not add a “more symbols” dial that
reintroduces language tokens.

### Output envelope

**Always** wrap the entire artifact in a single markdown fenced code block with
info string `text` (not a language that triggers syntax highlighting as JS/Python/
etc.). One fence for the whole sketch — do not fence each piece separately.
No prose before or after the fence unless the user asked for commentary or
iteration notes.

```text
# <required title — the one-sentence behavior name>

// seam map (if 2+ pieces)
//   [A] → [B] → [C]

// --- piece 1: ... ---
...

// --- piece 2: ... ---
...
```

Optional footer only when asked: glossary of records in appearance order
(never as a required preamble) — still **inside** the same fence, or a second
fenced block only if the user asked for a separate glossary.

**Why the fence is mandatory:** bare chat markdown treats `#` as a heading and
may flatten leading spaces, so the dialect stops reading as Algorithm-101.
The fence is rendering, not “production code.”

### Self-check (fail closed)

- `# title` is a full sentence naming the behavior (not a noun phrase alone)
- every dotted field has a prior `record` in this artifact
- records appear JIT (same piece as first use), not as a top dump before all algos
- when modules are used, records stay at piece top level (outside `module`);
  cross-module calls use `Module.function`
- earlier-piece functions stay in scope (no redeclare, no faux imports)
- lists: `for each` only; no `items[i]`; no `[…]` / `.push` / method `.append`;
  grow with `blank list` + statement `append(list, item)` (never `xs ← append(…)`);
  no map/dict syntax
- `in` appears only inside `for each … in …`; membership uses `belongsTo`
- assign uses `←` only; compare uses `=` / `≠`; arithmetic uses `×` not `*`;
  order uses `≤` `≥` not `<=` `>=`
- no forbidden language tokens (hard-reject list + membership test), including `then`
- booleans use `true`/`false`/`and`/`or`/`not` / `else if` only
- modules only if 2+ groupings; pieces alone do not force modules;
  at most one `module Name` block per grouping (no reopen)
- seam map present iff 2+ pieces
- builtins (`sameReference`, `belongsTo`, `blank …`, `append`) not redeclared as local helpers
- no preamble essay outside the artifact envelope
- entire artifact is wrapped in one ```text fence (not bare chat markdown)

---

## Dialect (frozen)

### Keywords

| Idea | Write |
|------|--------|
| group | `module Name` *(only when Modules says so)* |
| routine | `function name(args)` |
| data shape | `record Name` |
| always-true rule | `invariant: ...` |
| branch | `if` / `else if` / `else` |
| boolean connectives | `and` / `or` / `not` |
| boolean literals | `true` / `false` |
| list walk | `for each item in list` |
| counted walk | `for i from 1 to n` *(inclusive on both ends)* |
| condition loop | `while condition` |
| succeed | `return ...` |
| fail | `error "message"` *(aborts this function; no code after it runs)* |
| missing value | `null` |
| note | `// ...` |

No braces. Indentation is structure.

**Builtins** (dialect-provided; not “invented helpers”): `sameReference(a, b)`,
`belongsTo(item, list)`, `blank RecordName` / `blank list` (construct empty,
then assign / `append`), `append(list, item)` *(mutates `list` in place;
statement form — do not write `xs ← append(xs, item)`)*.
Field write `x.field ← value` **mutates** that field on the same record value.

### Operators

| Idea | Write |
|------|--------|
| assign | `←` **(locked)** |
| compare equal / not | `=` / `≠` |
| compare order | `<` `≤` `>` `≥` |
| arithmetic | `+` `-` `×` `/` |
| conditional value | `a if condition else b` *(expression form; prefer multi-line `if` when long)* |
| cross-module call | `Module.function(args)` |

`←` is assign. `=` is compare. Never overload `=` for both.

### Naming

- Modules: `PascalCase` or a single clear noun (`Checkout`, `Math`, `Users`)
- Functions / fields: `camelCase` (default) — do not mix styles in one artifact
- Prefer real domain names over `foo` / `bar` / `tmp` unless the user is
  illustrating syntax itself

### Records and invariants

```
record Wallet
    balance ≥ 0          // number
```

Multi-field rule:

```
record CartItem
    price ≥ 0
    qty ≥ 1
    invariant: price × qty ≥ 0
```

Rules:

- Every field access (`wallet.balance`) requires a prior `record` that declares
  that field.
- Declare the record in the same piece as first use (JIT), not in a distant
  preamble.
- If a later piece reuses a record already declared above, do not redeclare —
  reference by name only.
- If two modules share a record, declare it once in the first piece that needs
  it; later pieces treat it as known.
- **Cross-piece functions:** a `function` declared in an earlier piece is in
  scope for later pieces in the same artifact (do not redeclare; do not invent
  imports).
- **Collections:** write `// list of T` on the field. Walk with `for each` only.
  Do not use index brackets (`items[i]`). No map/dict/set syntax — model keyed
  data as `record` fields, a `list of` pairs, or plain words in a step.
  Build a list with `xs ← blank list` then `append(xs, item)` (builtin). Never
  use `[…]` literals, `.push`, or `.append` method syntax.
- **Construct a record:** `x ← blank RecordName`, then assign fields with `←`.
  Never use `{}`, `new`, or constructor-call syntax.

### Functions

```
function divideBy(a, b)          // a, b: numbers
    if b = 0
        error "cannot divide by zero"
    return a / b
```

Rules:

- Early exit for errors (prefer over deep if/else when both are equivalent).
- Typed hints as trailing `// name: Record` comments when helpful — not a
  separate type-system block.
- Keep bodies short; if a function grows past ~15 lines of steps, split into
  another piece.

### Modules — only when 2+ groupings (locked)

**Grouping ≠ piece.**

- A **piece** is a reading chunk (JIT records + functions for one seam step).
- A **grouping** is a named capability boundary you would want readers to see
  as `Name.function(...)` — a durable verb-area (`Payments`, `Users`), not
  “one function per piece.”
  Count groupings by **intended call-style**, not by whether bare names would
  clash: if the sketch wants two (or more) `Name.function` areas, that is 2+
  groupings → use `module`. If everything stays flat `function` calls, that is
  one grouping → no `module` (even when there are many pieces).

Use `module` **only when** there are **two or more** such groupings in the
sketch. Do **not** wrap a single grouping in `module` “just in case.”

Otherwise: flat `function`s at the top level of each piece — no `module`
wrapper. Several pieces may still share **one** flat grouping (see checkout
example: three pieces, zero modules).

When modules *are* used (2+ groupings), wrap **only functions** in the
`module`; keep JIT `record`s at piece top level (outside the module):

```
module Payments
    function charge(wallet, amount)     // wallet: Wallet
        ...
```

Cross-module call:

```
ok ← Payments.charge(wallet, amount)
```

When modules are on, **every** call into another module uses `Module.function`.
Bare `function` names stay for: flat sketches, and calls **inside** the same
module body.

**One block per grouping:** each `module Name` appears once in the artifact.
Put all of that grouping’s functions in that single block (usually in the first
piece that introduces it). Later pieces do not reopen `module Name` to add
siblings — they only *call* it via `Name.function`.

### Hard reject: language syntax → word equivalents (locked)

**Forbidden in output** (non-exhaustive — same class always rejected):

`===` `!==` `==` `!=` `&&` `||` `!` `?.` `??` `=>` `fn`
`func` braces/`{}` `try`/`catch` `throw new` `async` `await` `Promise` `def`
`elif` `then` `None` `nil` `undefined` `:=` `->` `<-` `+=` `-=` `*=` `/=` `%`
`*` (multiply — use `×`) `<=` `>=` `<>` ternary `? … : …` (question-mark
colon expressions only — not `// name: Type` comments), generics angle soup,
visibility keywords (`pub` `private`), `switch`/`case`, `BEGIN`/`END`, etc.

`in` is legal **only** inside `for each … in …`. For membership tests write
`belongsTo(item, list)` or a `for each` search — not bare `if x in xs`.

List growth / indexing: use `blank list` + `append(list, item)` and `for each`
only. Also reject `[…]` literals, `items[i]`, `.push`, and method-style
`.append` (same class as other language tokens).

**Required replacement style:** named word (or short phrase) that says what the
language token meant.

| Language-ish intent | Algo Sketch |
|---------------------|-------------|
| value equality | `=` / `≠` |
| same object / identity | `sameReference(a, b)` / `not sameReference(a, b)` |
| nullish coalesce | `a if a ≠ null else b` |
| optional chain | `if x = null` / `error` or `return` / else use `x.field` (multi-line `if`; no `then`) |
| lambda / arrow fn | name a `function` (or inline only if trivial and still wordy) |
| throw / raise | `error "message"` |
| async wait | `wait for …` *(phrase, not a keyword)* — continue on the next line (only if timing matters) |
| undefined vs null | just `null` unless the distinction *is* the point — then say it in words |

If any forbidden token appears, rewrite that line. No “close enough” language
flavoring.

**Membership test for “same class”:** if a token is an operator or
control/compare keyword in common languages (JS/TS, Python, Go, Rust, Java, C#)
and it is not listed in Keywords/Operators or as a Builtin, rewrite it to words
/ listed forms. When unsure, rewrite.

---

## Puzzle-piece layout

### What a piece is

One piece = one coherent unit the reader can hold:

1. Optional short title / role of the piece (one line)
2. `record`(s) needed for **this** piece only (if not already known)
3. `function`(s) / steps that use them
4. Explicit **outputs** this piece hands to the next (names + shapes)

### How pieces fit

Present multi-block logic as a short seam map, then the pieces in dependency
order. Seam rules:

- Show the map when there are **2+** pieces; skip it for a single function.
- Each seam arrow labels the handoff clearly enough that the next piece’s
  inputs are obvious (value + record, or the producing `function` /
  `Module.function`).
- Prefer linear or lightly branched seams over deep call graphs in the
  presentation; if the real design is a graph, show a small seam map of the
  *reading order*, not every runtime edge.

### Anti-patterns (reject these)

| Anti-pattern | Why it fails |
|--------------|--------------|
| All `record`s at the top, algos far below | Reader forgets shapes by use-site |
| Field used before its `record` | Breaks the invariant of the dialect |
| One mega-function for the whole system | No puzzle seams; unreadable |
| Language tokens (`===`, `try/catch`, arrows) | Hard-rejected; use word equivalents |
| Inventing helpers mid-piece without declaring | Same class of confusion as undeclared fields (dialect **builtins** are exempt) |
| `module` wrapper for a single flat sketch | Modules only when 2+ groupings |

---

## Scope

**In scope:** presenting algorithms, designs, and mental models; rewriting dense
code into Algo Sketch; multi-module flows with clear seams (when 2+ groupings);
**Teaching Standard hybrid P5** — when a teaching command (today: `start-work`)
opts in, Algo Sketch is the mechanism/solution delivery form (vocab nodes stay
first-principles prose; no language snippets until that command’s post-gate
edit phase).

**Out of scope** (unless the user expands): compilable code generation;
language-idiomatic translations; formal verification; UML / diagram rendering
(point at `concept-viz` when animation helps more).

### Teaching mode (when executed inline from `start-work`)

- Prefer mechanism sketches the learner **uses**; the parent command gates the
  **map + learner-produced claims**, not this artifact. Keep dialect frozen.
- Emit the sketch in the **mandatory ```text fence** (Output envelope) — that is
  rendering, not production code.
- Path **pointers** OK; no **production-language** code fences or language tokens
  (real JS/TS/Python/etc. snippets stay forbidden).
- Do not ask the user to “install” anything — the invoking command already
  pointed here; just produce the artifact.
- P6 layman-terms (if the parent runs it) must not rewrite this dialect.

---

## Worked examples (canonical)

### Flat functions (one grouping → no `module`)

```
# Checkout charges a wallet for the cart total

// seam map
//   [cart shapes + line total] → [cart total] → [wallet + pay]


// --- piece 1: cart shapes + line total ---

record CartItem
    price ≥ 0
    qty ≥ 1

record Cart
    items    // list of CartItem

function lineTotal(item)              // item: CartItem
    return item.price × item.qty


// --- piece 2: cart total ---

function cartTotal(cart)              // cart: Cart
    total ← 0
    for each item in cart.items
        total ← total + lineTotal(item)
    return total


// --- piece 3: wallet + pay ---

record Wallet
    balance ≥ 0

function pay(cart, wallet)            // cart: Cart, wallet: Wallet
    amount ← cartTotal(cart)
    if wallet.balance < amount
        error "insufficient funds"
    wallet.balance ← wallet.balance - amount
    return "paid"
```

### Identity (`sameReference`)

```
# Tell whether the candidate node is already the cached node

record Node
    // identity compared with sameReference; no extra fields required here

function alreadyCached(cached, candidate)   // cached, candidate: Node
    if sameReference(cached, candidate)
        return true
    return false
```

### Membership (`belongsTo`)

```
# Add up values that belong to the allowed list

function sumAllowed(scores, allowed)       // scores, allowed: list of number
    total ← 0
    for each value in scores
        if belongsTo(value, allowed)
            total ← total + value
    return total
```

### Counted loop (`for i` inclusive)

```
# Repeat a step n times

function repeatHello(n)                    // n: number ≥ 1
    for i from 1 to n
        // step i of n
    return "done"
```

### Build a list (`blank list` + in-place `append`)

```
# Collect positive scores into a new list

function positivesOnly(scores)             // scores: list of number
    out ← blank list
    for each value in scores
        if value > 0
            append(out, value)
    return out
```

### Two modules (2 groupings → modules on)

```
# Find a user by id and return a greeting

// seam map
//   [Users.findById] → [Greeter.hello]


// --- piece 1: users ---

record User
    id        // string
    name      // string

module Users
    function findById(users, id)          // users: list of User
        for each user in users
            if user.id = id
                return user
        return null


// --- piece 2: greeter ---

module Greeter
    function hello(user)                  // user: User
        if user = null
            error "user not found"
        return "hello " + user.name

// later piece / caller uses the module prefix:
// message ← Greeter.hello(Users.findById(users, id))
```
