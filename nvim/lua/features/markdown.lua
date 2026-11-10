-- Markdown checkbox helpers.
local M = {}

local function is_checkbox(line)
  return line ~= nil and line:match "^%s*[-*]?%s*%[.%]" ~= nil
end

-- Toggle the first `[ ]` / `[x]` on a line. Returns nil if there is none.
function M.toggle_line(line)
  if line:find "%[ %]" then
    return (line:gsub("%[ %]", "[x]", 1))
  elseif line:find "%[[xX]%]" then
    return (line:gsub("%[[xX]%]", "[ ]", 1))
  end
end

-- Find the checkbox block around `row` (1-indexed) and return its bounds and
-- the block with unchecked items first (order within each group preserved).
function M.sort_block(lines, row)
  local start_row = row
  while start_row > 1 and is_checkbox(lines[start_row - 1]) do
    start_row = start_row - 1
  end

  local end_row = row
  while end_row < #lines and is_checkbox(lines[end_row + 1]) do
    end_row = end_row + 1
  end

  local unchecked, checked = {}, {}
  for i = start_row, end_row do
    table.insert(lines[i]:find "%[ %]" and unchecked or checked, lines[i])
  end
  return start_row, end_row, vim.list_extend(unchecked, checked)
end

function M.toggle_checkbox()
  local line = M.toggle_line(vim.api.nvim_get_current_line())
  if line then
    vim.api.nvim_set_current_line(line)
  end
end

function M.sort_checkboxes()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local start_row, end_row, sorted = M.sort_block(lines, row)
  vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, sorted)
end

return M
