#!/usr/bin/env bash
# Linux package layer, sourced by install.sh. Ubuntu/Debian only.
#
# This mirrors the Brewfile as closely as Linux allows. Differences, and why:
#   - casks have no Linux equivalent: antigravity-cli (agy), gcloud-cli, the
#     Nerd Font. A VM has no local terminal, so the font belongs on whatever
#     machine you actually type into; gcloud comes from apt/snap instead.
#   - mk (Marked 3 CLI) drives a macOS app, and msupdate is macOS-only.
#   - googleworkspace-cli / GAM are Workspace admin tooling, deliberately
#     macOS-only (see install.sh).
#   - coreutils is unnecessary: gtimeout here is just `timeout`.
# Anything Ubuntu ships new enough comes from apt; the rest are vendor binaries
# dropped into ~/.local/bin, which zsh/zshrc already puts on PATH.

# Ubuntu 24.04 versions of these are all current enough to use as-is.
APT_PACKAGES=(
  zsh
  tmux              # 3.4; tmux.conf needs 3.2+ for extended-keys
  git
  curl
  unzip
  zip               # SDKMAN's installer hard-requires both zip and unzip
  ca-certificates
  build-essential   # asdf/uv builds compile native extensions
  fzf
  zoxide
  bat
  eza
  ripgrep
  direnv
  jq                # claude/statusline-command.sh parses its stdin with this
  shellcheck        # actionlint shells out to it
  bats              # ensemble plugin: bats test runner for the containment harness
)

# ---------- helpers ----------

# Ensure a vendor binary is present, reporting rather than aborting on failure.
# These are conveniences, and install.sh runs under `set -e`: a rate-limited
# release API or an upstream that renamed its assets should cost you one tool,
# not the rest of the install. Always returns 0 for that reason.
ensure_binary() {
  local binary="$1"; shift
  if have "$binary"; then
    ok "$binary already installed"
    return 0
  fi
  info "Installing $binary..."
  if "$@"; then
    ok "$binary installed"
  else
    warn "$binary install failed — skipping (re-run install.sh to retry)"
  fi
  return 0
}

# Resolve the download URL of the first asset of a release whose name matches an
# extended regex. Unauthenticated GitHub is 60 req/hr; this runs a handful of
# times per install, and only for tools that aren't present yet.
gh_release_asset() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | jq -r --arg p "$2" '.assets[]? | select(.name | test($p)) | .browser_download_url' \
    | head -1
}

# glab is developed on GitLab, not GitHub — there is no github.com/gitlab-org/cli
# to query, and its release assets live in a generic package registry.
glab_release_asset() {
  curl -fsSL "https://gitlab.com/api/v4/projects/$1/releases/permalink/latest" \
    | jq -r --arg p "$2" '.assets.links[]? | select(.name | test($p)) | .url' \
    | head -1
}

# Pull a single binary out of a release tarball into ~/.local/bin. Layouts vary
# (some tarballs put the binary at the root, some under bin/), so search for it.
install_tarball_binary() {
  local url="$1" binary="$2" rc=0
  local tmp; tmp="$(mktemp -d)"
  if curl -fsSL "$url" | tar -xz -C "$tmp"; then
    local found
    found="$(find "$tmp" -type f -name "$binary" -perm -u+x | head -1)"
    if [ -n "$found" ]; then
      install -m 0755 "$found" "$LOCAL_BIN/$binary"
    else
      warn "no $binary binary inside $url"
      rc=1
    fi
  else
    rc=1
  fi
  rm -rf "$tmp"
  return "$rc"
}

install_from_github() {
  local url; url="$(gh_release_asset "$1" "$2")"
  [ -n "$url" ] || { warn "no GitHub release asset in $1 matching /$2/"; return 1; }
  install_tarball_binary "$url" "$3"
}

install_from_gitlab() {
  local url; url="$(glab_release_asset "$1" "$2")"
  [ -n "$url" ] || { warn "no GitLab release asset in $1 matching /$2/"; return 1; }
  install_tarball_binary "$url" "$3"
}

# Neovim needs its whole runtime tree, not just the binary, so it doesn't go
# through install_tarball_binary.
install_neovim() {
  local url; url="$(gh_release_asset neovim/neovim "nvim-linux-${ARCH}\\.tar\\.gz$")"
  [ -n "$url" ] || { warn "no Neovim release for $ARCH"; return 1; }
  local tmp; tmp="$(mktemp -d)"
  if curl -fsSL "$url" | tar -xz -C "$tmp"; then
    mkdir -p "$HOME_DIR/.local/share"
    rm -rf "$HOME_DIR/.local/share/nvim-release"
    mv "$tmp"/nvim-linux-* "$HOME_DIR/.local/share/nvim-release"
    ln -sf "$HOME_DIR/.local/share/nvim-release/bin/nvim" "$LOCAL_BIN/nvim"
    rm -rf "$tmp"
    return 0
  fi
  rm -rf "$tmp"
  return 1
}

# overmind publishes a bare gzipped binary rather than a tarball.
install_overmind() {
  if curl -fsSL "$(gh_release_asset DarthSim/overmind "linux-${ARCH_ALT}\\.gz$")" \
       | gzip -dc > "$LOCAL_BIN/overmind" && [ -s "$LOCAL_BIN/overmind" ]; then
    chmod +x "$LOCAL_BIN/overmind"
    return 0
  fi
  rm -f "$LOCAL_BIN/overmind"
  return 1
}

install_actionlint() {
  curl -fsSL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash \
    | bash -s -- latest "$LOCAL_BIN" >/dev/null
}

# azcopy redirects to the current tarball rather than publishing tagged release
# assets. See zsh/custom/azure.zsh for how it picks up a tenant.
install_azcopy() {
  install_tarball_binary "https://aka.ms/downloadazcopy-v10-linux" azcopy
}

# Start zsh from ~/.profile, for accounts whose login shell can't be changed
# locally (see the caller). bash reads ~/.profile on login, so this is the last
# hook available before you get a prompt.
#
# Deliberately narrow, because ~/.profile is shared with everything else that
# logs in: it fires only for an *interactive* shell, so `ssh host <command>`,
# scripts and agent subshells still get plain bash; it no-ops once zsh is
# already running, so there's no loop; and it uses `exec` so you get one shell
# rather than zsh nested inside a stray bash.
#
# If zsh ever breaks badly enough to fail at startup, get back in with:
#   ssh <host> -t bash --noprofile
handoff_to_zsh() {
  local zsh_path="$1" profile="$HOME_DIR/.profile"
  local marker="# >>> dotfiles: hand off to zsh >>>"
  if grep -qF "$marker" "$profile" 2>/dev/null; then
    ok "login shell hands off to zsh from ~/.profile"
    return 0
  fi
  {
    printf '\n%s\n' "$marker"
    printf '%s\n' "# This account's shell is set by a directory service (GCP OS Login), so"
    printf '%s\n' "# chsh can't change it. Start zsh here instead, for interactive logins only."
    printf '%s\n' "case \$- in"
    printf '%s\n' "  *i*) [ -z \"\${ZSH_VERSION:-}\" ] && [ -x $zsh_path ] && exec $zsh_path -l ;;"
    printf '%s\n' "esac"
    printf '%s\n' "# <<< dotfiles: hand off to zsh <<<"
  } >> "$profile"
  ok "login shell hands off to zsh from ~/.profile (chsh can't be used on this account)"
}

# ---------- main ----------

linux_packages() {
  mkdir -p "$LOCAL_BIN"

  info "Installing apt packages..."
  # Refresh only if the cache is stale; apt-get update is slow and this script
  # is meant to be re-run freely.
  if [ -z "$(find /var/lib/apt/lists -maxdepth 1 -name '*Packages*' -mmin -60 2>/dev/null)" ]; then
    sudo apt-get update -qq
  fi
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq "${APT_PACKAGES[@]}"
  ok "apt packages installed"

  # Debian ships bat as `batcat` (the `bat` name collides with an unrelated
  # package). This repo's rule is "no aliases, use tools by their real names",
  # so give it its real name on PATH rather than aliasing it in zsh.
  if [ -x /usr/bin/batcat ] && [ ! -e "$LOCAL_BIN/bat" ]; then
    ln -sf /usr/bin/batcat "$LOCAL_BIN/bat"
    ok "linked bat -> batcat"
  fi

  # Ubuntu 24.04 is stuck on Neovim 0.9.5; the plugins pinned in
  # nvim/lua/plugins want 0.10+, so take the upstream release instead.
  ensure_binary nvim install_neovim

  # asdf has no apt package. 0.16+ is a single Go binary, and install.sh's
  # runtime steps use its `asdf set --home` syntax.
  ensure_binary asdf install_from_github asdf-vm/asdf "linux-${ARCH_ALT}\\.tar\\.gz$" asdf

  # Brew formulae with no Ubuntu package, each shipping an official static
  # binary. Presence check only — these don't self-update, the same way the
  # brew side needs `brew upgrade`.
  ensure_binary glow    install_from_github charmbracelet/glow "Linux_${ARCH}\\.tar\\.gz$" glow
  ensure_binary glab    install_from_gitlab gitlab-org%2Fcli "linux_${ARCH_ALT}\\.tar\\.gz$" glab
  ensure_binary overmind   install_overmind
  ensure_binary actionlint install_actionlint
  ensure_binary azcopy     install_azcopy

  # ---------- .NET ----------
  # No usable apt story: Ubuntu's feed stops at 8.0 and Microsoft's feed
  # conflicts with it on 24.04. The official script installs user-local under
  # ~/.dotnet, which zsh/custom/dotnet.zsh already puts on PATH, and needs no
  # root or third-party apt repo.
  if [ ! -x "$HOME_DIR/.dotnet/dotnet" ]; then
    info "Installing .NET SDK (LTS)..."
    if curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS >/dev/null; then
      ok ".NET SDK installed"
    else
      warn ".NET SDK install failed"
    fi
  else
    ok ".NET SDK already installed"
  fi

  # PowerShell: the Brewfile gets pwsh from homebrew-core, which has no Linux
  # counterpart here. Microsoft also publishes it as a .NET global tool, which
  # lands in ~/.dotnet/tools — already on PATH, and no apt repo to maintain.
  if [ ! -x "$HOME_DIR/.dotnet/tools/pwsh" ] && [ -x "$HOME_DIR/.dotnet/dotnet" ]; then
    info "Installing PowerShell..."
    if "$HOME_DIR/.dotnet/dotnet" tool install --global PowerShell >/dev/null 2>&1; then
      ok "PowerShell installed"
    else
      warn "PowerShell install failed"
    fi
  elif [ -x "$HOME_DIR/.dotnet/tools/pwsh" ]; then
    ok "PowerShell already installed"
  fi

  # ---------- login shell ----------
  # macOS already defaults to zsh; a Linux account almost never does, and
  # nothing in this repo takes effect until zsh is the shell you land in.
  local zsh_path; zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    warn "zsh not installed, leaving the login shell alone"
  elif [ "$(getent passwd "$USER" | cut -d: -f7)" = "$zsh_path" ]; then
    ok "login shell already zsh"
  elif ! grep -q "^$USER:" /etc/passwd; then
    # The account resolves through a directory service rather than /etc/passwd
    # — GCP OS Login here, but LDAP and SSSD behave the same way. The shell
    # field lives in the directory, so chsh cannot touch it and only a
    # workspace admin can change it. Hand the session over instead.
    handoff_to_zsh "$zsh_path"
  else
    grep -qxF "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    if sudo chsh -s "$zsh_path" "$USER" 2>/dev/null; then
      ok "login shell set to zsh (effective next login)"
    else
      warn "could not change login shell; run: chsh -s $zsh_path"
    fi
  fi
}
