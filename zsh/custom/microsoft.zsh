# Exception to the repo's "no aliases" rule: Microsoft AutoUpdate's msupdate
# binary lives at a fixed, space-laden path under /Library and is not on PATH,
# so there's no clean real-name invocation. Alias it for convenience.
#
# macOS-only, hence the existence check — this file is symlinked on every
# platform, and on Linux there is no Microsoft AutoUpdate to update.
_msupdate="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
[[ -x $_msupdate ]] && alias msupdate="\"$_msupdate\""
unset _msupdate
