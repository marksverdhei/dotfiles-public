local M = {}

-- Base46's light themes reverse the neutral foreground/background ramp. A
-- straight 50/50 mix therefore makes both converge on the same grey. Keep the
-- dark theme's readable foreground ramp while moving backgrounds and accents
-- toward their light counterparts.
local background_keys = {
  darker_black = true,
  black = true,
  black2 = true,
  one_bg = true,
  one_bg2 = true,
  one_bg3 = true,
  line = true,
  statusline_bg = true,
  lightbg = true,
}

M.pairs = {
  { family = "ayu", dark = "ayu_dark", light = "ayu_light", mid = "ayu_mid" },
  { family = "catppuccin", dark = "catppuccin", light = "catppuccin-latte", mid = "catppuccin-mid" },
  { family = "default", dark = "default-dark", light = "default-light", mid = "default-mid" },
  { family = "everforest", dark = "everforest", light = "everforest_light", mid = "everforest_mid" },
  { family = "flex", dark = "flexoki", light = "flex-light", mid = "flex-mid" },
  { family = "flexoki", dark = "flexoki", light = "flexoki-light", mid = "flexoki-mid" },
  { family = "github", dark = "github_dark", light = "github_light", mid = "github_mid" },
  { family = "gruvbox", dark = "gruvbox", light = "gruvbox_light", mid = "gruvbox_mid" },
  { family = "material", dark = "material-darker", light = "material-lighter", mid = "material-mid" },
  { family = "oceanic", dark = "oceanic-next", light = "oceanic-light", mid = "oceanic-mid" },
  { family = "one", dark = "onedark", light = "one_light", mid = "one_mid" },
  { family = "onenord", dark = "onenord", light = "onenord_light", mid = "onenord_mid" },
  { family = "penumbra", dark = "penumbra_dark", light = "penumbra_light", mid = "penumbra_mid" },
  { family = "rosepine", dark = "rosepine", light = "rosepine-dawn", mid = "rosepine-mid" },
  { family = "seoul256", dark = "seoul256_dark", light = "seoul256_light", mid = "seoul256_mid" },
  { family = "solarized", dark = "solarized_dark", light = "solarized_light", mid = "solarized_mid" },
  { family = "vscode", dark = "vscode_dark", light = "vscode_light", mid = "vscode_mid" },
}

local function blend(dark, light, amount)
  if type(dark) ~= "string" or type(light) ~= "string" then
    return dark
  end

  local dr, dg, db = dark:match "^#(%x%x)(%x%x)(%x%x)$"
  local lr, lg, lb = light:match "^#(%x%x)(%x%x)(%x%x)$"
  if not dr or not lr then
    return dark
  end

  local function channel(a, b)
    return math.floor(tonumber(a, 16) + (tonumber(b, 16) - tonumber(a, 16)) * amount + 0.5)
  end

  return string.format("#%02x%02x%02x", channel(dr, lr), channel(dg, lg), channel(db, lb))
end

local function luminance(hex)
  local channels = { hex:match "^#(%x%x)(%x%x)(%x%x)$" }
  if #channels ~= 3 then
    return nil
  end

  local total = 0
  local weights = { 0.2126, 0.7152, 0.0722 }
  for index, value in ipairs(channels) do
    local channel = tonumber(value, 16) / 255
    channel = channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
    total = total + channel * weights[index]
  end
  return total
end

local function contrast(a, b)
  local a_lum, b_lum = luminance(a), luminance(b)
  if not a_lum or not b_lum then
    return math.huge
  end
  return (math.max(a_lum, b_lum) + 0.05) / (math.min(a_lum, b_lum) + 0.05)
end

local function ensure_contrast(color, background, target, lightest)
  for _ = 1, 24 do
    if contrast(color, background) >= target then
      break
    end
    color = blend(color, lightest, 0.10)
  end
  return color
end

local function blend_table(dark, light, amount_for)
  local result = {}
  for key, value in pairs(dark or {}) do
    result[key] = blend(value, light and light[key], amount_for(key))
  end
  return result
end

function M.between(dark_name, light_name, mid_name)
  local dark = require("base46.themes." .. dark_name)
  local light = require("base46.themes." .. light_name)

  local theme = {
    type = "dark",
    base_30 = blend_table(dark.base_30, light.base_30, function(key)
      if background_keys[key] then
        return 0.28
      end
      if key == "white" then
        return 0.08
      end
      return 0.20
    end),
    base_16 = blend_table(dark.base_16, light.base_16, function(key)
      local index = tonumber(key:match "base0(%x)", 16)
      if index and index <= 3 then
        return 0.28
      end
      if index and index <= 7 then
        return 0.08
      end
      return 0.20
    end),
    polish_hl = vim.deepcopy(dark.polish_hl or {}),
  }

  -- Comments need a little extra lift on the middle-tone canvas.
  theme.base_30.grey = blend(theme.base_30.grey, theme.base_30.white, 0.18)
  theme.base_30.grey_fg = blend(theme.base_30.grey_fg, theme.base_30.white, 0.32)
  theme.base_30.grey_fg2 = blend(theme.base_30.grey_fg2, theme.base_30.white, 0.34)
  theme.base_30.light_grey = blend(theme.base_30.light_grey, theme.base_30.white, 0.38)

  local lightest = dark.base_16.base07 or "#ffffff"
  theme.base_30.white = ensure_contrast(theme.base_30.white, theme.base_30.black, 4.5, lightest)
  theme.base_30.grey = ensure_contrast(theme.base_30.grey, theme.base_30.black, 3.0, lightest)
  theme.base_30.grey_fg = ensure_contrast(theme.base_30.grey_fg, theme.base_30.black, 3.0, lightest)
  theme.base_30.grey_fg2 = ensure_contrast(theme.base_30.grey_fg2, theme.base_30.black, 3.0, lightest)
  theme.base_30.light_grey = ensure_contrast(theme.base_30.light_grey, theme.base_30.black, 3.0, lightest)

  for index = 4, 7 do
    local key = string.format("base0%X", index)
    local target = index == 4 and 3.5 or 4.5
    theme.base_16[key] = ensure_contrast(theme.base_16[key], theme.base_16.base00, target, lightest)
  end
  for index = 8, 15 do
    local key = string.format("base0%X", index)
    theme.base_16[key] = ensure_contrast(theme.base_16[key], theme.base_16.base00, 3.0, lightest)
  end
  theme.base_16.base03 = theme.base_30.grey_fg

  return require("base46").override_theme(theme, mid_name)
end

function M.for_theme(name)
  for _, pair in ipairs(M.pairs) do
    if name == pair.family or name == pair.dark or name == pair.light or name == pair.mid then
      return pair.mid
    end
  end
end

return M
