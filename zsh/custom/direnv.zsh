# Cached, and a no-op when direnv isn't installed (see cache.zsh).
_cached_eval direnv "${commands[direnv]}" direnv hook zsh
