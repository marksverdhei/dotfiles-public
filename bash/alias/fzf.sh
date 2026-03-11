alias cpe="fe | xcp"
alias cpn="fn | xcp"
alias fa="alias | sed -e 's/^alias //'| fzf"
alias ffile='find . -type d -print | fzf'
# find bash functions
alias ff='compgen -A function | fzf'
# find all auto-completable elements
alias fac='compgen -ac | sort -u | fzf'
alias fe='printenv | cut -d= -f1 | fzf --height=40% --reverse | xargs -r -I{} printenv {}'
alias fn='printenv | cut -d= -f1 | fzf --height=40% --reverse'
alias fzh="find . -type f -not -path '*/\.git/*' | fzf"
alias fat='cat $(fzf)'
alias fbf='search_func'


# alias 
alias funset='unset $(fn)'
