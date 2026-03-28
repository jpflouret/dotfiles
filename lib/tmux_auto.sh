# Tmux session picker and auto-launch functions.

# Draw the TUI session picker menu
_tmux_pick_draw_menu() {
  local count=$1 selected=$2
  shift 2
  local items=("$@")
  local i
  for (( i = count - 1; i >= 0; i-- )); do
    if [ $i -eq $selected ]; then
      printf '\e[K> %s\n' "${items[$i]}"
    else
      printf '\e[K  %s\n' "${items[$i]}"
    fi
  done
}

# Pick a tmux session. Sets REPLY to a session name, ":new", or "".
_tmux_pick_session() {
  local items=("$@" "New session")
  local count=${#items[@]}

  local new_idx=$(( count - 1 ))

  if command -v fzf &>/dev/null; then
    REPLY=$(printf '%s\n' "${items[@]}" | \
      fzf --height="~50%" --no-info --prompt="tmux session: ")
    [ "$REPLY" == "${items[$new_idx]}" ] && REPLY=":new"
  else
    local selected=0

    printf '\e[?25l' # hide cursor
    _tmux_pick_draw_menu "$count" "$selected" "${items[@]}"
    printf '\e[Ktmux session: '

    while true; do
      local key
      read -rsn1 key
      case "$key" in
        "") # enter
          printf '\e[?25h' # show cursor
          if [ $selected -eq $new_idx ]; then
            REPLY=":new"
          else
            REPLY="${items[$selected]}"
          fi
          break
          ;;
        $'\e') # escape or arrow key
          local seq
          read -rsn1 -t 0.1 seq
          if [ -z "$seq" ]; then
            printf '\e[?25h' # show cursor
            REPLY=""
            break
          fi
          read -rsn1 -t 0.1 seq
          case "$seq" in
            A) (( selected < count - 1 )) && (( selected++ )) ;;
            B) (( selected > 0 )) && (( selected-- )) ;;
          esac
          ;;
        *) continue ;;
      esac
      printf '\r\e[%dA' "$count" # move cursor to start of first menu line
      _tmux_pick_draw_menu "$count" "$selected" "${items[@]}"
      printf '\e[Ktmux session: '
    done
  fi
}

# Print MOTD for the first pane of the first window in a tmux session.
_tmux_motd() {
  [ -n "$TMUX" ] || return 1
  [ -f "$HOME/.hushlogin" ] && return 0
  [ "$(tmux display-message -p '#{window_index}:#{pane_index}')" == "1:1" ] || return 0
  if [ -f /run/motd.dynamic ] || [ -f /etc/motd ]; then
    for motd in /run/motd.dynamic /etc/motd; do
      if [ -s "$motd" ]; then cat "$motd"; break; fi
    done
  elif command -v agetty &>/dev/null; then
    agetty --show-issue 2>/dev/null || uname -a
  fi
}

# Auto-attach or create a tmux session. Returns 0 if we entered tmux.
# Skips when tmux is unavailable, suppressed, or in certain terminals.
_tmux_auto_start() {
  [ -f "$HOME/.no_tmux" ] && return 1
  command -v tmux &>/dev/null || return 1
  [ "$TERM_PROGRAM" == "vscode" ] && return 1
  [ "$LC_TERMINAL" == "ShellFish" ] && return 1
  [ -n "$TMUX" ] && return 1

  local sessions=()
  while IFS= read -r s; do
    sessions+=("$s")
  done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)

  if [ ${#sessions[@]} -eq 0 ] && [ -f "$HOME/.hushlogin" ]; then
    exec tmux -2 new-session
  fi

  _tmux_pick_session "${sessions[@]}"
  case "$REPLY" in
    "")     ;;
    ":new") exec tmux -2 new-session ;;
    *)      exec tmux -2 attach-session -t "$REPLY" ;;
  esac

  if [ -z "$TMUX" ]; then
    tmux list-sessions 2>/dev/null
  fi
  return 1
}

# Interactively pick and attach to a tmux session.
ta() {
  if [ -n "$TMUX" ]; then
    echo "Already inside tmux."
    return 1
  fi
  local sessions=()
  while IFS= read -r s; do
    sessions+=("$s")
  done < <(tmux list-sessions -F "#{session_name}" 2>/dev/null)
  if [ ${#sessions[@]} -eq 0 ]; then
    echo "No tmux sessions."
    return 1
  fi
  _tmux_pick_session "${sessions[@]}"
  case "$REPLY" in
    "")     ;;
    ":new") exec tmux -2 new-session ;;
    *)      exec tmux -2 attach-session -t "$REPLY" ;;
  esac
}
