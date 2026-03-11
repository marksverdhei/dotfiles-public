#!/bin/bash
# ~/.bashrc.d/init.sh
# Sources all bash configuration files in order.

# Only run for interactive shells
[[ $- != *i* ]] && return

# Get the directory of this script
export BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in "${BASHRC_DIR}"/[0-9][0-9]-*.sh; do
    [ -r "${file}" ] && source "${file}"
done

unset BASHRC_DIR file host_config
