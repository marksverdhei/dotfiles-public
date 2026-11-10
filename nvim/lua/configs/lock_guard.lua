-- Keep the committed lazy-lock.json pins when startup installs rewrite it.
-- See the comment in init.lua.
local M = {}

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read "*a"
  f:close()
  return content
end

local function write(path, content)
  local f = assert(io.open(path, "w"))
  f:write(content)
  f:close()
end

function M.snapshot(path)
  path = path or (vim.fn.stdpath "config" .. "/lazy-lock.json")
  return { path = path, content = read(path) }
end

-- Returns true if the lockfile had been rewritten and was restored.
function M.restore_if_changed(snapshot)
  if not snapshot.content or read(snapshot.path) == snapshot.content then
    return false
  end
  write(snapshot.path, snapshot.content)
  vim.schedule(function()
    vim.notify(
      "Installed new plugins and kept the pinned versions in lazy-lock.json.\n"
        .. "Run :Lazy restore, then restart, to move the other plugins to those pins.",
      vim.log.levels.WARN,
      { title = "lazy-lock.json" }
    )
  end)
  return true
end

return M
