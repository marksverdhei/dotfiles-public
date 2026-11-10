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
- **Leader**: `<Space>` (set in `init.lua`)

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
| Normal | `<leader>V` | `ggVG` | Select entire file |
| Normal | `<leader>Y` | `:%yank` | Yank entire file without moving cursor |

### Terminal Mode

| Key | Action | Description |
|-----|--------|-------------|
| `<C-x>` | `<C-\><C-n>` | Exit terminal to normal mode (NvChad default) |

`<Esc>` and `<C-w>` are not mapped, so TUIs get Esc without delay and the shell keeps delete-word.

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
| Visual (x) | `<leader>s` | `:'<,'>sort<CR>` | Sort selected lines ascending |
| Visual (x) | `<leader>S` | `:'<,'>sort!<CR>` | Sort selected lines descending |

### Line Movement

Move lines up/down (normal mode accepts a count, e.g. `3<A-j>`):

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<A-k>` | Move current line up |
| Normal | `<A-j>` | Move current line down |
| Insert | `<A-k>` | Move current line up |
| Insert | `<A-j>` | Move current line down |
| Visual | `<A-k>` | Move selection up |
| Visual | `<A-j>` | Move selection down |

### Markdown Utilities

Only defined in markdown buffers.

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>mc` | `md_toggle_checkbox` | Toggle checkbox `[ ]` ↔ `[x]` |
| `<leader>ms` | `md_sort_checkboxes` | Sort checkboxes: unchecked up, checked down |

### Bash/Command Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ml` | `toggle_bash_multiline` | Collapse/expand bash multi-line commands |

### Debugging (nvim-dap)

| Key | Action |
|-----|--------|
| `<F5>` | Continue / start |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>dr` | Open REPL |
| `<leader>dq` | Terminate |

### Which-key groups

`<leader>a` AI (Avante), `<leader>d` debug / data / diagnostics, `<leader>m` markdown / shell,
`<leader>s` toggles (secrets, ANSI), `<leader>t` terminal / theme / telescope.

### URL & HuggingFace Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>u` | `open_nearest_url` | Open URL under/nearest cursor in browser |
| `<leader>dh` | `open_hf_repo` | Open HuggingFace repo (owner/model) in browser |
| `<leader>da` | `open_hf_dataset` | Open HuggingFace dataset (owner/dataset) in browser |

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
| `<A-w>` | `toggle_nvimtree_width` | Toggle width (expand to fit longest name) |

### System Monitoring

| Key | Action | Description |
|-----|--------|-------------|
| `<A-n>` | `:ToggleNvtop<CR>` | Toggle nvtop panel (GPU monitoring) |

## Plugins

Custom plugins beyond the default NvChad setup:

### Formatting & Editing

**[conform.nvim](https://github.com/stevearc/conform.nvim)** - Code formatting
- Configured formatters (installed automatically, see [Tooling](#tooling); missing ones are skipped quietly):
  - Lua: `stylua`
  - Python: `ruff_organize_imports`, `ruff_format`
  - Shell: `shfmt`
- Format on save is on; `:FormatToggle` toggles it globally, `:FormatToggle!` for the current buffer
- Location: `lua/configs/conform.lua`

**[nvim-surround](https://github.com/kylechui/nvim-surround)** - Add/change/delete surrounding delimiters
- Version: `^3.0.0`
- Custom surround for Python f-strings: `s=` → `f"{...=}"`
- Location: `lua/plugins/init.lua`

**[nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)** - Toggle between common values (true/false, etc.)
- Location: `lua/plugins/init.lua`

### Navigation

**[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)** - Seamless navigation between Tmux and Vim
- Loaded eagerly (`lazy = false`)
- Location: `lua/plugins/init.lua`

### AI Assistants

**[avante.nvim](https://github.com/yetone/avante.nvim)** - AI-powered coding assistant
- Provider: OpenRouter (`:OpenRouterModels` to switch model)
- Model: `anthropic/claude-sonnet-5.5`
- Build: `make` (compiled from source)
- Dependencies: treesitter, plenary, nui, telescope, nvim-cmp, dressing, img-clip, render-markdown
- Location: `lua/plugins/init.lua`

### Tooling

**[mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)** - Installs the toolchain through Mason on startup:
lua-language-server, pyright, ruff, bash-language-server, marksman, stylua, shfmt, shellcheck, debugpy.
- `:MasonToolsUpdate` updates them; a fresh machine only needs `node`/`npm` (for pyright and bash-language-server) and the `tree-sitter` CLI (for parsers)

**[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** (`main` branch) - Parser installer. Highlighting is started per buffer by NvChad (`vim.treesitter.start`).
- Extra parsers: python, bash, markdown, markdown_inline, json, yaml, toml

**[lazydev.nvim](https://github.com/folke/lazydev.nvim)** - Makes lua_ls aware of the Neovim API, plugins and this config's modules (also a completion source)

**[nvim-dap](https://github.com/mfussenegger/nvim-dap)** + **[nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)** - Python debugging with Mason's `debugpy`
- Commands: `:DapToggleBreakpoint`, `:DapContinue`, `:DapNew`, `:DapToggleRepl`; keys under [Debugging](#debugging-nvim-dap)

### LSP

**[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** - LSP configuration
- See [LSP Servers](#lsp-servers) section for enabled servers
- Location: `lua/configs/lspconfig.lua`

## Custom Commands

All custom user commands defined in `cmds.lua` (functions live on the module returned by `require "cmds"`):

| Command | Function | Description |
|---------|----------|-------------|
| `:Taken <key>` | `is_mapped` | Check if a key is mapped and in which mode |
| `:MdToggleCheckbox` | `md_toggle_checkbox` | Toggle markdown checkbox between `[ ]` and `[x]` |
| `:MdSortCheckboxes` | `md_sort_checkboxes` | Sort checkboxes in current block (unchecked first) |
| `:UcOpenNearestURL` | `open_nearest_url` | Open nearest URL in default browser |
| `:OpenHuggingFaceRepo` | `open_hf_repo` | Open HuggingFace model repo (owner/model format) |
| `:OpenHuggingFaceDataset` | `open_hf_dataset` | Open HuggingFace dataset (owner/dataset format) |
| `:ToggleBashMultiline` | `toggle_bash_multiline` | Collapse/expand bash commands with line continuations |
| `:ToggleNvtop` | `toggle_nvtop` | Toggle nvtop monitoring panel in vertical split |
| `:ToggleNvimTreeWidth` | `toggle_nvimtree_width` | Toggle NvimTree between default and auto-fit width |
| `:WorkspaceLumi` | `workspace_lumi` | Open workspace preset: file tree + terminal with lumi |
| `:ToggleAnsi` | `toggle_ansi` | Toggle ANSI escape code color rendering |
| `:FormatToggle[!]` | (`configs/conform.lua`) | Toggle format on save (`!` = current buffer) |

### Command Details

#### Markdown Commands
- **MdToggleCheckbox**: Toggles between `[ ]` and `[x]` on current line
- **MdSortCheckboxes**: Finds checkbox block around cursor and sorts (unchecked → checked)

#### URL/HuggingFace Commands
- **OpenNearestUrl**: Searches for URLs under cursor, then scans ±100 lines
- **OpenHuggingFaceRepo**: Searches for a bare `owner/model` id (paths like `lua/foo.lua` and URLs are ignored), opens `https://huggingface.co/owner/model`
- **OpenHuggingFaceDataset**: Searches for `owner/dataset` pattern, opens `https://huggingface.co/datasets/owner/dataset`

#### Bash Command
- **ToggleBashMultiline**:
  - If collapsed: expands by adding `\` before each `-` or `--` flag
  - If expanded: collapses by removing all `\` and normalizing spaces

#### System Monitoring
- **ToggleNvtop**: Opens nvtop in 80-column vertical split on the right side

#### NvimTree
- **ToggleNvimTreeWidth**: Dynamically expands tree to fit longest filename, or resets to default (30 cols)

#### Workspace Preset
- **WorkspaceLumi**: Opens NvimTree file tree and a vertical split terminal running the `lumi` command

#### ANSI Renderer
- **ToggleAnsi**: Strips ANSI escape codes from the current buffer and applies color extmarks to render pixel art. The rendered buffer is read-only so a stray `:w` can't overwrite the original escape codes; toggling off reloads the file from disk. `*.ans` files render automatically on open.

## LSP Servers

Configured LSP servers (`lua/configs/lspconfig.lua`, plus `lua_ls` from NvChad):

- **html** - HTML language server
- **cssls** - CSS language server
- **pyright** - Python language server
- **marksman** - Markdown language server
- **ruff** - Python linter/formatter language server
- **bashls** - Bash language server

Each server is enabled only when its binary is on `$PATH`.

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
Ensures absolute + relative line numbers are on in normal and terminal windows (floats and special buffers like NvimTree/Telescope are left alone).

### Slurm File Detection
```lua
vim.filetype.add: *.slurm, *.sbatch, and other files with "sbatch" in the name → sh
```
The name pattern has lowest priority, so e.g. `sbatch_utils.py` is still Python.
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
- **Dark**: `hei`
- **Mid**: `github_mid`
- **Light**: `github_light`

### Environment Variables
You can override themes using environment variables:
```bash
export NVIM_THEME="hei"               # Primary theme
export NVIM_DARK_THEME="hei"          # Dark theme for toggle
export NVIM_MID_THEME="github_mid"     # Mid theme for the three-way cycle
export NVIM_LIGHT_THEME="github_light" # Light theme for toggle
export NVIM_APPEARANCE="mid"           # Select dark, mid, or light at startup
```

### Mid themes

Every Base46 family in this install that has both a dark and light palette also
has a readable middle-luminance variant: Ayu, Catppuccin, Default, Everforest,
Flex/Flexoki, GitHub, Gruvbox, Material, Oceanic, One, OneNord, Penumbra,
Rose Pine, Seoul256, Solarized, and VS Code.

Use `:ThemeMid` to move the current family to its mid variant, or pass a family
such as `:ThemeMid gruvbox`. `:ThemeCycle` and `<leader>ty` cycle the configured
dark, mid, and light defaults. `<leader>tm` applies the current family's mid.

### HEI and HAI

- `:Hei` selects the old-notebook palette: dim beige paper with warm brown
  surrounding chrome.
- `:HAI` selects cool chrome/grey with bright electric-blue default text.
- `:Theme <name>` selects any Base46 or custom theme for the current session.

Set `NVIM_THEME=hei` or `NVIM_THEME=hai` to start in either custom theme.

### Other Settings
- **NvDash**: Disabled on startup (`load_on_startup = false`)
- **Theme Toggle**: Base46's button switches dark/light; `:ThemeCycle` includes mid

Location: `lua/_chadrc.lua` (copied to `lua/chadrc.lua` by bootstrap)

## File Structure

```
nvim/
├── init.lua                 # Main entry point, lazy.nvim bootstrap
├── lazy-lock.json          # Plugin version lock file
├── lua/
│   ├── options.lua         # Custom options (snippet path)
│   ├── mappings.lua        # All custom keybindings
│   ├── cmds.lua            # User command registration
│   ├── features/           # Command implementations (openers, markdown, shell, ansi, panels)
│   ├── autocmds.lua        # Custom autocommands
│   ├── _chadrc.lua         # NvChad config template (bootstrap copies it to chadrc.lua, which is gitignored)
│   ├── configs/
│   │   ├── conform.lua     # Formatter configuration
│   │   ├── lspconfig.lua   # LSP server configuration
│   │   ├── openrouter.lua  # OpenRouter model picker for Avante
│   │   └── lazy.lua        # Lazy.nvim configuration
│   ├── plugins/
│   │   └── init.lua        # Plugin definitions
│   ├── theme/              # :Theme/:ThemeMid/:ThemeCycle and mid-theme blending
│   ├── themes/             # Custom base46 themes (hei, hai, *_mid)
│   └── snippets/
│       └── python.lua      # Python snippets (hfload)
├── tests/run.lua           # Unit tests for features/ and theme/
├── .stylua.toml, selene.toml, vim.yml  # Formatter / linter config
└── pack/                   # Optional hand-installed plugins (gitignored)
```

## Development

```sh
cd nvim
stylua --check .        # formatting
selene .                # lint
nvim -l tests/run.lua   # unit tests
```

CI for these checks lives in `.github/workflows/nvim.yml` (added separately; pushing workflow files needs the `workflow` token scope).

## Notes

- Configuration is built on **NvChad v2.5** as the base framework
- Uses **lazy.nvim** for plugin management
- Custom snippet path: `~/.config/nvim/lua/snippets`
- All customizations preserve NvChad defaults while adding enhancements
