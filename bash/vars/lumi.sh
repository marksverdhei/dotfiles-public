# Lumi vars — credentials and project IDs are in private dotfiles
# Source private lumi config if available
if [[ -f "$DOTFILES_PRIVATE/bash/vars/lumi.sh" ]]; then
  . "$DOTFILES_PRIVATE/bash/vars/lumi.sh"
fi
