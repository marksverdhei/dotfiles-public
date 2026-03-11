
for file in "${BASHRC_DIR}"/functions/*.sh; do
    [ -r "${file}" ] && source "${file}"
done
