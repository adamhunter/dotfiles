# Google Cloud CLI (installed via the gcloud-cli Homebrew cask).
# Binaries (gcloud/bq/gsutil) are symlinked onto PATH by brew, so only the
# optional path/completion includes from the SDK root need sourcing.
GCLOUD_SDK="${HOMEBREW_PREFIX:-/opt/homebrew}/share/google-cloud-sdk"
[ -f "$GCLOUD_SDK/path.zsh.inc" ] && . "$GCLOUD_SDK/path.zsh.inc"
[ -f "$GCLOUD_SDK/completion.zsh.inc" ] && . "$GCLOUD_SDK/completion.zsh.inc"
unset GCLOUD_SDK
