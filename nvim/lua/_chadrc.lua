---@type ChadrcConfig
local M = {}

local default_light = "github_light"
local default_dark = "hei"
local default_mid = "github_mid"

local aliases = { HAI = "hai", HEI = "hei" }

-- Validate theme exists in base46, fallback to default if not
local function validate_theme(theme, fallback)
  theme = aliases[theme] or theme
  local builtin = vim.fn.stdpath("data") .. "/lazy/base46/lua/base46/themes/" .. theme .. ".lua"
  local custom = vim.fn.stdpath("config") .. "/lua/themes/" .. theme .. ".lua"
  if vim.uv.fs_stat(builtin) or vim.uv.fs_stat(custom) then
    return theme
  end
  return fallback
end

local light_theme = validate_theme(os.getenv("NVIM_LIGHT_THEME") or default_light, default_light)
local dark_theme = validate_theme(os.getenv("NVIM_DARK_THEME") or default_dark, default_dark)
local mid_theme = validate_theme(os.getenv("NVIM_MID_THEME") or default_mid, default_mid)
local appearance = (os.getenv("NVIM_APPEARANCE") or os.getenv("SYS_THEME") or "dark"):lower()
local appearance_theme = ({ light = light_theme, mid = mid_theme, dark = dark_theme })[appearance] or dark_theme
local primary_theme = validate_theme(os.getenv("NVIM_THEME") or appearance_theme, appearance_theme)

M.appearance_themes = { dark_theme, mid_theme, light_theme }

M.base46 = {
  theme = primary_theme,
  -- Base46's built-in button only supports two entries. :ThemeCycle provides
  -- the full dark -> mid -> light cycle.
  theme_toggle = { dark_theme, light_theme },
}

M.nvdash = { load_on_startup = false }

return M
