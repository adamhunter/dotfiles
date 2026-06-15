#!/usr/bin/env bash
# ~/.claude/hooks/protect-ensemble.sh
#
# Deterministic lockout for the ensemble multi-model review skill. Blocks Claude (the
# Branch-A fixer) from neutralizing the critic's failing tests, which live in
# .ensemble/tests/ (per-repo, in the review's working dir). Two things are blocked:
#
#   1. Any tool call touching .ensemble/tests   — create/edit/move/delete a critic test
#      (Edit/Write/MultiEdit file_path, or a Bash sed/cat>/mv/rm naming the path), with or
#      without a trailing slash.
#   2. Any op on the bare .ensemble dir as a unit — e.g. `rm -rf .ensemble`,
#      `mv .ensemble x` — which would nuke tests/ by taking the parent with it.
#
# What stays ALLOWED: writes under .ensemble/review/ (Branch B raw outputs + digest) and
# any .ensemble/<child> that is not the tests subtree. The peers (Codex/AGY) are separate
# processes NOT governed by this hook, so they still author tests in .ensemble/tests/.
#
# PreToolUse hook: exit 2 blocks the call and feeds stderr back to Claude. Matches on the
# path token, not a fixed location, so it protects every repo.

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
haystack=$(printf '%s %s' "$file_path" "$command")

# 1) the locked tests subtree (with or without trailing slash)
locked='(^|[^A-Za-z0-9_])\.ensemble/tests([^A-Za-z0-9_]|$)'
# 2) the .ensemble parent as a whole-dir target (bare, or `.ensemble/` with nothing useful
#    after it) — blocks rm -rf / mv of the parent; allows `.ensemble/<name>` subpaths
parent='(^|[^A-Za-z0-9_])\.ensemble/?($|[^A-Za-z0-9_/])'

if printf '%s' "$haystack" | grep -Eq "$locked|$parent"; then
  echo "Blocked: .ensemble/tests/ holds critic-authored tests, and .ensemble/ must not be removed wholesale. The fixer may not create, edit, move, or delete them." >&2
  exit 2
fi

exit 0
