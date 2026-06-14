vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.o.number = true            -- absolute number on the current line
vim.o.relativenumber = true    -- relative numbers on the others

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- Restore the `all = false` treesitter shim that Neovim 0.12 dropped, so the
-- archived nvim-treesitter master branch stops crashing on list-form matches.
-- Must run before lazy loads nvim-treesitter (which registers the handlers).
require "configs.ts_compat"

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme (only if cache exists, otherwise base46 will compile on first load)
local base46_defaults = vim.g.base46_cache .. "defaults"
local base46_statusline = vim.g.base46_cache .. "statusline"
if vim.uv.fs_stat(base46_defaults) then
  dofile(base46_defaults)
  dofile(base46_statusline)
end

require "options"
require "autocmds"
require "cmds"

vim.schedule(function()
  require "mappings"
end)
