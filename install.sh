#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

info() { printf "\033[34m→\033[0m %s\n" "$1"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "\033[33m!\033[0m %s\n" "$1"; }

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    warn "$dst exists and is not a symlink, skipping"
    return
  fi
  ln -sf "$src" "$dst"
  ok "linked $dst"
}

# ---------- Homebrew ----------
info "Checking Homebrew dependencies..."
if command -v brew &>/dev/null; then
  brew bundle --file="$DOTFILES/Brewfile" --no-lock
  ok "Brew dependencies installed"
else
  warn "Homebrew not found, skipping brew bundle"
fi

# ---------- oh-my-zsh ----------
info "Checking oh-my-zsh..."
if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "oh-my-zsh installed"
else
  ok "oh-my-zsh already installed"
fi

# ---------- ZSH ----------
info "Linking zsh config..."
link "$DOTFILES/zsh" "$HOME_DIR/.zsh"
link "$HOME_DIR/.zsh/zshrc" "$HOME_DIR/.zshrc"

# Custom oh-my-zsh files
for f in "$DOTFILES/zsh/custom/"*.zsh; do
  link "$f" "$HOME_DIR/.oh-my-zsh/custom/$(basename "$f")"
done
ok "zsh configured"

# ---------- Neovim ----------
info "Linking nvim config..."
mkdir -p "$HOME_DIR/.config/nvim"
link "$DOTFILES/nvim/init.lua" "$HOME_DIR/.config/nvim/init.lua"
link "$DOTFILES/nvim/lua" "$HOME_DIR/.config/nvim/lua"
ok "nvim configured (run nvim to bootstrap lazy.nvim plugins)"

# ---------- tmux ----------
info "Linking tmux config..."
link "$DOTFILES/tmux" "$HOME_DIR/.tmux"
link "$DOTFILES/tmux/tmux.conf" "$HOME_DIR/.tmux.conf"
ok "tmux configured"

# ---------- Git ----------
info "Linking git config..."
link "$DOTFILES/git/gitconfig" "$HOME_DIR/.gitconfig"
link "$DOTFILES/git/gitignore_global" "$HOME_DIR/.gitignore_global"
ok "git configured"

# ---------- bin ----------
info "Linking bin directory..."
link "$DOTFILES/bin" "$HOME_DIR/.bin"
ok "bin configured"

# ---------- Claude Code ----------
info "Linking Claude Code config..."
mkdir -p "$HOME_DIR/.claude"
link "$DOTFILES/claude/settings.json" "$HOME_DIR/.claude/settings.json"
link "$DOTFILES/claude/keybindings.json" "$HOME_DIR/.claude/keybindings.json"
link "$DOTFILES/claude/statusline-command.sh" "$HOME_DIR/.claude/statusline-command.sh"
link "$DOTFILES/claude/CLAUDE.md" "$HOME_DIR/.claude/CLAUDE.md"
ok "Claude Code configured"

# ---------- Claude Code install ----------
info "Checking Claude Code..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code installed"
else
  ok "Claude Code already installed"
fi

# ---------- uv (Python package manager) ----------
info "Checking uv..."
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | bash
  ok "uv installed"
else
  ok "uv already installed"
fi

# ---------- SDKMAN ----------
info "Checking SDKMAN..."
if [ ! -d "$HOME_DIR/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
  ok "SDKMAN installed"
else
  ok "SDKMAN already installed"
fi

# ---------- AI CLI tools ----------
info "Checking AI CLI tools..."
if command -v npm &>/dev/null; then
  command -v gemini &>/dev/null || npm install -g @google/gemini-cli
  command -v codex &>/dev/null || npm install -g @openai/codex
  ok "AI CLI tools installed"
else
  warn "npm not found, skipping gemini-cli and codex install"
fi

# ---------- Shell integration ----------
info "Setting up shell tool integrations..."
if command -v fzf &>/dev/null; then ok "fzf ready (ctrl-r, ctrl-t)"; fi
if command -v zoxide &>/dev/null; then ok "zoxide ready (z command)"; fi
if command -v bat &>/dev/null; then ok "bat ready"; fi
if command -v eza &>/dev/null; then ok "eza ready"; fi
if command -v rg &>/dev/null; then ok "ripgrep ready"; fi

echo ""
info "Done! Open a new terminal or run: source ~/.zshrc"
