#!/usr/bin/env bash
# Claude Code status line — inspired by the sorin zsh theme
# Shows: current dir | git branch | model | context usage

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Current directory basename (like %c in sorin)
if [ -n "$cwd" ]; then
  dir=$(basename "$cwd")
else
  dir=$(basename "$(pwd)")
fi

# Git branch (skip optional locks)
branch=""
if git -C "${cwd:-$(pwd)}" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "${cwd:-$(pwd)}" symbolic-ref --short HEAD 2>/dev/null || git -C "${cwd:-$(pwd)}" rev-parse --short HEAD 2>/dev/null)
fi

# Build the status line with ANSI colors (cyan dir, blue git, dim model/context)
line=""

# Cyan: current directory
line+=$(printf '\033[36m%s\033[0m' "$dir")

# Blue: git branch
if [ -n "$branch" ]; then
  line+=$(printf ' \033[34mgit\033[0m:\033[31m%s\033[0m' "$branch")
fi

# Dim separator
line+=$(printf ' \033[2m|\033[0m')

# Dim: model name
if [ -n "$model" ]; then
  line+=$(printf ' \033[2m%s\033[0m' "$model")
fi

# Dim: context usage
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  printf_pct=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "$used_pct")
  line+=$(printf ' \033[2mctx:%s%%\033[0m' "$printf_pct")
fi

printf '%s' "$line"