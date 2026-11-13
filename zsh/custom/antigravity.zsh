# Antigravity IDE CLI. Its installer appends a hardcoded PATH line to ~/.zshrc;
# it lives here instead so zshrc stays untouched. Absent on Linux, so guarded.
[[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ]] && path=("$HOME/.antigravity-ide/antigravity-ide/bin" $path)
