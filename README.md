dotfiles
========

Installing the dotfiles will remove any conflicting .zshrc .vimrc directories.
It will try to remove .zsh and .vim but will fail unless they are symlinks.

```zsh
git clone --recursive git@github.com:adamhunter/dotfiles.git
cd dotfiles
rake dotfiles:install
```

## iTerm2 Setup

These settings are required for full compatibility with tmux and Claude Code.

### Shift+Enter (Required for Claude Code)

Without this, Shift+Enter sends a bare newline indistinguishable from Enter.
Claude Code uses Shift+Enter to insert newlines without submitting input.

1. Open **iTerm2 → Settings → Profiles → Keys → General**
2. Set **"Report modifiers using CSI u"** to **Yes**

### Recommended Profile Settings

**Profiles → Terminal:**

- Set **"Report Terminal Type"** to `xterm-256color`
- Check **"Enable mouse reporting"**
- Check **"Allow clipboard access to terminal apps"** (enables OSC 52 paste)

**Profiles → General:**

- Set **"Scrollback lines"** to a high value (e.g. 10,000+) — though with `mouse on` in tmux, scrollback is handled by tmux's `history-limit` (set to 50,000 in tmux.conf)

### tmux Notes

The tmux.conf in this repo is configured for tmux 3.2+ with:

- `extended-keys on` + `extkeys` terminal feature — enables Shift+Enter passthrough
- `mouse on` — trackpad scrolling within tmux panes
- `history-limit 50000` — large scrollback for long Claude Code output
- `allow-passthrough on` — lets iTerm2 escape sequences work inside tmux
- `set-clipboard on` — OSC 52 clipboard integration

After changing tmux.conf, kill all sessions and restart (F5 reload won't pick up server-level options):

```zsh
tmux kill-server
tmux
```
