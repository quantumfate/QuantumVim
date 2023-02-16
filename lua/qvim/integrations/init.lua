local M = {}

local Log = require "qvim.integrations.log"
local integrations = {
  "qvim.integrations.dashboard",
  "qvim.integrations.dbsession",
  "qvim.integrations.telescope",
  --"qvim.integrations.vimnotify",
  --"qvim.integrations.autopairs",
  --"qvim.integrations.bufferline",
  --"qvim.integrations.colorscheme",
  --"qvim.integrations.comment",
  --"qvim.integrations.gitsigns",
  "qvim.integrations.hop",
  "qvim.integrations.autopairs",
  "qvim.integrations.bufferline",
  "qvim.integrations.illuminate",
  --"qvim.integrations.indentline",
  "qvim.integrations.lualine",
  "qvim.integrations.nvim-tree",
  --"qvim.integrations.toggleterm",
  --"qvim.integrations.treesitter",
  --"qvim.integrations.vimtex",
  --"qvim.integrations.whichkey",
  "qvim.integrations.nightfox"
}

function M:init()
  for _, integration_path in ipairs(integrations) do
    local integration = reload(integration_path)

    if integration.config then
      integration.config()
    else
      Log:warn(string.format("The integration '%s' does not implement a config function.", integration))
    end
  end
end

return M
