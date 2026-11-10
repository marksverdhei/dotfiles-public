-- Collapse/expand shell commands split with `\` line continuations.
local M = {}

-- Return the 1-indexed [start, end] of the continued command containing `row`.
function M.segment_bounds(lines, row)
  local start_line = row
  while start_line > 1 and (lines[start_line - 1] or ""):match "\\%s*$" do
    start_line = start_line - 1
  end

  local end_line = start_line
  while end_line < #lines and lines[end_line]:match "\\%s*$" do
    end_line = end_line + 1
  end
  return start_line, end_line
end

-- Collapse a multi-line segment to one line, or expand a one-liner so each
-- `-x` / `--flag` starts a continued line.
function M.toggle_segment(segment_lines)
  local text = table.concat(segment_lines, "\n")
  if text:find "\\" then
    local collapsed = text:gsub("%s*\\%s*\n%s*", " "):gsub("%s+", " ")
    return { collapsed }
  end
  local expanded = text:gsub("(%s)(%-%-?%w)", " \\\n  %2")
  return vim.split(expanded, "\n")
end

function M.toggle_multiline()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 0 then
    return
  end
  local start_line, end_line = M.segment_bounds(lines, vim.api.nvim_win_get_cursor(0)[1])
  local segment = vim.list_slice(lines, start_line, end_line)
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, M.toggle_segment(segment))
end

return M
