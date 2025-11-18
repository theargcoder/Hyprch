local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "biome" },
    javascript = { "biome" },
    typescript = { "biome" },
    jsonc = { "biome" },
    bash = { "beautysh" },
    csh = { "beautysh" },
    ksh = { "beautysh" },
    sh = { "beautysh" },
    zsh = { "beautysh" },
    cmake = { "cmake-format" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2500,
    lsp_fallback = true,
  },
}

return options
