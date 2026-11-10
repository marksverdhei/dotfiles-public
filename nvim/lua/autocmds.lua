require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePost", {
  pattern = "lua/mappings.lua",
  callback = function()
    dofile(vim.fn.stdpath "config" .. "/lua/mappings.lua")
    vim.notify("Reloaded mappings.lua", vim.log.levels.INFO)
  end,
})
autocmd("VimEnter", {
  callback = function()
    -- Load every base46 integration (tabufline, nvim-tree, cmp, treesitter, ...).
    -- init.lua only loads `defaults` and `statusline`; without this, those
    -- groups stay empty until a theme switch.
    require("base46").load_all_highlights()
    -- if Neovim was launched with no file arguments...
    if vim.fn.argc() == 0 then
      vim.cmd "terminal"
    end
  end,
})

-- Always turn both options on whenever a window becomes current
autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
  callback = function()
    -- Skip floats and special buffers (NvimTree, Telescope, help, ...)
    local bt = vim.bo.buftype
    if vim.api.nvim_win_get_config(0).relative ~= "" or (bt ~= "" and bt ~= "terminal") then
      return
    end
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

-- Auto-render ANSI escape codes when opening .ans files
autocmd("BufReadPost", {
  pattern = "*.ans",
  callback = function(args)
    -- Respect a manual :ToggleAnsi off (which reloads the file and lands here)
    if vim.b[args.buf].ansi_raw then
      return
    end
    vim.schedule(function()
      require("cmds").toggle_ansi()
    end)
  end,
})

-- Treat Slurm scripts as Bash/Shell files for syntax highlighting.
-- The pattern runs after extension matching, so e.g. sbatch_utils.py stays Python.
vim.filetype.add {
  extension = { slurm = "sh", sbatch = "sh" },
  pattern = { [".*/[^/]*sbatch[^/]*"] = { "sh", { priority = -math.huge } } },
}
