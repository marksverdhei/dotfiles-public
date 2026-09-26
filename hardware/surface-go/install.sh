#!/bin/bash
# Install the system portion only; see README.md for per-user configuration.
set -euo pipefail

if (( EUID != 0 )); then
    echo "Run with sudo: sudo bash hardware/surface-go/install.sh" >&2
    exit 1
fi
if [[ $(cat /sys/class/dmi/id/product_name) != 'Surface Go 2' ]]; then
    echo "This workaround has only been checked on a Surface Go 2; refusing installation." >&2
    exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
hook=/usr/lib/systemd/system-sleep/surface-go-type-cover
bash -n "$source_dir/surface-go-type-cover"
backup=$(mktemp -d /var/lib/surface-go-suspend-backup.XXXXXX)
if [[ -e "$hook" || -L "$hook" ]]; then
    cp -a -- "$hook" "$backup/surface-go-type-cover"
fi
systemctl show sleep.target suspend.target -p Id -p LoadState -p UnitFileState > "$backup/units-before.txt"
printf 'Backup and previous unit state: %s\n' "$backup"

install -d -m 0755 /usr/lib/systemd/system-sleep
install -o root -g root -m 0755 -- "$source_dir/surface-go-type-cover" "$hook"
systemctl unmask sleep.target suspend.target
echo "System hook installed. Follow README.md to enable the per-user configs."
