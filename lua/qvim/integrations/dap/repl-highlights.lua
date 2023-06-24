---The repl-highlights configuration file of the dap plugin
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for dap
function M:config()
  qvim.integrations.dap.repl_highlights = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
        -- repl_highlights option configuration

    },
  }
end

---The repl-highlights setup function. The module will be required by 
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, repl_highlights = pcall(reload, "repl-highlights")
  if not status_ok then
    Log:warn(string.format("The extension '%s' could not be loaded.", repl_highlights))
    return
  end

  local _dap_repl_highlights = qvim.integrations.dap.repl_highlights
  repl_highlights.setup(_dap_repl_highlights.options)

  if _dap_repl_highlights.on_config_done then
    _dap_repl_highlights.on_config_done()
  end
end

return M