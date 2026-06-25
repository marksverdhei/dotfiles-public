# CLAUDE.md — dotfiles

Public dotfiles with optional private extension.

## Validation & Linting

```bash
# Validate dotfiles installation (broken symlinks, missing directories/commands)
bin/dotfiles-check
```

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
└── private/        # Private dotfiles (separate repo, gitignored)
```

## Conventions

- **No Co-Authored-By: Claude on commits.** Hook at `.git/hooks/commit-msg` strips them automatically.
- **Squash-merge PRs** (preferred merge strategy).
- Use `bootstrap.sh` to install/setup public/private dotfiles.
- Files in `~/.bashrc.d/` load by numeric prefix (e.g., `00-*.sh` for pre-setup, `30-*.sh` for aliases).
