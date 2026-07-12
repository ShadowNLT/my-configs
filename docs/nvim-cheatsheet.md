# Neovim cheat sheet

> Leader key → `Space`

---

## 📑 Index

*Sections are sorted alphabetically.*

- Buffers
- Comments
- Completion
- Debugging
- File Explorer
- Flash
- Folding
- Formatting
- Git — Gitsigns
- Harpoon
- LazyGit
- Linting
- LSP Keymaps
- Markdown
- Mason
- Noice / Notifications
- Numbers
- Quick Motions
- Refactoring
- Search
- Sessions
- Spelling
- Surround
- Tabs
- Telescope
- TreeSitter
- Trouble
- Window Management
- Yank / Paste

---

## 🔄 Buffers

| Command | Description |
|---------|-------------|
| `:e` | Reload current buffer from disk (errors if unsaved changes) |
| `:e!` | Force-reload, discarding unsaved changes |
| `:checktime` | Reload only if changed on disk with no local edits (non-destructive) |
| `:bufdo e` | Reload all open buffers |

---

## 💬 Comments (Comment.nvim)

| Key | Description |
|-----|-------------|
| `gcc` | Toggle comment on current line |
| `gc<motion>` | Toggle comment over motion (e.g. `gc5j`) |
| `gc` (visual) | Toggle comment on selection |
| `[t` | Jump to previous TODO comment |
| `]t` | Jump to next TODO comment |

TODO syntax: `TODO:` · `HACK:` · `BUG:` · `NOTE:`

---

## 🧩 Completion (nvim-cmp)

Keys active while the completion menu is open (insert mode), plus snippet jumps.

| Key | Description |
|-----|-------------|
| `C-Space` | Open the completion menu manually |
| `C-j` | Next item in the menu |
| `C-k` | Previous item in the menu |
| `Enter` | Confirm the highlighted item |
| `C-e` | Close / cancel the menu |
| `C-f` / `C-b` | Scroll the docs window — cmp's docs, or the signature/hover popup while tabbing placeholders |
| `Tab` | Jump to next snippet placeholder (`${1:..}` → `${2:..}`); also moves menu selection |
| `S-Tab` | Jump to previous placeholder; also moves menu selection |

Function-argument placeholders come from the LSP (gopls `usePlaceholders`, lua_ls `callSnippet`, snippet support enabled for every server). Signature help pops up automatically as you type inside `(...)`.

---

## 🐛 Debugging (nvim-dap)

| Key | Description |
|-----|-------------|
| `<leader>bc` | Start / Continue |
| `<leader>bi` | Step Into |
| `<leader>bo` | Step Over |
| `<leader>bO` | Step Out |
| `<leader>be` | Stop / Terminate |
| `<leader>bb` | Toggle breakpoint |
| `<leader>bB` | Set conditional breakpoint |
| `<leader>bt` | Toggle DAP UI |
| `<leader>bl` | Run last configuration |

---

## 📁 File Explorer (nvim-tree)

### Global keymaps
| Key | Description |
|-----|-------------|
| `<leader>ee` | Toggle file explorer |
| `<leader>ef` | Toggle explorer focused on current file |
| `<leader>ec` | Collapse file explorer |
| `<leader>er` | Refresh file explorer |

### Inside the tree — navigation
| Key | Description |
|-----|-------------|
| `Enter` / `o` | Open file / expand directory |
| `<Tab>` | Preview file (open without moving cursor) |
| `<C-v>` | Open in vertical split |
| `<C-x>` | Open in horizontal split |
| `<C-t>` | Open in new tab |
| `P` | Jump to parent directory |
| `<BS>` | Close current directory |
| `W` | Collapse all |
| `E` | Expand all |
| `-` | Go up to parent root |
| `<C-]>` | CD into directory (change tree root) |
| `q` | Close tree |
| `g?` | Toggle help |

### Inside the tree — file operations
| Key | Description |
|-----|-------------|
| `a` | Create file or directory (end name with `/` for dir) |
| `r` | Rename |
| `e` | Rename — basename only |
| `<C-r>` | Rename — omit filename (edit dir path only) |
| `d` | Delete |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste (into the directory under cursor) |
| `gp` | Move — prompts for destination path |
| `y` | Copy filename |
| `Y` | Copy relative path |
| `gy` | Copy absolute path |

### Inside the tree — bulk operations (bookmarks)
| Key | Description |
|-----|-------------|
| `m` | Toggle bookmark on file/dir |
| `bmv` | Move all bookmarked to a destination |
| `bd` | Delete all bookmarked |
| `bt` | Trash all bookmarked |

### Inside the tree — filter & search
| Key | Description |
|-----|-------------|
| `f` | Live filter (narrow tree by name) |
| `F` | Clear live filter |
| `H` | Toggle dotfiles |
| `I` | Toggle git-ignored files |
| `S` | Search / jump to node by name |

---

## ⚡ Flash (navigation)

| Key | Mode | Description |
|-----|------|-------------|
| `s <term>` | Normal/Visual/Op | Jump to any location by search label |
| `S` | Normal/Visual/Op | TreeSitter node selection (`;` expand, `,` shrink) |
| `r` | Operator-pending | Remote action — jump somewhere, do op, return |
| `R` | Operator/Visual | Remote TreeSitter selection |
| `<C-s>` | Command | Toggle Flash on `/` search |

---

## 📦 Folding (nvim-ufo + TreeSitter)

| Key | Description |
|-----|-------------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds except specified kinds |
| `zm` | Close folds by level |
| `zo` | Open fold under cursor |
| `zc` | Close fold under cursor |
| `za` | Toggle fold under cursor |

---

## ✏️ Formatting (conform.nvim)

| Key | Description |
|-----|-------------|
| `<leader>mp` | Format file (or selected range in visual mode) |

Formatters by filetype: `prettier` (JS/TS/CSS/HTML) · `stylua` (Lua) · `isort` + `black` (Python) · `goimports` + `gofumpt` (Go)

---

## 🐙 Git — Gitsigns

### Navigation
| Key | Description |
|-----|-------------|
| `]h` | Next hunk |
| `[h` | Previous hunk |

### Hunk Actions
| Key | Description |
|-----|-------------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hs` (visual) | Stage selected lines |
| `<leader>hr` (visual) | Reset selected lines |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hu` | Undo last stage |
| `<leader>hp` | Preview hunk diff |
| `ih` (op/visual) | Select hunk as text object (`dih`, `yih`) |

### Blame & Diff
| Key | Description |
|-----|-------------|
| `<leader>hb` | Full blame popup for current line |
| `<leader>hB` | Toggle inline blame |
| `<leader>hd` | Diff vs index (staged) |
| `<leader>hD` | Diff vs HEAD~1 |

---

## 🎯 Harpoon

Pin a small working set of files and jump to them instantly by slot — faster
than fuzzy-searching when you keep bouncing between the same few files.

| Key | Description |
|-----|-------------|
| `<leader>a` | Add current file to the list |
| `<leader>m` | Toggle the quick menu (view / reorder / remove) |
| `<leader>1`–`<leader>4` | Jump to pinned file 1–4 |

### Inside the quick menu (`<leader>m`)

The menu is an editable buffer of your pinned files in slot order — manage it with
normal Vim editing; changes **save when you close the window**.

| Key | Description |
|-----|-------------|
| `dd` | Remove the file on that line from the list |
| `dd` then `p` | Reorder — slot numbers `1–4` follow line order |
| `<CR>` | Open the file on the current line |
| `<C-v>` | Open it in a vertical split |
| `<C-x>` | Open it in a horizontal split |
| `<C-t>` | Open it in a new tab |
| `q` / `<Esc>` | Close the menu and save the list |

---

## 😸 LazyGit

| Key | Description |
|-----|-------------|
| `<leader>lg` | Open LazyGit |

---

## 🔎 Linting (nvim-lint)

| Key | Description |
|-----|-------------|
| `<leader>l` | Trigger linter for current file |

Active linters: `pylint` (Python)

---

## 🔡 LSP Keymaps
*Only active when an LSP is attached to the buffer.*

| Key | Description |
|-----|-------------|
| `gR` | Show all references (Telescope) |
| `gD` | Go to declaration (Lspsaga) |
| `gd` | Peek definition (Lspsaga) |
| `gi` | Show implementations (Telescope) |
| `gt` | Show type definitions (Telescope) |
| `<leader>ca` | Code actions (Lspsaga) |
| `<leader>rn` | Smart rename |
| `<leader>D` | Show diagnostics for file (Telescope) |
| `<leader>d` | Show diagnostics for current line |
| `[d` | Go to previous diagnostic |
| `]d` | Go to next diagnostic |
| `K` | Hover documentation (Lspsaga) |
| `<leader>co` | Toggle symbol outline (Lspsaga) |
| `<leader>cf` | Finder — definitions + references combined (Lspsaga) |
| `<leader>ci` | Incoming calls — who calls this? (Lspsaga) |
| `<leader>cO` | Outgoing calls — what does this call? (Lspsaga) |
| `<leader>rs` | Restart LSP |
| `<leader>rr` | Revive a "dead" buffer: restart LSP + re-detect filetype (see note) |

> Auto-removes unused imports on save for TS/JS/TSX/JSX.
>
> `<leader>rr` is **global** — unlike the rest of this section it works even when no
> LSP is attached. Reach for it when a file opens with no auto-pairs or completion
> instead of quitting nvim.

---

## 📝 Markdown (render-markdown.nvim)

Renders markdown inline (headings, code blocks, tables, lists) automatically.
No keymaps — driven by commands. The raw text is shown on the line your
cursor is on, rendered everywhere else.

| Command | Description |
|---------|-------------|
| `:RenderMarkdown toggle` | Toggle rendering on/off |
| `:RenderMarkdown enable` | Force rendering on |
| `:RenderMarkdown disable` | Force rendering off (see raw markdown) |
| `:RenderMarkdown expand` | Show more raw text around the cursor |
| `:RenderMarkdown contract` | Show less raw text around the cursor |

> Markdown buffers soft-wrap (`wrap` + `linebreak` + `breakindent`) so long
> lines flow into the next row instead of scrolling — see
> `after/ftplugin/markdown.lua`.

---

## 🛠 Mason

| Command | Description |
|---------|-------------|
| `:Mason` | Open Mason UI |
| `i` | Install package (inside Mason UI) |
| `X` | Uninstall package (inside Mason UI) |

---

## 🔔 Noice / Notifications

| Key | Description |
|-----|-------------|
| `<leader>nc` | Dismiss all notification messages |

---

## 🔢 Numbers

| Key | Description |
|-----|-------------|
| `<leader>+` | Increment number under cursor |
| `<leader>-` | Decrement number under cursor |

---

## ⚡ Quick Motions

| Key | Description |
|-----|-------------|
| `gg` | Top of file |
| `G` | Bottom of file |
| `H` | Top of screen |
| `M` | Middle of screen |
| `L` | Bottom of screen |
| `zz` | Center current line on screen |
| `C-o` | Jump **backwards** in jump list |
| `C-i` | Jump **forwards** in jump list |

---

## 🔁 Refactoring (refactoring.nvim)

| Key | Description |
|-----|-------------|
| `<leader>R` | Open refactor menu (normal & visual) |

Actions include: extract function, extract variable, inline variable, etc.

---

## 🔍 Search

| Key | Description |
|-----|-------------|
| `<leader>nh` | Clear search highlights |

---

## 💾 Sessions (auto-session)

| Key | Description |
|-----|-------------|
| `<leader>wr` | Search / restore a session |
| `<leader>ws` | Save current session |
| `<leader>wa` | Toggle autosave |

Sessions are saved and restored automatically per working directory.

---

## ✍️ Spelling (cspell + none-ls)

Spell-checks comments & prose in code files — same engine as VS Code's *Code
Spell Checker*, including camelCase/snake_case splitting. Misspellings appear as
quiet **hint**-level squiggles. Custom words live in a global
`~/.config/cspell/cspell.json` (a project-local `cspell.json` overrides it).

| Key | Description |
|-----|-------------|
| `<leader>cs` | Toggle cspell on/off (silence a noisy buffer) |
| `<leader>cw` | Add word under cursor to the dictionary (cursor must be on the squiggle) |
| `<leader>ca` | Code actions — also lists cspell "use suggestion" / "add to dictionary" fixes |

Checked filetypes: lua · python · js/ts (+react) · go · graphql · html/css/scss · markdown · text · gitcommit · sh/bash

---

## 🔗 Surround (nvim-surround)

### 🧠 The three core verbs
| Verb | Meaning | Shape |
|------|---------|-------|
| `ys` | **add** surround ("you surround") | `ys` + *motion/textobj* + *char* |
| `cs` | **change** surround | `cs` + *old* + *new* |
| `ds` | **delete** surround | `ds` + *char* |

> 💡 The cursor can sit **anywhere inside** the target — surround searches outward.

### ➕ Add surround — `ys{motion}{char}`
| Command | Before (cursor `*`) | After |
|---------|--------------------|-------|
| `ysiw)` | `wo*rd` | `(word)` |
| `ysiw"` | `wo*rd` | `"word"` |
| `ysiw}` | `wo*rd` | `{word}` |
| `ysiwt` → `em<CR>` | `wo*rd` | `<em>word</em>` |
| `ysiwf` → `fn<CR>` | `wo*rd` | `fn(word)` |
| `yss)` | whole line | `(line contents)` |
| `ys$"` | from cursor → EOL | `"...rest of line"` |
| `yS` (instead of `ys`) | — | puts surround **on its own lines** (great for JSX/blocks) |

### 🔁 Change surround — `cs{old}{new}`
| Command | Before | After |
|---------|--------|-------|
| `cs"'` | `"text"` | `'text'` |
| `cs'"` | `'text'` | `"text"` |
| `cs)]` | `(text)` | `[text]` |
| `cs]}` | `[text]` | `{text}` |
| `cs"t` → `div<CR>` | `"text"` | `<div>text</div>` |
| `cstt` → `h1<CR>` | `<b>text</b>` | `<h1>text</h1>` |

### ➖ Delete surround — `ds{char}`
| Command | Before | After |
|---------|--------|-------|
| `ds"` | `"text"` | `text` |
| `ds)` | `(text)` | `text` |
| `ds]` | `[text]` | `text` |
| `ds}` | `{text}` | `text` |
| `dst` | `<b>text</b>` | `text` |
| `dsf` | `fn(args)` | `args` |

### 🏷 Tags (HTML / JSX)
| Command | Cursor position | Result |
|---------|----------------|--------|
| `ysat)` | inside the tag | wrap **whole tag** in parens `<ul>…</ul>` → `(<ul>…</ul>)` |
| `ysit)` | inside the tag | wrap **inner content** only, tags stay outside |
| `ySatt` → `div<CR>` | inside the tag | wrap **whole tag in a new tag** (on its own lines) |
| `ysatt` → `div<CR>` | inside the tag | same, but inline `<div><form>…</form></div>` |
| `dst` | inside the tag | remove the surrounding tag |
| `cstt` → `section<CR>` | inside the tag | rename the tag |

> 🔑 **The doubled `t`:** the first `t` is part of `at` (the *target* = a tag); the second `t` means "wrap with a **t**ag" and triggers the name prompt. Without it, the next single key gets eaten as the delimiter.

> ⚠️ `at`/`it` grab the **nearest** enclosing tag. To target the outer `<form>` when inside a child element, move the cursor **onto the `<form>` line** first.

> 💡 At the name prompt you can include attributes: `div class="wrapper"` + `<CR>` → opens `<div class="wrapper">`, closes plain `</div>`.

### 🎯 Visual mode
1. Select text (`v`, `V`, or `<C-v>`)
2. Press **`S`** + char → wraps the selection
   - e.g. select a word → `S)` → `(word)`
   - select lines → `S}` → wraps in `{ }`

### 🔑 Spacing rule (memorize this)
| Char | Result | Note |
|------|--------|------|
| `)` `]` `}` | `(x)` `[x]` `{x}` | **closing** bracket = **no** inner spaces |
| `(` `[` `{` | `( x )` `[ x ]` `{ x }` | **opening** bracket = **adds** inner spaces |

---

## 🗂 Tabs

| Key | Description |
|-----|-------------|
| `<leader>to` | Open new tab |
| `<leader>tx` | Close current tab |
| `<leader>tn` | Go to next tab |
| `<leader>tp` | Go to previous tab |
| `<leader>tf` | Open new empty tab |

---

## 🔭 Telescope

| Key | Description |
|-----|-------------|
| `<leader>ff` | Fuzzy find files in cwd |
| `<leader>fo` | Fuzzy find open buffers |
| `<leader>fr` | Find recent files |
| `<leader>fs` | Live grep in cwd |
| `<leader>fc` | Find string under cursor in cwd |
| `<leader>fg` | Live grep with args |
| `<leader>ft` | Find TODO comments |
| `<leader>fb` | File browser |

---

## 🌳 TreeSitter

| Key | Description |
|-----|-------------|
| `<C-space>` | Init / expand selection (incremental) |
| `<BS>` | Shrink selection |
| `:InspectTree` | View the syntax tree (AST) |

---

## 🚨 Trouble (diagnostics)

| Key | Description |
|-----|-------------|
| `<leader>xx` | Toggle workspace diagnostics |
| `<leader>xd` | Toggle document diagnostics |
| `<leader>xq` | Toggle quickfix list |
| `<leader>xl` | Toggle location list |
| `<leader>xt` | Toggle TODOs in Trouble |

---

## 🪟 Window Management

| Key | Description |
|-----|-------------|
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<leader>se` | Make splits equal size |
| `<leader>sx` | Close current split |
| `<leader>sm` | Maximize / restore split (vim-maximizer) |

### Navigation between splits (vim-tmux-navigator)
Use `Ctrl` + vim direction: `h` left · `j` down · `k` up · `l` right  
Works across Neovim splits **and** tmux panes seamlessly.

---

## ✂️ Yank / Paste

| Key | Description |
|-----|-------------|
| `yy` | Yank (copy) current line |
| `Y` | Yank to end of line (Neovim default = `y$`) |
| `3yy` | Yank 3 lines from cursor down |
| `p` / `P` | Paste after / before cursor |
| `dd` | Delete (cut) current line |
| `"+yy` | Yank current line to the system clipboard |
