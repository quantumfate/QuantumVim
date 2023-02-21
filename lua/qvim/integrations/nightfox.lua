---The nightfox configuration file
local M = {}

local in_headless = #vim.api.nvim_list_uis() == 0
local Log = require "qvim.integrations.log"

---Registers the global configuration scope for nightfox
function M:init()
  local nightfox = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    supported_modules = nil,
    -- nightfox option configuration
    options = {
      transparent = false, -- Disable setting background
    },
  }

  return nightfox
end

---The nightfox setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, nightfox = pcall(reload, "nightfox")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", nightfox)
    return
  end

  local _nightfox = qvim.integrations.nightfox
  local modules = {}

  _nightfox.supported_modules = require("nightfox.config").module_names
  if _nightfox.supported_modules then
    for module, _ in pairs(_nightfox.supported_modules) do
      if qvim.integrations[module] and qvim.integrations[module].active then
        modules[modules + 1] = module
      end
    end

    _nightfox.options[#_nightfox.options + 1] = modules
  end

  nightfox.setup({ options = _nightfox.options })

  vim.cmd("colorscheme nightfox")

  if _nightfox.on_config_done then
    _nightfox.on_config_done()
  end
end

return M
