---The extensions configuration file of the telescope plugin
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for telescope
M.config = function()
  qvim.integrations.telescope.extensions = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- extensions option configuration
      extensions = {
        "fzf-native",
        "lazy",
        "dap",
      },
    },
  }
end

---The extensions setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, extensions = pcall(reload, "extensions")
  if not status_ok then
    Log:warn(string.format("The extension '%s' could not be loaded.", extensions))
    return
  end

  local extension = qvim.integrations.telescope.extensions
  extensions.setup(extension.options)

  if extension.on_config_done then
    extension.on_config_done()
  end
end

return M
