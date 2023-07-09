---The rainbow configuration file of the treesitter plugin
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for treesitter
function M:config()
    qvim.integrations.treesitter.rainbow = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            -- rainbow option configuration
            enable = true,
            -- list of languages you want to disable the plugin for
            disable = {},
            -- Which query to use for finding delimiters
            query = "rainbow-parens",
            -- Highlight the entire buffer all at once
            strategy = require("ts-rainbow").strategy.global,
        },
    }
end

return M
