# Exception to the repo's "no aliases" rule: Microsoft AutoUpdate's msupdate
# binary lives at a fixed, space-laden path under /Library and is not on PATH,
# so there's no clean real-name invocation. Alias it for convenience.
alias msupdate='"/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate"'
