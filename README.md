# dotfiles

Personal dotfiles for macOS — zsh, neovim, tmux, git, and AI tooling.

## Quick Start

```bash
git clone git@github.com:adamhunter/dotfiles.git
cd dotfiles
./install.sh
```

The installer is idempotent — safe to re-run anytime.

## What Gets Installed

### Brew Dependencies

```bash
brew bundle  # or let install.sh handle it
```

neovim, tmux, direnv, asdf, fzf, zoxide, bat, eza, ripgrep, and
DejaVuSansM Nerd Font Mono.

### Shell (zsh + oh-my-zsh)

- oh-my-zsh installed via standard installer (auto-updates)
- Theme: sorin
- Plugins: git, macos
- Custom files in `zsh/custom/` symlinked to `~/.oh-my-zsh/custom/`
- fzf integration: `ctrl-r` fuzzy history, `ctrl-t` fuzzy file finder
- zoxide: `z <dir>` for smart directory jumping

### Neovim

Lua-based config with lazy.nvim plugin manager. Plugins bootstrap on first launch.

- **LSP**: ts_ls, gopls, terraformls via nvim-lspconfig
- **Syntax**: Treesitter
- **Fuzzy finding**: Telescope with fzf-native
- **File tree**: neo-tree (`:Neotree`)
- **Formatting**: conform.nvim (prettier, gofmt, terraform_fmt)
- **Theme**: gruvbox
- **Statusline**: lualine
- **Keybindings**: which-key for discoverability
- **AI**: Copilot (disabled by default, toggle in `nvim/lua/plugins/copilot.lua`)

Leader key: `,`

### tmux

Configured for tmux 3.2+ with Claude Code compatibility:

- Mouse support, extended keys (Shift+Enter passthrough)
- OSC 52 clipboard, iTerm2 passthrough
- 50,000 line history buffer

### Git

- Global gitignore (.DS_Store, .env, .idea/, .vscode/, etc.)
- Pull with rebase by default
- Auto setup remote on push

### AI Tools

```bash
# Claude Code (primary) — installed by install.sh
curl -fsSL https://claude.ai/install.sh | bash

# Gemini CLI
npm install -g @google/gemini-cli

# Codex
npm install -g @openai/codex
```

Claude Code config (settings, keybindings, statusline) is managed in `claude/`
and symlinked to `~/.claude/`.

## iTerm2 Setup

Required for full compatibility with tmux and Claude Code.

### Shift+Enter (Required for Claude Code)

1. Open **iTerm2 → Settings → Profiles → Keys → General**
2. Set **"Report modifiers using CSI u"** to **Yes**

### Recommended Profile Settings

**Profiles → Text:**
- Font: DejaVuSansM Nerd Font Mono

**Profiles → Terminal:**
- Report Terminal Type: `xterm-256color`
- Enable mouse reporting
- Allow clipboard access to terminal apps (OSC 52)

### tmux Notes

After changing tmux.conf, kill all sessions and restart:

```zsh
tmux kill-server
tmux
```

## Modern Shell Tools

All installed via Brewfile, no aliases — use by name:

| Tool | What it does |
|------|-------------|
| `fzf` | Fuzzy finder — ctrl-r for history, ctrl-t for files |
| `zoxide` | Smart cd — `z foo` jumps to best match |
| `bat` | cat with syntax highlighting |
| `eza` | Modern ls with git status and icons |
| `ripgrep` | Fast grep (also used by Telescope) |
