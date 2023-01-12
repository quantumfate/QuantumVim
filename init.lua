require "user.plugins"
require "user.impatient"
require "user.keymap"
require "user.options"
require "user.illuminate"
require "user.hop"
if vim.g.vscode then
  -- VSCode extension
  require "user.vscode"
else
  require "user.alpha"
  require "user.comment"
  require "user.colorscheme"
  require "user.languages"
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
  require "user.vimtex"
--  require "user.whichkey"  
end






