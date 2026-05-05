# Dotfiles

Personal dotfiles for macOS with zsh, nvim, tmux, git, and AI tooling.

## Structure

- `zsh/` — zshrc, exports, custom oh-my-zsh files
- `nvim/` — Lua-based neovim config with lazy.nvim
- `tmux/` — tmux.conf (Claude Code compatible, tmux 3.2+)
- `git/` — gitconfig and global gitignore
- `claude/` — Claude Code settings, keybindings, statusline
- `bin/` — personal scripts
- `install.sh` — idempotent installer (symlinks, brew, oh-my-zsh, AI tools)
- `Brewfile` — Homebrew dependencies

## Conventions

- No shell aliases — use tools by their real names
- No vim — nvim only with Lua config
- oh-my-zsh installed via standard installer, NOT vendored
- Never edit `zsh/zshrc` directly — add new shell config as a `.zsh` file in `zsh/custom/`, which gets symlinked to `~/.oh-my-zsh/custom/` by `install.sh`
- Plugins managed by lazy.nvim, not submodules
- Fonts installed via brew cask, not vendored
