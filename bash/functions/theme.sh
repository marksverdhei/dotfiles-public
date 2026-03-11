export GHOSTTY_CONFIG="$HOME/.config/ghostty/config"

ghostty_find_theme_preview() {
  # prerequisites
  if [[ -z "${GHOSTTY_THEME_DIR:-}" || ! -d "$GHOSTTY_THEME_DIR" ]]; then
    printf 'Error: GHOSTTY_THEME_DIR is not set or not a directory.\n' >&2
    return 2
  fi
  if ! command -v fzf >/dev/null 2>&1; then
    printf 'Error: fzf is required.\n' >&2
    return 2
  fi

  # Determine sort order: dark→light (default), light→dark if SYS_THEME != dark
  local sort_order
  if [[ "${SYS_THEME:-dark}" == "dark" ]]; then
    sort_order="-k4,4n"
  else
    sort_order="-k4,4nr"
  fi

  local sel
  sel=$(
    {
      while IFS= read -r -d '' f; do
        bg=$(
          awk -F'=' '
            BEGIN{IGNORECASE=1}
            /^[[:space:]]*background[[:space:]]*=/ {
              gsub(/[[:space:]]/, "", $2); print $2; exit
            }' "$f"
        )
        [[ $bg =~ ^#[0-9A-Fa-f]{6}$ ]] || continue

        name=$(basename -- "$f")
        hex=${bg#\#}
        r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
        # Rec. 709 luminance: L = 0.2126*R + 0.7152*G + 0.0722*B
        # Scaled by 10000 to avoid floating point: (2126*R + 7152*G + 722*B)
        lum=$(( 2126*r + 7152*g + 722*b ))
        printf '%s\t%s\t#%s\t%d\n' "$name" "$f" "$hex" "$lum"
      done < <(find "$GHOSTTY_THEME_DIR" -maxdepth 1 -type f -print0)
    } | sort -t$'\t' $sort_order \
      | fzf --ansi --pointer "❯" --with-nth=1 --delimiter $'\t' --preview '
          name=$(cut -f1 <<< "{}")
          file=$(cut -f2 <<< "{}")
          hex=$(cut -f3 <<< "{}" | tr -d "#")
          if [ -z "$hex" ]; then
            printf "Theme: %s\nFile : %s\n(No background found)\n" "$name" "$file"
            exit 0
          fi
          r=$((16#${hex:0:2})); g=$((16#${hex:2:2})); b=$((16#${hex:4:2}))
          yiq=$(( (r*299 + g*587 + b*114) / 1000 ))
          if [ "$yiq" -gt 128 ]; then fr="0;0;0"; else fr="255;255;255"; fi
          printf "Theme: %s\nFile : %s\nBG   : #%s\n\n" "$name" "$file" "$hex"
          printf "Sample:\n"
          printf "\e[48;2;%s;%s;%sm\e[38;2;%s;%s;%sm  %-60s  \e[0m\n" "$r" "$g" "$b" ${fr//;/ } " "
          printf "\e[48;2;%s;%s;%sm\e[38;2;%s;%s;%sm  The quick brown fox jumps over the lazy dog  \e[0m\n" "$r" "$g" "$b" ${fr//;/ }
        '
  ) || return $?  # propagate fzf exit code

  [[ -z "$sel" ]] && return 1

  printf '%s\n' "$(cut -f1 <<< "$sel")"
  return 0
}

reload_ghostty_config() {
  echo 'No reload yet.'
}

ghostty_set_dark_theme() {
  sed -E -i "s/dark:[^,\n]*,/dark:$1,/" "$GHOSTTY_CONFIG"
  reload_ghostty_config
}

ghostty_set_light_theme() {
  sed -E -i "s/light:[^,\n]*/light:$1/" "$GHOSTTY_CONFIG"
  reload_ghostty_config
}


ghostty_pick_dark_theme() {
  ghostty_set_dark_theme "$(ghostty_find_theme_preview)"
}

ghostty_pick_light_theme() {
  ghostty_set_light_theme "$(ghostty_find_theme_preview)"
}

ghostty_set_current_theme() {
  if [ "$SYS_THEME" = 'dark' ]; then
    ghostty_set_dark_theme "$1"
  else
    ghostty_set_light_theme "$1"
  fi
}

ghostty_pick_current_theme() {
  ghostty_set_current_theme "$(ghostty_find_theme_preview)"
}
