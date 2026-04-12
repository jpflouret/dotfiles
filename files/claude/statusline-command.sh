#!/usr/bin/env bash
# Claude Code status line - reads JSON from stdin and renders via oh-my-posh

input=$(cat)

# Extract model display name (shorten it to fit the status bar)
model_full=$(echo "$input" | jq -r '.model.display_name // empty')
# Strip "Claude " prefix to save space, e.g. "Claude 3.5 Sonnet" -> "3.5 Sonnet"
model="${model_full#Claude }"

# Extract context usage percentage (pre-calculated field, null if no messages yet)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Export env vars for oh-my-posh templates
export CLAUDE_MODEL="$model"

if [ -n "$used_pct" ]; then
  # Round to integer
  used_int=$(printf "%.0f" "$used_pct")
  export CLAUDE_CONTEXT_PCT="$used_int"
  # Set threshold flags for background color templates
  if [ "$used_int" -ge 80 ]; then
    export CLAUDE_CONTEXT_HIGH=1
  elif [ "$used_int" -ge 50 ]; then
    export CLAUDE_CONTEXT_MED=1
  elif [ "$used_int" -lt 20 ]; then
    export CLAUDE_CONTEXT_LOW=1
  fi
fi

# Extract cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
if [ -n "$cost" ]; then
  CLAUDE_COST=$(printf "%.2f" "$cost")
  export CLAUDE_COST
fi

# Extract worktree name
worktree=$(echo "$input" | jq -r '.worktree.name // empty')
if [ -n "$worktree" ]; then
  export CLAUDE_WORKTREE="$worktree"
fi

# Use the cwd from the JSON so the path segment is accurate
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
  cd "$cwd" 2>/dev/null || true
fi

# Render the status line via oh-my-posh
oh-my-posh print primary --config ~/.claude/statusline.omp.json --shell plain 2>/dev/null
