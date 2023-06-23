---The dap configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for dap
function M:init()
  local dap = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- dap option configuration

    },
  }
  return dap
end

function M:config()
  -- dap config function to call additional configs
end

---The dap setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_mason_dap, mason_dap = pcall(require, "mason-nivm-dap")
  if not status_mason_dap then
    return
  end
  local status_ok, dap = pcall(reload, "dap")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", dap))
    return
  end

  local _dap = qvim.integrations.dap
  dap.setup(_dap.options)

  if _dap.on_config_done then
    _dap.on_config_done()
  end
end

return M
