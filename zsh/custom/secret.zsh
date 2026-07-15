# GCP Secret Manager helpers.
#
# gcp-secret-add wraps `gcloud secrets` to add a secret the way macOS Keychain
# does it: the value is typed silently (never echoed), entered twice and
# compared, and the value is streamed to gcloud over stdin so it never lands in
# argv, the process list, or the environment.

gcp-secret-add() {
  emulate -L zsh

  local prog=gcp-secret-add
  local usage="usage: $prog <secret-name> [gcloud args...]"

  # No args, or an explicit help request, prints help and exits.
  if [[ $# -eq 0 || $1 == -h || $1 == --help ]]; then
    print -r -- "$usage"
    print -r --
    print -r -- "Add a value to Google Cloud Secret Manager, Keychain-style:"
    print -r -- "  - the value is typed silently (no echo) and entered twice to confirm;"
    print -r -- "  - a mismatch re-prompts; an empty value is rejected;"
    print -r -- "  - the value is streamed over stdin, never passed as an argument."
    print -r --
    print -r -- "If the secret already exists, a new version is added; otherwise the"
    print -r -- "secret is created with the default (automatic) replication policy."
    print -r --
    print -r -- "Any extra arguments are forwarded to gcloud, e.g.:"
    print -r -- "  $prog DB_PASSWORD --project=my-proj"
    print -r -- "  $prog API_KEY --labels=team=platform"
    print -r --
    print -r -- "For multi-region replication, just pass --locations; user-managed"
    print -r -- "replication is implied. Locations apply only at first creation:"
    print -r -- "  $prog DB_PASSWORD --locations=us-central1,us-east1"
    # No args is a usage error; -h/--help is a successful, intentional request.
    [[ $# -eq 0 ]] && return 2 || return 0
  fi

  local name=$1
  shift

  # Replication flags are create-only: gcloud's `describe` and `versions add`
  # reject them. Split them out so only `create` sees them, while common flags
  # (e.g. --project) are forwarded to every subcommand.
  local -a create_only common
  local saw_locations='' saw_policy=''
  while (( $# )); do
    case $1 in
      --replication-policy=*|--replication-policy-file=*)
        saw_policy=1; create_only+=("$1"); shift ;;
      --replication-policy|--replication-policy-file)
        saw_policy=1; create_only+=("$1" "$2"); shift 2 ;;
      --locations=*)
        saw_locations=1; create_only+=("$1"); shift ;;
      --locations)
        saw_locations=1; create_only+=("$1" "$2"); shift 2 ;;
      *)
        common+=("$1"); shift ;;
    esac
  done

  # --locations is only valid with a user-managed policy, and that's the only
  # policy it can pair with, so supply it automatically: callers just name the
  # regions. An explicit --replication-policy (or -file) is left untouched.
  if [[ -n $saw_locations && -z $saw_policy ]]; then
    create_only+=(--replication-policy=user-managed)
  fi

  local value confirm
  while true; do
    read -rs "value?Enter value for secret '$name': "; print
    if [[ -z $value ]]; then
      print -u2 -- "$prog: empty value, aborting."
      return 1
    fi
    read -rs "confirm?Re-enter value to confirm: "; print
    [[ $value == $confirm ]] && break
    print -u2 -- "$prog: values did not match, try again."
  done

  if gcloud secrets describe "$name" "${common[@]}" >/dev/null 2>&1; then
    if (( ${#create_only} )); then
      print -u2 -- "$prog: secret '$name' exists; replication is fixed at creation, ignoring: ${create_only[*]}"
    fi
    printf '%s' "$value" | gcloud secrets versions add "$name" --data-file=- "${common[@]}"
  else
    printf '%s' "$value" | gcloud secrets create "$name" --data-file=- "${common[@]}" "${create_only[@]}"
  fi
  local rc=$?

  unset value confirm
  return $rc
}
