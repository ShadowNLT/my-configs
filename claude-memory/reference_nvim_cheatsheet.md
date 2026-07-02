---
name: reference-nvim-cheatsheet
description: "Locations + conventions for the user's Neovim and tmux keymap cheat sheets (Obsidian source + repo copies)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 277fd1be-9fd5-496e-81ad-447e659aaee9
---

The user keeps keymap cheat sheets in their Obsidian vault (source of truth) AND mirrored copies in the [[project-dotfiles]] repo under `docs/`.

**Obsidian (source of truth, clickable wikilink index):**
- `/Users/batmannlt/Documents/Obsidian/Batcave/6- Zettelkasten/NeoVim Cheat Sheet.md`
- `/Users/batmannlt/Documents/Obsidian/Batcave/6- Zettelkasten/Tmux.md`

**Repo copies (GitHub-facing, plain-list index):**
- `docs/nvim-cheatsheet.md`
- `docs/tmux-cheatsheet.md`

When nvim/tmux keymaps change, update BOTH the Obsidian source and the repo copy.

Conventions (both):
- Sections are `## <emoji> <Name>`, kept **sorted alphabetically by header** (emoji ignored for sorting).
- Top has a `## 📑 Index` listing every section. Obsidian uses `[[#<full header>|<alias>]]` wikilinks; the repo copy uses a plain bulleted list (GitHub's emoji-heading anchors are unreliable — leading hyphens, invisible variation-selector chars — so links aren't used there).
- Each section is a `| Key | Description |` table, separated by `---` rules.
- A leader/prefix callout up top (nvim: Leader = Space; tmux: Prefix = C-b).

Do NOT put a cheat sheet in the repo `readme.md` — the user removed one from there; repo cheat sheets live in `docs/`.
