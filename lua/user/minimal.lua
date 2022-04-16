vim.o.packpath = '/tmp/nvim/site'

local plugins = {
  gitsigns = 'https://github.com/lewis6991/gitsigns.nvim',
  quantumvim = 'https://github.com/quantumfate/quantumvim.git',
  -- ADD OTHER PLUGINS _NECESSARY_ TO REPRODUCE THE ISSUE
}

for name, url in pairs(plugins) do
  local install_path = '/tmp/nvim/site/pack/test/start/'..name
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { 'git', 'clone', '--depth=1', url, install_path }
  end
end

require('gitsigns').setup{
  debug_mode = true, -- You must add this to enable debug messages
  -- ADD GITSIGNS CONFIG THAT IS _NECESSARY_ FOR REPRODUCING THE ISSUE
}

-- ADD INIT.LUA SETTINGS THAT IS _NECESSARY_ FOR REPRODUCING THE ISSUE
require "plugins"
require "keymap"
require "colorscheme"
require "options"
require "lsp"
require "nvim-cmp"
require "bufferline"
require "treesitter"
require('lualine').setup()
require "autopairs"

