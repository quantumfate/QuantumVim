---The tree-sitter configuration file
local M = {}

local utils = require "qvim.utils"
local Log = require "qvim.utils.log"

---Registers the global configuration scope for tree-sitter
M.config = function()
  qvim.integrations.tree_sitter = {
    active = true,
    on_config_done = nil,
    options = {
        -- tree_sitter option configuration

    },
  }
end

---The QV_NAME_OF_PLUGIN setup function. The module will be required by 
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, tree_sitter = pcall(reload, "tree-sitter")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", tree_sitter)
    return
  end

  tree_sitter.setup(qvim.integrations.tree_sitter.options)

  if qvim.integrations.tree_sitter.on_config_done then
    qvim.integrations.tree_sitter.on_config_done()
  end
end

return M