local M = {}

local Log = require "qvim.integrations.log"

---Populate the qvim.integrations table. Runs a config method if the plugin has one.
function M:init()
  qvim.integrations = {}
  local base = require("qvim.integrations.base")
  for _, integration in ipairs(qvim_integrations()) do
    local _integration, instance = base:new(integration)
    integration = string.gsub(integration, "-", "_") -- hyphons are not allowed
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
