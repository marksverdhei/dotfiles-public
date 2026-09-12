#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/home/.local/share/omarchy/bin"
cat > "$T/bin/haios-workspace-scenes" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" > "$ROUTE_LOG"
STUB
cat > "$T/home/.local/share/omarchy/bin/omarchy" <<'STUB'
#!/bin/bash
printf '%s\n' "${OMARCHY_THEME_SKIP_BACKGROUND:-unset}:$*" > "$ROUTE_LOG"
STUB
cp "$T/home/.local/share/omarchy/bin/omarchy" "$T/home/.local/share/omarchy/bin/omarchy-theme-set"
chmod +x "$T/bin/haios-workspace-scenes" "$T/home/.local/share/omarchy/bin/"*
export ROUTE_LOG="$T/log"
export PATH="$T/bin:$ROOT/bin:/usr/bin:/bin"
HOME="$T/home" "$ROOT/bin/omarchy" theme bg set '/a path/movie.mp4'
[[ $(cat "$ROUTE_LOG") == 'set-active /a path/movie.mp4' ]]
HOME="$T/home" "$ROOT/bin/omarchy" theme set 'Tokyo Night'
[[ $(cat "$ROUTE_LOG") == '1:theme set Tokyo Night' ]]
HOME="$T/home" "$ROOT/bin/omarchy-theme-set" 'Tokyo Night'
[[ $(cat "$ROUTE_LOG") == '1:Tokyo Night' ]]
HOME="$T/home" "$ROOT/bin/omarchy" version
[[ $(cat "$ROUTE_LOG") == 'unset:version' ]]
echo 'PASS: wallpaper routing, both theme forms, and unrelated command delegation'
