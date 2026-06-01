require("nvchad.configs.lspconfig").defaults()

-- Server -> the binary it launches (matches nvim-lspconfig's lsp/<name>.lua).
-- Only enable a server when its binary is on $PATH. Enabling one whose cmd is
-- missing (e.g. pyright / marksman not installed) makes Neovim 0.12 throw
-- "invalid config: cmd ... is not executable" on every matching buffer. This
-- skips the missing ones quietly and auto-enables each the moment you install
-- it. (vim.lsp.config[name] doesn't expose cmd until enable() resolves it, so
-- we can't introspect it ahead of time — hence the explicit map.)
local servers = {
  html = "vscode-html-language-server",
  cssls = "vscode-css-language-server",
  pyright = "pyright-langserver",
  marksman = "marksman",
}

local enabled = {}
for name, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then
    table.insert(enabled, name)
  end
end
if #enabled > 0 then
  vim.lsp.enable(enabled)
end

-- read :h vim.lsp.config for changing options of lsp servers 
