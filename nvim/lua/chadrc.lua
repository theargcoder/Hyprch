-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "gatekeeper",

  hl_override = {
    ---------------------- comments --------------------------------
    ["@comment"] = { fg = "#4a4a4a", italic = true },
    ---------------------- visual mode --------------------------------
    Visual = { bg = "#0c313d" },
    VisualNOS = { bg = "#0c313d" },

    -------------------- line and cursor ------------------------------
    LineNr = { fg = "#4a4a4a", bg = nil, italic = true, bold = false },
    CursorLineNr = { fg = "#ffad41", bg = nil, italic = true, bold = true },

    ------------------ class, variables, etc----------------------------
    Character = { fg = "#afafff" },
    Constant = { fg = "#faadf9" },
    Number = { fg = "#bdd99d" },
    Boolean = { fg = "#cad95d", italic = true, bold = true },
    Float = { fg = "#fad95d" },
    Conditional = { fg = "#3fddee" },
    Statement = { fg = "#2fff9d" },
    Repeat = { fg = "#fffffd" },
    Label = { fg = "#70429f" },
    Operator = { fg = "#70429f" },
    Keyword = { fg = "#daadf0" },
    Exception = { fg = "#ff6050" },
    Include = { fg = "#c54bcf" },
    PreProc = { fg = "#bb762a" },
    Define = { fg = "#c54bcf" },
    Macro = { fg = "#2390af" },
    PreCondit = { fg = "#df6a69" },
    StorageClass = { fg = "#be620a" },
    Structure = { fg = "#0fd0ad" },
    Typedef = { fg = "#c54bcf" },
    Type = { fg = "#2380af" },
    Identifier = { fg = "#ff0000" },
    Tag = { fg = "#fffffd" },
    Special = { fg = "#29adff" },
    SpecialChar = { fg = "#29adff" },
    SpecialComment = { fg = "#29adff" },

    ------------------- LSP stuff --------------------------------------
    ["@keyword"] = { fg = "#ff4394" },
    ["@keyword.repeat"] = { fg = "#ff4394" },
    ["@keyword.conditional"] = { fg = "#ff4394" },
    ["@keyword.exception"] = { fg = "#ff4394" },

    ["@keyword.directive"] = { fg = "#c54bcf" },
    ["@attribute"] = { fg = "#c54bcf" },

    ["@type.builtin"] = { fg = "#be620a", italic = true },

    ["@variable.parameter"] = { fg = "#cccdd1" },

    ["@module"] = { fg = "#c31d1d" },
    ["@variable"] = { fg = "#e6ae2d" },
    ["@property"] = { fg = "#65def1" },

    --["@function"] = { fg = "#5ae453" },
    -- ["@function"] = { fg = "#d3ff72" },
    ["@constructor"] = { fg = "#c54bcf" },
    ["@function"] = { fg = "#c54bcf" },
    ["@function.method"] = { fg = "#c54bcf" },
    ["@function.method.call"] = { fg = "#c54bcf" },
  },
}

-------------------------LSP stuff -------------------------------
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {
  fg = "#db302d",
  bg = "#570f0e",
  italic = false,
  bold = false,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", {
  fg = "#b28500",
  bg = "#332700",
  italic = false,
  bold = false,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", {
  fg = "#268bd3",
  bg = "#0f2856",
  italic = false,
  bold = false,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", {
  fg = "#29a298",
  bg = "#103a3c",
  italic = false,
  bold = false,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualText", {
  fg = "#b28500",
  bg = "#332700",
  italic = false,
  bold = false,
})

vim.api.nvim_set_hl(0, "DiagnosticVirtualText", {
  fg = "#b28500",
  bg = "#332700",
  italic = false,
  bold = false,
})

M.nvdash = { load_on_startup = true }

-- M.mappings = require "custom.dap-mappings"

M.ui = {
  tabufline = {
    lazyload = false,
  },
}

return M
