if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
  fi
  if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
  fi

  # HAIos fzf look — same tokens as bin/omarchy-tmux-theme (~/ht/design-system):
  # terminal bg shows through, ONE accent, cyan-tint chip for the cursor line.
  # Accent is HAIos cyan unless the active theme carries its own
  # (session-accent.env, SESSION_ACCENT_SOURCE=theme). Prepended, so anything
  # already in FZF_DEFAULT_OPTS still wins.
  _haios_fzf_accent="#22d3ee"
  if [[ -r "$HOME/.config/hai-os/session-accent.env" ]]; then
    _haios_fzf_accent="$(
      . "$HOME/.config/hai-os/session-accent.env" 2>/dev/null
      if [[ "${SESSION_ACCENT_SOURCE:-}" == theme && "${SESSION_ACCENT:-}" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        echo "$SESSION_ACCENT"
      else
        echo "$_haios_fzf_accent"
      fi
    )"
  fi
  _a="$_haios_fzf_accent"
  # Re-sourcing replaces the previous HAIos block rather than stacking it.
  _rest="${FZF_DEFAULT_OPTS:-}"
  [[ -n "${_HAIOS_FZF_OPTS:-}" ]] && _rest="${_rest#"$_HAIOS_FZF_OPTS"}" && _rest="${_rest# }"
  export _HAIOS_FZF_OPTS="--color=bg:-1,gutter:-1,fg:#c9e6ee,fg+:#e6f7fb,bg+:#0e2633,hl:$_a,hl+:$_a:bold,query:#e6f7fb,prompt:$_a,pointer:$_a,marker:$_a,spinner:$_a,info:#6f95a1,header:#8fb8c4,border:#135464,separator:#135464,scrollbar:#135464,label:#8fb8c4,preview-border:#135464 --prompt='❯ ' --pointer='❯' --marker='▌' --separator='─' --scrollbar='│' --info=inline-right"
  export FZF_DEFAULT_OPTS="$_HAIOS_FZF_OPTS${_rest:+ $_rest}"
  unset _a _rest _haios_fzf_accent
fi
