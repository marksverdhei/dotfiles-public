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
          require("nvim-surround").setup({
              surrounds = {
                  ["="] = {
                      add = function()
                          if vim.bo.filetype == "python" then
                              return { { "f\"{" }, { "=}\"" } }
                          else
                              return { { "=" }, { "=" } }
                          end
                      end,
                  },
              },
          })
      end
  },
  -- Track the legacy `master` branch: it still ships the `configs` module
  -- (so NvChad v2.5 keeps working) but, unlike the old 2023 commit, it carries
  -- the treesitter-API compat fixes for Neovim 0.12. The old pin threw
  -- "decoration provider conceal_line: attempt to call method 'range' (nil)"
  -- on every redraw after the 0.11→0.12 upgrade. Run :TSUpdate after bumping.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "python", "bash", "markdown", "markdown_inline", "json", "yaml", "toml",
      })
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
    build = "make",  -- ⚠️ must add this line! ! !
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
        'MeanderingProgrammer/render-markdown.nvim',
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
