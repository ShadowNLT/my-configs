# Dotfiles — Agent Instructions

Personal macOS dev environment for BatmanNLT (lekanetamba@gmail.com).

## Repo layout

```
nvim/          Neovim config (lazy.nvim, LSP, treesitter, ...)
tmux/          tmux config + TPM plugins
ghostty/       Ghostty terminal config
zsh/           zshrc + p10k.zsh (symlinked to ~/.zshrc and ~/.p10k.zsh)
yazi/          yazi file manager config
docs/          Cheat sheets (nvim-cheatsheet.md, tmux-cheatsheet.md)
setup.sh       Full bootstrap script for a fresh Mac
protocols/     Agent-agnostic procedures (agent decides skill vs command on install)
corporate/     Work agent seed: corporate-agent.md + work slash commands
personal/      Personal agent seed: AGENT.md (no work commands)
```

## New machine bootstrap

When the user checks out this repo on a fresh Mac and asks you to set it up, follow these steps in order:

### Step 1 -- Run the bootstrap script
```bash
bash setup.sh
```

> **Before running:** if `~/.zshrc` already exists on this machine, `setup.sh` will move it to `~/.zshrc.bak` (not delete it) before symlinking the repo version. After the script finishes, check whether `.zshrc.bak` exists and diff it against `zsh/zshrc` -- merge any machine-specific lines (custom PATH entries, work aliases, secrets sourcing, etc.) into the repo file before removing the backup. Never delete `.zshrc.bak` without inspecting it first.

This handles automatically (no interaction needed):
- Homebrew + all formulae and casks (neovim, tree-sitter-cli, tmux, fzf, ripgrep, fd, zoxide, nvm, yazi, lazygit, gh, git, go, python, ghostty, MesloLGS Nerd Font)
- Go formatters (goimports, golines, gofumpt, goimports-reviser)
- Node LTS via nvm + prettier
- Python formatters via pipx (isort, black, pylint)
- oh-my-zsh + zsh-autosuggestions, zsh-syntax-highlighting, zsh-npm-scripts-autocomplete
- Powerlevel10k theme
- All ~/.config symlinks (nvim, ghostty, tmux, yazi, zsh) + ~/.zshrc + ~/.p10k.zsh
- TPM clone (run `<prefix>+I` inside tmux to install plugins)
- Neovim headless lazy.nvim sync
- fzf shell key-bindings + completion

### Step 2 -- SSH key for GitHub
```bash
ssh-keygen -t ed25519 -C "lekanetamba@gmail.com"
cat ~/.ssh/id_ed25519.pub
```
Then add the public key to GitHub -> Settings -> SSH keys.
Test with: `ssh -T git@github.com`

### Step 3 -- GitHub CLI auth
```bash
gh auth login
```
Follow the interactive prompts (browser OAuth).

### Step 4 -- Restart the terminal
Open a new terminal window. Powerlevel10k and oh-my-zsh will be active immediately (p10k config is already symlinked -- no `p10k configure` needed).

### Step 5 -- Inside tmux: install TPM plugins
```
<prefix> + I
```

---

## Conventions

- Cheat sheets live in `docs/` (repo) AND in Obsidian at `6- Zettelkasten/`. Keep both in sync when keymaps change.
- Never add `Co-Authored-By` trailers to commits (regardless of which agent is writing them).
- LSP arg placeholders must stay on for every server (current and future). See `claude-memory/feedback_lsp_arg_placeholders.md`.
