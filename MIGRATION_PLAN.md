# Dotfiles Modernization — Migration Plan

Branch: `ah-claude-code-compat`
Date: 2026-03-14

## Phase 1: Strengthen Active Tooling

### tmux
- Already done (mouse, extended-keys, OSC 52, passthrough)
- Needs commit

### zsh cleanup
1. Remove `rvm.zsh` and all RVM PATH references
2. Remove dead `.python` PATH from `exports.zsh`
3. `EDITOR=vim` → `EDITOR=nvim`
4. Remove stale yarn PATH (asdf handles it)
5. Delete unused `agnoster2.zsh-theme` and `sorin2.zsh-theme`
6. Add asdf init if needed
7. Add fzf shell integration (`eval "$(fzf --zsh)"`)
8. Add zoxide shell integration (`eval "$(zoxide init zsh)"`)

### nvim — full Lua rewrite
1. Replace `nvim/init.vim` with `nvim/init.lua` + `nvim/lua/` module structure
2. lazy.nvim as plugin manager (replaces vim-plug)
3. Native LSP via nvim-lspconfig (replaces ALE)
4. Treesitter for syntax highlighting (replaces individual syntax plugins)
5. Telescope stays (add fzf-native extension, requires ripgrep)
6. Copilot kept but optional (lazy-loaded/commented out — no active license, may return)
7. Drop all Clojure plugins (conjure, aniseed, sexp, sexp-mappings)
8. Keep: gruvbox, fugitive, surround, repeat, tcomment, prettier
9. Add: which-key (keybinding discoverability), lualine (statusline)

### Font
- `brew install --cask font-dejavu-sans-mono-nerd-font`
- Replaces old Powerline font variants in `assets/fonts/`

---

## Phase 2: Remove Atrophied Code

### Delete entire `vim/` directory
- `vim/vimrc`, `vim/autoload/pathogen.vim`
- All 30 plugin submodules in `vim/bundle/`
- Remove all vim-related entries from `.gitmodules`

### Delete other dead submodules
- `vim-jsx-pretty/` (standalone JSX plugin, unused)
- `assets/gnome-terminal-solarized` (Linux-only)
- Orphaned `.gitmodules` entries for `vim/powerline` and `lib/powerline`

### Delete dead zsh files
- `zsh/rvm.zsh`

### Clean sweep of `assets/`
- `assets/*.terminal` (Apple Terminal profiles — using iTerm2)
- `assets/ios-linen-texture.jpg`
- Old Powerline `.ttf`/`.otf` files
- `assets/gnome-terminal-solarized/`
- Keep `assets/solarized-dark.itermcolors` if still used, otherwise delete

### oh-my-zsh: remove submodule, use standard install
- Remove `oh-my-zsh/` submodule from repo
- Document standard install in README as prerequisite
- Update installer to remove oh-my-zsh symlink step
- Custom themes (if any kept) symlinked to `~/.oh-my-zsh/custom/themes/`

### Rakefile/installer
- Remove vim symlink steps
- Remove `~/.vimrc` symlink creation
- Fix `Dir.exists?` → `Dir.exist?` (temporary, replaced in Phase 3)

---

## Phase 3: AI-Enabled Dotfiles

### AI Tools
- **Claude Code** (primary): `curl -fsSL https://claude.ai/install.sh | bash` — native installer, auto-updates, no npm dependency
- **GitHub Copilot**: Optional nvim plugin, lazy-loaded, no-error without license
- **Gemini CLI**: `npm install -g @google/gemini-cli` — standalone terminal tool
- **Codex**: `npm install -g @openai/codex` — standalone terminal tool
- Document all AI tools in README under "AI Tools" section
- Add Claude Code install to `install.sh`

### Claude Code config (portable files for new machines)
- Add `claude/settings.json` to dotfiles — symlink to `~/.claude/settings.json`
  - `effortLevel: "high"`
  - Custom statusline command
- Add `claude/keybindings.json` to dotfiles — symlink to `~/.claude/keybindings.json`
  - `ctrl+b` unbound (tmux prefix conflict)
  - `ctrl+shift+b` for background task
- Add `claude/statusline-command.sh` to dotfiles — symlink to `~/.claude/statusline-command.sh`
  - Sorin-inspired: dir, git branch, model, context usage
- Add `claude/CLAUDE.md` to dotfiles — symlink to `~/.claude/CLAUDE.md`
  - Global Spring Boot project conventions
- Update `install.sh` to create `~/.claude/` and symlink these files
- NOTE: `~/.claude/projects/`, `history.jsonl`, `sessions/` etc. are machine-local, NOT managed

### Git enhancements
- Add `git/gitconfig`:
  - Global `.gitignore` reference
  - Default branch = main
  - Pull rebase by default
  - Existing user name/email
- Add `git/gitignore_global`:
  - `.DS_Store`, `.env`, `*.swp`, `.idea/`, `.vscode/`, `node_modules/`, etc.
- Symlink both via installer

### Modern shell tools (no aliases — use by name)
- `fzf` — ctrl-r fuzzy history, ctrl-t fuzzy file finder
- `zoxide` — `z` command for smart directory jumping
- `bat` — cat with syntax highlighting
- `eza` — modern ls with git status and icons
- `ripgrep` — fast grep (also required by Telescope)

### Installer
- Replace `Rakefile` + `lib/installer.rb` with `install.sh`
- No Ruby dependency
- Idempotent (safe to re-run)
- Handles: symlinks, brew bundle, oh-my-zsh check, nvim lazy.nvim bootstrap

### Brewfile
```
brew "neovim"
brew "tmux"
brew "direnv"
brew "asdf"
brew "fzf"
brew "zoxide"
brew "bat"
brew "eza"
brew "ripgrep"
cask "font-dejavu-sans-mono-nerd-font"
```

---

## Migration Execution Order

### Step 0: Safety net
- Commit current WIP on `ah-claude-code-compat`

### Step 1: Brew dependencies
- Create `Brewfile`, run `brew bundle`
- Installs Nerd Font, fzf, zoxide, bat, eza, ripgrep

### Step 2: oh-my-zsh transition (CAREFUL)
- `~/.oh-my-zsh` currently symlinks → repo submodule
- Install oh-my-zsh standard way FIRST
- Remove symlink, run installer, verify shell
- THEN remove submodule from repo
- CRITICAL: don't open new terminal between removing symlink and installing

### Step 3: zsh cleanup
- Clean `zshrc`, `exports.zsh`
- Delete `rvm.zsh`, unused themes
- Add fzf + zoxide hooks
- Source new shell, verify

### Step 4: nvim rewrite
- Write `nvim/init.lua` + `nvim/lua/` modules
- Update symlink (init.vim → init.lua)
- First launch bootstraps lazy.nvim + installs plugins
- Verify: LSP, Telescope, Treesitter, Copilot
- Clean old vim-plug: `rm -rf ~/.local/share/nvim/plugged/`

### Step 5: Nuke atrophied code
- Delete `vim/` + all submodules
- Delete `vim-jsx-pretty/`, `assets/gnome-terminal-solarized`
- Clean `.gitmodules`
- Clean `assets/`

### Step 6: Add new pieces
- `git/gitconfig` + `git/gitignore_global`
- Replace `Rakefile` + `lib/` with `install.sh`
- Add `CLAUDE.md`
- Update `README.md`

### Step 7: Final verification
- Fresh terminal → zsh loads clean
- `nvim` → plugins load, LSP attaches, Telescope works
- `tmux` → mouse, shift+enter, clipboard
- `git config --list` → global config applied
- `install.sh` → runs idempotent

---

## User Preferences (for Claude)
- No aliases — types fast, wants portability across machines
- DejaVu Sans Mono is the preferred font family
- Multi-AI: Claude Code primary, Copilot optional (no license currently), Gemini CLI, Codex
- No Clojure, no vim — nvim only
- Using: asdf (node/yarn), conda, direnv, Homebrew on Apple Silicon
