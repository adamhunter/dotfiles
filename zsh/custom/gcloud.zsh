# Google Cloud CLI. The SDK root depends on how it was installed: the
# gcloud-cli Homebrew cask on macOS, the snap or the apt package on Linux, or
# an unpacked tarball in $HOME. In every case the binaries are already on PATH
# and only the optional path/completion includes need sourcing — so find the
# first root that has them and stop.
for _gcloud_sdk in \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/google-cloud-sdk" \
  /snap/google-cloud-cli/current \
  /usr/lib/google-cloud-sdk \
  "$HOME/google-cloud-sdk"
do
  [ -f "$_gcloud_sdk/path.zsh.inc" ] || continue
  . "$_gcloud_sdk/path.zsh.inc"
  [ -f "$_gcloud_sdk/completion.zsh.inc" ] && . "$_gcloud_sdk/completion.zsh.inc"
  break
done
unset _gcloud_sdk
