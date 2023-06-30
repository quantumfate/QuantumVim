---The swenv configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for swenv
function M:init()
  local swenv = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- swenv option configuration
      get_venvs = function(venvs_path)
        return require('swenv.api').get_venvs(venvs_path)
      end,
      -- Path passed to `get_venvs`.
      venvs_path = vim.fn.expand('~/venvs'),
      -- Something to do after setting an environment, for example call vim.cmd.LspRestart
      post_set_venv = function()
        return vim.cmd.LspRestart
      end,
    },
  }
  return swenv
end

---The swenv setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, swenv = pcall(reload, "swenv")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", swenv))
    return
  end

  local _swenv = qvim.integrations.swenv
  swenv.setup(_swenv.options)

  if _swenv.on_config_done then
    _swenv.on_config_done()
  end
end

return M
