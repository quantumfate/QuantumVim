---The copilot configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for copilot
function M:init()
    local copilot = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            -- copilot option configuration
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                    open = "<M-CR>",
                },
                layout = {
                    position = "bottom", -- | top | left | right
                    ratio = 0.4,
                },
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    accept = "<M-l>",
                    accept_word = false,
                    accept_line = false,
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            filetypes = {
                yaml = false,
                markdown = false,
                help = false,
                gitcommit = false,
                gitrebase = false,
                hgcommit = false,
                svn = false,
                cvs = false,
                ["."] = false,
            },
            copilot_node_command = "node", -- Node.js version must be > 16.x
            server_opts_overrides = {},
        },
    }
    return copilot
end

---The copilot setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    if in_headless_mode() then
        return
    end
    local status_ok, copilot = pcall(reload, "copilot")
    if not status_ok then
        Log:warn(string.format("The plugin '%s' could not be loaded.", copilot))
        return
    end

    local _copilot = qvim.integrations.copilot
    copilot.setup(_copilot.options)

    if _copilot.on_config_done then
        _copilot.on_config_done()
    end
end

return M
