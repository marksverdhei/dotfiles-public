return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
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
                          local config = require("nvim-surround.config")
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
  -- Pin treesitter to last version compatible with NvChad v2.5 (configs module removed after this)
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "310f0925ec64c7e54f3ee952679d285b13e5a735",
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
      providers = {
        -- OpenRouter - use :OpenRouterModels to dynamically switch models
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          api_key_name = "OPENROUTER_API_KEY",
          model = "anthropic/claude-sonnet-4",
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
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
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
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
