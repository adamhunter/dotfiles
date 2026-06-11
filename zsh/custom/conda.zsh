# Lazy-load conda. The eager `conda shell.zsh hook` costs ~1.1s of Python
# startup at every shell launch (plus ~0.5s activating base), which is wasted
# on the many shells that never touch conda. This stub defers the real init
# until the first `conda` call, then replaces itself with the real function.
conda() {
  unset -f conda
  local __conda_setup
  __conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/anaconda3/bin:$PATH"
  fi
  conda "$@"
}
