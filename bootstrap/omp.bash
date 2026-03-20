# Generate and link OMP config for current hostname
omp_config="$DOTFILES/omp/${HOSTNAME}.omp.json"
omp_fallback="$DOTFILES/omp/base.omp.json"

if [[ ! -f "$omp_config" ]]; then
  if "$DOTFILES/omp/generate.py" 2>/dev/null; then
    ok "OMP theme generated"
  else
    warn "OMP generation failed (missing python?)"
  fi
fi

if [[ -f "$omp_config" ]]; then
  slink "$omp_config" "$HOME/.config/omp.json"
  ok "OMP → $HOSTNAME"
elif [[ -f "$omp_fallback" ]]; then
  slink "$omp_fallback" "$HOME/.config/omp.json"
  warn "OMP → base (no config for $HOSTNAME)"
else
  warn "No OMP config available"
fi
