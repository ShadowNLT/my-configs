#!/usr/bin/env bash
# setup.sh — Bootstrap a fresh Mac with all dotfiles and tools
# Repo: git@github.com:ShadowNLT/my-configs.git
# Usage: bash setup.sh

set -euo pipefail

DOTFILES_DIR="$HOME/Developer/dotfiles/my-configs"
DOTFILES_REPO="https://github.com/ShadowNLT/my-configs.git"

# ─── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
err()     { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ─── Phase 1: Homebrew ────────────────────────────────────────────────────────
phase1_homebrew() {
  info "Phase 1 — Homebrew"

  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script (Apple Silicon default path)
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    success "Homebrew installed."
  else
    success "Homebrew already installed."
  fi

  info "Updating Homebrew..."
  brew update
}

# ─── Phase 2: Install tools ───────────────────────────────────────────────────
phase2_tools() {
  info "Phase 2 — Install tools via Homebrew"

  # CLI formulae
  local formulae=(
    neovim
    tree-sitter-cli   # required by nvim-treesitter `main` branch to compile parsers (Neovim 0.12+)
    tmux
    bat
    fzf
    ripgrep   # required by Telescope live_grep / grep_string
    fd        # faster file finding for Telescope
    zoxide
    nvm
    yazi
    lazygit
    gh
    git
    go
    python
    pipx      # used below to install Python formatters (PEP 668-safe)
  )

  info "Installing Homebrew formulae..."
  for pkg in "${formulae[@]}"; do
    if brew list --formula "$pkg" &>/dev/null; then
      success "$pkg already installed."
    else
      info "Installing $pkg..."
      brew install "$pkg"
    fi
  done

  # Cask apps
  local casks=(
    ghostty
    font-meslo-lg-nerd-font
    font-fira-code-nerd-font
  )

  info "Installing Homebrew casks..."
  # Note: homebrew/cask-fonts was deprecated in 2024 — nerd fonts now live
  # in the main homebrew/cask, so no tap is required.

  for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      success "$cask already installed."
    else
      info "Installing cask: $cask..."
      brew install --cask "$cask"
    fi
  done

  # ── Go formatters ──────────────────────────────────────────────────────────
  info "Installing Go formatters..."

  # Ensure GOPATH/bin is in PATH
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$PATH"

  local go_tools=(
    "golang.org/x/tools/cmd/goimports@latest"
    "github.com/incu6us/goimports-reviser/v3@latest"
    "github.com/segmentio/golines@latest"
    "mvdan.cc/gofumpt@latest"
  )

  for tool in "${go_tools[@]}"; do
    info "go install $tool"
    go install "$tool"
  done
  success "Go formatters installed."

  # ── Node via nvm ──────────────────────────────────────────────────────────
  info "Setting up Node.js via nvm..."

  # Source nvm from brew-installed location
  export NVM_DIR="$HOME/.nvm"
  local nvm_prefix
  nvm_prefix="$(brew --prefix nvm)"
  # shellcheck source=/dev/null
  [ -s "$nvm_prefix/nvm.sh" ] && source "$nvm_prefix/nvm.sh"

  if ! command -v nvm &>/dev/null; then
    err "nvm could not be loaded — check brew nvm installation."
  else
    info "Installing Node LTS..."
    nvm install --lts
    nvm use --lts

    info "Installing global npm packages..."
    npm install -g prettier
    success "npm globals installed."
  fi

  # ── Python formatters ─────────────────────────────────────────────────────
  info "Installing Python formatters..."
  if command -v pipx &>/dev/null; then
    pipx install isort  || true
    pipx install black  || true
    pipx install pylint || true
  else
    pip3 install --user isort black pylint
  fi
  success "Python formatters installed."

  # ── oh-my-zsh ─────────────────────────────────────────────────────────────
  info "Setting up oh-my-zsh..."

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh (unattended)..."
    RUNZSH=no CHSH=no \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "oh-my-zsh installed."
  else
    success "oh-my-zsh already installed."
  fi

  local omz_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # OMZ plugins
  local -A omz_plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting"
    [zsh-npm-scripts-autocomplete]="https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete"
  )

  for name in "${!omz_plugins[@]}"; do
    local dest="$omz_custom/plugins/$name"
    if [ ! -d "$dest" ]; then
      info "Installing OMZ plugin: $name..."
      git clone --depth=1 "${omz_plugins[$name]}" "$dest"
    else
      success "OMZ plugin already installed: $name"
    fi
  done

  # Powerlevel10k theme
  local p10k_dest="$omz_custom/themes/powerlevel10k"
  if [ ! -d "$p10k_dest" ]; then
    info "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dest"
    success "Powerlevel10k installed."
  else
    success "Powerlevel10k already installed."
  fi
}

# ─── Phase 3: Clone dotfiles ──────────────────────────────────────────────────
phase3_clone() {
  info "Phase 3 — Clone dotfiles repo"

  if [ -d "$DOTFILES_DIR/.git" ]; then
    success "Dotfiles repo already exists at $DOTFILES_DIR — skipping clone."
  else
    mkdir -p "$HOME/Developer/dotfiles"
    info "Cloning $DOTFILES_REPO → $DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    success "Dotfiles cloned."
  fi
}

# ─── Phase 4: symlinks ───────────────────────────────────────────────────────
phase4_symlinks() {
  info "Phase 4 — Create symlinks"

  mkdir -p "$HOME/.config"

  # ~/.config/<name> → $DOTFILES_DIR/<name>
  local -A config_symlinks=(
    [nvim]="$DOTFILES_DIR/nvim"
    [ghostty]="$DOTFILES_DIR/ghostty"
    [tmux]="$DOTFILES_DIR/tmux"
    [yazi]="$DOTFILES_DIR/yazi"
    [zsh]="$DOTFILES_DIR/zsh"
  )

  for name in "${!config_symlinks[@]}"; do
    local target="${config_symlinks[$name]}"
    local link="$HOME/.config/$name"
    _symlink "$link" "$target"
  done

  # $HOME dotfiles
  _symlink "$HOME/.zshrc"   "$DOTFILES_DIR/zsh/zshrc"
  _symlink "$HOME/.p10k.zsh" "$DOTFILES_DIR/zsh/p10k.zsh"
}

_symlink() {
  local link="$1" target="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    success "Symlink already correct: $link → $target"
  else
    if [ -e "$link" ]; then
      warn "$link exists but is not the expected symlink — backing up to ${link}.bak"
      mv "$link" "${link}.bak"
    fi
    ln -sf "$target" "$link"
    success "Linked: $link → $target"
  fi
}

# ─── Phase 5: TPM ────────────────────────────────────────────────────────────
phase5_tpm() {
  info "Phase 5 — Tmux Plugin Manager"

  local tpm_dir="$HOME/.config/tmux/plugins/tpm"

  if [ ! -d "$tpm_dir" ]; then
    info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    success "TPM cloned."
  else
    success "TPM already present."
  fi

  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    info "Installing TPM plugins..."
    # Requires a running tmux session or TMUX env var; skip gracefully if not in tmux
    if [ -n "${TMUX:-}" ]; then
      "$tpm_dir/bin/install_plugins"
      success "TPM plugins installed."
    else
      warn "Not inside a tmux session — run '~/.config/tmux/plugins/tpm/bin/install_plugins' manually, or press <prefix>+I inside tmux."
    fi
  fi
}

# ─── Phase 6: Neovim headless plugin install ─────────────────────────────────
phase6_nvim() {
  info "Phase 6 — Neovim headless plugin sync"

  if command -v nvim &>/dev/null; then
    info "Running lazy.nvim sync (this may take a moment)..."
    nvim --headless "+Lazy! sync" +qa 2>&1 || warn "Lazy sync exited non-zero — this is often harmless on first run."
    success "Neovim plugins synced."
  else
    warn "nvim not found in PATH — skipping plugin sync."
  fi
}

# ─── Phase 7: fzf shell integration ─────────────────────────────────────────
phase7_fzf() {
  info "Phase 7 — fzf shell integration"

  local fzf_install
  fzf_install="$(brew --prefix)/opt/fzf/install"

  if [ -x "$fzf_install" ]; then
    "$fzf_install" --key-bindings --completion --no-update-rc
    success "fzf shell integration installed."
  else
    warn "fzf install script not found at $fzf_install — skipping."
  fi
}

# ─── Phase 8: Manual steps reminder ─────────────────────────────────────────
phase8_reminder() {
  echo ""
  echo -e "${YELLOW}══════════════════════════════════════════════════════${RESET}"
  echo -e "${YELLOW}  Manual steps required after this script completes   ${RESET}"
  echo -e "${YELLOW}══════════════════════════════════════════════════════${RESET}"
  echo ""
  echo "  1. SSH key for GitHub"
  echo "       ssh-keygen -t ed25519 -C \"your@email.com\""
  echo "       # then add the public key to GitHub"
  echo ""
  echo "  2. GitHub CLI auth"
  echo "       gh auth login"
  echo ""
  echo "  3. Create ~/.zshrc"
  echo "       ~/.zshrc is NOT in the dotfiles repo."
  echo "       Create it manually and source the following as needed:"
  echo "         - oh-my-zsh"
  echo "         - Powerlevel10k  (ZSH_THEME=\"powerlevel10k/powerlevel10k\")"
  echo "         - nvm  (\$(brew --prefix nvm)/nvm.sh)"
  echo "         - fzf  (\$(brew --prefix)/opt/fzf/shell/*.zsh)"
  echo "         - zoxide  (eval \"\$(zoxide init zsh)\")"
  echo "         - completions dir: fpath+=~/.config/zsh/completions"
  echo ""
  echo "  4. Configure Powerlevel10k prompt"
  echo "       p10k configure"
  echo ""
  echo "  5. Mason LSP servers (auto-installs on first nvim open)"
  echo "       Just launch nvim — Mason will handle it."
  echo ""
  echo "  6. Install TPM plugins (if skipped above)"
  echo "       Inside tmux: press <prefix> + I"
  echo ""
  echo -e "${GREEN}Setup complete! Restart your terminal to apply all changes.${RESET}"
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║   macOS dotfiles bootstrap       ║${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════╝${RESET}"
  echo ""

  phase1_homebrew
  phase2_tools
  phase3_clone
  phase4_symlinks
  phase5_tpm
  phase6_nvim
  phase7_fzf
  phase8_reminder
}

main "$@"
