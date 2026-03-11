alias aa='create_alias common'
alias ap='ansible-playbook'
alias apb='ansible-playbook -K'

# Clipboard aliases - Wayland (wl-copy/wl-paste) vs X11 (xclip)
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  if [[ "$ID" == "arch" ]] && command -v wl-copy &>/dev/null; then
    alias xcp='wl-copy'
    alias xps='wl-paste'
    alias xcpf='wl-copy <'
    alias xpsf='wl-paste > '
    alias clump='wl-paste > '
    alias xcprint='tee >(wl-copy)'
  else
    alias xcp='xclip -selection clipboard'
    alias xps='xclip -selection clipboard -o'
    alias xcpf='xclip -selection clipboard <'
    alias xpsf='xclip -selection clipboard -o > '
    alias clump='xclip -selection clipboard -o > '
    alias xcprint='tee >(xclip -selection clipboard)'
  fi
fi
alias cptree="tree | xcp"
alias dv='deactivate'
alias ffc="ffmpeg_convert_file"
alias ft="flip_theme"
alias gg='gemini -m pro'
alias home='cd ~'
alias la='ls -a --color=auto'
alias lsa='list_abs'
alias mkissue="gh issue create"
alias mvold="mv *.err ./old/ && mv *.out ./old/"
alias nonet='firejail --net=none'
alias ntl='nautilus . > /dev/null 2>&1 &'
alias qp='fully_detach_run'
alias rp='realpath .'
alias crp='cd $(realpath .)'
alias zrp='cd $(realpath .)'
alias sy='sudo singularity'
alias uchown="sudo chown -R $USER:$USER"
alias xmod="chmod +x"
alias etgz='tar -xvzf'
alias fdu="find . -mindepth 2 -type f -printf '%h\n' | cut -d/ -f2 | sort | uniq -c | sort -nr"
alias mxf="maxfile"
alias clog='cat $(maxfile)'
alias qr='quick_replace'
alias d1='CUDA_VISIBLE_DEVICES=1'
alias xo='xdg-open'

alias var='create_var'
