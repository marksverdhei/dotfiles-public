require "nvchad.mappings"

local map = vim.keymap.set
local cmds = require "cmds"

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
-- Deliberately shadows the built-in `gp` (put, cursor after), which is rarely used.
map("n", "gp", '"_ddP', { desc = "Replace line with yanked content" })

-- Whole file. Normal-mode only: a visual-mode `A` would shadow visual-block
-- append, and a visual `yA` makes every visual `y` wait for 'timeoutlen'.
-- (NvChad's <C-c> already copies the whole file to the system clipboard.)
map("n", "<leader>V", "ggVG", { desc = "Select entire file" })
map("n", "<leader>Y", "<cmd>%yank<CR>", { desc = "Yank entire file without moving the cursor" })

-- Terminal
map("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open Terminal" })
-- Leave terminal mode with NvChad's <C-x>. <Esc> is not mapped at all, so TUIs
-- (fzf, lazygit, nvtop, shell vi-mode) get it with no 'timeoutlen' delay, and
-- <C-w> stays the shell's delete-word. <C-h/j/k/l> move between windows.

-- Themes
map("n", "<leader>tm", "<cmd>ThemeMid<CR>", { desc = "Use current theme family's mid variant" })
map("n", "<leader>ty", "<cmd>ThemeCycle<CR>", { desc = "Cycle dark, mid, and light themes" })

-- Window / tmux navigation
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Window Left" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window Right" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Window Down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Window Up" })
map("t", "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<CR>", { desc = "Window Left" })
map("t", "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<CR>", { desc = "Window Right" })
map("t", "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<CR>", { desc = "Window Down" })
map("t", "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<CR>", { desc = "Window Up" })

-- Panels
map("n", "<A-n>", "<cmd>ToggleNvtop<CR>", { desc = "Toggle nvtop panel" })
map("n", "<A-w>", cmds.toggle_nvimtree_width, { desc = "Toggle NvimTree width (expand to fit longest name)" })

-- Move lines (count-aware: 3<A-j> moves three lines down)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc><cmd>move .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc><cmd>move .-2<CR>==gi", { desc = "Move line up" })
map("x", "<A-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("x", "<A-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

-- Sort selection
map("x", "<leader>s", ":sort<CR>", { silent = true, desc = "Sort selected lines" })
map("x", "<leader>S", ":sort!<CR>", { silent = true, desc = "Sort selected lines (desc)" })

-- Markdown / shell helpers (<leader>m group; NvChad owns <leader>ch, <leader>cm).
-- Checkbox maps only exist in markdown buffers; the multiline toggle is global
-- because commands also live in notes and code blocks.
local function markdown_maps(buf)
  map("n", "<leader>mc", cmds.md_toggle_checkbox, { buffer = buf, desc = "Toggle markdown checkbox" })
  map(
    "n",
    "<leader>ms",
    cmds.md_sort_checkboxes,
    { buffer = buf, desc = "Sort markdown checkboxes: unchecked up, checked down" }
  )
end
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownMaps", { clear = true }),
  pattern = "markdown",
  callback = function(args)
    markdown_maps(args.buf)
  end,
})
-- This file is loaded via vim.schedule, after FileType already fired for any
-- file given on the command line.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[buf].filetype == "markdown" then
    markdown_maps(buf)
  end
end
map("n", "<leader>ml", cmds.toggle_bash_multiline, { desc = "Collapse or expand bash multi-line" })

-- Openers
map("n", "<leader>u", cmds.open_nearest_url, { desc = "Open URL under or nearest cursor in browser" })
map("n", "<leader>dh", cmds.open_hf_repo, { desc = "Open Hugging Face repo (owner/model) in browser" })
map("n", "<leader>da", cmds.open_hf_dataset, { desc = "Open Hugging Face dataset (owner/dataset) in browser" })

-- Telescope
map("n", "<leader>te", "<cmd>Telescope<CR>", { desc = "Telescope pickers" })
map("n", "<leader>tc", "<cmd>Telescope keymaps<CR>", { desc = "Telescope keymaps" })

-- Avante AI
map({ "n", "x" }, "<leader>aa", "<cmd>AvanteAsk<CR>", { desc = "Avante: Ask" })
map({ "n", "x" }, "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Avante: Edit" })
map("n", "<leader>ac", "<cmd>AvanteChat<CR>", { desc = "Avante: Chat" })
map("n", "<leader>at", "<cmd>AvanteToggle<CR>", { desc = "Avante: Toggle" })
map("n", "<leader>am", "<cmd>OpenRouterModels<CR>", { desc = "Avante: Pick OpenRouter Model" })
map("n", "<leader>aM", "<cmd>OpenRouterModels refresh<CR>", { desc = "Avante: Pick Model (refresh cache)" })
map("n", "<leader>ar", "<cmd>AvanteRefresh<CR>", { desc = "Avante: Refresh" })
map("n", "<leader>ah", "<cmd>AvanteHistory<CR>", { desc = "Avante: History" })

map("n", "<leader>sa", "<cmd>ToggleAnsi<CR>", { desc = "Toggle ANSI rendering" })

-- Debugging (nvim-dap loads on first use)
local function dap(fn)
  return function()
    require("dap")[fn]()
  end
end
map("n", "<F5>", dap "continue", { desc = "Debug: Continue / start" })
map("n", "<F10>", dap "step_over", { desc = "Debug: Step over" })
map("n", "<F11>", dap "step_into", { desc = "Debug: Step into" })
map("n", "<F12>", dap "step_out", { desc = "Debug: Step out" })
map("n", "<leader>db", dap "toggle_breakpoint", { desc = "Debug: Toggle breakpoint" })
map("n", "<leader>dr", dap "repl_open", { desc = "Debug: Open REPL" })
map("n", "<leader>dq", dap "terminate", { desc = "Debug: Terminate" })
