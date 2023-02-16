---The hop configuration file
local M = {}

local utils = require "qvim.utils"
local Log = require "qvim.integrations.log"
local directions = require('hop.hint').HintDirection
---Registers the global configuration scope for hop
M.config = function()
  qvim.integrations.hop = {
    active = true,
    on_config_done = nil,
    keymaps = {

    },
    -- hop option configuration
    options = {
      keys = 'etovxqpdygfblzhckisuran',
      -- Options to parse to a keymap
      opts = {
        silent = true,
        noremap = true,
        callback = nil,
        desc = nil,
      },
      -- Hop bindings
      bindings = {
        {
          mode = 'n',
          mapping = 'f',
          desc = 'Jump anywhere after the selected cursor.',
          direction = directions.AFTER_CURSOR,
          current_line_only = false
        },
        {
          mode = 'n',
          mapping = 'F',
          desc = 'Jump anywhere before the selected cursor.',
          direction = directions.BEFORE_CURSOR,
          current_line_only = false
        },
        {
          mode = 'n',
          mapping = 't',
          desc = 'Jump after the selected cursor on the current line only.',
          direction = directions.AFTER_CURSOR,
          current_line_only = true,
          hint_offset = -1
        },
        {
          mode = 'n',
          mapping = 'T',
          desc = 'Jump before the selected cursor on the current line only.',
          direction = directions.BEFORE_CURSOR,
          current_line_only = true,
          hint_offset = 1
        }
      }
    },
  }
end

---The hop setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, hop = pcall(reload, "hop")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", hop)
    return
  end
  local _hop = qvim.integrations.hop
  local hop_keys = _hop.options.keys

  hop.setup { keys = hop_keys }

  print("hello hop")
  local keymap = vim.api.nvim_set_keymap

  local hop_bindings = _hop.options.bindings
  local hop_opts = _hop.options.opts

  for _, value in ipairs(hop_bindings) do
    if value.hint_offset then
      hop_opts.callback = function()
        hop.hint_char1({
          direction = value.direction,
          current_line_only = value.current_line_only,
          hint_offset = value.hint_offset
        })
      end
    else
      hop_opts.callback = function()
        hop.hint_char1({
          direction = value.direction,
          current_line_only = value.current_line_only,
        })
      end
    end
    hop_opts.desc = value.desc
    keymap(value.mode, value.mapping, '', hop_opts)
  end

  if _hop.on_config_done then
    _hop.on_config_done()
  end
end

return M
