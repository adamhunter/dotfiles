#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"
# shellcheck disable=SC2034 # consumed by install/packages-linux.sh
LOCAL_BIN="$HOME_DIR/.local/bin"

info() { printf "\033[34m→\033[0m %s\n" "$1"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "\033[33m!\033[0m %s\n" "$1"; }

have() { command -v "$1" &>/dev/null; }

# Run an optional install step, reporting rather than aborting. This script runs
# under `set -e`, and one convenience tool hitting a transient network failure
# shouldn't take every step after it down too — a re-run picks it back up.
# Steps that must not be skipped (the symlinks) stay outside this.
attempt() {
  local label="$1"; shift
  if "$@"; then ok "$label installed"; else warn "$label install failed — skipping (re-run install.sh to retry)"; fi
  return 0
}

# ---------- platform ----------
# Package installation is the only genuinely per-platform step; everything below
# it (symlinks, vendor installers, runtimes) is shared. Each layer defines one
# function, <os>_packages, and install.sh calls it.
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) printf "unsupported platform: %s\n" "$(uname -s)" >&2; exit 1 ;;
esac

# Release assets disagree on how to spell the same CPU: neovim and glow say
# x86_64/arm64, asdf and glab say amd64/arm64. Carry both spellings.
# shellcheck disable=SC2034 # consumed by install/packages-linux.sh
case "$(uname -m)" in
  x86_64|amd64)  ARCH=x86_64; ARCH_ALT=amd64 ;;
  aarch64|arm64) ARCH=arm64;  ARCH_ALT=arm64 ;;
  *) ARCH="$(uname -m)"; ARCH_ALT="$ARCH" ;;
esac

# BSD and GNU sed disagree on -i: BSD requires a backup-suffix argument (empty
# for in-place), GNU reads that same argument as a filename and clobbers it.
sed_i() {
  if [ "$OS" = macos ]; then sed -i '' "$@"; else sed -i "$@"; fi
}

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    # A real file here (e.g. the default ~/.zshrc the oh-my-zsh installer
    # writes) would otherwise be left in place, silently orphaning our
    # config. Back it up and link anyway so the install is reliable.
    warn "$dst exists and is not a symlink, backing up to $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  ok "linked $dst"
}

# ---------- Packages ----------
# shellcheck source=/dev/null
source "$DOTFILES/install/packages-$OS.sh"
"${OS}_packages"

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

# tmux plugin manager (TPM) + plugins (resurrect, continuum)
TPM_DIR="$HOME_DIR/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  mkdir -p "$HOME_DIR/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed"
else
  ok "TPM already installed"
fi
if "$TPM_DIR/bin/install_plugins" >/dev/null 2>&1; then
  ok "tmux plugins installed"
else
  warn "tmux plugin install failed (open tmux and hit prefix + I)"
fi

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
link "$DOTFILES/claude/templates" "$HOME_DIR/.claude/templates"
ok "Claude Code configured"

# ---------- Codex ----------
# codex/AGENTS.md is a DISTILLED copy of claude/CLAUDE.md, not a symlink to it: it carries the
# shared rules and drops the ones tied to Claude Code's own machinery (model delegation, ensemble
# gates, its plugin/skill/template installation).
#
# This supersedes an earlier decision not to link any AGENTS.md at all, whose stated reason was that
# sharing the agentic orchestrator doc had anchored the ensemble review peers into implementing
# instead of reviewing. Treat that as an undocumented observation — no transcript or fixture in this
# repo substantiates it. Two things reduce the risk rather than eliminate it: ensemble-peer.sh
# overwrites AGENTS.md in the peer worktree with a review-only overlay, and per the documented
# lookup order (https://developers.openai.com/codex/guides/agents-md.md) that nearer file loads
# after ~/.codex/AGENTS.md, so it takes precedence; and the distilled file opens by deferring to any
# nearer read-only-reviewer AGENTS.md. Both files still sit in the peer's prompt, so if peers start
# implementing again, this link is the first thing to suspect.
#
# Keep the two files in sync; see the sync rule at the top of claude/CLAUDE.md.
# gemini/grok remain deliberately unlinked — their instructions are customized separately.
info "Linking Codex config..."
mkdir -p "$HOME_DIR/.codex"
link "$DOTFILES/codex/AGENTS.md" "$HOME_DIR/.codex/AGENTS.md"
ok "Codex configured"

# ---------- Claude Code install ----------
info "Checking Claude Code..."
if ! have claude; then
  attempt "Claude Code" bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
else
  ok "Claude Code already installed"
fi

# ---------- uv (Python package manager) ----------
info "Checking uv..."
if ! have uv; then
  attempt uv bash -c 'curl -LsSf https://astral.sh/uv/install.sh | bash'
else
  ok "uv already installed"
fi

# ---------- GAM (Google Workspace admin CLI) ----------
# Official gam7 PyPI package, installed isolated via uv (no brew formula
# exists; the curl installer prompts interactively). Binary lands in
# ~/.local/bin, already on PATH.
#
# macOS only: Workspace administration happens from the laptop, and the Linux
# boxes here are development machines. Nothing else depends on gam.
if [ "$OS" = macos ]; then
  info "Checking GAM..."
  if have uv; then
    if ! have gam; then
      attempt GAM uv tool install gam7
    else
      ok "GAM already installed"
    fi
  else
    warn "uv not found, skipping GAM install"
  fi
fi

# ---------- Azure Artifacts credential provider ----------
# NuGet plugin that authenticates dotnet/nuget to Azure DevOps Artifacts feeds. No brew
# formula exists, so use Microsoft's official installer, which drops the netcore plugin into
# ~/.nuget/plugins (re-run to update). The apphost binary sometimes lands without the exec
# bit — NuGet launches it directly, so chmod it (idempotent; fixes prior installs).
info "Checking Azure Artifacts credential provider..."
CREDPROVIDER_DIR="$HOME_DIR/.nuget/plugins/netcore/CredentialProvider.Microsoft"
if [ ! -d "$CREDPROVIDER_DIR" ]; then
  attempt "Azure Artifacts credential provider" \
    bash -c 'sh -c "$(curl -fsSL https://aka.ms/install-artifacts-credprovider.sh)"'
else
  ok "Azure Artifacts credential provider already installed"
fi
if [ -f "$CREDPROVIDER_DIR/CredentialProvider.Microsoft" ]; then
  chmod +x "$CREDPROVIDER_DIR/CredentialProvider.Microsoft"
fi

# ---------- SDKMAN ----------
# Needs both zip and unzip present; the Linux layer installs them.
info "Checking SDKMAN..."
if [ ! -d "$HOME_DIR/.sdkman" ]; then
  attempt SDKMAN bash -c 'curl -s "https://get.sdkman.io" | bash'
else
  ok "SDKMAN already installed"
fi

# ---------- Node (via asdf) ----------
# Runtimes are asdf-managed, not brew-installed. Node provides npm for codex below.
setup_node() {
  asdf plugin list 2>/dev/null | grep -qx nodejs || asdf plugin add nodejs || return 1
  local version
  version="$(asdf latest nodejs)" || return 1
  asdf install nodejs "$version" || return 1
  asdf set --home nodejs "$version" || return 1
  asdf reshim nodejs || return 1
  info "Node $version installed via asdf"
}
info "Checking Node via asdf..."
if have asdf; then
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  if [ -z "$(asdf list nodejs 2>/dev/null | tr -d '[:space:]')" ]; then
    attempt Node setup_node
  else
    ok "Node already managed by asdf"
  fi
else
  warn "asdf not found, skipping Node setup"
fi

# ---------- Terraform (via asdf) ----------
# Homebrew-core froze terraform at 1.5.7 when 1.6 moved to the BUSL license,
# so brew can't provide 1.6+; asdf can. Sets a global default; projects can
# still override via their own .tool-versions.
terraform_version="1.6.6"
setup_terraform() {
  asdf plugin list 2>/dev/null | grep -qx terraform || asdf plugin add terraform || return 1
  asdf list terraform 2>/dev/null | grep -q "$terraform_version" \
    || asdf install terraform "$terraform_version" || return 1
  asdf set --home terraform "$terraform_version" || return 1
  asdf reshim terraform || return 1
}
info "Checking Terraform via asdf..."
if have asdf; then
  attempt "Terraform $terraform_version (asdf global default)" setup_terraform
else
  warn "asdf not found, skipping terraform"
fi

# ---------- npm-delivered tools ----------
# codex is npm-only on both platforms. pnpm and firebase come from the Brewfile
# on macOS, which has no Linux counterpart here, so npm supplies them there.
info "Checking npm-delivered tools..."
if have npm; then
  npm_tools=(@openai/codex)
  [ "$OS" = linux ] && npm_tools+=(pnpm firebase-tools)
  installed=0
  for pkg in "${npm_tools[@]}"; do
    case "$pkg" in
      @openai/codex) bin=codex ;;
      firebase-tools) bin=firebase ;;
      *) bin="$pkg" ;;
    esac
    if ! have "$bin"; then
      attempt "$pkg" npm install -g "$pkg"
      installed=1
    fi
  done
  [ "$installed" = 1 ] && have asdf && asdf reshim nodejs
  ok "npm tools ready (${npm_tools[*]})"
else
  warn "npm not found (is asdf nodejs set?), skipping npm tools"
fi

# ---------- AI CLI tools ----------
# Peer model CLIs for the ensemble review skill. agy (antigravity-cli) installs via Brewfile
# and is a macOS cask with no Linux build — the ensemble plugin's agy peer is unavailable on
# Linux. grok (xAI first-party) installs via its official installer on both.
info "Checking AI CLI tools..."
if [ "$OS" = linux ]; then
  have agy || warn "agy (antigravity-cli) is macOS-only; the ensemble agy peer is unavailable here"
fi

# Grok CLI (`grok`, xAI first-party agentic CLI) — official installer; auth out of band via `grok login`.
if ! have grok; then
  attempt "Grok CLI" bash -c 'curl -fsSL https://x.ai/cli/install.sh | bash'
else
  ok "Grok CLI already installed"
fi
# The grok installer injects a PATH/compinit block into ~/.zshrc (our managed zsh/zshrc). Strip it —
# grok is reachable via ~/.local/bin, and completions load via zsh/custom/grok.zsh instead.
if grep -q '# >>> grok installer >>>' "$DOTFILES/zsh/zshrc" 2>/dev/null; then
  sed_i '/# >>> grok installer >>>/,/# <<< grok installer <<</d' "$DOTFILES/zsh/zshrc"
  ok "stripped grok installer's zshrc injection (using zsh/custom/grok.zsh)"
fi

# ---------- Shell integration ----------
info "Setting up shell tool integrations..."
if have fzf; then ok "fzf ready (ctrl-r, ctrl-t)"; fi
if have zoxide; then ok "zoxide ready (z command)"; fi
if have bat; then ok "bat ready"; fi
if have eza; then ok "eza ready"; fi
if have rg; then ok "ripgrep ready"; fi

echo ""
info "Done! Open a new terminal or run: source ~/.zshrc"
