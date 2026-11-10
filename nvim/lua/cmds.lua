-- User commands. The implementations live in lua/features/; this module
-- registers the commands and re-exports the functions used by mappings.lua.
local openers = require "features.openers"
local markdown = require "features.markdown"
local shell = require "features.shell"
local ansi = require "features.ansi"
local panels = require "features.panels"

local M = {
  open_nearest_url = openers.open_nearest_url,
  open_hf_repo = openers.open_hf_repo,
  open_hf_dataset = openers.open_hf_dataset,
  md_toggle_checkbox = markdown.toggle_checkbox,
  md_sort_checkboxes = markdown.sort_checkboxes,
  toggle_bash_multiline = shell.toggle_multiline,
  toggle_ansi = ansi.toggle,
  toggle_nvtop = panels.toggle_nvtop,
  toggle_nvimtree_width = panels.toggle_nvimtree_width,
  workspace_lumi = panels.workspace_lumi,
}

function M.is_mapped(lhs)
  for _, mode in ipairs { "n", "v", "i", "c", "x", "s", "o", "l", "t" } do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      if m.lhs == lhs then
        print("Mapped in mode: " .. mode)
        return
      end
    end
  end
  print "Not custom mapped (may be built-in or unmapped)"
end

local user_command = vim.api.nvim_create_user_command
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
