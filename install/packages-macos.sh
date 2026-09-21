#!/usr/bin/env bash
# macOS package layer, sourced by install.sh. Everything here comes from the
# Brewfile; see install/packages-linux.sh for how the same set is assembled on
# Linux and which entries have no Linux equivalent.

macos_packages() {
  info "Checking Homebrew dependencies..."
  if ! have brew; then
    warn "Homebrew not found, skipping brew bundle"
    return 0
  fi

  # mk (Marked 3 CLI) ships from Brett Terpstra's third-party tap (also declared in the
  # Brewfile). Newer Homebrew refuses formulae from untrusted taps, so tap and trust just
  # that one formula before bundling — bundle would otherwise abort on it. Both idempotent.
  brew tap ttscoff/thelab &>/dev/null || true
  brew trust --formula ttscoff/thelab/mk &>/dev/null || true
  # qodana (Qodana CLI) ships from JetBrains' third-party tap; same trust dance as mk above.
  brew tap jetbrains/utils &>/dev/null || true
  brew trust --formula jetbrains/utils/qodana &>/dev/null || true
  brew bundle --file="$DOTFILES/Brewfile"
  ok "Brew dependencies installed"
}
