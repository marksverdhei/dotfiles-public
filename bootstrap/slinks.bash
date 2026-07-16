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
slink "$DOTFILES/heartbeat" "$HOME/.config/heartbeat"

# Waybar — prefer the private per-host config (like tmux above), then the
# private shared one, then the public dir. The MK2 reinstall taught us the
# hard way: a hand-made link dies with the box; bootstrap must own this.
WAYBAR_SRC="$DOTFILES/private/waybar/$(hostname)"
[[ -d "$WAYBAR_SRC" ]] || WAYBAR_SRC="$DOTFILES/private/waybar/shared"
[[ -d "$WAYBAR_SRC" ]] || WAYBAR_SRC="$DOTFILES/waybar"
if command -v waybar &>/dev/null && [[ -d "$WAYBAR_SRC" ]]; then
  slink "$WAYBAR_SRC" "$HOME/.config/waybar"
fi

# ── tmux (pointer file, NOT a symlink) ────────
# Omarchy ships its own ~/.config/tmux/tmux.conf (prefix C-Space + prefix2 C-b
# = a double leader key) and `omarchy-refresh-tmux` cp -f's it back over ours.
# A symlink is unsafe: that cp -f would write THROUGH the link and clobber the
# repo file. So we install a tiny pointer that source-files the real config —
# if Omarchy overwrites the pointer, only the pointer is lost (repo stays safe),
# and re-running this bootstrap restores it. Prefer the private config.
TMUX_SRC="$DOTFILES/private/tmux/tmux1.conf"
[[ -f "$TMUX_SRC" ]] || TMUX_SRC="$DOTFILES/tmux/tmux1.conf"
if [[ -f "$TMUX_SRC" ]]; then
  mkdir -p "$HOME/.config/tmux"
  {
    echo "# dotfiles-managed pointer — real config lives in the repo."
    echo "# NOTE: \`omarchy-refresh-tmux\` will clobber THIS file (repo stays safe);"
    echo "# re-run bootstrap to restore it."
    echo "source-file $TMUX_SRC"
  } > "$HOME/.config/tmux/tmux.conf"
  # TPM (referenced by the config); plugins install to ~/.config/tmux/plugins/.
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1
  fi
  ok "tmux config pointed at $TMUX_SRC (prefix C-Space, no double leader)"
fi
