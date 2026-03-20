#!/usr/bin/env bash

export DOTFILES="$HOME/dotfiles"
export DOTFILES_PRIVATE="$DOTFILES/private"

DOTFILES_STATE="$HOME/.config/dotfiles"
PRIVATE_FLAG="$DOTFILES_STATE/no-private"

# Determine private dotfiles behavior:
#   DOTFILES_NO_PRIVATE=1 env var, --no-private flag, or remembered from previous run
CLONE_PRIVATE=true
for arg in "$@"; do
  case "$arg" in
    --no-private) CLONE_PRIVATE=false ;;
    --private) CLONE_PRIVATE=true ;;
  esac
done

if [[ "${DOTFILES_NO_PRIVATE:-}" == "1" ]]; then
  CLONE_PRIVATE=false
fi

# Check remembered preference (flag file)
if $CLONE_PRIVATE && [[ -f "$PRIVATE_FLAG" ]]; then
  CLONE_PRIVATE=false
fi

# Persist the preference for future runs
mkdir -p "$DOTFILES_STATE"
if ! $CLONE_PRIVATE; then
  touch "$PRIVATE_FLAG"
else
  rm -f "$PRIVATE_FLAG"
fi

. "$DOTFILES/bootstrap/tools.bash"
. "$DOTFILES/bootstrap/ui.bash"

banner

# ── Git ────────────────────────────────────────
section "Git"
if gh auth status &>/dev/null; then
  spin "Pulling dotfiles" git -C "$DOTFILES" pull
  if $CLONE_PRIVATE; then
    if [[ -d "$DOTFILES_PRIVATE/.git" ]]; then
      spin "Pulling private dotfiles" git -C "$DOTFILES_PRIVATE" pull
    else
      spin "Cloning private dotfiles" gh repo clone marksverdhei/dotfiles "$DOTFILES_PRIVATE" -- --quiet
    fi
  else
    skip "Private dotfiles skipped (--no-private)"
  fi
else
  skip "Sync skipped (gh not authenticated)"
fi

# ── Main config ────────────────────────────────
. "$DOTFILES/bootstrap/main.bash"

# ── Private integration ────────────────────────
if [[ -d "$DOTFILES_PRIVATE" ]]; then
  [[ -f "$DOTFILES_PRIVATE/bootstrap.sh" ]] && source "$DOTFILES_PRIVATE/bootstrap.sh"
fi

done_msg
