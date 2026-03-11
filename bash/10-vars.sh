for file in "${BASHRC_DIR}"/vars/*.sh; do
  [ -r "${file}" ] && source "${file}"
done
