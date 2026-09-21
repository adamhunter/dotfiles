# azcopy can borrow the Azure CLI's OAuth token instead of keeping a login of its
# own (`azcopy login` needs an OS secret store). AZCLI mode is safe to set always:
# it only tells azcopy *where* to look for a token if a command needs OAuth.
export AZCOPY_AUTO_LOGIN_TYPE=AZCLI

# Microsoft's docs pair that export with a hardcoded AZCOPY_TENANT_ID
# (https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-authorize-azure-active-directory).
# Derive it from whatever `az` is logged into instead, so `az login` / `az account
# set` stays the single source of truth and no client's tenant is baked into this
# repo. Not an alias — the real name still runs the real binary; this is a wrapper
# for the same reason `microsoft.zsh` documents its own exception to the
# "no aliases" rule: there's no clean way to get the env right without one.
#
# Deliberate choices: lazy (`az account show` is ~1s of Python startup, too slow
# for every shell), never triggers `az login` itself (interactive browser side
# effect is the human's call), and re-derives per invocation rather than caching,
# so a stale tenant can't outlive an `az account set`.
# Fabric/OneLake needs one more thing this file can't supply. azcopy only sends
# Entra tokens to its default trusted suffixes (*.core.windows.net et al), so a
# onelake.dfs.fabric.microsoft.com URL fails with "Authenticating to destination
# using Unknown" until you pass --trusted-microsoft-suffixes "fabric.microsoft.com".
# Verified against azcopy 10.32.6: that is a flag only — no AZCOPY_* env var exists
# for it — so it stays a per-command argument by choice rather than automated here.
azcopy() {
  # An explicit pin wins — e.g. a client repo's .envrc targeting another tenant.
  if [[ -n $AZCOPY_TENANT_ID ]]; then
    command azcopy "$@"
    return
  fi

  # Derive the tenant when there's a session to derive one from -- and when
  # there isn't, still run azcopy rather than refusing. Gating every invocation
  # on an az session was wrong: plenty of them need no Entra token at all
  # (--version, --help, jobs list, and any transfer whose credential is already
  # in a SAS URL), and `azcopy --version` failing with "run: az login" is just
  # a lie. For the invocations that genuinely do need a token, azcopy's own
  # error names the real problem better than a guess from out here can.
  local tenant
  tenant=$(az account show --query tenantId -o tsv 2>/dev/null)
  if [[ -n $tenant ]]; then
    AZCOPY_TENANT_ID=$tenant command azcopy "$@"
  else
    command azcopy "$@"
  fi
}
