local status_ok, hop = pcall(require, "hop")
if not status_ok then
  return
end

-- remap default vim bindings
local opts = { silent = true , noremap=false }
local keymap = vim.api.nvim_set_keymap
local directions = require('hop.hint').HintDirection
hop.setup {
  keys = 'etovxqpdygfblzhckisuran'
}
local directions = require('hop.hint').HintDirection
vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})
vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})
vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})
