alias vz='nvr -c "cd $(pwd)"'

alias fzt="set_nvim_theme"
alias va='cd $DOTFILES/bash && $EDITOR alias/$(ls alias | fzf)'
alias vb='cd $DOTFILES/bash && $EDITOR'
alias vbr='$EDITOR ${HOME}/.bashrc'
alias vo='cd ${HOME}/dotfiles && $EDITOR'

alias vnv='cd $DOTFILES/nvim && v'
alias vf='v $(fzf)'
