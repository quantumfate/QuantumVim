vim.cmd [[
try
  colorscheme tokyonight
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]

vim.g.tokyonight_style = "storm"
vim.g.tokyonight_terminal_colors = true
vim.g.tokyonight_italic_comments = true
vim.g.tokyonight_hide_inactive_statusline = true
vim.g.tokyonight_sidebars = {"NvimTree"}
vim.g.tokyonight_dark_float = true

