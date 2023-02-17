local M = {}

local Log = require "qvim.integrations.log"
local integrations = {
  "dashboard",
  "dbsession",
  "telescope",
  "hop",
  "autopairs",
  "bufferline",
  "illuminate",
  "lualine",
  "nvim-tree",
  "nightfox",
  "treesitter"
}

function M:init()
  for _, integration in ipairs(integrations) do
    local _integration = reload("qvim.integrations." .. integration)

    if _integration.init then
      _integration.init()
    end

    if _integration.config then
      _integration.config()
    end

    if not _integration.config and not _integration.init then
      Log:warn(string.format("The integration '%s' does not implement a config function.", integration))
    end
  end
end

return M
