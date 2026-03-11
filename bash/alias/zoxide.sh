alias zb='z ..'
alias zbb='z ../..'
alias zbbb='z ../../..'
alias zn='d=$(ls -d -- .*/ */ 2>/dev/null | grep -vE "^(\./?\.{1,2}/?$|\.{1,2}/?$)" | head -n1 | sed "s:/*$::"); [ -n "$d" ] && z "$d"'
alias zv='z "$(nvr --remote-expr "getcwd()")"'
# in nvim.sh
# alias vz='z "$(nvr --remote-expr "getcwd()")"'

alias zl='z -'
alias az='create_alias zoxide'
alias zo='z $DOTFILES'
alias zrp='z $(rp)'
