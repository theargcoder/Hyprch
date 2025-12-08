return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require "configs.dap" -- this line explicitly loads ~/.config/nvim/lua/configs/dap.lua
    end,
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "Toggle breakpoint" },
      { "<leader>dr", "<cmd>DapContinue<CR>", desc = "Start/Continue debugger" },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      handlers = {
        -- don't auto-setup codelldb
        ["codelldb"] = function() end,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio", -- required dependency
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePre", "BufNewFile" },
    config = function()
      require "configs.lint" -- this line explicitly loads ~/.config/nvim/lua/configs/lint.lua
    end,
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "biome",
        "clang-format",
        "clangd",
        "cmake-language-server",
        "cmakelang",
        "css-lsp",
        "html-lsp",
        "lua-language-server",
        "stylua",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c",
        "cpp",
        "java",
        "json",
      },
    },
  },
  -- Auto-fit NvimTree width to longest filename
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        adaptive_size = true, -- auto width based on longest filename
      },
      actions = {
        open_file = {
          resize_window = true, -- resize when opening files
        },
      },
    },
  },

  -- Bufferline: dynamic tab width based on filename length
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        tab_size = 0, -- auto width
        max_name_length = 60, -- optional safety cap
      },
    },
  },
}
