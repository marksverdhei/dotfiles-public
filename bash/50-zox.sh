# zoxide init moved to 97-zox-init.sh (must run after starship/prompt setup)
if ! cmd_exists zoxide; then
    alias z='cd'
    if [[ $- == *i* ]]; then
      alias z
    fi
fi
