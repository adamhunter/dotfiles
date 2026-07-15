# Lazy-load SDKMAN. Its init (~0.6s here) sources scripts and spawns
# subprocesses at every shell start. Instead, cheaply add the current default
# candidate bins to PATH (no subprocess) so tools like java stay available,
# and defer the full init until the first `sdk` command.
export SDKMAN_DIR="$HOME/.sdkman"
for _sdk_bin in "$SDKMAN_DIR"/candidates/*/current/bin(N); do
  path=("$_sdk_bin" $path)
done
unset _sdk_bin

sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}
