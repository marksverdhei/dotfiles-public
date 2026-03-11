# Neovim Configuration

This Neovim configuration is based on [NvChad v2.5](https://github.com/NvChad/NvChad) with extensive customizations for enhanced productivity.

## Table of Contents
- [Basic Settings](#basic-settings)
- [Custom Keybindings](#custom-keybindings)
- [Plugins](#plugins)
- [Custom Commands](#custom-commands)
- [LSP Servers](#lsp-servers)
- [Autocommands](#autocommands)
- [Custom Snippets](#custom-snippets)
- [Theme Configuration](#theme-configuration)

## Basic Settings

### Leader Key
- **Leader**: `<Space>` (set in `init.lua:2`)

### Line Numbers
- **Absolute number** on current line
- **Relative numbers** on all other lines
- Enforced across all windows via autocmds

## Custom Keybindings

### General Navigation & Editing

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| Normal | `;` | `:` | Enter command mode |
| Insert | `jk` | `<ESC>` | Exit to normal mode |
| Normal | `<leader>tt` | `:terminal<CR>` | Open terminal |
| Normal | `gp` | `"_ddP` | Replace line with yanked content |
| Normal | `vv` | `V` | Start linewise visual mode |

### Terminal Mode

| Key | Action | Description |
|-----|--------|-------------|
| `<Esc>` | `<C-\><C-n>` | Exit terminal to normal mode |
| `<C-w>` | `<C-\><C-n><C-w>` | Enter window select mode from terminal |

### Tmux Integration (vim-tmux-navigator)

Navigation between Neovim and Tmux panes:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<C-h>` | Navigate left |
| Normal | `<C-l>` | Navigate right |
| Normal | `<C-j>` | Navigate down |
| Normal | `<C-k>` | Navigate up |
| Terminal | `<C-h>` | Navigate left |
| Terminal | `<C-l>` | Navigate right |
| Terminal | `<C-j>` | Navigate down |
| Terminal | `<C-k>` | Navigate up |

### Visual Mode Operations

| Mode | Key | Action | Description |
|------|-----|--------|-------------|
| Visual | `A` | `<ESC>GVgg` | Mark entire file |
| Visual | `yA` | `<ESC><cmd>%yank<CR>` | Yank entire file without moving cursor |
| Visual (x) | `<leader>s` | `:'<,'>sort<CR>` | Sort selected lines ascending |
| Visual (x) | `<leader>S` | `:'<,'>sort!<CR>` | Sort selected lines descending |

### Line Movement

Move lines up/down in any mode:

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<A-k>` | Move current line up |
| Normal | `<A-j>` | Move current line down |
| Insert | `<A-k>` | Move current line up |
| Insert | `<A-j>` | Move current line down |
| Visual | `<A-k>` | Move selection up |
| Visual | `<A-j>` | Move selection down |

### Markdown Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>c` | `:MdToggleCheckbox<CR>` | Toggle checkbox `[ ]` ↔ `[x]` |
| `<leader>ms` | `MdSortCheckboxes` | Sort checkboxes: unchecked up, checked down |

### Bash/Command Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ml` | `ToggleBashMultiline` | Collapse/expand bash multi-line commands |

### URL & HuggingFace Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>u` | `OpenNearestUrl` | Open URL under/nearest cursor in browser |
| `<leader>dh` | `OpenHuggingFaceRepo` | Open HuggingFace repo (owner/model) in browser |
| `<leader>da` | `OpenHuggingFaceDataset` | Open HuggingFace dataset (owner/dataset) in browser |

### AI/Copilot

| Key | Action | Description |
|-----|--------|-------------|
| `co` | `:CopilotChatOpen<CR>` | Open Copilot chat |

### Telescope

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>te` | `:Telescope<CR>` | Open Telescope |
| `<leader>tc` | `:Telescope keymaps<CR>` | Browse keymaps with Telescope |

### NvimTree

| Key | Action | Description |
|-----|--------|-------------|
| `<A-w>` | `ToggleNvimTreeWidth` | Toggle width (expand to fit longest name) |

### System Monitoring

| Key | Action | Description |
|-----|--------|-------------|
| `<A-n>` | `:ToggleNvtop<CR>` | Toggle nvtop panel (GPU monitoring) |

## Plugins

Custom plugins beyond the default NvChad setup:

### Formatting & Editing

**[conform.nvim](https://github.com/stevearc/conform.nvim)** - Code formatting
- Configured formatters:
  - Lua: `stylua`
- Location: `lua/configs/conform.lua`

**[nvim-surround](https://github.com/kylechui/nvim-surround)** - Add/change/delete surrounding delimiters
- Version: `^3.0.0`
- Custom surround for Python f-strings: `s=` → `f"{...=}"`
- Location: `lua/plugins/init.lua:8-27`

**[nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)** - Toggle between common values (true/false, etc.)
- Location: `lua/plugins/init.lua:40-45`

### Navigation

**[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)** - Seamless navigation between Tmux and Vim
- Loaded eagerly (`lazy = false`)
- Location: `lua/plugins/init.lua:36-38`

### AI Assistants

**[avante.nvim](https://github.com/yetone/avante.nvim)** - AI-powered coding assistant
- Provider: Claude (default), with OpenRouter support
- Model: `claude-sonnet-4.5`
- Build: `make` (compiled from source)
- Dependencies: treesitter, plenary, nui, img-clip, render-markdown
- Location: `lua/plugins/init.lua:47-116`

**[copilot.vim](https://github.com/github/copilot.vim)** - GitHub Copilot integration
- Installed via pack system: `pack/github/start/copilot.vim`

**[CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)** - Copilot chat interface
- Auto-completion disabled for `@` and `/` (set to empty string)
- Build: `make tiktoken`
- Location: `lua/plugins/copilot_chat.lua`

### LSP

**[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** - LSP configuration
- See [LSP Servers](#lsp-servers) section for enabled servers
- Location: `lua/configs/lspconfig.lua`

## Custom Commands

All custom user commands defined in `cmds.lua`:

| Command | Function | Description |
|---------|----------|-------------|
| `:Taken <key>` | `IsMapped` | Check if a key is mapped and in which mode |
| `:MdToggleCheckbox` | `MdToggleCheckbox` | Toggle markdown checkbox between `[ ]` and `[x]` |
| `:MdSortCheckboxes` | `MdSortCheckboxes` | Sort checkboxes in current block (unchecked first) |
| `:UcOpenNearestURL` | `OpenNearestUrl` | Open nearest URL in default browser |
| `:OpenHuggingFaceRepo` | `OpenHuggingFaceRepo` | Open HuggingFace model repo (owner/model format) |
| `:OpenHuggingFaceDataset` | `OpenHuggingFaceDataset` | Open HuggingFace dataset (owner/dataset format) |
| `:ToggleBashMultiline` | `ToggleBashMultiline` | Collapse/expand bash commands with line continuations |
| `:ToggleNvtop` | `ToggleNvtop` | Toggle nvtop monitoring panel in vertical split |
| `:ToggleNvimTreeWidth` | `ToggleNvimTreeWidth` | Toggle NvimTree between default and auto-fit width |

### Command Details

#### Markdown Commands
- **MdToggleCheckbox**: Toggles between `[ ]` and `[x]` on current line
- **MdSortCheckboxes**: Finds checkbox block around cursor and sorts (unchecked → checked)

#### URL/HuggingFace Commands
- **OpenNearestUrl**: Searches for URLs under cursor, then scans ±100 lines
- **OpenHuggingFaceRepo**: Searches for `owner/model` pattern, opens `https://huggingface.co/owner/model`
- **OpenHuggingFaceDataset**: Searches for `owner/dataset` pattern, opens `https://huggingface.co/datasets/owner/dataset`

#### Bash Command
- **ToggleBashMultiline**:
  - If collapsed: expands by adding `\` before each `-` or `--` flag
  - If expanded: collapses by removing all `\` and normalizing spaces

#### System Monitoring
- **ToggleNvtop**: Opens nvtop in 80-column vertical split on the right side

#### NvimTree
- **ToggleNvimTreeWidth**: Dynamically expands tree to fit longest filename, or resets to default (30 cols)

## LSP Servers

Configured LSP servers (`lua/configs/lspconfig.lua:3`):

- **html** - HTML language server
- **cssls** - CSS language server
- **pyright** - Python language server
- **marksman** - Markdown language server

## Autocommands

Custom autocommands defined in `autocmds.lua`:

### Auto-reload Mappings
```lua
BufWritePost lua/mappings.lua → reload mappings.lua
```
Automatically reloads keybindings when `mappings.lua` is saved.

### Terminal on Startup
```lua
VimEnter → open terminal if no file arguments
```
Opens a terminal automatically when Neovim is launched without files.

### Force Line Numbers
```lua
BufWinEnter, WinEnter, TermOpen → set number and relativenumber
```
Ensures absolute + relative line numbers are always on in all windows.

### Slurm File Detection
```lua
BufRead, BufNewFile *.slurm, *.sbatch, *sbatch* → setfiletype sh
```
Treats Slurm batch scripts as shell files for proper syntax highlighting.

## Custom Snippets

### Python Snippets

**Trigger**: `hfload`

Expands to HuggingFace model loading boilerplate:
```python
from transformers import AutoTokenizer, AutoModelForCausalLM

model_path = '|'
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForCausalLM.from_pretrained(model_path)
```

Location: `lua/snippets/python.lua`

## Theme Configuration

### Default Themes
- **Dark**: `catppuccin`
- **Light**: `github_light`

### Environment Variables
You can override themes using environment variables:
```bash
export NVIM_THEME="catppuccin"        # Primary theme
export NVIM_DARK_THEME="catppuccin"   # Dark theme for toggle
export NVIM_LIGHT_THEME="github_light" # Light theme for toggle
```

### Other Settings
- **NvDash**: Disabled on startup (`load_on_startup = false`)
- **Theme Toggle**: Switch between dark and light themes

Location: `lua/chadrc.lua`

## File Structure

```
nvim/
├── init.lua                 # Main entry point, lazy.nvim bootstrap
├── lazy-lock.json          # Plugin version lock file
├── lua/
│   ├── options.lua         # Custom options (snippet path)
│   ├── mappings.lua        # All custom keybindings
│   ├── cmds.lua            # Custom commands and functions
│   ├── autocmds.lua        # Custom autocommands
│   ├── chadrc.lua          # NvChad configuration (theme, etc.)
│   ├── configs/
│   │   ├── conform.lua     # Formatter configuration
│   │   ├── lspconfig.lua   # LSP server configuration
│   │   └── lazy.lua        # Lazy.nvim configuration
│   ├── plugins/
│   │   ├── init.lua        # Main plugin definitions
│   │   └── copilot_chat.lua # CopilotChat plugin config
│   └── snippets/
│       └── python.lua      # Python snippets (hfload)
└── pack/
    └── github/start/
        └── copilot.vim/    # GitHub Copilot
```

## Notes

- Configuration is built on **NvChad v2.5** as the base framework
- Uses **lazy.nvim** for plugin management
- Custom snippet path: `~/.config/nvim/lua/snippets`
- All customizations preserve NvChad defaults while adding enhancements
