# ── Neovim (replaces stock config if present) ─
NVIM_SRC="$DOTFILES/nvim"
NVIM_DST="$HOME/.config/nvim"
if [[ -d "$NVIM_SRC" ]]; then
  _nvim_msg="Neovim"
  if [[ -d "$NVIM_DST" && ! -L "$NVIM_DST" ]]; then
    mv "$NVIM_DST" "$NVIM_DST.bak.$(date +%s)"
    for dir in ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
      [[ -d "$dir" ]] && mv "$dir" "$dir.bak.$(date +%s)"
    done
    _nvim_msg="Neovim (migrated from old config)"
  fi
  slink "$NVIM_SRC" "$NVIM_DST"
  ok "$_nvim_msg"
fi

# ── Other symlinks ────────────────────────────
slink "$DOTFILES/ghostty" "$HOME/.config/ghostty"
slink "$DOTFILES/vim/.vimrc" "$HOME/.vimrc"
