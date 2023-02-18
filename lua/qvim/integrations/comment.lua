---The comment configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for comment
M.config = function()
  qvim.integrations.comment = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- comment option configuration
      pre_hook = function(ctx)
        local U = require "Comment.utils"

        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return require("ts_context_commentstring.internal").calculate_commentstring {
          key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
          location = location,
        }
      end,
      opleader = {
        line = "gc",
        block = "gb",
      },
      mappings = {
        ---Operator-pending mapping
        ---Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
        ---NOTE: These mappings can be changed individually by `opleader` and `toggler` config
        basic = true,
        ---Extra mapping
        ---Includes `gco`, `gcO`, `gcA`
        extra = true,
        ---Extended mapping
        ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
        extended = false,
      },
    },
  }
end

---The comment setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, comment = pcall(reload, "comment")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", comment))
    return
  end

  local _comment = qvim.integrations.comment
  comment.setup(_comment.options)

  if _comment.on_config_done then
    _comment.on_config_done()
  end
end

return M
