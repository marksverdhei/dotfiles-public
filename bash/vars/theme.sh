if is_light_preferred; then
  export SYS_THEME="light"
else
  export SYS_THEME="dark"
fi

# Follow the active Omarchy theme; fall back to catppuccin off-Omarchy.
if [ -f "$HOME/.config/omarchy/current/theme.name" ]; then
  export THEME="$(cat "$HOME/.config/omarchy/current/theme.name")"
else
  export THEME="catppuccin"
fi

export GHOSTTY_THEME_DIR="/snap/ghostty/current/share/ghostty/themes"
export GHOSTTY_THEME=$THEME
export GHOSTTY_RANDOM_THEME=true
export NVIM_DARK_THEME="oxocarbon"
export NVIM_LIGHT_THEME="github_light"
export NVIM_RANDOM_THEME=true

if is_light_preferred; then
  export NVIM_THEME=$NVIM_LIGHT_THEME
else
  export NVIM_THEME=$NVIM_DARK_THEME
fi
