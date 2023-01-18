local utils = require("quantum.utils.util")
local integrations = {
  "quantum.integrations.vimnotify",
  "quantum.integrations.autopairs",
  "quantum.integrations.bufferline",
  "quantum.integrations.colorscheme",
  "quantum.integrations.comment",
  "quantum.integrations.gitsigns",
  "quantum.integrations.hop",
  "quantum.integrations.illuminate",
  "quantum.integrations.indentline",
  "quantum.integrations.lualine",
  "quantum.integrations.nvim-tree",
  "quantum.integrations.toggleterm",
  "quantum.integrations.treesitter",
  --"quantum.integrations.vimtex",
  "quantum.integrations.whichkey",
}

local M = {}
for i, module in ipairs(integrations) do
  utils:require_module(module)
end
