---The dbsession configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for dbsession
M.config = function()
  qvim.integrations.dbsession = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      dir = join_paths(get_cache_dir(), "session")
      -- dbsession option configuration
    },
  }
end

---The dbsession setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, dbsession = pcall(reload, "dbsession")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", dbsession)
    return
  end

  local _dbsession = qvim.integrations.dbsession
  dbsession.setup(_dbsession.options)

  if _dbsession.on_config_done then
    _dbsession.on_config_done()
  end
end

return M
