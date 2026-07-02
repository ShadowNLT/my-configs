# tmux cheat sheet

> Prefix → `C-b`

---

## 📑 Index

*Sections are sorted alphabetically.*

- Behaviour & options
- Clock mode
- Copy mode
- Panes
- Plugins
- Sessions
- Windows

---

## ⚙️ Behaviour & options

Configured in `tmux.conf`; reload after edits with `C-b r`.

| Key / setting | Description |
|-----|-------------|
| `C-b r` | Reload `tmux.conf` |
| `C-b :` | Enter tmux command mode |
| mouse on | Click to select panes/windows, drag borders to resize, scroll to enter copy mode |
| vi mode | `mode-keys vi` — copy mode uses Vim motions |

---

## 🕐 Clock mode

| Key | Description |
|-----|-------------|
| `C-b t` | Enter clock mode |
| `Esc` | Quit clock mode |

---

## 📋 Copy mode

Vim-style selection (`mode-keys vi`). Once inside, keys are pressed **without** the prefix.

| Key | Description |
|-----|-------------|
| `C-b [` | Enter copy mode |
| `h` `j` `k` `l` | Move by character / line |
| `C-u` / `C-d` | Half page up / down |
| `C-b` / `C-f` | Full page up / down |
| `v` | Start selection |
| `y` | Copy selection (and exit) |
| `C-c` / `q` | Exit copy mode |

---

## 🔲 Panes

| Key | Description |
|-----|-------------|
| `C-b \|` | Split to the right (vertical) |
| `C-b -` | Split below (horizontal) |
| `C-b h` `j` `k` `l` | Resize pane left / down / up / right (repeatable) |
| `C-b m` | Maximize / restore (zoom) the pane |
| `C-b q` | Kill pane (no confirmation) |
| `C-b x` | Kill pane (confirm with `y`) |
| `$ exit` | Kill pane from the shell |

### Navigation between panes (vim-tmux-navigator)
Use `Ctrl` + Vim direction, **no prefix**: `C-h` left · `C-j` down · `C-k` up · `C-l` right.
Moves seamlessly across tmux panes **and** Neovim splits.

---

## 🔌 Plugins (TPM)

Managed by TPM. Installed: `vim-tmux-navigator`, `tmux-resurrect`, `tmux-continuum`.

| Key | Description |
|-----|-------------|
| `C-b I` | Install plugins |
| `C-b U` | Update plugins |
| `C-b alt-u` | Uninstall plugins not in the list |
| `C-b C-s` | Save session (tmux-resurrect) |
| `C-b C-r` | Restore session (tmux-resurrect) |

Sessions auto-save and restore across restarts, including pane contents (tmux-continuum + resurrect).

---

## 🗂 Sessions

| Key / command | Description |
|-----|-------------|
| `C-b S` | Create a new session (prompts for a name) |
| `C-b K` | Kill the current session (confirm with `y`) |
| `C-b $` | Rename the current session |
| `C-b s` | List / switch sessions |
| `C-b d` | Detach from the session |
| `$ tmux new -s <name>` | Create a session from the shell |
| `$ tmux attach -t <name>` | Attach to a session |
| `$ tmux ls` | List sessions from the shell |

---

## 🪟 Windows

| Key | Description |
|-----|-------------|
| `C-b c` | Create a new window |
| `C-b ,` | Rename the current window |
| `C-b n` / `C-b p` | Next / previous window |
| `C-b <number>` | Jump to window by number |
| `C-b w` | List all windows |
| `C-b &` | Close window (confirm) |
