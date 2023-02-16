---The telescope configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for telescope
M.config = function()
  qvim.integrations.telescope = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- telescope option configuration

    },
  }

  require("qvim.integrations.telescope.extensions").config()
end

---The telescope setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, telescope = pcall(reload, "telescope")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", telescope))
    return
  end

  local integration = qvim.integrations.telescope
  telescope.setup(integration.options)
  for _, value in ipairs(integration.extensions) do
    telescope.load_extension(value)
  end


  if integration.on_config_done then
    integration.on_config_done()
  end
end

return M
