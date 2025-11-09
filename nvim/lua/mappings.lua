require "nvchad.mappings"

local map = vim.keymap.set

-- your existing example
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
