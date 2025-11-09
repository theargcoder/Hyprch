local dap = require "dap"
local dapui = require "dapui"
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- =======================
-- Adapter & configurations
-- =======================
dap.adapters.codelldb = {
  type = "executable",
  command = "/home/lucca/.local/share/nvim/mason/packages/codelldb/codelldb",
}

dap.configurations.cpp = {
  {
    name = "Launch Temp",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

dap.configurations.c = dap.configurations.cpp

-- =======================
-- Custom highlight & signs
-- =======================
vim.api.nvim_set_hl(0, "DapBreakpointRed", { fg = "#FF2244", bold = true })

vim.fn.sign_define("DapBreakpoint", {
  text = "●",
  texthl = "DapBreakpointRed",
  linehl = "",
  numhl = "DapBreakpointRed",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "◆",
  texthl = "Comment",
  linehl = "",
  numhl = "Error",
})

vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "String",
  linehl = "Visual",
  numhl = "String",
})

vim.fn.sign_define("DapLogPoint", {
  text = "■",
  texthl = "Comment",
  linehl = "",
  numhl = "",
})

-- =======================
-- Debug mode state
-- =======================
_G.debug_mode_active = false

-- store key strings for debug mode
local debug_mode_keys = {}

function _G.debug_mode_enable()
  if _G.debug_mode_active then
    return
  end
  _G.debug_mode_active = true
  print "DEBUG MODE ON"

  debug_mode_keys = {
    n = "n",
    i = "i",
    o = "o",
    c = "c",
    r = "r",
    q = "q",
    b = "b",
  }

  -- remap stepping keys to intuitive keys
  map("n", debug_mode_keys.n, dap.step_over, { desc = "Debug: Step over", noremap = true, silent = true })
  map("n", debug_mode_keys.i, dap.step_into, { desc = "Debug: Step into", noremap = true, silent = true })
  map("n", debug_mode_keys.o, dap.step_out, { desc = "Debug: Step out", noremap = true, silent = true })
  map("n", debug_mode_keys.c, dap.run_to_cursor, { desc = "Debug: Run to cursor", noremap = true, silent = true })
  map("n", debug_mode_keys.r, dap.restart, { desc = "Debug: Restart session", noremap = true, silent = true })
  map("n", debug_mode_keys.q, dap.terminate, { desc = "Debug: Terminate session", noremap = true, silent = true })
  map(
    "n",
    debug_mode_keys.b,
    dap.toggle_breakpoint,
    { desc = "Debug: Toggle breakpoint", noremap = true, silent = true }
  )
end

function _G.debug_mode_disable()
  if not _G.debug_mode_active then
    return
  end
  _G.debug_mode_active = false
  print "DEBUG MODE OFF"

  -- unmap the debug-mode keys properly
  for _, key in pairs(debug_mode_keys) do
    vim.keymap.del("n", key)
  end
  debug_mode_keys = {}
end

-- =======================
-- Core DAP keybindings
-- =======================
map("n", "<leader>dr", function()
  dap.continue()
  _G.debug_mode_enable()
end, { desc = "Debug: Start / Continue", noremap = true, silent = true })

map("n", "<leader>du", function()
  dapui.toggle()
  _G.debug_mode_disable()
end, { desc = "Debug: Toggle UI / Disable debug mode", noremap = true, silent = true })

map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint", noremap = true, silent = true })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "Debug: Conditional breakpoint", noremap = true, silent = true })
map("n", "<leader>dp", dap.pause, { desc = "Debug: Pause", noremap = true, silent = true })
map("n", "<leader>dq", dap.terminate, { desc = "Debug: Terminate session", noremap = true, silent = true })

-- =======================
-- DAP UI keybindings
-- =======================
dapui.setup()
map("n", "<leader>ds", function()
  dapui.toggle "scopes"
end, { desc = "Debug UI: Toggle scopes", noremap = true, silent = true })
map("n", "<leader>dbp", function()
  dapui.toggle "breakpoints"
end, { desc = "Debug UI: Toggle breakpoints", noremap = true, silent = true })
map("n", "<leader>dst", function()
  dapui.toggle "stacks"
end, { desc = "Debug UI: Toggle stacks", noremap = true, silent = true })
map("n", "<leader>dw", function()
  dapui.toggle "watches"
end, { desc = "Debug UI: Toggle watches", noremap = true, silent = true })

-- =======================
-- Auto enable/disable debug mode on DAP events
-- =======================
dap.listeners.after.event_initialized["my_debug_mode"] = function()
  _G.debug_mode_enable()
end

dap.listeners.before.event_terminated["my_debug_mode"] = function()
  _G.debug_mode_disable()
end

dap.listeners.before.event_exited["my_debug_mode"] = function()
  _G.debug_mode_disable()
end
