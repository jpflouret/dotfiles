#!/usr/bin/env bash
set -euo pipefail

# Add or replace the statusLine configuration in Claude Code settings.json

SETTINGS="${1:-$HOME/.claude/settings.json}"

if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

if ! command -v jq &>/dev/null; then
  echo "jq is required but not installed"
  exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

cp "$SETTINGS" "$SETTINGS.bak"

# Merge statusLine into existing settings, preserving everything else
jq '. + {"statusLine": {"type": "command", "command": "bash ~/.claude/statusline-command.sh"}}' \
  "$SETTINGS" > "$tmp" || exit 1

cp "$tmp" "$SETTINGS"
echo "statusLine configured in $SETTINGS"
