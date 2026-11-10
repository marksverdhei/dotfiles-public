-- Render 24-bit ANSI colour escape codes (pixel art) with extmarks.
local M = {}

local ns = vim.api.nvim_create_namespace "ansi_render"

local function utf8_len(byte)
  if byte >= 0xF0 then
    return 4
  elseif byte >= 0xE0 then
    return 3
  elseif byte >= 0xC0 then
    return 2
  end
  return 1
end

-- Strip `ESC[...m` sequences. Returns the clean lines and a list of
-- { row (0-based), start_col, end_col, "#rrggbb" } foreground spans.
function M.parse(lines)
  local clean_lines, spans = {}, {}

  for i, line in ipairs(lines) do
    local parts, clean_len, fg, pos = {}, 0, nil, 1

    while pos <= #line do
      local esc_start, esc_end, code = line:find("\27%[([0-9;]*)m", pos)
      if esc_start == pos then
        if code == "0" or code == "" then
          fg = nil
        else
          local r, g, b = code:match "38;2;(%d+);(%d+);(%d+)"
          if r then
            fg = string.format("#%02x%02x%02x", tonumber(r), tonumber(g), tonumber(b))
          end
        end
        pos = esc_end + 1
      else
        local char = line:sub(pos, pos + utf8_len(line:byte(pos)) - 1)
        local start_col = clean_len
        parts[#parts + 1] = char
        clean_len = clean_len + #char
        if fg then
          spans[#spans + 1] = { i - 1, start_col, clean_len, fg }
        end
        pos = pos + #char
      end
    end

    clean_lines[i] = table.concat(parts)
  end

  return clean_lines, spans
end

function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.b[bufnr].ansi_rendered then
    -- Toggle OFF: reload file from disk to restore raw escape codes
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    vim.bo[bufnr].modifiable = true
    vim.bo[bufnr].readonly = false
    vim.b[bufnr].ansi_raw = true
    vim.cmd "edit!"
    vim.b[bufnr].ansi_rendered = nil
    vim.notify("ANSI rendering OFF", vim.log.levels.INFO)
    return
  end

  if vim.bo[bufnr].modified then
    vim.notify("ToggleAnsi: save or discard your changes first", vim.log.levels.WARN)
    return
  end

  local clean_lines, spans = M.parse(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, clean_lines)

  local defined = {}
  for _, s in ipairs(spans) do
    local hl = "Ansi_" .. s[4]:sub(2)
    if not defined[hl] then
      vim.api.nvim_set_hl(0, hl, { fg = s[4] })
      defined[hl] = true
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, s[1], s[2], { end_col = s[3], hl_group = hl })
  end

  -- The buffer now holds stripped text; lock it so a stray :w can't write it
  -- over the original escape codes. Toggling off reloads from disk.
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  vim.b[bufnr].ansi_rendered = true
  vim.b[bufnr].ansi_raw = nil
  vim.notify("ANSI rendering ON", vim.log.levels.INFO)
end

return M
