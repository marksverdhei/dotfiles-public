export TERMINAL=alacritty
export TERM=xterm-256color
export DOTFILES="$HOME/dotfiles"

if [[ -z "$LANG" ]]; then
  export LANG="en_US.UTF-8"
fi

export COMMIT_MSG_MODEL='qwen3-coder:latest'

export HF_HOME="$HOME/Models/huggingface"

export ANONYMIZED_TELEMETERY='false'

export MODELS="$HOME/Models"
export GGUFS="$HOME/Models/llama.cpp"

# export CLAUDE_CONFIG_DIR="/home/me/dotfiles/claude/"
unset CLAUDE_CONFIG_DIR
