require "user.plugins"
require "user.impatient"
require "user.keymap"
require "user.options"
require "user.comment"
require "user.vim-easymotion"
require "user.quickscope"
if (vim.g.vscode) then
    -- VSCode extension
  require "user.vscode"
    -- map keyboard quickfix
else
  require'alpha'.setup(require'alpha.themes.startify'.config)
  require "user.which-key"  
  require "user.colorscheme"
  require "user.lsp"
  require "user.nvim-cmp"
  require "user.bufferline"
  require "user.treesitter"
  require "user.lualine"
  require "user.autopairs"
  require "user.gitsigns"
  require "user.bufferline"
  require "user.nvim-tree"

end






