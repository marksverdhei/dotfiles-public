local M = {}

local aliases = { HAI = "hai", HEI = "hei" }

local function normalize(name)
  return aliases[name] or name
end

local function available_themes()
  local ok, themes = pcall(function()
    return require("nvchad.utils").list_themes()
  end)
  if not ok then
    return {}
  end
  table.sort(themes)
  return themes
end

local function theme_exists(name)
  name = normalize(name)
  for _, candidate in ipairs(available_themes()) do
    if candidate == name then
      return true
    end
  end
  return false
end

function M.set(name)
  name = normalize(name)
  if not theme_exists(name) then
    vim.notify("Unknown theme: " .. name, vim.log.levels.ERROR)
    return false
  end

  require("nvconfig").base46.theme = name
  require("base46").load_all_highlights()
  vim.notify("Theme: " .. name)
  return true
end

function M.mid(name)
  local current = name
  if not current or current == "" then
    current = require("nvconfig").base46.theme
  end

  local mid = require("theme.mid").for_theme(current)
  if not mid then
    vim.notify("No light/dark family found for: " .. current, vim.log.levels.WARN)
    return false
  end
  return M.set(mid)
end

function M.cycle()
  local themes = require("chadrc").appearance_themes
  local current = require("nvconfig").base46.theme
  local next_index = 1

  for index, name in ipairs(themes) do
    if name == current then
      next_index = index % #themes + 1
      break
    end
  end

  return M.set(themes[next_index])
end

function M.setup()
  vim.api.nvim_create_user_command("Theme", function(opts)
    M.set(opts.args)
  end, {
    nargs = 1,
    complete = function(arglead)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arglead)
      end, available_themes())
    end,
    desc = "Switch Base46 theme for this session",
    force = true,
  })

  vim.api.nvim_create_user_command("ThemeMid", function(opts)
    M.mid(opts.args)
  end, {
    nargs = "?",
    complete = function(arglead)
      local families = vim.tbl_map(function(pair)
        return pair.family
      end, require("theme.mid").pairs)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arglead)
      end, families)
    end,
    desc = "Use the mid variant of a theme family",
    force = true,
  })

  vim.api.nvim_create_user_command("ThemeCycle", M.cycle, {
    desc = "Cycle dark, mid, and light appearance themes",
    force = true,
  })
  vim.api.nvim_create_user_command("Hei", function()
    M.set "hei"
  end, { desc = "Use the humble notebook theme", force = true })
  vim.api.nvim_create_user_command("HAI", function()
    M.set "hai"
  end, { desc = "Use chrome and electric-blue HAI mode", force = true })
end

return M
