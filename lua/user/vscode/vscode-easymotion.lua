local status_ok, hop = pcall(require, "hop")
if not status_ok then
  return
end


local vg = vim.g
-- remap default vim bindings
local opts = { silent = true , noremap=false }
local keymap = vim.api.nvim_set_keymap
local directions = require('hop.hint').HintDirection
local after_cursor = directions.AFTER_CURSOR, current_line_only = true }
hop.setup {
  keys = 'etovxqpdygfblzhckisuran'
}
local directions = require('hop.hint').HintDirection
keymap("n", "<leader>w", ":call HopWord<CR>", opts)
keymap("n", "<leader>W", ":call HopWordMW<CR>", opts)
keymap("n", "f", ":call HopChar1(" .. after_cursor ..")<CR>", opts)
keymap("n", "F", ":call HopChar1CurrentLine<CR>", opts)
