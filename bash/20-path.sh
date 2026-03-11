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

if cmd_exists nvidia-smi; then
  export CUDA_VERSION=$(nvidia-smi --version | tail -n 1 | grep -o -E "[0-9]+\.[0-9]+")
  export CUDA_HOME="/usr/local/cuda-$CUDA_VERSION"
  CUDA_BIN=$CUDA_HOME/bin
  add_to_path "$CUDA_BIN"
  add_to_ldpath "$CUDA_HOME/lib64"
fi
