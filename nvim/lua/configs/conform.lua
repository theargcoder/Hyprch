local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    json = { "biome" },
    javascript = { "biome" },
    typescript = { "biome" },
    jsonc = { "biome" },
    bash = { "beautysh" },
    csh = { "beautysh" },
    ksh = { "beautysh" },
    sh = { "beautysh" },
    zsh = { "beautysh" },
    --cmake = { "cmake_format" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 5000,
    lsp_fallback = true,
  },
}

return options
