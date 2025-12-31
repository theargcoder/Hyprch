require "nvchad.mappings"

local is_cyan = false

local function toggle_linenr_color()
  if is_cyan then
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#4a4a4a", bg = nil, italic = true, bold = false })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#4a4a4a", bg = nil, italic = true })
    print "LineNr: Grey"
  else
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#527542", bg = nil, italic = true, bold = true })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#527542", bg = nil, italic = true })
    print "LineNr: VsCode"
  end
  is_cyan = not is_cyan
end

local map = vim.keymap.set

-- your existing example
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Add this line to map Code Actions to <leader>ca
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })

map("n", "<leader>tc", toggle_linenr_color, { desc = "Toggle LineNr Color" })
