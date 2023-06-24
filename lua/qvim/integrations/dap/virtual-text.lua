---The virtual-text configuration file of the dap plugin
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for dap
function M:config()
  qvim.integrations.dap.virtual_text = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- virtual_text option configuration

    },
  }
end

---The virtual-text setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, virtual_text = pcall(reload, "nvim-dap-virtual-text")
  if not status_ok then
    Log:warn(string.format("The extension '%s' could not be loaded.", virtual_text))
    return
  end

  local _dap_virtual_text = qvim.integrations.dap.virtual_text
  virtual_text.setup(_dap_virtual_text.options)

  if _dap_virtual_text.on_config_done then
    _dap_virtual_text.on_config_done()
  end
end

return M
