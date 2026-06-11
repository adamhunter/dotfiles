# Source a tool's shell-init output from a cache file, regenerating only when
# the tool's binary is newer than the cache. Spawning slow binaries (brew,
# fzf, zoxide) at every shell start is the dominant startup cost on this
# machine; their init output is static between upgrades, so cache it.
#
# Usage: _cached_eval <cache-name> <binary-path-to-stat> <command> [args...]
# Loads before other custom files (alphabetical), so they can use it.
_cached_eval() {
  local name="$1" bin="$2"; shift 2
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${name}.zsh"
  if [[ ! -r "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache" 2>/dev/null
  fi
  source "$cache"
}
