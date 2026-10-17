-- Archilang (.alang) — filetype, LSP (diagnostics + hover). Spec: ~/archilang/SPEC.md
vim.filetype.add({ extension = { alang = "alang" } })

vim.lsp.config("archilang", {
  cmd = { "python3", vim.fn.expand("~/archilang/archilang_ls.py"), "lsp" },
  filetypes = { "alang" },
})
vim.lsp.enable("archilang")
