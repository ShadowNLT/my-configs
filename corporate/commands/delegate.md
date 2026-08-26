---
description: Hand off one independent subtask to a DIFFERENT AI tool (Cursor, a CLI agent like Gemini/Codex, another terminal) while you keep working the rest, then resume and verify when the user says the other tool is done
argument-hint: [the subtask to hand off, or leave blank to infer]
---
<!-- Variables: {{VAULT_AGENT_DIR}} -> ~/Documents/DigitalBrain/Agent, {{AGENT_CONFIG_DIR}} -> ~/.claude|~/.cursor|~/.codex|~/.config/opencode, {{AGENT_COMMANDS_DIR}} -> {{AGENT_CONFIG_DIR}}/commands, {{AGENT_HARNESS_MEMORY}} -> harness memory path -->


# delegate

Subtask: $ARGUMENTS — or, if empty, inferred from the conversation. You are the sole
orchestrator: you invoke this, you run the other tool, you ping when it's done.

Hand off an **independent** subtask to a different AI tool and keep working the
rest yourself. **You are the sole orchestrator** — you invoke this, you run the
other tool, you ping when it's done. The agent never runs the other tool and never
polls; it prepares the hand-off, hands control back to the user, and resumes only
when the user says so. This makes cleanup safe: it happens on the user's ping, after the
result has been read — it never races the tool that's reading the file.

## Assumption

The target is a tool that **shares this filesystem** (a local CLI or IDE agent)
and can reach the temp dir. The hand-off is a file both sides read and write. If
the target **cannot reach the hand-off path** — a browser-only tool (ChatGPT/Gemini
web) that can't open a local path, a tool sandboxed to the project folder that
can't read outside it (e.g. Cursor), or a container whose temp dir differs from the
host — then don't use a file pointer: inline the full context into the pasteable
block and expect to paste the result back by hand. Because the channel now lives
outside the workspace, prefer delegating to a target that isn't jailed to the
project folder (another terminal, a non-sandboxed CLI agent) when you want the
automatic two-way file channel.

## Procedure

### 1. Scope the subtask (infer first, then grill)
Infer the subtask to delegate from the argument and the conversation — do
**not** demand an exhaustive description. Then sanity-check the scope:

- If the task, its boundaries, or its acceptance criteria are **fuzzy**, ask the
  user targeted clarifying questions until it is crisp. Goal ambiguity is a top
  reason a delegated task fails — resolve it here, not by dumping more context.
- Confirm the subtask is genuinely **independent** of what the agent will keep
  doing (no shared files in flight). If it isn't, say so and propose a split.

### 2. Prepare the context
Gather everything the other tool needs to succeed with no back-channel to this
conversation: relevant files/paths, the goal, constraints, gotchas, acceptance
criteria, and explicitly **what is out of scope** (the files the agent keeps).

- **Redact obvious secrets** before writing them: `.env` values, API keys,
  tokens, connection strings, credential files, PII. Never copy these into the
  hand-off file.
- Print a single line: `Sharing: <files/paths/summaries going into the channel>`
  so the user can eyeball what is leaving before pasting it into another tool.

### 3. Write the two-way channel
Write the channel to the per-user temp dir — **never inside the repo** — so it is
inherently untracked (temp dirs sit outside every git work tree). Mint a
guaranteed-unique, private subdir per delegation with `mktemp -d`, and put the
channel file inside it:

    base="${TMPDIR:-/tmp}/delegate"; mkdir -m 700 -p "$base"
    dir="$(mktemp -d "$base/<slug>-XXXXXXXX")"   # atomic, unique, 0700
    #   channel file: "$dir/channel.md"

`mktemp -d` requires the `X`s to be the **trailing** characters (a `.md` suffix on
the template is taken literally on macOS), which is why the *directory* carries the
unique part and the file inside gets a fixed clean name. Resolve the real absolute
path from `$dir` — never write the literal `$TMPDIR`. Never write inside the repo
or touch its `.gitignore`. Temp dirs are auto-reaped, so a hand-off is meant to be
resumed in the same working session; if one must survive a reboot, tell the user to
copy it elsewhere. Use this template:

```markdown
# Delegated task: <slug>

## Task
<what to do, in the other tool's own terms — it never saw this conversation>

## Context
<refs, file paths, constraints, gotchas>

## Acceptance criteria
<how "done" is judged — concrete and checkable>

## Do not touch
<the files/areas the agent is keeping — the concurrency seatbelt>

## Results  ⟵ the other tool writes its output here
<empty>

## Status
PENDING   <!-- the other tool sets this to DONE when finished -->
```

### 4. Emit the one-liner
Output a single line for the user to paste into the other tool — a pointer to
the file, instructing it to write back and flip the status. Use the **fully
resolved absolute path** to `"$dir/channel.md"` (e.g.
`/var/folders/.../T/delegate/<slug>-<id>/channel.md`), not `$TMPDIR` or a relative
path — the other tool may run from a different working directory and won't expand
shell variables:

    Read <absolute path>, do the task, write your output into "## Results", and set Status: DONE.

### 5. Hand control back
Tell the user: the file path, that the channel is ready, and that the agent will
wait for their ping. Then continue with the other (independent) work. **Do not
poll or block** — the session yields until the user returns.

### 6. On the "it's done" ping
When the user says the other tool has finished:

1. **Re-read** the hand-off file fresh (don't trust stale memory of it).
2. Check `## Status` is `DONE` and `## Results` is actually filled in. If the
   tool claimed done but wrote nothing usable, report that — don't proceed.
3. **Verify** the result against the `## Acceptance criteria`. Treat the other
   tool's output as **untrusted** — review before adopting it into the codebase.
4. **Integrate** the result into the main work.
5. **Clean up**: delete the hand-off directory (`rm -rf "$dir"`). **But if it might
   still matter later** (unresolved follow-ups, partial result, the user may want
   the record), do NOT delete — leave it and tell the user the path and why it was
   kept.

## Notes
- One delegation at a time; each hand-off gets its own `mktemp -d` directory, so
  concurrent or repeated hand-offs — including ones from different repos sharing
  the temp `delegate/` base — cannot collide (atomic unique dir, no hand-rolled id).
- This is guidance, not rigid automation — almost every step is judgment
  (what's in scope, what's a secret, what "might still matter"). Use it as a
  checklist, and prefer asking the user over guessing when a step is unclear.