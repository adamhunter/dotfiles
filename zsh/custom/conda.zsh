# Lazy-load conda. The eager `conda shell.zsh hook` costs ~1.1s of Python
# startup at every shell launch (plus ~0.5s activating base), which is wasted
# on the many shells that never touch conda. This stub defers the real init
# until the first `conda` call, then replaces itself with the real function.
#
# The prefix is resolved at call time rather than hardcoded: it's the Homebrew
# anaconda3 cask on macOS and a plain ~/miniconda3 (or similar) on Linux, and
# on a machine with no conda at all this stays a stub that says so.
conda() {
  local root
  for root in \
    /opt/homebrew/anaconda3 /usr/local/anaconda3 \
    "$HOME/anaconda3" "$HOME/miniconda3" "$HOME/miniforge3"
  do
    [[ -x $root/bin/conda ]] || continue
    unset -f conda
    local setup
    if setup="$("$root/bin/conda" shell.zsh hook 2>/dev/null)"; then
      eval "$setup"
    elif [[ -f $root/etc/profile.d/conda.sh ]]; then
      . "$root/etc/profile.d/conda.sh"
    else
      export PATH="$root/bin:$PATH"
    fi
    conda "$@"
    return
  done
  print -u2 "conda: no conda installation found (looked under /opt/homebrew, /usr/local and \$HOME)"
  return 1
}
