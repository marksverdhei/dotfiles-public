export SESSION_NAME=$(tmux display-message -p '#S')
export AGENT_PERSONA="${SESSION_NAME:-}"

if [ -z AGENT_PERSONA ]; then
  export SAY_VOICE='zap'
fi
