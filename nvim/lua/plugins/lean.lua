return {
  {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    init = function()
      -- Keep editing available before the Lean toolchain is installed.
      local has_lean = vim.fn.executable "lean" == 1
      vim.g.lean_config = {
        mappings = true,
        lsp = { enable = has_lean },
        infoview = { autoopen = has_lean },
      }
    end,
  },
}
