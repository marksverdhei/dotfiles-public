require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("BufWritePost", {
  pattern = "lua/mappings.lua",
  callback = function()
    dofile(vim.fn.stdpath("config") .. "/lua/mappings.lua")
    vim.notify("Reloaded mappings.lua", vim.log.levels.INFO)
  end,
})
-- if Neovim was launched with no file arguments...
autocmd("VimEnter", {
  callback = function()
    require("base46").load_all_highlights()
    if vim.fn.argc() == 0 then
      vim.cmd("terminal")
    end
  end,
})

-- Always turn both options on whenever a window becomes current
autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

-- Auto-render ANSI escape codes when opening .ans files
autocmd("BufReadPost", {
  pattern = "*.ans",
  callback = function()
    vim.schedule(function()
      local ok = pcall(vim.cmd, "ToggleAnsi")
      if not ok then
        vim.notify("baleia.nvim not loaded yet — use :ToggleAnsi manually", vim.log.levels.WARN)
      end
    end)
  end,
})

-- Treat Slurm scripts as Bash/Shell files for syntax highlighting
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.slurm", "*.sbatch", "*sbatch*" },
  desc = "Set filetype to sh for Slurm files",
  command = "setfiletype sh",
})

-- Resize terminal windows to half the screen width when opened
-- Currently does not work as expected, commented out
-- augroup("Term50", { clear = true })
-- autocmd("TermOpen", {
--   group = "Term50",
--   callback = function()
--     if vim.bo.buftype == "terminal" then
--       local half = math.floor(vim.o.columns * 0.5)
--       vim.cmd("vertical resize " .. half)
--     end
--   end,
-- })
