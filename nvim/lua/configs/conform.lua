local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    sh = { "shfmt" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  -- Formatters that aren't installed are skipped quietly (install them with
  -- :MasonInstall stylua ruff shfmt). Toggle with :FormatToggle, or
  -- :FormatToggle! for the current buffer only.
  notify_no_formatters = false,
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 500, lsp_format = "never" }
  end,
}

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
  end
end, { bang = true, desc = "Toggle format on save (! for current buffer)" })

return options
