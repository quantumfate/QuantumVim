local M = {}

local Log = require "qvim.integrations.log"

---Populate the qvim.integrations table. Runs a config method if the plugin has one.
function M:init()
  local base = require("qvim.integrations.base")

  qvim.integrations = setmetatable({}, {
    __newindex = function(t, k, v)
      local integration = k:gsub("-", "_")
      rawset(t, integration, v)
    end
  })

  for _, integration in ipairs(qvim_integrations()) do
    local _integration, instance = base:new(integration)
    qvim.integrations[integration] = _integration
    if instance ~= nil and instance.config then
      instance:config()
    end
  end

  ---Returns a table with configured integrations
  ---@return table integrations
  function _G.qvim_configured_integrations()
    return qvim.integrations
  end
end

return M
