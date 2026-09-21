# Homebrew, wherever it lives — or nowhere. The prefix differs by platform and
# CPU: /opt/homebrew on Apple silicon, /usr/local on Intel macs, and
# /home/linuxbrew/.linuxbrew for Linuxbrew. Linux boxes here install via apt
# instead (see install/packages-linux.sh), so this is usually a no-op there.
#
# Cached: running `brew shellenv` (Ruby) at every shell start costs ~1.3s here.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $_brew ]] || continue
  _cached_eval brew-shellenv "$_brew" "$_brew" shellenv zsh
  break
done
unset _brew
