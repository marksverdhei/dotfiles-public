#!/bin/bash
# ~/.bashrc.d/init.sh
# Sources all bash configuration files in order.

# Only run for interactive shells
[[ $- != *i* ]] && return

# Omarchy's default aliases are sourced before us and collide with function
# names we define (an active alias mangles `name() {` into a parse error).
# Clear the known collisions before our files are parsed.
unalias cx t n 2>/dev/null

# Get the directory of this script. Use `builtin cd`, not `cd`: on boxes where
# an earlier rc has already aliased `cd` to a wrapper that prints to stdout
# (e.g. zoxide's `zd`, which emits a glyph), a plain `cd` here poisons the
# command substitution and BASHRC_DIR ends up as garbage — the glob then
# matches nothing and none of the dotfiles load. `builtin cd` bypasses the alias.
export BASHRC_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in "${BASHRC_DIR}"/[0-9][0-9]-*.sh; do
    [ -r "${file}" ] && source "${file}"
done

unset BASHRC_DIR file host_config
