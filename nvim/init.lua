vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.o.number = true -- absolute number on the current line
vim.o.relativenumber = true -- relative numbers on the others

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- When lazy.nvim installs a missing plugin at startup it uses the locked
-- commit, but then rewrites lazy-lock.json from *every* installed plugin. After
-- pulling a change that adds a plugin, that silently replaces the committed
-- pins with whatever older commits happen to be on disk. Snapshot the lockfile
-- here and put it back if startup changed it.
local lock_guard = require "configs.lock_guard"
local lock_snapshot = lock_guard.snapshot(lazy_config.lockfile)

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

lock_guard.restore_if_changed(lock_snapshot)

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
require("theme").setup()

vim.schedule(function()
  require "mappings"
end)
