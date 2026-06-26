# Loaded last (zz-) so it runs after asdf.zsh and homebrew.zsh. oh-my-zsh sources
# custom/*.zsh alphabetically and both of those *prepend* to PATH, so the later one wins:
# homebrew.zsh's /opt/homebrew/bin would otherwise land ahead of asdf's shims, and brew's
# node (pulled in as a firebase-cli dependency) would shadow the asdf-managed default.
# Re-assert asdf's shims as the first PATH entry so asdf owns node/npm/etc. brew's node
# stays installed but shadowed — firebase still uses it internally, which is fine.
asdf_shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
path=("$asdf_shims" "${(@)path:#$asdf_shims}")
unset asdf_shims
export PATH
