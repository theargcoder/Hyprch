-- Load NvChad defaults
require("nvchad.configs.lspconfig").defaults()

-- Define servers
local servers = { "clangd", "cmake" }

-- Enable servers with custom opts
vim.lsp.enable(servers, {
  clangd = {
    cmd = { "clangd", "--offset-encoding=utf-16" },
  },
})
