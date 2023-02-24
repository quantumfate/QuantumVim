local M = {}
local Log = require "qvim.integrations.log"
local fn = require("qvim.utils.fn")

---Populate the qvim.integrations table and defines how
---the table can be interacted with. And the following actions:
---- Runs a config method when the integration implements one.
---- A global function that returns the qvim.integrations table
---or a specific value when a key is specified
function M:init()
  local autocmds = require "qvim.integrations.autocmds"
  autocmds.load_defaults()

  local base = require("qvim.integrations.base")

  qvim.integrations = setmetatable({}, {
    __index = function(t, k)
      return fn.rawget_debug(t, k, "qvim integrations")
    end,
    __newindex = function(t, k, v)
      return fn.rawset_debug(t, fn.normalize(k), v, "qvim integrations")
    end
  })

  for _, name in ipairs(qvim_integrations()) do
    local obj, instance = base:new(name)

    qvim.integrations[name] = obj
    if instance ~= nil and instance.config then
      instance:config()
    end
  end


  ---Returns a table with configured integrations or
  ---a table of a specific integration when specified.
  ---Integrations with hyphons will automatically
  ---translated to underscores.
  ---@param integration string?
  ---@return table integrations
  function _G.qvim_configured_integrations(integration)
    return qvim.integrations[integration]
  end

  Log:info("Integrations were loaded.")
end

return M
