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
- `~/.config/starship.toml` is generated, not a symlink: `bootstrap/prompt.bash` renders
  `starship/starship.toml` (or the private base) with the machine accent as `session_bg`

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

## Look

The tmux theme (`bin/omarchy-tmux-theme`) and the Starship prompt
(`starship/starship.toml`) follow the HAIos design system
(`heiervang-technologies/design-system`): flat, rounded glass pills, one cyan
accent, and the host colour shown only as the hostname dot. They are the HAIos
default look. The prompt template is mirrored in hai-os
(`overlay/themes/gem/starship.toml`, `containers/haios/terminal/`) and in the
private base, so change them together.

## Contributing (agents)

Fleet agents work as the GitHub user `marksverdhai`, which has write access
to this repo:

```bash
git -C ~/dotfiles fetch origin
git -C ~/dotfiles worktree add ~/worktrees/<task> -b <branch> origin/main
# ... commit in ~/worktrees/<task> ...
git -C ~/worktrees/<task> push -u origin <branch>
gh pr create -R marksverdhei/dotfiles-public --head <branch>
# once peer-reviewed:
gh pr merge <n> -R marksverdhei/dotfiles-public --squash --delete-branch
```

Never edit or switch branches in `~/dotfiles` itself, because it is the live
config of the machine. If a push is denied (HTTP 403), the access was revoked
or the invitation was never accepted. Check it with
`gh api repos/marksverdhei/dotfiles-public --jq .permissions`. Pending
invitations are listed by `gh api user/repository_invitations`, and you
accept one with `gh api -X PATCH user/repository_invitations/<id>`. As a
fallback, push to the fork (`marksverdhai/dotfiles-public`) and open the PR
with `--head marksverdhai:<branch>`. The owner then has to merge it.
