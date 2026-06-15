# grok (xAI CLI) — shell completions, loaded the dotfiles way.
#
# The grok installer otherwise injects a PATH/compinit block straight into ~/.zshrc (our managed
# zsh/zshrc) on every run; install.sh strips that. grok itself is already on PATH via
# ~/.local/bin/grok, so here we only register its completions.
if [ -d "$HOME/.grok/completions/zsh" ]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
  autoload -Uz compinit && compinit -C
fi
