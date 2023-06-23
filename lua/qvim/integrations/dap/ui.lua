---The ui configuration file of the dap plugin
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for dap
function M:config()
  qvim.integrations.dap.ui = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
        -- ui option configuration

    },
  }
end

---The ui setup function. The module will be required by 
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, ui = pcall(reload, "ui")
  if not status_ok then
    Log:warn(string.format("The extension '%s' could not be loaded.", ui))
    return
  end

  local _dap_ui = qvim.integrations.dap.ui
  ui.setup(_dap_ui.options)

  if _dap_ui.on_config_done then
    _dap_ui.on_config_done()
  end
end

return M