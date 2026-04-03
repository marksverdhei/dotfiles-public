export TERMINAL=alacritty
export TERM=xterm-256color
export DOTFILES="$HOME/dotfiles"

if [[ -z "$LANG" ]]; then
  export LANG="en_US.UTF-8"
fi


export LLM='qwen3.5-27b'
export VLM="$LLM"
export COMMIT_MSG_MODEL="$LLM"
export HAT_MODEL="$LLM"

export HF_HOME="$HOME/Models/huggingface"

export ANONYMIZED_TELEMETERY='false'

export MODELS="$HOME/Models"
export GGUFS="$HOME/Models/llama.cpp"

unset CLAUDE_CONFIG_DIR
export UNLEASH_DIR='/home/me/ht/unleash'
