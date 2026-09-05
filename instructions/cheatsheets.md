# Cheat sheets

Repo `docs/` is the source of truth. Machine copies (often Obsidian notes) are mirrors. Do not put a cheat sheet in the repo `readme.md`.

## Files

| Sheet | Repo (source of truth) | Machine path |
|-------|------------------------|--------------|
| Neovim | `docs/nvim-cheatsheet.md` | `local/machine.yaml` → `cheatsheets.nvim` |
| tmux | `docs/tmux-cheatsheet.md` | `local/machine.yaml` → `cheatsheets.tmux` |

Machine paths are per-machine and not committed. See `local/machine.example.yaml`.

## Shared format

- Sections are `## <emoji> <Name>`, sorted alphabetically by header (emoji ignored).
- Top has a `## 📑 Index` listing every section.
- Each section is a `| Key | Description |` table, separated by `---` rules.
- Leader / prefix callout at the top (nvim: Leader = Space; tmux: Prefix = C-b).

**Index format differs:**

- Repo: plain bullets (`- Buffers`). GitHub heading anchors with leading emoji are unreliable, so the repo index is not linked.
- Machine: Obsidian wikilinks `[[#<full heading>|<index alias>]]`. Full heading is the `## ` text (emoji included). Alias is the repo bullet text.

Example: repo `- Comments` and heading `## 💬 Comments (Comment.nvim)` become `- [[#💬 Comments (Comment.nvim)|Comments]]`.

## When `local/machine.yaml` is missing

Ask. Do not guess a vault path.

1. Ask for the Neovim cheatsheet path on this machine.
2. Ask for the tmux cheatsheet path on this machine.
3. Echo both paths and get confirmation.
4. Write `local/machine.yaml` (gitignored).

Empty answers mean skip for now; ask again the next time a sync is needed.

## Sync

After keymap or cheatsheet edits:

1. Update the repo file first.
2. Read `local/machine.yaml`. If it is missing, ask and write it (above).
3. Write the machine copy: same body as the repo file, but rewrite the Index to Obsidian wikilinks.
4. If a configured path does not exist yet, create the file (and parent directories).
5. If a path is set but unreadable or not a file you can write, stop and ask. Do not invent a vault.
