-- Open URLs and Hugging Face ids found under or near the cursor.
local M = {}

-- File extensions that mark an `a/b.ext` token as a path, not a Hub repo id.
local path_exts = {
  lua = true,
  py = true,
  sh = true,
  md = true,
  json = true,
  jsonl = true,
  txt = true,
  yaml = true,
  yml = true,
  toml = true,
  js = true,
  ts = true,
  rs = true,
  go = true,
  c = true,
  h = true,
  cpp = true,
  html = true,
  css = true,
  csv = true,
  ipynb = true,
}

function M.extract_url(s)
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

-- Match a bare `owner/name` Hugging Face id: exactly one slash, not part of a
-- longer path or URL, and not ending in a file extension.
function M.extract_hf_id(s)
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

-- Find the first match of `extract` in the WORD under the cursor, otherwise in
-- the nearest line (scanning outward up to 100 lines in each direction).
function M.find_nearest(extract)
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
        found = extract(vim.api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1])
        if found then
          return found
        end
      end
    end
  end
end

local function open_nearest(extract, url_prefix, not_found_msg)
  local found = M.find_nearest(extract)
  if found then
    vim.ui.open(url_prefix .. found)
  else
    vim.notify(not_found_msg, vim.log.levels.WARN)
  end
end

function M.open_nearest_url()
  open_nearest(M.extract_url, "", "No URL found near cursor")
end

function M.open_hf_repo()
  open_nearest(
    M.extract_hf_id,
    "https://huggingface.co/",
    "No Hugging Face repo pattern (owner/model) found near cursor"
  )
end

function M.open_hf_dataset()
  open_nearest(
    M.extract_hf_id,
    "https://huggingface.co/datasets/",
    "No Hugging Face dataset pattern (owner/dataset) found near cursor"
  )
end

return M
