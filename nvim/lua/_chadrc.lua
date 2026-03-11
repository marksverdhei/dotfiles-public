---@type ChadrcConfig
local M = {}

local default_light = "github_light"
local default_dark = "catppuccin"

-- Validate theme exists in base46, fallback to default if not
local function validate_theme(theme, fallback)
  local themes_dir = vim.fn.stdpath("data") .. "/lazy/base46/lua/base46/themes/"
  local theme_file = themes_dir .. theme .. ".lua"
  if vim.uv.fs_stat(theme_file) then
    return theme
  end
  return fallback
end

local light_theme = validate_theme(os.getenv("NVIM_LIGHT_THEME") or default_light, default_light)
local dark_theme = validate_theme(os.getenv("NVIM_DARK_THEME") or default_dark, default_dark)
local primary_theme = validate_theme(os.getenv("NVIM_THEME") or dark_theme, dark_theme)

M.base46 = {
  theme = primary_theme,
  theme_toggle = { dark_theme, light_theme },
}

M.nvdash = { load_on_startup = false }

return M
