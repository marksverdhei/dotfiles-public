# dotfiles

Public dotfiles with optional private extension.

## Quick Start

```bash
git clone https://github.com/marksverdhei/dotfiles-public ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh
```

## Structure

```
dotfiles/
├── bash/           # Modular bash config (numbered loading)
│   ├── 00-pre.sh   # Early utilities (cmd_exists, is_light_preferred)
│   ├── 20-path.sh  # PATH setup
│   ├── 30-aliases.sh
│   ├── alias/      # Categorized aliases
│   └── functions/  # Shell functions
├── nvim/           # Neovim config
├── ghostty/        # Ghostty terminal config
├── omp/            # Oh My Posh prompt
├── bootstrap/      # Setup scripts
│   ├── main.bash
│   ├── slinks.bash # Symlink definitions
│   └── tools.bash  # Helper functions
└── private/        # Private dotfiles (separate repo)
```

## Bootstrap Flow

1. `bootstrap.sh` sources helper functions
2. Pulls latest changes (if `gh` authenticated)
3. Clones/updates private dotfiles
4. Runs `bootstrap/main.bash` (symlinks, bashrc injection)
5. Integrates private dotfiles if present

## Bash Loading Order

Files in `~/.bashrc.d/` load by numeric prefix:
- `00-*.sh` - Early setup (utilities)
- `10-*.sh` - Variables
- `20-*.sh` - PATH
- `30-*.sh` - Aliases
- `40-*.sh` - Functions
- `50-*.sh` - Tool initialization
- `90-*.sh` - Private config
- `99-*.sh` - Cleanup

## Symlinks

Key symlinks created by bootstrap:
- `~/.bashrc.d` → `dotfiles/bash/`
- `~/.config/nvim` → `dotfiles/nvim/`
- `~/.config/ghostty` → `dotfiles/ghostty/`

## Private Dotfiles

Private dotfiles extend public with:
- SSH config
- Git credentials
- Host-specific settings
- Additional aliases/functions

Set `LINK_CLAUDE=true` before bootstrap to link Claude config.

## Validation

Run `dotfiles-check` to validate installation (checks broken symlinks, missing deps).

## Host-Specific Config

Different configs load based on `$HOSTNAME`:
- tmux config selection in `private/bootstrap.sh`
- OMP prompt generated per-host

## Omarchy

On Omarchy (Arch + Hyprland), the bootstrap automatically:
- Comments out `source ~/.local/share/omarchy/default/bash/rc` in `~/.bashrc` to avoid conflicts
- Links `~/.bashrc.d` and injects the dotfiles init, same as other systems
