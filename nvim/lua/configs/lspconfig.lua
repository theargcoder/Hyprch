-- lua/configs/lspconfig.lua

-- Load NvChad defaults
require("nvchad.configs.lspconfig").defaults()

-- NEW API (Neovim 0.11+)
-- No require("lspconfig").

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--background-index",
    "--all-scopes-completion",
    "--compile-commands-dir=build",
    "--clang-tidy", -- STATIC ANALIZER
    "--completion-style=detailed", -- suggestions are detailed
    "--header-insertion=iwyu", -- for dinamic header adding
    "--header-insertion-decorators", -- for pseudo warn about completion without headers in file
    "--rename-file-limit=0", -- no limit
    "--log=error", -- no need to fill up the nvim log with ERRORS
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
  root_dir = vim.fs.root(0, { "compile_commands.json", ".clangd", ".clang-tidy", ".git" }),
}

vim.lsp.config.neocmake = {
  cmd = {
    "neocmakelsp",
    "stdio",
    init_options = {
      scan_cmake_in_package = true,
    },
  },
  filetypes = { "cmake" },
  root_dir = vim.fs.root(0, { ".git" }),
}

-- enable servers
vim.lsp.enable { "clangd", "neocmake", "bashls" }
