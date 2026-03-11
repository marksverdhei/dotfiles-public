require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open Terminal" })
map("n", "<A-n>", "<cmd>ToggleNvtop<CR>", { desc = "Toggle nvtop panel" })
map("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "Window Left" })
map("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "Window Right" })
map("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "Window Down" })
map("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "Window Up" })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal to Normal" })
map("t", "<C-w>", "<C-\\><C-n><C-w>", { desc = "Enter window select mode from Terminal" })

map("t", "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<CR>", { desc = "Window Left" })
map("t", "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<CR>", { desc = "Window Right" })
map("t", "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<CR>", { desc = "Window Down" })
map("t", "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<CR>", { desc = "Window Up" })

map('v', 'A', '<ESC>GVgg', { desc = 'Mark entire file'})
map('v', 'yA', '<ESC><cmd>%yank<CR>', { desc = 'Yank entire file without moving the cursor.' })

map('n', 'gp', '"_ddP', { desc = 'Replace line with yanked content' })

map("n", "co", "<cmd>CopilotChatOpen<CR>", { desc = "Open copilot chat" })

map('n', 'vv', 'V', { desc = 'Start linewise visual mode' })

map('n', '<leader>c', ':MdToggleCheckbox<CR>', { noremap = true, silent = true })

map("n", "<leader>u", OpenNearestUrl, {
  noremap = true,
  silent = true,
  desc = "Open URL under or nearest cursor in default browser",
})

map("n", "<leader>dh", OpenHuggingFaceRepo, {
  noremap = true,
  silent = true,
  desc = "Open Hugging Face repo (owner/model) in browser",
})

map("n", "<leader>da", OpenHuggingFaceDataset, {
  noremap = true,
  silent = true,
  desc = "Open Hugging Face dataset (owner/dataset) in browser",
})

map('n', '<leader>ms', MdSortCheckboxes, { noremap = true, silent = true, desc = "Sort markdown checkboxes: unchecked up, checked down" })
map('n', '<leader>ml', ToggleBashMultiline, { silent = true, desc = "Collapse or expand bash multi-line." })

-- Move current line
map("n", "<A-k>", ":m .-2<CR>==", { silent = true })
map("n", "<A-j>", ":m .+1<CR>==", { silent = true })

-- Move while typing
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { silent = true })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { silent = true })

-- Move a visual selection
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- Visual-mode (any Visual type)
map('x', '<leader>s', ":'<,'>sort<CR>",  { desc = 'Sort selected lines' })
map('x', '<leader>S', ":'<,'>sort!<CR>", { desc = 'Sort selected lines (desc)' })

map("n", "<leader>te", ":Telescope<CR>", { desc = 'Open telescope'})
map("n", "<leader>tc", ":Telescope keymaps<CR>", { desc = 'Open telescope'})

map("n", "<A-w>", ToggleNvimTreeWidth, { desc = 'Toggle NvimTree width (expand to fit longest name)' })

-- Avante AI keybindings
map("n", "<leader>aa", "<cmd>AvanteAsk<CR>", { desc = "Avante: Ask" })
map("v", "<leader>aa", "<cmd>AvanteAsk<CR>", { desc = "Avante: Ask (selection)" })
map("n", "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Avante: Edit" })
map("v", "<leader>ae", "<cmd>AvanteEdit<CR>", { desc = "Avante: Edit (selection)" })
map("n", "<leader>ac", "<cmd>AvanteChat<CR>", { desc = "Avante: Chat" })
map("n", "<leader>at", "<cmd>AvanteToggle<CR>", { desc = "Avante: Toggle" })
map("n", "<leader>am", "<cmd>OpenRouterModels<CR>", { desc = "Avante: Pick OpenRouter Model" })
map("n", "<leader>aM", "<cmd>OpenRouterModels refresh<CR>", { desc = "Avante: Pick Model (refresh cache)" })
map("n", "<leader>ar", "<cmd>AvanteRefresh<CR>", { desc = "Avante: Refresh" })
map("n", "<leader>ah", "<cmd>AvanteHistory<CR>", { desc = "Avante: History" })

map("n", "<leader>sa", "<cmd>ToggleAnsi<CR>", { desc = "Toggle ANSI rendering" })
