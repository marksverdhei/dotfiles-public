# OS detection
is_omarchy() {
  [[ -f /etc/os-release ]] && . /etc/os-release
  [[ "$ID" == "arch" ]] && command -v hyprctl &>/dev/null
}

section "Shell"

if is_omarchy; then
  # Remove Omarchy's default bash config sourcing — our dotfiles replace it
  if grep -q '^source ~/.local/share/omarchy/default/bash/rc' "$HOME/.bashrc"; then
    sed -i 's|^source ~/.local/share/omarchy/default/bash/rc|# &|' "$HOME/.bashrc"
    ok "Commented out Omarchy default bash rc"
  fi
fi

if [[ -L "$HOME/.bashrc.d" ]]; then
  unlink "$HOME/.bashrc.d"
elif [[ -d "$HOME/.bashrc.d" ]]; then
  rm -rf "$HOME/.bashrc.d"
fi
ln -s "$DOTFILES/bash/" "$HOME/.bashrc.d"
inject_bashrc
ok "bashrc.d linked"

. "$HOME/.bashrc"
touch "$HOME/.cache/hf.env"
ok "Initialized"

cp "$DOTFILES/nvim/lua/_chadrc.lua" "$DOTFILES/nvim/lua/chadrc.lua" 2>/dev/null
cp "$DOTFILES_PRIVATE/ghostty/default.config" "$DOTFILES_PRIVATE/ghostty/config" 2>/dev/null

. "$DOTFILES/bootstrap/prompt.bash"
