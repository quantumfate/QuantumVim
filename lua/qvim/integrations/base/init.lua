local M = {}

local default_whichkey = {
    leader = nil,
    name = nil,
    bindings = {

    },
}

local Log = require "qvim.integrations.log"

---Create a new integration table with defaults and whatever
---an integration might implement.
---@param integration string
---@return table|nil
function M:new(integration)
    local status_ok, config = pcall(require, "qvim.integrations." .. integration)
    if not status_ok then
        Log:debug(string.format("No configuration file for plugin '%s'", integration))
        return
    end

    local enabled = true
    if type(config.active) == "boolean" then
        enabled = config.active
    end

    local base_table = {
        active = enabled,
        on_config_done = config.on_config_done or nil,
        whichkey = config.whichkey or default_whichkey,
        keymaps = config.keymaps or {},
        options = config.options or {},
    }

    local obj = setmetatable({}, { __index = base_table })

    for key, value in pairs(config) do
        obj[key] = value
    end

    return obj
end

return M
