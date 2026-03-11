if [[ $- == *i* ]]; then
  if [ -e "$HOME/.venv" ]; then
    gv
  fi
  # Display bashrc loading time
  if [ -n "$BASHRC_START_TIME" ]; then
    BASHRC_END_TIME=$(date +%s%N)
    BASHRC_LOAD_TIME=$(( (BASHRC_END_TIME - BASHRC_START_TIME) / 1000000 ))
    echo "Bashrc loaded in ${BASHRC_LOAD_TIME}ms"
    unset BASHRC_START_TIME BASHRC_END_TIME BASHRC_LOAD_TIME
  fi
fi

