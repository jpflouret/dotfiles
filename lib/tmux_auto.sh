# tmux session picker and auto-launch functions.

if command -v fzf &>/dev/null; then

  # Pick a tmux session using fzf. Sets REPLY to a session name, ":new", or "".
  _tmux_pick_session() {
    local items=("$@" "New session")
    local new_idx=$(( ${#items[@]} - 1 ))
    REPLY=$(printf '%s\n' "${items[@]}" | \
      fzf --height="~50%" --no-info --prompt="tmux session: ")
    [ "$REPLY" == "${items[$new_idx]}" ] && REPLY=":new"
  }

else

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

  # Pick a tmux session using a TUI menu. Sets REPLY to a session name, ":new", or "".
  _tmux_pick_session() {
    local items=("$@" "New session")
    local count=${#items[@]}
    local new_idx=$(( count - 1 ))
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
  }

fi

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

# List tmux session names with the most recently attached session first.
_tmux_list_sessions() {
  tmux list-sessions -F "#{session_last_attached}	#{session_name}" 2>/dev/null | sort -rn | cut -f2-
}

# List sessions, prompt user to pick one, and attach or create.
# Inside tmux, switches client instead of exec-attaching.
_tmux_pick_and_attach() {
  local sessions=()
  while IFS= read -r s; do
    sessions+=("$s")
  done < <(_tmux_list_sessions)

  if [ -f "$HOME/.hushlogin" ] && [ ${#sessions[@]} -eq 0 ]; then
    REPLY=":new"
  else
    _tmux_pick_session "${sessions[@]}"
  fi
  if [ -n "$TMUX" ]; then
    case "$REPLY" in
      "")     return 1 ;;
      ":new") tmux new-session -d && tmux switch-client -n ;;
      *)      tmux switch-client -t "$REPLY" ;;
    esac
  else
    while true; do
      local target=""
      case "$REPLY" in
        "")     return 1 ;;
        ":new") target=$(tmux -2 new-session -dP) && tmux -2 attach-session -t "$target" ;;
        *)      target="$REPLY"; tmux -2 attach-session -t "$target" ;;
      esac
      # If the attached session still exists, the user detached. End the
      # shell so the SSH connection closes.
      if [ -n "$target" ] && tmux has-session -t "$target" 2>/dev/null; then
        exit
      fi
      # No sessions left means we exited the last one.
      tmux list-sessions &>/dev/null || exit
      # Session ended but others remain. Re-list and let the user pick.
      sessions=()
      while IFS= read -r s; do
        sessions+=("$s")
      done < <(_tmux_list_sessions)
      _tmux_pick_session "${sessions[@]}"
    done
  fi
}

# Auto-attach or create a tmux session. Returns 0 if we entered tmux.
# Skips when tmux is unavailable, suppressed, or in certain terminals.
_tmux_auto_start() {
  [ -f "$HOME/.no_tmux" ] && return 1           # no if ~/.no_tmux exists
  command -v tmux &>/dev/null || return 1       # no if tmux not found
  [ "$TERM_PROGRAM" == "vscode" ] && return 1   # not for vscode
  [ "$LC_TERMINAL" == "ShellFish" ] && return 1 # not for shellfish
  [ "$TERM" == "tmux-256color" ] && return 1    # avoid tmux-in-tmux
  [ -n "$TMUX" ] && return 1                    # not if already in tmux

  _tmux_pick_and_attach

  if [ -z "$TMUX" ]; then
    tmux list-sessions 2>/dev/null
  fi
  return 1
}
