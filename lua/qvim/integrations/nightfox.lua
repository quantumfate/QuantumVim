---The nightfox configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for nightfox
M.config = function()
  qvim.integrations.nightfox = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    supported_modules = nil,
    -- nightfox option configuration
    options = {
      transparent = false, -- Disable setting background
    },
  }

  qvim.integrations.nightfox = require("nightfox.config").module_names
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

  local _nightfox = qvim.integrations.nightfox
  local supported_modules = _nightfox.supported_modules
  print(_nightfox)
  local modules = {}

  if supported_modules then
    for module, _ in pairs(supported_modules) do
      if qvim.integrations[module] and qvim.integrations[module].active then
        modules[modules + 1] = module
      end
    end

    _nightfox.options[#_nightfox.options + 1] = modules
  end

  nightfox.setup({ options = _nightfox.options })

  print("DO I even get here")
  vim.cmd("colorscheme nightfox")

  if _nightfox.on_config_done then
    _nightfox.on_config_done()
  end
end

return M
