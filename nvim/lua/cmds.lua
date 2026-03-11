local user_command = vim.api.nvim_create_user_command

function IsMapped(lhs)
  local modes = {'n', 'v', 'i', 'c', 'x', 's', 'o', 'l', 't'}
  for _, mode in ipairs(modes) do
    local map = vim.api.nvim_get_keymap(mode)
    for _, m in ipairs(map) do
      if m.lhs == lhs then
        print("Mapped in mode: " .. mode)
        return
      end
    end
  end
  print("Not custom mapped (may be built-in or unmapped)")
end

function MdSortCheckboxes()
  local api = vim.api
  local bufnr = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- get cursor row (1-indexed)
  local row = api.nvim_win_get_cursor(0)[1]

  -- find the bounds of the checkbox block
  local function is_checkbox(line)
    return line:match("^%s*[-*]?%s*%[.%]")
  end

  local start_row = row
  while start_row > 1 and is_checkbox(lines[start_row-1]) do
    start_row = start_row - 1
  end

  local end_row = row
  while end_row < #lines and is_checkbox(lines[end_row+1]) do
    end_row = end_row + 1
  end

  -- collect the block
  local block = {}
  for i = start_row, end_row do
    table.insert(block, lines[i])
  end

  -- partition into unchecked and checked
  local unchecked, checked = {}, {}
  for _, line in ipairs(block) do
    if line:find("%[ %]") then
      table.insert(unchecked, line)
    else
      table.insert(checked, line)
    end
  end

  -- rebuild and write back
  local sorted = vim.list_extend(unchecked, checked)
  api.nvim_buf_set_lines(bufnr, start_row-1, end_row, false, sorted)
end

function MdToggleCheckbox()
  local line = vim.api.nvim_get_current_line()
  if line:find("%[ %]") then
    line = line:gsub("%[ %]", "[x]")
  elseif line:find("%[x%]") or line:find("%[X%]") then
    line = line:gsub("%[x%]", "[ ]"):gsub("%[X%]", "[ ]")
  else
    return
  end
  vim.api.nvim_set_current_line(line)
end

function OpenNearestUrl()
  -- helper: extract first http(s):// URL from a string
  local function extract_url(s)
    return s:match("(https?://[%w%-_%.%?%.:/%+=&]+)")
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- 1) Try the WORD under cursor
  local word = vim.fn.expand("<cWORD>")
  local url = extract_url(word)
  if url then
    -- open it
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
    return
  end

  -- 2) Search outward for nearest URL in buffer
  local max_scan = 100  -- max lines to scan in each direction
  local best = nil

  for d = 0, max_scan do
    for _, direction in ipairs({-1, 1}) do
      local r = row + d * direction
      if r >= 1 and r <= vim.api.nvim_buf_line_count(bufnr) then
        local line = vim.api.nvim_buf_get_lines(bufnr, r-1, r, false)[1]
        local found = extract_url(line)
        if found then
          best = found
          break
        end
      end
    end
    if best then break end
  end

  if best then
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, best }, { detach = true })
  else
    vim.notify("No URL found near cursor", vim.log.levels.WARN)
  end
end

function OpenHuggingFaceRepo()
  -- helper: extract owner/model pattern from a string
  local function extract_hf_repo(s)
    -- Match patterns like: owner/model-name or owner/model_name
    return s:match("([%w%-_%.]+/[%w%-_%.]+)")
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- 1) Try the WORD under cursor
  local word = vim.fn.expand("<cWORD>")
  local repo = extract_hf_repo(word)
  if repo then
    -- open it
    local url = "https://huggingface.co/" .. repo
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
    return
  end

  -- 2) Search outward for nearest HF repo in buffer
  local max_scan = 100  -- max lines to scan in each direction
  local best = nil

  for d = 0, max_scan do
    for _, direction in ipairs({-1, 1}) do
      local r = row + d * direction
      if r >= 1 and r <= vim.api.nvim_buf_line_count(bufnr) then
        local line = vim.api.nvim_buf_get_lines(bufnr, r-1, r, false)[1]
        local found = extract_hf_repo(line)
        if found then
          best = found
          break
        end
      end
    end
    if best then break end
  end

  if best then
    local url = "https://huggingface.co/" .. best
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
  else
    vim.notify("No Hugging Face repo pattern (owner/model) found near cursor", vim.log.levels.WARN)
  end
end

function OpenHuggingFaceDataset()
  -- helper: extract owner/dataset pattern from a string
  local function extract_hf_dataset(s)
    -- Match patterns like: owner/dataset-name or owner/dataset_name
    return s:match("([%w%-_%.]+/[%w%-_%.]+)")
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1], cursor[2]

  -- 1) Try the WORD under cursor
  local word = vim.fn.expand("<cWORD>")
  local dataset = extract_hf_dataset(word)
  if dataset then
    -- open it
    local url = "https://huggingface.co/datasets/" .. dataset
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
    return
  end

  -- 2) Search outward for nearest HF dataset in buffer
  local max_scan = 100  -- max lines to scan in each direction
  local best = nil

  for d = 0, max_scan do
    for _, direction in ipairs({-1, 1}) do
      local r = row + d * direction
      if r >= 1 and r <= vim.api.nvim_buf_line_count(bufnr) then
        local line = vim.api.nvim_buf_get_lines(bufnr, r-1, r, false)[1]
        local found = extract_hf_dataset(line)
        if found then
          best = found
          break
        end
      end
    end
    if best then break end
  end

  if best then
    local url = "https://huggingface.co/datasets/" .. best
    local opener = vim.fn.has("macunix") == 1 and "open" or "xdg-open"
    vim.fn.jobstart({ opener, url }, { detach = true })
  else
    vim.notify("No Hugging Face dataset pattern (owner/dataset) found near cursor", vim.log.levels.WARN)
  end
end

function ToggleBashMultiline()
  local buf = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  
  -- Find start of segment (while previous line ends with \)
  local start_line = cursor_line
  while start_line > 1 do
    local prev_line = vim.api.nvim_buf_get_lines(buf, start_line - 2, start_line - 1, false)[1] or ""
    if not prev_line:match("\\%s*$") then break end
    start_line = start_line - 1
  end
  
  -- Find end of segment (while current line ends with \)
  local end_line = start_line
  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, -1, false)
  for i = 1, #lines do
    end_line = start_line + i - 1
    if not lines[i]:match("\\%s*$") then break end
  end
  
  -- Get segment lines
  local segment_lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
  if #segment_lines == 0 then return end
  
  local segment_text = table.concat(segment_lines, "\n")
  
  if segment_text:find("\\") then
    -- Collapse: remove line continuations and normalize spacing
    local collapsed = segment_text:gsub("%s*\\%s*\n%s*", " "):gsub("%s+", " ")
    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, {collapsed})
  else
    -- Expand: add line continuations before args starting with - or --
    local expanded = segment_text:gsub("(%s)(%-%-?%w)", " \\\n  %2")
    local expanded_lines = vim.split(expanded, "\n")
    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, expanded_lines)
  end
end

-- command defs
user_command('UcOpenNearestURL', OpenNearestUrl, {nargs=0})
user_command('OpenHuggingFaceRepo', OpenHuggingFaceRepo, {nargs=0})
user_command('OpenHuggingFaceDataset', OpenHuggingFaceDataset, {nargs=0})
user_command('MdSortCheckboxes', MdSortCheckboxes, {nargs=0})
user_command('MdToggleCheckbox', MdToggleCheckbox, {nargs=0})
user_command('ToggleBashMultiline', ToggleBashMultiline, {nargs=0})
user_command('Taken', function(opts)
  IsMapped(opts.args)
end, {nargs=1})

-- nvtop panel state
local nvtop_win = nil
local nvtop_buf = nil

function ToggleNvtop()
  -- Check if window still exists and is valid
  if nvtop_win and vim.api.nvim_win_is_valid(nvtop_win) then
    vim.api.nvim_win_close(nvtop_win, true)
    nvtop_win = nil
    nvtop_buf = nil
    return
  end

  -- Open a new vertical split on the right
  vim.cmd('vsplit')
  vim.cmd('wincmd L')  -- Move to far right

  -- Set a reasonable width (e.g., 80 columns)
  vim.cmd('vertical resize 80')

  -- Open nvtop in terminal
  vim.cmd('terminal nvtop')

  -- Store the window and buffer
  nvtop_win = vim.api.nvim_get_current_win()
  nvtop_buf = vim.api.nvim_get_current_buf()

  -- Make buffer ephemeral (deleted when window closes)
  vim.api.nvim_buf_set_option(nvtop_buf, 'bufhidden', 'wipe')

  -- Go back to previous window
  vim.cmd('wincmd p')
end

user_command('ToggleNvtop', ToggleNvtop, {nargs=0})

-- nvim-tree width toggle state
local nvimtree_expanded = false
local default_width = 30

function ToggleNvimTreeWidth()
  local api = require('nvim-tree.api')

  -- Check if nvim-tree is open
  local view = require('nvim-tree.view')
  if not view.is_visible() then
    vim.notify("NvimTree is not open", vim.log.levels.WARN)
    return
  end

  if nvimtree_expanded then
    -- Collapse back to default width
    api.tree.resize({ absolute = default_width })
    nvimtree_expanded = false
    vim.notify("NvimTree: Reset to default width", vim.log.levels.INFO)
  else
    -- Expand to fit longest line
    local bufnr = view.get_bufnr()
    if not bufnr then return end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local max_len = default_width

    for _, line in ipairs(lines) do
      -- Strip ANSI codes and calculate display width
      local display_line = line:gsub('\27%[[0-9;]*m', '')
      local len = vim.fn.strdisplaywidth(display_line)
      if len > max_len then
        max_len = len
      end
    end

    -- Add some padding
    local new_width = max_len + 2

    api.tree.resize({ absolute = new_width })
    nvimtree_expanded = true
    vim.notify("NvimTree: Expanded to " .. new_width, vim.log.levels.INFO)
  end
end

user_command('ToggleNvimTreeWidth', ToggleNvimTreeWidth, {nargs=0})

-- Workspace preset: File tree + terminal with lumi
function WorkspaceLumi()
  -- Open file tree
  vim.cmd('NvimTreeOpen')

  -- Create vsplit and open terminal
  vim.cmd('vsplit')
  vim.cmd('terminal')

  -- Run lumi command in the terminal
  vim.api.nvim_chan_send(vim.bo.channel, 'lumi\n')

  -- Go back to the left window (file tree area)
  vim.cmd('wincmd h')
end

user_command('WorkspaceLumi', WorkspaceLumi, {nargs=0})

-- ANSI pixel art renderer
local ansi_rendered_bufs = {}
local ansi_ns = vim.api.nvim_create_namespace("ansi_render")

function ToggleAnsi()
  local bufnr = vim.api.nvim_get_current_buf()

  if ansi_rendered_bufs[bufnr] then
    -- Toggle OFF: reload file from disk to restore raw escape codes
    vim.api.nvim_buf_clear_namespace(bufnr, ansi_ns, 0, -1)
    vim.cmd('edit!')
    ansi_rendered_bufs[bufnr] = nil
    vim.notify("ANSI rendering OFF", vim.log.levels.INFO)
    return
  end

  -- Toggle ON: parse ANSI escape codes and apply RGB highlights
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local clean_lines = {}
  local marks = {}
  local hl_groups = {}

  for i, line in ipairs(lines) do
    local clean = ""
    local current_fg = nil
    local pos = 1

    while pos <= #line do
      -- Match ESC[ ... m sequences
      local esc_start, esc_end, code = line:find("\27%[([0-9;]*)m", pos)

      if esc_start == pos then
        if code == "0" or code == "" then
          current_fg = nil
        else
          local r, g, b = code:match("38;2;(%d+);(%d+);(%d+)")
          if r then
            current_fg = string.format("#%02x%02x%02x", tonumber(r), tonumber(g), tonumber(b))
          end
        end
        pos = esc_end + 1
      else
        -- Read one UTF-8 character
        local byte = line:byte(pos)
        local char_len = 1
        if byte >= 0xF0 then char_len = 4
        elseif byte >= 0xE0 then char_len = 3
        elseif byte >= 0xC0 then char_len = 2
        end
        local char = line:sub(pos, pos + char_len - 1)

        local byte_start = #clean
        clean = clean .. char

        if current_fg then
          local hl_name = "Ansi_" .. current_fg:sub(2)
          if not hl_groups[hl_name] then
            vim.api.nvim_set_hl(0, hl_name, { fg = current_fg })
            hl_groups[hl_name] = true
          end
          table.insert(marks, { i - 1, byte_start, #clean, hl_name })
        end

        pos = pos + char_len
      end
    end

    table.insert(clean_lines, clean)
  end

  -- Replace buffer with clean text (escape codes stripped)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, clean_lines)

  -- Apply color extmarks
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(bufnr, ansi_ns, m[1], m[2], {
      end_col = m[3],
      hl_group = m[4],
    })
  end

  vim.bo[bufnr].modified = false
  ansi_rendered_bufs[bufnr] = true
  vim.notify("ANSI rendering ON", vim.log.levels.INFO)
end

user_command('ToggleAnsi', ToggleAnsi, {nargs=0})
