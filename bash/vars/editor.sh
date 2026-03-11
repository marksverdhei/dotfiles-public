if cmd_exists nvim; then
  export CHADRC=$DOTFILES/nvim/lua/chadrc.lua

  if [ -n "$TMUX" ]; then
    # use tmux session name so each session has its own socket
    export NVIM_LISTEN_ADDRESS="$XDG_RUNTIME_DIR/nvim-${TMUX_PANE}.sock"
  fi

  if cmd_exists nvr && [ -n "$NVIM" ]; then
    NEOVIM='nvr --remote-wait'
  else
    NEOVIM='nvim'
  fi

  export EDITOR=$NEOVIM
elif cmd_exists vim; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
