alias ta='tmux attach'
alias td='tmux detach'
alias tl='tmux list-session'
alias tn='tmux new'
alias tns='tmux new -s'

# Attach to a tmux session; if multiple, let me pick one (fzf if available, else a menu).
tmux_select() {
  # If already inside tmux, we need switch-client instead of attach
  if [ -n "$TMUX" ]; then
    attach_cmd=(tmux switch-client -t)
  else
    attach_cmd=(tmux attach -t)
  fi

  # List existing sessions
  IFS=$'\n' sessions=($(tmux list-sessions -F '#S' 2>/dev/null)) ; unset IFS
  count=${#sessions[@]}

  if [ "$count" -eq 0 ]; then
    tmux new-session
  elif [ "$count" -eq 1 ]; then
    "${attach_cmd[@]}" "${sessions[0]}"
  else
    # Pick with fzf if present; otherwise use a simple PS3/select menu
    if command -v fzf >/dev/null 2>&1; then
      choice=$(printf '%s\n' "${sessions[@]}" | fzf --prompt='tmux session > ')
    else
      echo "Select a tmux session:"
      select s in "${sessions[@]}"; do [ -n "$s" ] && choice="$s" && break; done
    fi
    [ -n "$choice" ] && "${attach_cmd[@]}" "$choice"
  fi
}

alias ts='tmux_select'   # type `ta` to run it
alias tas='tmux_select'   # type `ta` to run it
