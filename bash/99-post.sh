if [[ $- == *i* ]]; then
  # ~/.venv is NOT auto-activated any more (Hei, 2026-08-09). It used to be
  # sourced here on every interactive shell, which put its python ahead of the
  # system one — so anything pacman installed into the system python was
  # invisible, and this box quietly diverged from what a HAIos install produces.
  # It is opt-in now: `gv` (or `vg`) activates it, `vv` activates a local .venv.

  # Display bashrc loading time
  if [ -n "$BASHRC_START_TIME" ]; then
    BASHRC_END_TIME=$(date +%s%N)
    BASHRC_LOAD_TIME=$(( (BASHRC_END_TIME - BASHRC_START_TIME) / 1000000 ))
    echo "Bashrc loaded in ${BASHRC_LOAD_TIME}ms"
    unset BASHRC_START_TIME BASHRC_END_TIME BASHRC_LOAD_TIME
  fi
fi

