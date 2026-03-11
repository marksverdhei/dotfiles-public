# Bootstrap UI — gum spinners + ANSI status lines

HAS_GUM=false
command -v gum &>/dev/null && HAS_GUM=true

if [[ -t 1 ]]; then
  _b=$'\033[1m'      _d=$'\033[2m'      _r=$'\033[0m'
  _grn=$'\033[38;5;78m'  _ylw=$'\033[38;5;214m'
  _cyn=$'\033[38;5;75m'  _mag=$'\033[38;5;212m'  _gry=$'\033[38;5;240m'
else
  _b='' _d='' _r='' _grn='' _ylw='' _cyn='' _mag='' _gry=''
fi

banner() {
  printf '\n'
  if $HAS_GUM; then
    gum style --foreground 212 --bold --border rounded --border-foreground 240 \
      --padding "0 2" --margin "0 2" "dotfiles · $(hostname)"
  else
    printf '  %s%s● dotfiles%s %s· %s%s\n' "$_mag" "$_b" "$_r" "$_gry" "$(hostname)" "$_r"
  fi
}

section() { printf '\n  %s%s▸ %s%s\n' "$_cyn" "$_b" "$1" "$_r"; }
ok()      { printf '    %s✓%s %s\n' "$_grn" "$_r" "$1"; }
warn()    { printf '    %s⚠%s %s\n' "$_ylw" "$_r" "$1"; }
skip()    { printf '    %s○ %s%s\n' "$_gry" "$1" "$_r"; }

spin() {
  local title="$1"; shift
  if $HAS_GUM; then
    gum spin --spinner dot --title "    ◌ $title" -- "$@" 2>/dev/null
    local rc=$?
    (( rc == 0 )) && ok "$title" || warn "$title"
    return $rc
  else
    printf '    %s◌%s %s' "$_gry" "$_r" "$title"
    if "$@" &>/dev/null; then
      printf '\r\033[2K'
      ok "$title"
    else
      printf '\r\033[2K'
      warn "$title"
      return 1
    fi
  fi
}

done_msg() { printf '\n  %s%s✓ All done%s\n\n' "$_grn" "$_b" "$_r"; }
