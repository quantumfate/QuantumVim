---The notify configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for notify
M.config = function()
  qvim.integrations.notify = {
    active = true,
    on_config_done = function(notify)
      vim.notify = notify
    end,
    keymaps = {},
    options = {
      -- notify option configuration
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "",
        WARN = "",
        OFF = "",
      }
    },
  }
end

---The notify setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, notify = pcall(reload, "notify")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", notify))
    return
  end

  local _notify = qvim.integrations.notify
  notify.setup(_notify.options)

  if _notify.on_config_done then
    _notify.on_config_done(notify)
  end
end

return M
