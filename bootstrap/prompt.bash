# Generate and link Starship config for current hostname
# Priority: private per-host > private base > public default
starship_dir="$DOTFILES_PRIVATE/starship"
starship_config="$starship_dir/${HOSTNAME}.starship.toml"
# For container hostnames like "host-dev-gpu-1", try the base name "host"
if [[ ! -f "$starship_config" && "$HOSTNAME" == *-* ]]; then
  _base_host="${HOSTNAME%%-*}"
  [[ -f "$starship_dir/${_base_host}.starship.toml" ]] && starship_config="$starship_dir/${_base_host}.starship.toml"
fi
starship_fallback="$starship_dir/base.starship.toml"
starship_public="$DOTFILES/starship/starship.toml"

if [[ -d "$starship_dir" ]]; then
  if [[ ! -f "$starship_config" ]]; then
    if "$starship_dir/generate.py" 2>/dev/null; then
      ok "Starship configs generated"
    else
      warn "Starship generation failed (missing python?)"
    fi
  fi

  if [[ -f "$starship_config" ]]; then
    slink "$starship_config" "$HOME/.config/starship.toml"
    ok "Starship → $HOSTNAME"
  elif [[ -f "$starship_fallback" ]]; then
    slink "$starship_fallback" "$HOME/.config/starship.toml"
    warn "Starship → base (no config for $HOSTNAME)"
  elif [[ -f "$starship_public" ]]; then
    slink "$starship_public" "$HOME/.config/starship.toml"
    ok "Starship → public default"
  else
    warn "No Starship config available"
  fi
elif [[ -f "$starship_public" ]]; then
  slink "$starship_public" "$HOME/.config/starship.toml"
  ok "Starship → public default"
else
  warn "No Starship config available"
fi
