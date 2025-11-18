-- lua/configs/lspconfig.lua

-- Load NvChad defaults
require("nvchad.configs.lspconfig").defaults()

-- NEW API (Neovim 0.11+)
-- No require("lspconfig").

vim.lsp.config.clangd = {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--clang-tidy-checks=clang-analyzer-*,bugprone-*,modernize-*,performance-*,readability-*,cppcoreguidelines-*,misc-*,cert-*,hicpp-*",
    "--background-index",
    "--all-scopes-completion",
    "--header-insertion=never",
    "--compile-commands-dir=build",
    "--offset-encoding=utf-8",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
  root_dir = vim.fs.root(0, { "compile_commands.json", ".clangd", ".clang-tidy", ".git" }),
}

-- enable servers
vim.lsp.enable { "clangd" }
