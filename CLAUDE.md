# Dotfiles

Personal dotfiles for macOS and Ubuntu Linux with zsh, nvim, tmux, git, and AI
tooling. The same repo drives both; `install.sh` detects the platform.

## Structure

- `zsh/` — zshrc, exports, custom oh-my-zsh files
- `nvim/` — Lua-based neovim config with lazy.nvim
- `tmux/` — tmux.conf (Claude Code compatible, tmux 3.2+)
- `git/` — gitconfig and global gitignore
- `claude/` — Claude Code settings, keybindings, statusline
- `bin/` — personal scripts
- `install.sh` — idempotent installer (platform detection, symlinks, oh-my-zsh, AI tools)
- `install/` — the one per-platform step: `packages-macos.sh` (Brewfile) and `packages-linux.sh` (apt + vendor binaries)
- `Brewfile` — Homebrew dependencies (macOS)

## Conventions

- No shell aliases — use tools by their real names
- No vim — nvim only with Lua config
- oh-my-zsh installed via standard installer, NOT vendored
- Never edit `zsh/zshrc` directly — add new shell config as a `.zsh` file in `zsh/custom/`, which gets symlinked to `~/.oh-my-zsh/custom/` by `install.sh`
- Plugins managed by lazy.nvim, not submodules
- Fonts installed via brew cask, not vendored (macOS only — a Linux VM has no
  local terminal, so the font belongs on the machine you type into)
- Everything outside `install/packages-*.sh` must work on both platforms. A
  `zsh/custom/*.zsh` file is symlinked on every machine, so it guards its own
  platform-specific parts rather than assuming they exist
- Never hardcode a package-manager prefix (`/opt/homebrew`) or a home directory
  (`/Users/...`) — resolve it or use `$HOME`
- `sed -i` differs between BSD and GNU; use `install.sh`'s `sed_i` wrapper
