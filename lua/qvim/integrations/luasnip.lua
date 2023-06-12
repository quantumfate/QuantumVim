---The luasnip configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for luasnip
function M:init()
  local luasnip = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
        -- luasnip option configuration

    },
  }
  return luasnip
end

---The luasnip setup function. The module will be required by 
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, luasnip = pcall(reload, "luasnip")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", luasnip))
    return
  end

  local _luasnip = qvim.integrations.luasnip
  luasnip.setup(_luasnip.options)

  if _luasnip.on_config_done then
    _luasnip.on_config_done()
  end
end

return M