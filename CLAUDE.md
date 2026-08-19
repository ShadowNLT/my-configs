# BatmanNLT dotfiles — Claude context

Personal macOS dev environment for BatmanNLT (lekanetamba@gmail.com).

## Shared instructions

**Read `instructions/README.md` first.** It covers repo layout, bootstrap steps, and conventions that apply to all agents.

The sections below are Claude-specific additions on top of those shared instructions.

## Repo layout (Claude additions)

```
claude-memory/ Persistent Claude memory (symlinked from ~/.claude/projects/.../memory)
```

## New machine bootstrap (Claude-specific step)

After running Step 1 from `instructions/README.md`, wire up the persistent Claude memory so it survives future checkouts:

```bash
REPO="$(pwd)"
SLUG=$(echo "$REPO" | sed 's|/|-|g' | sed 's|^-||')
MEMORY_DIR="$HOME/.claude/projects/$SLUG/memory"
mkdir -p "$(dirname "$MEMORY_DIR")"
ln -sf "$REPO/claude-memory" "$MEMORY_DIR"
```

Then continue with Steps 2-5 from `instructions/README.md`.

## Conventions (Claude-specific)

- Never add `Co-Authored-By: Claude` trailers to commits.
- LSP arg placeholders must stay on for every server (current and future). See `claude-memory/feedback_lsp_arg_placeholders.md`.
