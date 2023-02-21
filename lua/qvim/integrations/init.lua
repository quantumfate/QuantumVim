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

function M:init()
  local base = require("qvim.integrations.base")
  for _, integration in ipairs(integrations) do
    local _integration = base:new(integration)
    qvim[integration] = _integration
  end
end

return M
