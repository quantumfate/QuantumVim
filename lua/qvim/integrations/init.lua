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
  qvim.integrations = {}
  local base = require("qvim.integrations.base")
  for _, integration in ipairs(integrations) do
    local this = integration
    local _integration = base:new(this)
    this = string.gsub(this, "-", "_") -- hyphons are not allowed
    qvim.integrations[this] = _integration
  end
end

return M
