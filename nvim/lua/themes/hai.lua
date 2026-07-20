-- HAI mode: cool machine chrome with electric-blue phosphor text.
local M = {}

M.base_30 = {
  white = "#86e6ff",
  darker_black = "#30363b",
  black = "#3d444a",
  black2 = "#4b535a",
  one_bg = "#596269",
  one_bg2 = "#68727a",
  one_bg3 = "#77828a",
  grey = "#89949c",
  grey_fg = "#9ca6ad",
  grey_fg2 = "#adb6bc",
  light_grey = "#c1c8cd",
  red = "#ff6684",
  baby_pink = "#ff8ba2",
  pink = "#b58cff",
  line = "#d4d9dd",
  green = "#48e0b4",
  vibrant_green = "#66f2c7",
  nord_blue = "#00b7ff",
  blue = "#28c8ff",
  yellow = "#ffd866",
  sun = "#ffe48f",
  purple = "#9da7ff",
  dark_purple = "#7d8cff",
  teal = "#35d8db",
  orange = "#ffac66",
  cyan = "#54e6ff",
  statusline_bg = "#252a2f",
  lightbg = "#555e65",
  pmenu_bg = "#00a8e8",
  folder_bg = "#28c8ff",
}

M.base_16 = {
  base00 = "#3d444a",
  base01 = "#4b535a",
  base02 = "#596269",
  base03 = "#89949c",
  base04 = "#bac3ca",
  base05 = "#86e6ff",
  base06 = "#afefff",
  base07 = "#dcf9ff",
  base08 = "#54e6ff",
  base09 = "#28c8ff",
  base0A = "#8fdfff",
  base0B = "#48e0d0",
  base0C = "#00b7ff",
  base0D = "#42cfff",
  base0E = "#9da7ff",
  base0F = "#5aa9ff",
}

M.type = "dark"

M.polish_hl = {
  defaults = {
    Normal = { fg = M.base_16.base05, bg = M.base_16.base00 },
    NormalFloat = { fg = M.base_16.base05, bg = M.base_30.darker_black },
    CursorLineNr = { fg = M.base_30.cyan, bold = true },
    FloatBorder = { fg = M.base_30.line },
    WinSeparator = { fg = M.base_30.line },
  },
  treesitter = {
    ["@variable"] = { fg = M.base_16.base05 },
    ["@variable.builtin"] = { fg = M.base_16.base06 },
    ["@punctuation.bracket"] = { fg = M.base_30.light_grey },
  },
}

return require("base46").override_theme(M, "hai")
