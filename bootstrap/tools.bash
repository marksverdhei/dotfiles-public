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
