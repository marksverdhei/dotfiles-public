# Initialize zoxide AFTER starship and other PROMPT_COMMAND modifiers
# to avoid zoxide doctor warnings about hook placement.
if cmd_exists zoxide; then
    eval "$(zoxide init bash)"
fi
