---The nightfox configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for nightfox
M.config = function()
  qvim.integrations.nightfox = {
    active = true,
    on_config_done = nil,
    keymaps = { },
    options = {
        -- nightfox option configuration

    },
  }
end

---The nightfox setup function. The module will be required by 
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, nightfox = pcall(reload, "nightfox")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", nightfox)
    return
  end

  nightfox.setup(qvim.integrations.nightfox.options)

  if qvim.integrations.nightfox.on_config_done then
    qvim.integrations.nightfox.on_config_done()
  end
end

return M