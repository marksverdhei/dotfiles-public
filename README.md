# dotfiles

Public dotfiles with optional private extension. Designed for [Omarchy](https://github.com/nicholasgasior/omarchy) (Arch + Hyprland) but works on any Linux system.

## Quick Start

```bash
bash <(curl -sL https://raw.githubusercontent.com/marksverdhei/dotfiles-public/main/bootstrap.sh)
```

Or clone manually:

```bash
git clone https://github.com/marksverdhei/dotfiles-public ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

Use `--no-private` to skip cloning private dotfiles.

## Structure

```
dotfiles/
├── bash/           # Modular bash config (numbered loading)
│   ├── 00-pre.sh   # Early utilities (cmd_exists, is_light_preferred)
│   ├── 20-path.sh  # PATH setup
│   ├── 30-aliases.sh
│   ├── alias/      # Categorized aliases
│   ├── functions/  # Shell functions
│   └── vars/       # Environment variables
├── bin/            # Custom scripts (added to PATH)
├── hypr/           # Hyprland config (bindings, autostart, idle, lock)
├── nvim/           # Neovim config (NvChad)
├── ghostty/        # Ghostty terminal config
├── starship/       # Starship prompt config
├── tmux/           # tmux configs
├── keyd/           # Key remapping
├── bootstrap/      # Setup scripts
│   ├── main.bash   # Core bootstrap (shell, symlinks)
│   ├── prompt.bash # Starship prompt setup
│   ├── slinks.bash # Symlink definitions
│   ├── tools.bash  # Helper functions (slink, inject_bashrc)
│   └── ui.bash     # Bootstrap output formatting
└── private/        # Private dotfiles (separate repo, gitignored)
```

## Bootstrap Flow

1. `bootstrap.sh` sources helper functions
2. Pulls latest changes (if `gh` authenticated)
3. Clones/updates private dotfiles (unless `--no-private`)
4. Runs `bootstrap/main.bash` (symlinks, bashrc injection, starship)
5. Integrates private dotfiles if present (Hyprland, waybar, machine configs)

## Bash Loading Order

Files in `~/.bashrc.d/` load by numeric prefix:
- `00-*.sh` - Early setup (utilities)
- `05-*.sh` - Environment detection
- `10-*.sh` - Variables
- `20-*.sh` - PATH
- `30-*.sh` - Aliases
- `40-*.sh` - Functions
- `50-*.sh` - Tool initialization (zoxide, etc.)
- `55-*.sh` - Prompt (starship)
- `90-*.sh` - Private config
- `99-*.sh` - Cleanup

## Symlinks

Key symlinks created by bootstrap:
- `~/.bashrc.d` → `dotfiles/bash/`
- `~/.config/nvim` → `dotfiles/nvim/`
- `~/.config/ghostty` → `dotfiles/ghostty/`
- `~/.config/starship.toml` → per-host or default starship config

## Private Dotfiles

Private dotfiles extend public with:
- SSH and git config
- Machine-specific Hyprland configs (monitors, devices)
- Waybar configs
- Additional aliases, functions, and variables
- Voice/audio tool configs (ears, talking-stick)

## Omarchy

On Omarchy (Arch + Hyprland), the private bootstrap additionally:
- Symlinks Hyprland configs (bindings, autostart, input, idle, lock)
- Sets up machine-specific monitor and device configs
- Configures waybar (per-machine)
- Symlinks hyprshade screen filter shaders from the `aether` package
- Sets up vibe audio visualizer, ears ASR, and desktop apps

## Validation

Run `dotfiles-check` to validate installation (checks broken symlinks, missing deps).
