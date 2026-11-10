return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        surrounds = {
          ["="] = {
            add = function()
              if vim.bo.filetype == "python" then
                return { { 'f"{' }, { '=}"' } }
              else
                return { { "=" }, { "=" } }
              end
            end,
          },
        },
      }
    end,
  },
  -- nvim-treesitter `main` (the rewrite NvChad v2.5 now targets). Highlighting
  -- is started per buffer by NvChad's FileType autocmd (vim.treesitter.start);
  -- this spec only makes sure the parsers are installed. Needs the
  -- `tree-sitter` CLI (pacman: tree-sitter-cli).
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "python",
        "bash",
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "toml",
      })
    end,
    config = function(_, opts)
      -- Async; parsers that are already installed are skipped.
      require("nvim-treesitter").install(opts.ensure_installed)
    end,
  },

  -- Install LSP servers, formatters, linters and debuggers on startup, so a
  -- fresh machine gets the full toolchain without manual :MasonInstall.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- LSP
        "lua-language-server",
        "pyright",
        "ruff",
        "bash-language-server",
        "marksman",
        -- formatters / linters
        "stylua",
        "shfmt",
        "shellcheck", -- used by bash-language-server for diagnostics
        -- debuggers
        "debugpy",
      },
    },
    config = function(_, opts)
      local mti = require "mason-tool-installer"
      mti.setup(opts)
      -- The plugin's own run_on_start hook is a VimEnter autocmd, which has
      -- already fired by the time VeryLazy loads it, so trigger it here.
      mti.run_on_start()
    end,
  },
  -- Teaches lua_ls about the Neovim runtime, plugin APIs and this config's own
  -- modules (only when editing Lua).
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, 1, { name = "lazydev", group_index = 0 })
    end,
  },
  -- Name the <leader> groups in the which-key popup.
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = {
        { "<leader>a", group = "AI (Avante)" },
        { "<leader>d", group = "Debug / data / diagnostics" },
        { "<leader>m", group = "Markdown / shell" },
        { "<leader>s", group = "Toggles (secrets, ANSI)" },
        { "<leader>t", group = "Terminal / theme / telescope" },
      }
    end,
  },
  -- Python debugging. :DapContinue / :DapToggleBreakpoint etc.; uses the
  -- debugpy installed by mason-tool-installer above.
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapNew", "DapToggleRepl" },
    dependencies = { "mfussenegger/nvim-dap-python" },
    config = function()
      local debugpy = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(vim.uv.fs_stat(debugpy) and debugpy or "python3")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "nguyenvukhang/nvim-toggler",
    config = function()
      require("nvim-toggler").setup()
    end,
    lazy = false,
  },
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make", -- ⚠️ must add this line! ! !
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = "openrouter",
      -- Use dressing (a dep below) for prompts; the native input provider
      -- can't do concealed input, so the API-key login prompt errors without this.
      input = {
        provider = "dressing",
      },
      providers = {
        -- OpenRouter - use :OpenRouterModels to dynamically switch models
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "anthropic/claude-sonnet-5.5",
          timeout = 120000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8192,
          },
        },
      },
    },
    init = function()
      require("configs.openrouter").setup()
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- Optional deps: only the pickers/inputs this config actually uses
      "nvim-telescope/telescope.nvim", -- file_selector + :OpenRouterModels picker
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "stevearc/dressing.nvim", -- input provider (see `input` above)
      "nvim-tree/nvim-web-devicons",
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "laytan/cloak.nvim",
    lazy = false,
    opts = {
      enabled = true,
      cloak_character = "*",
      patterns = {
        { file_pattern = ".env*", cloak_pattern = "=.+" },
        { file_pattern = ".secret*", cloak_pattern = "=.+" },
        { file_pattern = ".credentials*", cloak_pattern = "=.+" },
      },
    },
    keys = {
      { "<leader>ss", "<cmd>CloakToggle<cr>", desc = "Toggle secret cloaking" },
    },
  },
}
