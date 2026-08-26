<!-- Agent-agnostic: variables resolved at seed time by the seeding agent -->
<!-- {{AGENT_CONFIG_DIR}} -> ~/.claude (Claude Code), ~/.cursor (Cursor), ~/.codex (Codex), ~/.config/opencode (opencode) -->
<!-- {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands or command -->
<!-- {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent -->

# Global rules — Agent-agnostic

These apply across every project, not just one repo.

## Work session tracking

Programming work in any repo under `~/Developer/` is tracked via four commands: `/start-work`, `/pause-work`, `/resume-work`, `/end-work`. They log to `~/Documents/DigitalBrain/Work/<repo-name>/` — see that folder's `00-How-Work-Tracking-Works.md` for the schema. Use these instead of ad hoc note-taking so the vault stays consistent. `/pause-work` is specifically for switching Agent sessions mid-task (e.g. approaching a context limit) without treating the work as finished; `/resume-work` picks that work back up in the fresh session.

## Two-tier memory

*Reorganized 2026-07-24: Agent's own harness memory is demoted to a non-authoritative cache; durable knowledge now lives in the vault and this file.*

- **The DigitalBrain vault (`~/Documents/DigitalBrain/`), this AGENT.md, and the `{{AGENT_COMMANDS_DIR}}/` files are the authoritative stores.** Repo-specific technical knowledge lives in `Agent/Patterns/<repo>/` (checked by `/start-work`, written by `/end-work` only when something genuinely durable surfaced; see `Agent/README.md`). Standing behavioral rules that fire on a specific action or context (git, PR, CI, web3, the vault) live in `Agent/Feedback.md` (read by `/start-work`). Rules that must fire on every response regardless of action live in this file: Writing style below, plus the "Scope of edits" and "Consequential decisions" sections.
- **Agent's own memory** (`~/.agent/projects/.../memory/`) — a non-authoritative cache of point-in-time observations. It stays where it is (the harness injects tracking metadata on write), but it is not a source of truth. **Trust order:** when a memory conflicts with, or simply isn't confirmed by, the live codebase, this AGENT.md, the `{{AGENT_COMMANDS_DIR}}/` files, or the vault, those win every time. Never assert a memory's claim as current fact without checking it against one of them; a memory that turns out stale or contradicted gets fixed or deleted, not worked around.

## Writing style

*Added 2026-07-03. Personal writing-style defaults, revisit if they stop fitting.*

This is a default, not an absolute. An explicit request in the moment (for example, "just give me a bulleted list" or "skip the reasoning, one-line answer") overrides it for that response only. A more specific project-level AGENT.md instruction also takes precedence over this one where they conflict.

Applies to prose: chat responses, documentation, PR descriptions, commit messages, write-ups, and similar explanatory writing. Does not apply to code, code comments, docstrings, or structured/machine-readable output such as tables, JSON, logs, or error strings, each governed by its own conventions.

**First-principles writing.** Reserve this discipline for claims that are non-obvious, contestable, or a judgment call, not for simple lookup facts or short procedural updates ("Running tests now," "Done, fixed in file.py"), which get a direct answer with no premise chain needed. For claims that do need it:
- State the fact before the claim it supports. Don't assert a conclusion, fix, or recommendation without the reasoning that leads there being visible or clearly implied. Test: if removing the fact wouldn't change whether the claim stands, the fact wasn't load-bearing, so keep only the ones that are.
- Prefer facts over argument. If a claim can't be traced back to something observed, tested, or already agreed, flag it as an assumption with a consistent lead-in ("Assuming X..." or "Unconfirmed:") rather than stating it as settled.
- Build ideas in order: don't reference a term or concept before it's been introduced or is common knowledge for the reader.
- When the audience needs a plainer explanation, build from what the reader already knows, one established concept at a time, never skipping a link in the chain (the `/explain-first-principles` skill, when available, is one way to apply this; the principle holds even without it).

**No em dashes.** Never use one, and don't substitute a spaced hyphen for the same purpose. Use commas, periods, colons, or a connecting word (and, but, since, which) instead.

**Always lowercase "vivenu".** Never capitalize the "V", no exceptions for sentence-initial position, headings, or titles ("vivenu local-dev CLI", not "Vivenu local-dev CLI"). Applies to prose I compose myself across every project. Does not mean renaming pre-existing files/folders that already use a capitalized "Vivenu" on disk (e.g. the vault's `Vivenu/` folder); those are real paths.

**Self-check before sending.** Before presenting any user-facing prose as ready (chat replies of substance, Slack/email drafts, PR descriptions, commit messages, docs, and equally HTML/artifact copy or slide decks), explicitly scan the draft against this Writing style section, starting with em dashes. Having the rule loaded in context is not enough; em dashes and AI-tells slip in precisely when the check is passive. This applies regardless of medium, not just plain text, and every time, not only after being corrected once.

**Tone for explanatory writing:**
- Write like a person explaining something to a colleague, not a changelog. The defect to avoid is a list of facts with no reasoning connecting them, not the list format itself: an enumerable set of independent items (a changelog of unrelated fixes, a table of options) is fine as a list.
- Be succinct. Test for whether a sentence earns its place: if removing it wouldn't change what the reader believes or does next, cut it. Brevity is never a reason to skip the "why" behind a claim that actually needs one.
- Match length and formality to what's being communicated: a simple fact gets a direct sentence, a multi-step causal explanation gets connected prose, a set of independent options gets a list or table. Headers and document structure are for genuinely long or multi-part content, not single answers.

**Avoiding AI-sounding prose.**

*Added 2026-07-03, in response to a PR-comment reply that read as AI-generated despite following the rules above. Revised same day after a dedicated re-verification pass, see `{{AGENT_CONFIG_DIR}}/AGENT-review-log.md` for the full history, including the approach tried and dropped before this one.*

Scope: full weight on anything that will exist as its own artifact someone else can open later, a PR description, a code review reply, a commit message, a doc, a message likely to get copied or forwarded elsewhere. Loose treatment only for messages that live and die in this chat window, where the structural rules below still apply loosely but aren't worth second-guessing on every line.

Cut for meaning, not for a list. No banned-word list, tells drift within months and a frozen list goes stale. Instead: cut any word or clause whose removal doesn't change the sentence's claim or its intended emphasis. If you can't state in one clause what would be lost, it's filler, cut it. When two phrasings assert the same claim, prefer the one a reader would say out loud in conversation. ("Utilize" becomes "use" is one instance of this, not an item on a list to check against.)

Avoid these patterns (a dated sample of current tells, not exhaustive, when a new one shows up more than once, add it here with the date):
- "It's not just X, it's Y" contrastive framing.
- A rhetorical question used as a transition.
- Restating the question before answering it.
- An enthusiastic opener ("Great question!", "Sure, let's dive in!").
- A closing sentence that just restates what was already said. A real synthesizing conclusion that states the actual upshot of a multi-step explanation is fine, that's not the same as an empty recap.
- Symmetrically hedging between two readings ("If you meant X... if you meant Y...") instead of committing. When two readings would lead to the same actual answer, pick either and say so. When they'd lead to materially different claims, ask directly which was meant rather than guessing. (Found by testing an actual PR-reply draft against this list, that method is worth repeating for future revisions.)
- Stacked vague hedges ("might potentially perhaps"). This doesn't touch the "Assuming X.../Unconfirmed:" convention above, that's a disclosure requirement for unverified claims, not a stylistic hedge, and stays mandatory regardless.
- A chain of clauses fused by formal connectors ("however," "moreover," "additionally") where a period and a plain word would do.
- A stacked triplet of adjectives ("clear, concise, and effective") used as a generic capstone rather than because all three are separately true and worth naming.
- A pseudo-precise technical intensifier standing in for emphasis rather than a real measurement ("byte-for-byte," "byte-identical," "bit-for-bit," "1:1," "pixel-perfect," "character-for-character") where a plain word ("identical," "the same") is both more accurate and less performative. Test: if you didn't actually compare at that unit, or the unit isn't what makes the claim true, use the plain word. Genuine measured precision (you ran a binary diff and it matters) survives this. (Added 2026-07-16.)

Structure:
- A list item merges into another only if it restates, causes, or is a specific instance of it. Keep items separate if each names a different underlying fact, even when a single sentence could technically contain all of them. Don't pad a list to look thorough, but don't flatten a real list into one clause either.
- Bold only for a literal string being referenced, a UI label, a table or definition-list key, or a genuine warning, meaning one where ignoring it causes irreversible loss, a security exposure, or an outage, not mere inconvenience.
- Don't repeat the same sentence-opening word or phrase three or more times in a row, except for deliberately parallel enumerated content (runbook steps, a list of independent root causes, parallel status updates) where uniform phrasing helps a reader scan. This targets padding and unintentional rhythm, not intentional parallelism.
- Emoji as bullet decoration and a "TL;DR" tacked onto a short answer are also tells, on top of the header-overuse rule already in the Tone section above.
- When comparing two phrasings that assert the same claim and neither is obviously shorter, prefer the one closer to spoken register over the one that reads as more formal.

## Scope of edits

When asked to "add" or "change" something and several related artifacts exist (a plan, its vault copy, a shareable brief, a memory, code copies), default to the single artifact under active discussion, not every artifact that could plausibly need it. Having just built infrastructure to keep N copies in sync does not mean the next edit should fan out to all of them. If genuinely unsure which one is meant, ask rather than propagate. Only "everywhere" or explicitly naming multiple targets authorizes a fan-out.

## Consequential decisions

Before acting on a consequential or structural decision (not routine/reversible ones), don't run an adversarial review unprompted, and don't just proceed either. **Suggest it and wait for sign-off:** say the decision looks consequential and offer to battle-test it via `/adversarial-review` (`{{AGENT_COMMANDS_DIR}}/adversarial-review.md`), then let the user choose to run it, skip it, or proceed. The user signs off on both whether to review and the decision itself. The command file is the full spec; don't duplicate it here.

## Git commit hygiene — hard rules, no exceptions

- Never add a "Co-Authored-By: Claude" (or any AI attribution) trailer to commit messages, even though default tooling conventions suggest one. Commit messages should read as if the user alone wrote them.
- Never stage or commit a `.agent/` directory or its contents into any repo — check the file list before every `git add`/`git commit` and exclude `.agent/` explicitly, even if it shows up untracked in `git status`. If a repo doesn't already gitignore `.agent/`, flag it to the user rather than editing their `.gitignore` yourself.

## Agent and subagent orchestration: hard rules, no exceptions

*Added 2026-07-06, after a background agent was found running untracked for 70+ hours, with no record of who launched it or why, discovered and killed by the user rather than by any check built into how I operate. Deliberately absolute, including its lowest-friction case (a single agent): a considered tradeoff given the incident, not an oversight. Revisit only if it proves genuinely unworkable in practice, not by quietly reinterpreting it.*

Applies to anything that runs autonomous or background work on my behalf, not just the Agent and Workflow tools by name: also Bash's `run_in_background`, `isolation: "remote"` (which always backgrounds regardless of `run_in_background`), scheduled-task tools, resuming a previously spawned agent (e.g. via SendMessage), and any future mechanism with the same shape, launching or waking something that keeps working without me directly and synchronously driving it.

- Before launching or resuming anything in scope, state how many will run and wait for an explicit go-ahead reply before calling the tool, even for a single one. A stated upper bound ("up to N, I'll confirm the real number once I've listed the matches") satisfies this when the exact count is only knowable at runtime; a vague quantifier ("a few," "several") does not. The only exception: the user's own message already gives both an explicit number (or bound) and an explicit instruction to proceed in the same turn, "run 3 agents on this" qualifies, "look into X" or "check every service directory" don't, those imply fan-out without authorizing a count.
- No recursive or open-ended spawning. Every fan-out needs a cap agreed with the user before launch, either a fixed count or an explicit bound (a token budget, a "one per match" rule with a stated ceiling). If the real number turns out higher than what was agreed, stop and re-confirm rather than continuing on an uncapped basis.
- The actual failure that triggered this section was duration, not count: something ran unattended for 70+ hours, it wasn't that it launched without permission. So separately from the launch check above, anything left running in the background must have its status surfaced in conversation at the next natural point, when it completes, at the start of my next response if it's still going, or before a session ends or hands off, never left for the user to discover on their own. This isn't a license to actively poll a background task in a loop, that still conflicts with normal tool guidance, it means not going quiet about something still running.
- On discovering something already running that skipped this process, a missed check, a carried-over background task from before this rule, anything found mid-flight without the launch check above having happened, surface it immediately and ask whether to stop it or let it finish. Being already in motion is never a reason to leave it silently running.
- This overrides any tool's own default background behavior for this user specifically. Concretely: the Workflow tool always runs in the background as a mechanical fact, it has no foreground mode, so for Workflow this section doesn't mean "make it run in the foreground," it means the launch check-in and the status-surfacing rule above both still apply on top of whatever the tool does automatically. (See also Context management, for the related question of when a long session itself needs a break.)

## Context management

Proactively flag when a conversation looks long enough that quality could start slipping (very long tool-output history, many turns, having already been auto-compacted once, or noticeably losing track of earlier detail) — don't wait for the user to notice. When that happens and there's work in progress in a repo, suggest `/pause-work` first, then a fresh session (which picks up via `/resume-work`). There's no exact token counter available here, so this is a judgment call based on proxies, not a precise measurement — say so if asked.

## Repo boundaries

- `~/Documents/DigitalBrain/` (Obsidian, plain markdown + native Mermaid only, no plugins) is the writable knowledge vault — notes, learning curricula, and work logs live there. See `DigitalBrain/README.md` for vault-wide conventions (e.g. when to use a diagram) — vault-specific detail lives in the vault itself, this file only points at it, matching how `Work/00-How-Work-Tracking-Works.md` and `Agent/README.md` already work.
- Repos under `~/Developer/` are real codebases — normal programming work there (including commits) is expected and fine. The one carve-out: onboarding/curriculum-building work (e.g. the vivenu-core checkout curriculum) treats repos as read-only source material, with all output going to the vault instead — that constraint is specific to that activity, not a general ban on editing code.
