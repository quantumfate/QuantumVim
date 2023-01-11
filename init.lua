require "user.plugins"
require "user.impatient"
require "user.keymap"
require "user.options"
require "user.quickscope"
require "user.illuminate"
if vim.g.vscode then
  -- VSCode extension
  require "user.vscode"
else
  require "user.nvim-easymotion"
  require "user.alpha"
  require "user.comment"
  require "user.colorscheme"
  require "user.lsp"
  require "user.nvim-cmp"
  require "user.lang"
  require "user.telescope"
  require "user.bufferline"
  require "user.nvim-tree"
  require "user.treesitter"
  require "user.lualine"
  require "user.toggleterm"
  require "user.autopairs"
  require "user.gitsigns"
  require "user.bufferline"
  require "user.indentline"
--  require "user.whichkey"  
end






