# Public ears client for Omarchy desktops. Backend and microphone configuration
# remain local; bootstrap never replaces an existing ears installation or profile.
install_ears_release() (
  local version=v1.1.144
  local checksum=b6a821f0ab180683d150914bcb386a659efca5a286e2dac8846c201298d4a69b
  local tmp
  mkdir -p "$HOME/.local/bin" || exit 1
  tmp=$(mktemp -d "$HOME/.local/bin/.ears-install.XXXXXX") || exit 1
  trap 'rm -rf "$tmp"' EXIT
  curl --fail --location --silent --show-error --retry 3 \
    "https://github.com/heiervang-technologies/ears/releases/download/$version/ears" \
    -o "$tmp/ears" || exit 1
  printf '%s  %s\n' "$checksum" "$tmp/ears" | sha256sum --check --status || exit 1
  chmod 755 "$tmp/ears" || exit 1
  "$tmp/ears" --version || exit 1
  mv "$tmp/ears" "$HOME/.local/bin/ears"
)

ensure_ears() {
  is_omarchy || return 0
  section "ears dictation"
  if [[ "${DOTFILES_NO_EARS:-0}" == 1 ]]; then
    skip "ears skipped (DOTFILES_NO_EARS=1)"
    return 0
  fi

  if command -v ears &>/dev/null || [[ -x "$HOME/.local/bin/ears" ]]; then
    skip "ears already installed"
  elif [[ "$(uname -m)" != x86_64 ]]; then
    warn "ears release is x86_64 only; build from https://github.com/heiervang-technologies/ears"
    return 1
  else
    if ! command -v curl &>/dev/null || ! command -v sha256sum &>/dev/null; then
      warn "Installing ears requires curl and sha256sum"
      return 1
    fi
    if ! install_ears_release; then
      warn "ears installation failed; rerun bootstrap to retry"
      return 1
    fi
    ok "Installed ears v1.1.144"
  fi

  if ! command -v wtype &>/dev/null; then
    if command -v omarchy &>/dev/null; then
      spin "Installing wtype for dictation" omarchy pkg add wtype || return 1
    else
      warn "Install wtype for Hyprland text input"
    fi
  fi
  command -v pw-record &>/dev/null || warn "ears requires PipeWire's pw-record"
  ok "ears available; configure your ASR endpoint with ears server URL, then run ears test"
}

ensure_ears
