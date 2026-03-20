unlink "$HOME/.config/kanata"

function slink() {

    local target="$1"
    local link_name="$2"

    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$link_name")"

    # Create the symlink
    ln -sf "$target" "$link_name"
}

sudo groupadd uinput
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"


function copy_root () {
    local source="$1"
    local dest="$2"
    sudo mkdir -p $(dirname "$dest")
    sudo cp "$source" "$dest"
    sudo chown root:root "$dest"
    sudo chmod 644 "$dest"
}

sudo udevadm control --reload-rules && sudo udevadm trigger
copy_root "$DOTFILES/kanata/99-input.rules" "/etc/udev/rules.d/99-input.rules"

slink "$DOTFILES/kanata" "$HOME/.config/kanata"
slink "$DOTFILES/kanata/kanata.service" "$HOME/.config/systemd/user/kanata.service"

systemctl --user daemon-reload
systemctl --user enable kanata.service
systemctl --user start kanata.service
systemctl --user status kanata.service --lines=0
