---
name: dotfiles structure
description: Dotfiles repo layout, symlink structure, and per-tool dependencies for the setup script
type: project
---

Dotfiles repo: `git@github.com:ShadowNLT/my-configs.git`
Cloned to: `~/Developer/dotfiles/my-configs/`

Each tool's config folder is symlinked from `~/.config/<tool>` → `~/Developer/dotfiles/my-configs/<tool>`

Symlinks:
- `~/.config/nvim` → `…/nvim`
- `~/.config/ghostty` → `…/ghostty`
- `~/.config/tmux` → `…/tmux`
- `~/.config/yazi` → `…/yazi`
- `~/.config/zsh` → `…/zsh` (contains completions/ with `_gh`, `_tmux`)

**Why:** User wants a bootstrap script to replicate this setup on a new Mac.
**How to apply:** When writing the setup script, clone to that exact path and symlink all 5 dirs.

---

## Tool dependencies

### Shell / Zsh
- Homebrew (macOS package manager)
- oh-my-zsh
- Powerlevel10k theme (`powerlevel10k/powerlevel10k`)
- OMZ plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-npm-scripts-autocomplete`
- fzf (via brew, shell integration sourced in .zshrc)
- zoxide (via brew, `eval "$(zoxide init zsh)"`)
- nvm (via brew `nvm` formula)
- `~/.zshrc` is NOT in the dotfiles repo — lives at `~/.zshrc` directly

### Neovim
- neovim (via brew)
- Plugin manager: lazy.nvim (auto-bootstrapped in `lazy.lua`)
- All plugins auto-installed by lazy on first launch
- LSP servers installed via mason.nvim (lua_ls, ts_ls, graphql, angularls, emmet_ls, gopls)
- Formatters (need to be in PATH or mason): prettier, stylua, isort, black, goimports-reviser, goimports, golines, gofumpt
- Linters: eslint_d, pylint
- Go toolchain needed for gopls/go formatters
- Node.js needed for ts_ls, prettier, eslint_d

### Ghostty
- Ghostty terminal (via brew cask)
- Font: MesloLGS Nerd Font Mono (must be installed)

### Tmux
- tmux (via brew)
- TPM (Tmux Plugin Manager) — cloned to `~/.config/tmux/plugins/tpm`
- Plugins (installed by TPM): vim-tmux-navigator, tmux-themepack, tmux-resurrect, tmux-continuum
- Note: tmux plugins directory is already committed inside the repo

### Yazi
- yazi (via brew)
- Only a `theme.toml` — no extra plugins needed

### lazygit
- lazygit (via brew) — used via nvim plugin
