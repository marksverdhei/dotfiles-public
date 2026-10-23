inject_bashrc() {
    local bashrc_init="$HOME/.bashrc.d/init.sh"
    local bashrc="$HOME/.bashrc"
    
    grep -q "\. $bashrc_init" "$bashrc" || {
        echo ". $bashrc_init" >> "$bashrc"
        echo "Added . $bashrc_init to the end of .bashrc"
    }
}

inject_zshrc() {
    local bashrc_init="$HOME/.bashrc.d/init.sh"
    local zshrc="$HOME/.zshrc"

    grep -q "\. $bashrc_init" "$zshrc" || {
        echo ". $bashrc_init" >> "$zshrc"
        echo "Added . $bashrc_init to the end of .zshrc"
    }
}

matches_any() {
    local target="$1"
    shift
    printf '%s\n' "$@" | grep -Fxq "$target"
}

_slink_count=0

slink() {
    local target="$1"
    local link_name="$2"

    # Refuse to create broken symlinks
    if [[ ! -e "$target" ]]; then
        warn "slink: target does not exist, skipping: $target"
        return 1
    fi

    mkdir -p "$(dirname "$link_name")"

    # Already correct: symlink pointing to the right place, or hardlink (same inode)
    if [[ -L "$link_name" && "$(readlink -f "$link_name")" == "$(readlink -f "$target")" ]]; then
        _slink_count=$((_slink_count + 1))
        return 0
    fi
    if [[ -f "$link_name" && ! -L "$link_name" && -f "$target" && ! -L "$target" ]]; then
        if [[ "$(stat -c %i "$link_name")" == "$(stat -c %i "$target")" ]]; then
            _slink_count=$((_slink_count + 1))
            return 0
        fi
    fi

    # Back up existing regular files/dirs (not symlinks) before overwriting
    if [[ -e "$link_name" && ! -L "$link_name" ]]; then
        local backup="${link_name}.bak.$(date +%s)"
        mv "$link_name" "$backup"
        warn "slink: backed up $link_name → $backup"
    fi

    ln -sfn "$target" "$link_name"
    _slink_count=$((_slink_count + 1))
}

slink_reset() { _slink_count=0; }

copy_root () {
    local source="$1"
    local dest="$2"
    sudo mkdir -p "$dest"
    sudo cp "$source" "$dest"
    sudo chown root:root "$dest"
    sudo chmod 644 "$dest"
}

# ── Jinja2 templating ─────────────────────────
# Echo an interpreter that can `import jinja2`, or return non-zero. Probes the
# active python3 first, then the system one — the active python3 may be a venv
# without system site-packages (where pacman installs python-jinja).
_jinja_python() {
    local py
    for py in python3 /usr/bin/python3; do
        command -v "$py" &>/dev/null || continue
        "$py" -c 'import jinja2' 2>/dev/null && { echo "$py"; return 0; }
    done
    return 1
}

# True if some Jinja2 renderer is reachable: the jinja2/j2 CLIs, or (the
# reliable path) the python jinja2 module itself.
have_jinja() {
    command -v jinja2 &>/dev/null && return 0
    command -v j2 &>/dev/null && return 0
    _jinja_python >/dev/null
}

# Make a Jinja2 renderer available. The python `jinja2` module (Arch:
# python-jinja, official repo — no AUR needed) is what render_template leans
# on; the standalone jinja2-cli / j2cli CLIs are optional niceties. Returns 0
# once any renderer is present.
ensure_jinja() {
    have_jinja && return 0
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm python-jinja &>/dev/null
    fi
    have_jinja
}

# render_template TEMPLATE OUTFILE [KEY=VALUE ...]
# Render a Jinja2 TEMPLATE to OUTFILE, exposing each KEY=VALUE as a context
# variable. Fallback chain, first that works wins:
#   1. jinja2-cli  (`jinja2 -D key=value ...`)
#   2. j2cli       (`j2`, vars via env)
#   3. python jinja2 module   (the engine; installed by ensure_jinja)
#   4. envsubst    (best-effort ${VAR} substitution when Jinja is absent)
render_template() {
    local tpl="$1" out="$2"; shift 2
    local -a kv=("$@") pair

    # 1) jinja2-cli
    if command -v jinja2 &>/dev/null; then
        local -a dargs=()
        for pair in "${kv[@]}"; do dargs+=(-D "$pair"); done
        jinja2 "${dargs[@]}" "$tpl" >"$out" 2>/dev/null && return 0
    fi

    # 2) j2cli (reads context from the environment)
    if command -v j2 &>/dev/null; then
        if ( for pair in "${kv[@]}"; do export "$pair"; done
             j2 --format=env "$tpl" ) >"$out" 2>/dev/null; then
            return 0
        fi
    fi

    # 3) python jinja2 module
    local py
    if py=$(_jinja_python); then
        "$py" - "$tpl" "${kv[@]}" >"$out" <<'PY'
import sys, jinja2
tpl = sys.argv[1]
ctx = dict(p.split("=", 1) for p in sys.argv[2:] if "=" in p)
with open(tpl) as f:
    src = f.read()
env = jinja2.Environment(keep_trailing_newline=True)
sys.stdout.write(env.from_string(src).render(**ctx))
PY
        return $?
    fi

    # 4) No Jinja at all — envsubst on ${VAR} style placeholders.
    ( for pair in "${kv[@]}"; do export "$pair"; done; envsubst <"$tpl" ) >"$out"
}
