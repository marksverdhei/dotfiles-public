# Start timing for bashrc loading
export BASHRC_START_TIME=$(date +%s%N)

export DOTFILES="$HOME/dotfiles"
export DOTFILES_PRIVATE="$DOTFILES/private"
# A more readable way to check for 
# existence of commands
cmd_exists() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Theme settings
is_light_preferred() {
  # Linux/GNOME: Try the modern color-scheme key
  if val=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null); then
    val=${val//\'/}
    [[ $val == default ]] && return 0 || return 1
  fi

  # Fallback: check gtk-theme name for "-dark"
  if theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null); then
    theme=${theme//\'/}
    [[ $theme == *-dark ]] && return 1 || return 0
  fi

  # If all else fails, assume dark
  return 1
}
