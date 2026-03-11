# TODO: might be different on other platforms
THEMES_DIR=$HOME/.local/share/nvim/lazy/base46/lua/base46/themes/
alias list_nvchad_themes="ls $THEMES_DIR | sed s/\.lua//g"
alias search_nvchad_themes="list_nvchad_themes | fzf"

set_nvim_theme() {
  local theme
  theme=$(search_nvchad_themes)
  export NVIM_THEME="$theme"
}

# Get themes that match the system appearance (light/dark)
get_matching_nvim_themes() {
  local themes
  themes=$(ls "$THEMES_DIR" 2>/dev/null | sed 's/\.lua//g')

  if [[ "${SYS_THEME:-dark}" == "dark" ]]; then
    # Dark mode: exclude themes with "light" or "_light" in the name
    echo "$themes" | grep -v -i "light" | grep -v "github_" | grep -v "one_light"
  else
    # Light mode: include only themes with "light" in the name
    echo "$themes" | grep -i "light"
  fi
}

# Get a random theme that matches the system appearance
get_random_nvim_theme() {
  local theme_list
  theme_list=$(get_matching_nvim_themes)

  if [ -n "$theme_list" ]; then
    echo "$theme_list" | shuf -n 1
  else
    # Fallback to configured defaults
    if [[ "${SYS_THEME:-dark}" == "dark" ]]; then
      echo "${NVIM_DARK_THEME:-catppuccin}"
    else
      echo "${NVIM_LIGHT_THEME:-github_light}"
    fi
  fi
}

nvim() {
  if [ "$NVIM_RANDOM_THEME" = "true" ] && [ -d "$THEMES_DIR" ]; then
    export NVIM_THEME=$(get_random_nvim_theme)
  fi

  # Smart default: open current directory if no args provided
  if [ "$#" -eq 0 ]; then
    command nvim .
  else
    command nvim "$@"
  fi
}
