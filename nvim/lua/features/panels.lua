-- Window/panel helpers: nvtop split, NvimTree width, workspace presets.
local M = {}

local nvtop_win = nil

function M.toggle_nvtop()
  if nvtop_win and vim.api.nvim_win_is_valid(nvtop_win) then
    vim.api.nvim_win_close(nvtop_win, true)
    nvtop_win = nil
    return
  end

  -- Open nvtop in an 80-column split on the far right
  vim.cmd "vsplit"
  vim.cmd "wincmd L"
  vim.cmd "vertical resize 80"
  vim.cmd "terminal nvtop"

  nvtop_win = vim.api.nvim_get_current_win()
  -- Make buffer ephemeral (deleted when window closes)
  vim.bo.bufhidden = "wipe"

  vim.cmd "wincmd p"
end

local nvimtree_expanded = false
local default_width = 30

function M.toggle_nvimtree_width()
  local api = require "nvim-tree.api"
  local view = require "nvim-tree.view"
  if not view.is_visible() then
    vim.notify("NvimTree is not open", vim.log.levels.WARN)
    return
  end

  if nvimtree_expanded then
    api.tree.resize { absolute = default_width }
    nvimtree_expanded = false
    vim.notify("NvimTree: Reset to default width", vim.log.levels.INFO)
    return
  end

  -- Expand to fit longest line
  local bufnr = view.get_bufnr()
  if not bufnr then
    return
  end

  local max_len = default_width
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    max_len = math.max(max_len, vim.fn.strdisplaywidth(line))
  end

  local new_width = max_len + 2
  api.tree.resize { absolute = new_width }
  nvimtree_expanded = true
  vim.notify("NvimTree: Expanded to " .. new_width, vim.log.levels.INFO)
end

-- Workspace preset: File tree + terminal with lumi
function M.workspace_lumi()
  vim.cmd "NvimTreeOpen"
  vim.cmd "vsplit"
  vim.cmd "terminal"
  vim.api.nvim_chan_send(vim.bo.channel, "lumi\n")
  vim.cmd "wincmd h"
end

return M
