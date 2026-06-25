# Generate the Starship config for this machine from ONE template + the machine
# accent colour ($HAI_OS_ACCENT). Replaces the old per-host *.starship.toml files
# (only `session_bg` ever differed between them). Themes public / no-private boxes
# too: the accent resolves from a hai-os-seeded accent.env, so no gh-auth or
# private repo is required just to colour the prompt.
#
# Accent resolution (first hit wins):
#   1. $HAI_OS_ACCENT already in the env
#   2. ~/.config/hai-os/accent.env   (hai-os seeds this at provision)
#   3. bin/hai-os-accent             (private resolver: omp/colors.json by hostname)
#   4. sane default
#
# Template: the private base (richer "host" palette) when the private repo is
# present, else the public default.

starship_template="$DOTFILES/starship/starship.toml"
[[ -f "$DOTFILES_PRIVATE/starship/base.starship.toml" ]] && \
  starship_template="$DOTFILES_PRIVATE/starship/base.starship.toml"

_accent="${HAI_OS_ACCENT:-}"
if [[ -z "$_accent" && -f "$HOME/.config/hai-os/accent.env" ]]; then
  . "$HOME/.config/hai-os/accent.env"
  _accent="${HAI_OS_ACCENT:-}"
fi
[[ -z "$_accent" ]] && command -v hai-os-accent >/dev/null 2>&1 && _accent="$(hai-os-accent)"
_accent="${_accent:-#7aa2f7}"

if [[ -f "$starship_template" ]]; then
  mkdir -p "$HOME/.config"
  # ~/.config/starship.toml is a GENERATED file now, not a symlink — drop any
  # stale symlink first so we never write through to a repo file.
  [[ -L "$HOME/.config/starship.toml" ]] && rm -f "$HOME/.config/starship.toml"
  sed -E "s|^(session_bg[[:space:]]*=[[:space:]]*).*|\\1\"$_accent\"|" \
    "$starship_template" > "$HOME/.config/starship.toml"
  ok "Starship → \$HAI_OS_ACCENT ($_accent)"
else
  warn "No Starship template available"
fi
