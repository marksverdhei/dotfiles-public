shopt -s expand_aliases

for file in "${BASHRC_DIR}"/alias/*.sh; do
    [ -r "${file}" ] && source "${file}"
done
