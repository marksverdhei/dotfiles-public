# Machine accent colour as a single env var, from the hai-os-seeded accent.env, so
# generic configs (starship, …) theme on public / no-private boxes too — no gh-auth
# or private repo needed. The private bash layers a fleet-registry fallback on top
# of this (see dotfiles/private/bash/vars/hai-os-accent.sh); both are idempotent.
[[ -z "${HAI_OS_ACCENT:-}" && -r "$HOME/.config/hai-os/accent.env" ]] && \
  . "$HOME/.config/hai-os/accent.env"
export HAI_OS_ACCENT
