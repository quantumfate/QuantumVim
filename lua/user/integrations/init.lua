local utils = require("user.utils.util")
local integrations = {
  "user.integrations.vimnotify",
  "user.integrations.autopairs",
  "user.integrations.bufferline",
  "user.integrations.colorscheme",
  "user.integrations.comment",
  "user.integrations.gitsigns",
  "user.integrations.hop",
  "user.integrations.illuminate",
  "user.integrations.indentline",
  "user.integrations.lualine",
  "user.integrations.nvim-tree",
  "user.integrations.toggleterm",
  "user.integrations.treesitter",
  --"user.integrations.vimtex",
  "user.integrations.whichkey",
}

local M = {}
for i, module in ipairs(integrations) do
  utils:require_module(module)
end
