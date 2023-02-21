local M = {}

local default_whichkey = {
    leader = nil,
    name = nil,
    bindings = {

    },
}

local Log = require "qvim.integrations.log"

---Create the base table for an integration
---@param config table
---@return table base_table
local function create_base_table(config)
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
    return base_table
end

---Create a new integration table with defaults and whatever
---an integration might implement.
---@param config_file string
---@return table|nil
function M:new(config_file)
    local status_ok, integration = pcall(require, "qvim.integrations." .. config_file)
    if not status_ok then
        Log:debug(string.format("No configuration file for plugin '%s'", config_file))
        return
    end

    local config = integration:init()
    local base_table = create_base_table(config)
    local obj = setmetatable({}, { __index = base_table })

    for key, value in pairs(config) do
        obj[key] = value
    end

    return obj
end

return M
