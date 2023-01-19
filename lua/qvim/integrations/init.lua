local utils = require("qvim.utils.util")
local integrations = {
  "qvim.integrations.vimnotify",
  "qvim.integrations.autopairs",
  "qvim.integrations.bufferline",
  "qvim.integrations.colorscheme",
  "qvim.integrations.comment",
  "qvim.integrations.gitsigns",
  "qvim.integrations.hop",
  "qvim.integrations.illuminate",
  "qvim.integrations.indentline",
  "qvim.integrations.lualine",
  "qvim.integrations.nvim-tree",
  "qvim.integrations.toggleterm",
  "qvim.integrations.treesitter",
  --"qvim.integrations.vimtex",
  "qvim.integrations.whichkey",
}

local M = {}
for i, module in ipairs(integrations) do
  utils:require_module(module)
end
