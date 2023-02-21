local M = {}

local Log = require "qvim.integrations.log"
local integrations = {
  "alpha",
  "telescope",
  "hop",
  "autopairs",
  "bufferline",
  "illuminate",
  "lualine",
  "nvim-tree",
  "nightfox",
  "treesitter",
  "indentline",
  "notify",
  "toggleterm",
  "gitsigns",
  "comment",
  "whichkey",
  "vimtex"
}

---Populate the qvim.integrations table. Runs a config method if the plugin has one.
function M:init()
  qvim.integrations = {}
  local base = require("qvim.integrations.base")
  for _, integration in ipairs(integrations) do
    local _integration, instance = base:new(integration)
    integration = string.gsub(integration, "-", "_") -- hyphons are not allowed
    qvim.integrations[integration] = _integration
    if instance ~= nil and instance.config then
      instance:config()
    end
  end
end

return M
