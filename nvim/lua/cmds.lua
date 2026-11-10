local M = {}

local user_command = vim.api.nvim_create_user_command

function M.is_mapped(lhs)
  local modes = { "n", "v", "i", "c", "x", "s", "o", "l", "t" }
  for _, mode in ipairs(modes) do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      if m.lhs == lhs then
        print("Mapped in mode: " .. mode)
        return
      end
    end
  end
  print "Not custom mapped (may be built-in or unmapped)"
end

function M.md_sort_checkboxes()
  local api = vim.api
  local bufnr = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- get cursor row (1-indexed)
  local row = api.nvim_win_get_cursor(0)[1]

  -- find the bounds of the checkbox block
  local function is_checkbox(line)
    return line:match "^%s*[-*]?%s*%[.%]"
  end

  local start_row = row
  while start_row > 1 and is_checkbox(lines[start_row - 1]) do
    start_row = start_row - 1
  end

  local end_row = row
  while end_row < #lines and is_checkbox(lines[end_row + 1]) do
    end_row = end_row + 1
  end

  -- partition into unchecked and checked
  local unchecked, checked = {}, {}
  for i = start_row, end_row do
    local line = lines[i]
    if line:find "%[ %]" then
      table.insert(unchecked, line)
    else
      table.insert(checked, line)
    end
  end

  local sorted = vim.list_extend(unchecked, checked)
  api.nvim_buf_set_lines(bufnr, start_row - 1, end_row, false, sorted)
end

function M.md_toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  if line:find "%[ %]" then
    line = line:gsub("%[ %]", "[x]", 1)
  elseif line:find "%[[xX]%]" then
    line = line:gsub("%[[xX]%]", "[ ]", 1)
  else
    return
  end
  vim.api.nvim_set_current_line(line)
end

local function open_in_browser(url)
  if vim.ui.open then
    vim.ui.open(url)
  else
    local opener = vim.fn.has "macunix" == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
  end
end

-- Find the first match of `extract` in the WORD under the cursor, otherwise in
-- the nearest line (scanning outward up to 100 lines in each direction).
local function find_nearest(extract)
  local found = extract(vim.fn.expand "<cWORD>")
  if found then
    return found
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for d = 0, 100 do
    for _, direction in ipairs { -1, 1 } do
      local r = row + d * direction
      if r >= 1 and r <= line_count then
        local line = vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1]
        found = extract(line)
        if found then
          return found
        end
      end
    end
  end
end

local function extract_url(s)
  local url = s:match "https?://[^%s<>\"'`]+"
  if not url then
    return nil
  end
  -- drop trailing punctuation and unbalanced closing brackets, e.g. markdown `(url)`
  url = url:gsub("[%.,;:!%?]+$", "")
  while url:sub(-1) == ")" and select(2, url:gsub("%(", "")) < select(2, url:gsub("%)", "")) do
    url = url:sub(1, -2)
  end
  return url
end

-- File extensions that mark an `a/b.ext` token as a path, not a Hub repo id.
local path_exts = {
  lua = true, py = true, sh = true, md = true, json = true, jsonl = true, txt = true,
  yaml = true, yml = true, toml = true, js = true, ts = true, rs = true, go = true,
  c = true, h = true, cpp = true, html = true, css = true, csv = true, ipynb = true,
}

-- Match a bare `owner/name` Hugging Face id: exactly one slash, not part of a
-- longer path or URL, and not ending in a file extension.
local function extract_hf_id(s)
  for token in s:gmatch "[%w%-_%./:]+" do
    local owner, name = token:match "^([%w%-_%.]+)/([%w%-_%.]+)$"
    if owner and not owner:match "^%.+$" then
      local ext = name:match "%.(%w+)$"
      if not (ext and path_exts[ext:lower()]) then
        return owner .. "/" .. name
      end
    end
  end
end

local function open_nearest(extract, url_prefix, not_found_msg)
  local found = find_nearest(extract)
  if found then
    open_in_browser(url_prefix .. found)
  else
    vim.notify(not_found_msg, vim.log.levels.WARN)
  end
end

function M.open_nearest_url()
  open_nearest(extract_url, "", "No URL found near cursor")
end

function M.open_hf_repo()
  open_nearest(
    extract_hf_id,
    "https://huggingface.co/",
    "No Hugging Face repo pattern (owner/model) found near cursor"
  )
end

function M.open_hf_dataset()
  open_nearest(
    extract_hf_id,
    "https://huggingface.co/datasets/",
    "No Hugging Face dataset pattern (owner/dataset) found near cursor"
  )
end

function M.toggle_bash_multiline()
  local buf = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

  -- Find start of segment (while previous line ends with \)
  local start_line = cursor_line
  while start_line > 1 do
    local prev_line = vim.api.nvim_buf_get_lines(buf, start_line - 2, start_line - 1, false)[1] or ""
    if not prev_line:match "\\%s*$" then
      break
    end
    start_line = start_line - 1
  end

  -- Find end of segment (while current line ends with \)
  local end_line = start_line
  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, -1, false)
  for i = 1, #lines do
    end_line = start_line + i - 1
    if not lines[i]:match "\\%s*$" then
      break
    end
  end

  local segment_lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
  if #segment_lines == 0 then
    return
  end

  local segment_text = table.concat(segment_lines, "\n")

  if segment_text:find "\\" then
    -- Collapse: remove line continuations and normalize spacing
    local collapsed = segment_text:gsub("%s*\\%s*\n%s*", " "):gsub("%s+", " ")
    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, { collapsed })
  else
    -- Expand: add line continuations before args starting with - or --
    local expanded = segment_text:gsub("(%s)(%-%-?%w)", " \\\n  %2")
    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, vim.split(expanded, "\n"))
  end
end

-- nvtop panel state
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

-- nvim-tree width toggle state
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

-- ANSI pixel art renderer
local ansi_ns = vim.api.nvim_create_namespace "ansi_render"

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

function M.toggle_ansi()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.b[bufnr].ansi_rendered then
    -- Toggle OFF: reload file from disk to restore raw escape codes
    vim.api.nvim_buf_clear_namespace(bufnr, ansi_ns, 0, -1)
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

  -- Toggle ON: parse ANSI escape codes and apply RGB highlights
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local clean_lines = {}
  local marks = {}
  local hl_groups = {}

  for i, line in ipairs(lines) do
    local parts = {}
    local clean_len = 0
    local current_fg = nil
    local pos = 1

    while pos <= #line do
      -- Match ESC[ ... m sequences
      local esc_start, esc_end, code = line:find("\27%[([0-9;]*)m", pos)

      if esc_start == pos then
        if code == "0" or code == "" then
          current_fg = nil
        else
          local r, g, b = code:match "38;2;(%d+);(%d+);(%d+)"
          if r then
            current_fg = string.format("#%02x%02x%02x", tonumber(r), tonumber(g), tonumber(b))
          end
        end
        pos = esc_end + 1
      else
        local char_len = utf8_len(line:byte(pos))
        local char = line:sub(pos, pos + char_len - 1)
        local byte_start = clean_len
        parts[#parts + 1] = char
        clean_len = clean_len + #char

        if current_fg then
          local hl_name = "Ansi_" .. current_fg:sub(2)
          if not hl_groups[hl_name] then
            vim.api.nvim_set_hl(0, hl_name, { fg = current_fg })
            hl_groups[hl_name] = true
          end
          table.insert(marks, { i - 1, byte_start, clean_len, hl_name })
        end

        pos = pos + char_len
      end
    end

    table.insert(clean_lines, table.concat(parts))
  end

  -- Replace buffer with clean text (escape codes stripped)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, clean_lines)

  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(bufnr, ansi_ns, m[1], m[2], {
      end_col = m[3],
      hl_group = m[4],
    })
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

-- command defs
user_command("UcOpenNearestURL", M.open_nearest_url, { nargs = 0 })
user_command("OpenHuggingFaceRepo", M.open_hf_repo, { nargs = 0 })
user_command("OpenHuggingFaceDataset", M.open_hf_dataset, { nargs = 0 })
user_command("MdSortCheckboxes", M.md_sort_checkboxes, { nargs = 0 })
user_command("MdToggleCheckbox", M.md_toggle_checkbox, { nargs = 0 })
user_command("ToggleBashMultiline", M.toggle_bash_multiline, { nargs = 0 })
user_command("Taken", function(opts)
  M.is_mapped(opts.args)
end, { nargs = 1 })
user_command("ToggleNvtop", M.toggle_nvtop, { nargs = 0 })
user_command("ToggleNvimTreeWidth", M.toggle_nvimtree_width, { nargs = 0 })
user_command("WorkspaceLumi", M.workspace_lumi, { nargs = 0 })
user_command("ToggleAnsi", M.toggle_ansi, { nargs = 0 })

return M
