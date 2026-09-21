# dotfiles

Personal dotfiles for **macOS** and **Ubuntu Linux** — zsh, neovim, tmux, git,
and AI tooling. One repo, one installer; it detects the platform.

## Quick Start

```bash
git clone git@github.com:adamhunter/dotfiles.git
cd dotfiles
./install.sh
```

The installer is idempotent — safe to re-run anytime. On Linux it uses `sudo`
for apt and for setting your login shell to zsh; everything else installs
under `$HOME`.

If a step fails (a rate-limited release API, an upstream that renamed an
asset), the installer warns and carries on rather than aborting — re-run it to
retry just that step.

### Login shell

`install.sh` sets your login shell to zsh with `chsh`. On a box where the
account comes from a directory service rather than `/etc/passwd` — **GCP OS
Login**, LDAP, SSSD — `chsh` cannot work, because the shell field lives in the
directory and only an admin can change it. The installer detects this and
appends a small marked block to `~/.profile` that `exec`s zsh for interactive
logins instead. Non-interactive bash (`ssh host <command>`, scripts, agent
subshells) is untouched.

If zsh is ever broken enough to fail at startup, get back in with:

```bash
ssh <host> -t bash --noprofile
```

## How the two platforms fit together

Package installation is the only genuinely per-platform step. `install.sh`
detects the OS and calls one function from `install/`:

| | macOS | Linux (Ubuntu/Debian) |
|---|---|---|
| Layer | `install/packages-macos.sh` | `install/packages-linux.sh` |
| Source | `Brewfile` (Homebrew) | apt, plus vendor binaries in `~/.local/bin` |

Everything else — symlinks, oh-my-zsh, runtimes, the AI CLIs — is shared. If
you add a tool, add it to **both** lists.

### Platform differences

Things that exist on only one side, and why:

| Tool | Where | Why |
|------|-------|-----|
| Nerd Font | macOS only | A VM has no local terminal; install the font on whatever machine you type into. |
| `mk` (Marked 3), `msupdate` | macOS only | Drive macOS apps. |
| GAM, `googleworkspace-cli` | macOS only | Workspace admin is laptop work; the Linux boxes are for development. |
| `agy` (antigravity-cli) | macOS only | Cask with no Linux build — the ensemble plugin's agy peer is unavailable on Linux. |
| `qodana` | macOS only | Not ported; run it from the laptop. |
| Neovim | apt version skipped | Ubuntu 24.04 ships 0.9.5; this config's plugins want 0.10+, so Linux takes the upstream release tarball. |
| `bat` | symlinked on Linux | Debian ships the binary as `batcat`; `~/.local/bin/bat` gives it its real name rather than aliasing it. |
| .NET + PowerShell | different source | Ubuntu's feed stops at 8.0 and Microsoft's conflicts with it on 24.04, so Linux uses the official user-local installer into `~/.dotnet`; `pwsh` comes in as a .NET global tool. |
| `coreutils` | macOS only | `gtimeout` on Linux is just `timeout`. |
| conda | neither | Lazy-loaded if you install it; `uv` covers Python here. |

## What Gets Installed

### Shell (zsh + oh-my-zsh)

- oh-my-zsh installed via standard installer (auto-updates)
- Theme: sorin
- Plugins: `macos` on macOS only (it shells out to `open`/`osascript`)
- Custom files in `zsh/custom/` symlinked to `~/.oh-my-zsh/custom/`
- fzf integration: `ctrl-r` fuzzy history, `ctrl-t` fuzzy file finder
- zoxide: `z <dir>` for smart directory jumping

`zsh/custom/*.zsh` files are symlinked on every machine, so each one guards its
own platform-specific parts — `homebrew.zsh` is a no-op without brew,
`microsoft.zsh` defines nothing off macOS, and so on.

### Languages and runtimes

| Language | Managed by |
|---|---|
| Java | SDKMAN (`sdk install java`) — lazy-loaded in `zsh/custom/sdkman.zsh` |
| Python | `uv` |
| C# / .NET | `dotnet` + the Azure Artifacts credential provider (for Azure DevOps NuGet feeds) |
| TypeScript / Node | asdf (`nodejs` plugin), plus pnpm |
| Terraform | asdf, pinned to 1.6.6 (brew froze at 1.5.7 over the BUSL relicense) |

### Neovim

Lua-based config with lazy.nvim plugin manager. Plugins bootstrap on first
launch. Identical on both platforms.

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
- OSC 52 clipboard, terminal passthrough
- 50,000 line history buffer
- `default-shell` is resolved at load, not hardcoded (`/bin/zsh` vs `/usr/bin/zsh`)
- Copy (`prefix + y`) goes out over OSC 52, so it reaches your local clipboard
  even when tmux is running on a remote box

### Git

- Global gitignore (.DS_Store, .env, .idea/, .vscode/, etc.)
- Pull with rebase by default
- Auto setup remote on push

### AI Tools

Claude Code, Codex, and Grok are installed by `install.sh` on both platforms.
Claude Code config (settings, keybindings, statusline) lives in `claude/` and is
symlinked to `~/.claude/`; `codex/AGENTS.md` is symlinked to `~/.codex/`.

## Terminal Setup

The terminal is on the machine you type at, so this applies to your local
terminal whether you're working on macOS directly or SSH'd into a Linux box.

### Shift+Enter (Required for Claude Code)

iTerm2: **Settings → Profiles → Keys → General**, set **"Report modifiers using
CSI u"** to **Yes**.

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

No aliases — use by name:

| Tool | What it does |
|------|-------------|
| `fzf` | Fuzzy finder — ctrl-r for history, ctrl-t for files |
| `zoxide` | Smart cd — `z foo` jumps to best match |
| `bat` | cat with syntax highlighting |
| `eza` | Modern ls with git status and icons |
| `ripgrep` | Fast grep (also used by Telescope) |
| `glow` | Render markdown in the terminal |
