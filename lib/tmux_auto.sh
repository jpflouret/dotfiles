# Early return if we don't have or need tmux
[ -f "$HOME/.no_tmux" ] && return
command -v tmux &>/dev/null || return
[ "$TERM_PROGRAM" == "vscode" ] && return
[ "$LC_TERMINAL" == "ShellFish" ] && return

# If we're already inside tmux then print motd and exit
if [ -n "$TMUX" ]; then
  [ -f "$HOME/.hushlogin" ] && return
  [ "$(tmux display-message -p '#{window_index}:#{pane_index}')" == "1:1" ] || return
  if [ -f /run/motd.dynamic ] || [ -f /etc/motd ]; then
    for motd in /run/motd.dynamic /etc/motd; do
      if [ -s "$motd" ]; then cat "$motd"; break; fi
    done
  elif command -v agetty &>/dev/null; then
    agetty --show-issue 2>/dev/null || uname -a
  fi
  return
fi

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
      fzf --height="$(( count + 1 ))" --no-info --prompt="tmux session: ")
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

_tmux_init() {
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
}

_tmux_init
unset -f _tmux_init _tmux_pick_session _tmux_pick_draw_menu
