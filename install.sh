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
    # A real file here (e.g. the default ~/.zshrc the oh-my-zsh installer
    # writes) would otherwise be left in place, silently orphaning our
    # config. Back it up and link anyway so the install is reliable.
    warn "$dst exists and is not a symlink, backing up to $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  ok "linked $dst"
}

# ---------- Homebrew ----------
info "Checking Homebrew dependencies..."
if command -v brew &>/dev/null; then
  # mk (Marked 3 CLI) ships from Brett Terpstra's third-party tap (also declared in the
  # Brewfile). Newer Homebrew refuses formulae from untrusted taps, so tap and trust just
  # that one formula before bundling — bundle would otherwise abort on it. Both idempotent.
  brew tap ttscoff/thelab &>/dev/null || true
  brew trust --formula ttscoff/thelab/mk &>/dev/null || true
  brew bundle --file="$DOTFILES/Brewfile"
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

# codex/gemini/grok AGENTS.md are intentionally NOT symlinked to claude/CLAUDE.md — each tool's
# instructions are customized separately. Sharing the agentic orchestrator doc anchored the review
# peers (it pushed agy to "implement" instead of review); see the ensemble project. Only
# ~/.claude/CLAUDE.md is linked (above).

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

# ---------- GAM (Google Workspace admin CLI) ----------
# Official gam7 PyPI package, installed isolated via uv (no brew formula
# exists; the curl installer prompts interactively). Binary lands in
# ~/.local/bin, already on PATH.
info "Checking GAM..."
if command -v uv &>/dev/null; then
  if ! command -v gam &>/dev/null; then
    uv tool install gam7
    ok "GAM installed"
  else
    ok "GAM already installed"
  fi
else
  warn "uv not found, skipping GAM install"
fi

# ---------- Azure Artifacts credential provider ----------
# NuGet plugin that authenticates dotnet/nuget to Azure DevOps Artifacts feeds. No brew
# formula exists, so use Microsoft's official installer, which drops the netcore plugin into
# ~/.nuget/plugins (re-run to update). The apphost binary sometimes lands without the exec
# bit — NuGet launches it directly on macOS, so chmod it (idempotent; fixes prior installs).
info "Checking Azure Artifacts credential provider..."
CREDPROVIDER_DIR="$HOME_DIR/.nuget/plugins/netcore/CredentialProvider.Microsoft"
if [ ! -d "$CREDPROVIDER_DIR" ]; then
  sh -c "$(curl -fsSL https://aka.ms/install-artifacts-credprovider.sh)"
  ok "Azure Artifacts credential provider installed"
else
  ok "Azure Artifacts credential provider already installed"
fi
if [ -f "$CREDPROVIDER_DIR/CredentialProvider.Microsoft" ]; then
  chmod +x "$CREDPROVIDER_DIR/CredentialProvider.Microsoft"
fi

# ---------- SDKMAN ----------
info "Checking SDKMAN..."
if [ ! -d "$HOME_DIR/.sdkman" ]; then
  curl -s "https://get.sdkman.io" | bash
  ok "SDKMAN installed"
else
  ok "SDKMAN already installed"
fi

# ---------- Node (via asdf) ----------
# Runtimes are asdf-managed, not brew-installed. Node provides npm for codex below.
info "Checking Node via asdf..."
if command -v asdf &>/dev/null; then
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  asdf plugin list 2>/dev/null | grep -qx nodejs || asdf plugin add nodejs
  if [ -z "$(asdf list nodejs 2>/dev/null | tr -d '[:space:]')" ]; then
    node_version="$(asdf latest nodejs)"
    asdf install nodejs "$node_version"
    asdf set --home nodejs "$node_version"
    asdf reshim nodejs
    ok "Node $node_version installed via asdf"
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
info "Checking Terraform via asdf..."
if command -v asdf &>/dev/null; then
  asdf plugin list 2>/dev/null | grep -qx terraform || asdf plugin add terraform
  asdf list terraform 2>/dev/null | grep -q "$terraform_version" || asdf install terraform "$terraform_version"
  asdf set --home terraform "$terraform_version"
  asdf reshim terraform
  ok "Terraform $terraform_version set as global default via asdf"
else
  warn "asdf not found, skipping terraform"
fi

# ---------- AI CLI tools ----------
# Peer model CLIs for the ensemble review skill. agy (antigravity-cli) installs via Brewfile;
# codex via npm; grok (xAI first-party) via its official installer.
info "Checking AI CLI tools..."
if command -v npm &>/dev/null; then
  if ! command -v codex &>/dev/null; then
    npm install -g @openai/codex
    command -v asdf &>/dev/null && asdf reshim nodejs
  fi
  ok "codex ready"
else
  warn "npm not found (is asdf nodejs set?), skipping codex install"
fi

# Grok CLI (`grok`, xAI first-party agentic CLI) — official installer; auth out of band via `grok login`.
if ! command -v grok &>/dev/null; then
  curl -fsSL https://x.ai/cli/install.sh | bash
  ok "Grok CLI installed"
else
  ok "Grok CLI already installed"
fi
# The grok installer injects a PATH/compinit block into ~/.zshrc (our managed zsh/zshrc). Strip it —
# grok is reachable via ~/.local/bin, and completions load via zsh/custom/grok.zsh instead.
if grep -q '# >>> grok installer >>>' "$DOTFILES/zsh/zshrc" 2>/dev/null; then
  sed -i '' '/# >>> grok installer >>>/,/# <<< grok installer <<</d' "$DOTFILES/zsh/zshrc"
  ok "stripped grok installer's zshrc injection (using zsh/custom/grok.zsh)"
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
