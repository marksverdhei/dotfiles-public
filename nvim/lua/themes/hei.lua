-- A quiet old notebook: dim paper in the editor, worn brown around its edges.
local M = {}

M.base_30 = {
  white = "#f0ddb5",
  darker_black = "#5a3f2b",
  black = "#c9b184",
  black2 = "#bea574",
  one_bg = "#b39765",
  one_bg2 = "#a98a59",
  one_bg3 = "#9d7d4e",
  grey = "#8b704e",
  grey_fg = "#765d42",
  grey_fg2 = "#6c533a",
  light_grey = "#624a34",
  red = "#8f3f32",
  baby_pink = "#a95d51",
  pink = "#8b5265",
  line = "#876744",
  green = "#526b3f",
  vibrant_green = "#657c4b",
  nord_blue = "#7a2926",
  blue = "#7a2926",
  yellow = "#d6ad43",
  sun = "#e0bd58",
  purple = "#705675",
  dark_purple = "#604762",
  teal = "#794138",
  orange = "#9a5e34",
  cyan = "#83352f",
  statusline_bg = "#684a31",
  lightbg = "#806044",
  pmenu_bg = "#8c6a46",
  folder_bg = "#d9bd86",
}

M.base_16 = {
  base00 = "#c9b184",
  base01 = "#bea574",
  base02 = "#ad9060",
  base03 = "#846a49",
  base04 = "#6e563c",
  base05 = "#4b3728",
  base06 = "#3f2e22",
  base07 = "#34251c",
  base08 = "#8f3f32",
  base09 = "#9a5e34",
  base0A = "#d6ad43",
  base0B = "#526b3f",
  base0C = "#794138",
  base0D = "#7a2926",
  base0E = "#705675",
  base0F = "#74462f",
}

M.type = "light"

M.polish_hl = {
  defaults = {
    NormalFloat = { fg = M.base_30.white, bg = M.base_30.darker_black },
    FloatTitle = { fg = M.base_30.white, bg = M.base_30.darker_black, bold = true },
    CursorLineNr = { fg = M.base_16.base06, bold = true },
    LineNr = { fg = M.base_30.grey },
    Visual = { fg = M.base_16.base07, bg = M.base_30.yellow },
    Search = { fg = M.base_16.base07, bg = M.base_30.yellow },
    CurSearch = { fg = M.base_16.base07, bg = M.base_30.sun, bold = true },
    IncSearch = { fg = M.base_16.base07, bg = M.base_30.sun },
    Substitute = { fg = M.base_16.base07, bg = M.base_30.yellow },
    MatchWord = { fg = M.base_16.base07, bg = M.base_30.yellow },
  },
  nvimtree = {
    NvimTreeNormal = { fg = M.base_30.white, bg = M.base_30.darker_black },
    NvimTreeNormalNC = { fg = M.base_30.white, bg = M.base_30.darker_black },
    NvimTreeCursorLine = { bg = M.base_30.statusline_bg },
  },
  telescope = {
    TelescopeNormal = { fg = M.base_30.white, bg = M.base_30.darker_black },
  },
}

return require("base46").override_theme(M, "hei")
