alias gAcp='git add -A && git_commit_push_generated_msg'
alias gacp='git add . && git_commit_push_generated_msg'
alias gapc='git add . && git_commit_push_generated_msg'
alias gad='git_add_files'
alias ga='git_add_files'
alias gb='git branch'
alias gca='git commit -a -m'
alias gcb='git checkout -b'
alias gcm='git_commit_local'
alias gco='git checkout'
alias gcf='git_checkout_fzf'
alias gcob='git checkout -b'
alias gcp='git_commit_push_generated_msg'
alias gd="git diff"
alias gds="git diff --cached"
alias gf='git fetch'
alias st='git status -s'

alias gmm='git merge origin/HEAD'
alias pl="git pull"
alias gpl='git pull'
alias gp='git push'
alias gpup='git push --set-upstream origin @'
alias grh="git reset --hard"
alias gs='git status -s'
gsr() {
  local max=10 dirty=0 clean=0 results=""
  results="$(gum spin --spinner dot --title "Scanning repos..." -- bash -c '
    max=10; dirty=0; clean=0
    while IFS= read -r gitdir; do
      repo="${gitdir%/.git}"
      output="$(git -C "$repo" status -s)"
      if [[ -z "$output" ]]; then
        ((clean++))
        continue
      fi
      ((dirty++))
      echo "REPO:$repo"
      echo "$output"
      echo
      if ((dirty >= max)); then
        echo "LIMIT_REACHED"
        break
      fi
    done < <(bfs . -name .git -type d -prune 2>/dev/null)
    echo "SUMMARY:$dirty:$clean"
  ')"
  local summary
  summary="$(echo "$results" | grep '^SUMMARY:' | head -1)"
  dirty="$(echo "$summary" | cut -d: -f2)"
  clean="$(echo "$summary" | cut -d: -f3)"
  # Print repo results with styled headers
  echo "$results" | while IFS= read -r line; do
    if [[ "$line" == REPO:* ]]; then
      gum style --foreground 12 --bold "${line#REPO:}"
    elif [[ "$line" == SUMMARY:* ]]; then
      :
    elif [[ "$line" == "LIMIT_REACHED" ]]; then
      gum style --foreground 208 --italic "(limit of $max repos with changes reached)"
    else
      echo "$line"
    fi
  done
  gum style --foreground 245 "${dirty:-0} dirty, ${clean:-0} clean"
}
alias gprune="git fetch --prune && git branch -vv | grep ': gone]' | awk '{print \$1}' | xargs -r git branch -D"

alias isc='gh issue create'
alias isw="gh issue view"
alias isl='gh issue list'
alias lsis='echo use lis'

alias close='gh issue close'

alias lis='gh issue list'
alias prc='gh pr create'
alias prw='gh pr view'
alias lpr='gh pr list'
alias prl='gh pr list'
alias prs='gh pr list'
alias lspr='echo use prs'
alias closepr='gh pr close'
alias prm='gh pr merge'

alias rw='gh repo view --web > /dev/null 2>&1 &'

alias gl='git log'

alias unstage='git restore --staged'

# Fuzzy search GitHub repos (personal + orgs) with fzf
# Enter: return repo id | Ctrl-o: open in browser
ghf() {
  {
    gh repo list --limit 200 --json nameWithOwner,description -q '.[] | "\(.nameWithOwner)\t\(.description // "")"'
    for org in $(gh api user/orgs -q '.[].login'); do
      gh repo list "$org" --limit 100 --json nameWithOwner,description -q '.[] | "\(.nameWithOwner)\t\(.description // "")"'
    done
  } | sort -u | fzf --delimiter='\t' --with-nth=1,2 \
      --preview 'gh repo view {1}' \
      --header 'Enter: return repo | Ctrl-o: open in browser' \
      --bind 'ctrl-o:execute(gh repo view {1} --web)+abort' \
  | cut -f1
}

# Clone repo via fzf search
gcl() { gh repo clone "$(ghf)"; }

# View repo in browser via fzf search
grw() { gh repo view --web "$(ghf)"; }
