local M = {}

local Log = require "qvim.integrations.log"

---Populate the qvim.integrations table and defines how
---the table can be interacted with. And the following actions:
---- Runs a config method when the integration implements one.
---- A global function that returns the qvim.integrations table
---or a specific value when a key is specified
function M:init()
  local base = require("qvim.integrations.base")

  qvim.integrations = setmetatable({}, {
    __index = function(t, k)
      if k then
        local normalized_k = normalize(k)
        if t[normalized_k] then
          return t[normalized_k]
        else
          return nil
        end
      else
        return t
      end
    end,
    __newindex = function(t, k, v)
      rawset(t, normalize(k), v)
    end
  })

  for _, integration in ipairs(qvim_integrations()) do
    local _integration, instance = base:new(integration)
    qvim.integrations[integration] = _integration
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
end

return M
