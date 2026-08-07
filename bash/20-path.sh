#!/usr/bin/bash

add_to_path() {
  arg="$1"
  if [[ ":$PATH:" != *":$arg:"* ]]; then
      export PATH="$arg:$PATH"
  fi
}

add_to_ldpath() {
  arg="$1"
  if [[ ":$LD_LIBRARY_PATH:" != *":$arg:"* ]]; then
      export LD_LIBRARY_PATH="$arg:$LD_LIBRARY_PATH"
  fi
}

add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "$HOME/go/bin"
add_to_path "$DOTFILES/bin"
add_to_path "$DOTFILES_PRIVATE/bin"
# agent-tools migrated to the XDG data dir on HAIos (hai-os#292, 2026-07-28).
# ~/ht/agent-tools was NEVER a compat symlink here — it was an empty directory,
# and big-dog removed it 2026-08-08. The else-branch below is therefore
# vestigial: it adds a path that does not exist. Kept because a bare
# add_to_path on a missing dir is harmless, and because deleting it would hide
# the one real hazard — anything that re-creates ~/ht/agent-tools/bin flips
# hai-os-setup.sh:1313 back to the archived prefix.
if [[ -d "$HOME/.local/share/hai-os/agent-tools/bin" ]]; then
  add_to_path "$HOME/.local/share/hai-os/agent-tools/bin"
else
  add_to_path "$HOME/ht/agent-tools/bin"
fi

if cmd_exists nvidia-smi; then
  export CUDA_VERSION=$(nvidia-smi --version | tail -n 1 | grep -o -E "[0-9]+\.[0-9]+")
  export CUDA_HOME="/usr/local/cuda-$CUDA_VERSION"
  CUDA_BIN=$CUDA_HOME/bin
  add_to_path "$CUDA_BIN"
  add_to_ldpath "$CUDA_HOME/lib64"
fi
