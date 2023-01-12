local status_ok, hop = pcall(require, "hop")
if not status_ok then
  return
end
--[[
--  
--  Author: Leon Connor Holm
--  Plugin: https://github.com/phaazon/hop.nvim
--  
--]]

hop.setup {
  keys = 'etovxqpdygfblzhckisuran'
}

-- Options to parse to a keymap
local opts = { 
  silent = true, 
  noremap=true,
  callback=nil,
  desc=nil,
}

local keymap = vim.api.nvim_set_keymap
local directions = require('hop.hint').HintDirection

local bindings = {
    { 
      mode = 'n',
      mapping = 'f', 
      desc = '',
      func = function() hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false }) end
    },
    { 
      mode = 'n', 
      mapping = 'F',
      desc = '',
      func = function() hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false }) end
    },
    {
      mode = 'n', 
      mapping = 't',
      desc = '',
      func = function() hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }) end
    },
    {
      mode = 'n', 
      mapping = 'T',
      desc = '',
      func = function() hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 }) end
    },
}


table.foreach(bindings, function(idx, binding) 
  opts.callback = binding.func
  opts.desc = binding.desc
  keymap(binding.mode, binding.mapping, '', opts)
end)


