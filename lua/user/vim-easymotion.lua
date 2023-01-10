-- Require the wrapper
local vim = require "user.utils.nvim-api"

local vg = vim.g
-- easymotion options
vg.EasyMotion_smartcase = 1 -- This setting makes EasyMotion work similarly to Vim's smartcase option for global searches.
vg.EasyMotion_startofline = 0 -- keep cursor column when JK motion
vg.EasyMotion_do_mapping = 0 -- Disable default mappings
vg.EasyMotion_use_upper= 1 -- Use uppercase target labels and type as a lower case
vg.EasyMotion_use_smartsign_us = 1 -- Smartsign (type `3` and match `3`&`#`) - US layout

-- remap default vim bindings
local opts = { noremap = false, silent = true }
local keymap = vim.api.nvim_set_keymap

vim.g.mapleader = "g"
vim.g.maplocalleader = "g"
-- VSCODE specific bindings
-- Easy motion on default l,j,k,h
keymap("n", "<Leader>l", "<Plug>(easymotion-lineforward)", opts)
keymap("n", "<Leader>j", "<Plug>(easymotion-j)", opts)
keymap("n", "<Leader>k", "<Plug>(easymotion-k)", opts)
keymap("n", "<Leader>h", "<Plug>(easymotion-linebackward)", opts)
-- remap default vim searches
keymap("n", "/", "<Plug>(easymotion-sn)", opts)
keymap("o", "/", "<Plug>(easymotion-tn)", opts)

-- Adcanced n and N search navigation
keymap("n", "n", "<Plug>(easymotion-next)", opts)
keymap("n", "N", "<Plug>(easymotion-prev)", opts)
