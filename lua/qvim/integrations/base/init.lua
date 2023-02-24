local M = {}

local meta = require("qvim.integrations.base.meta")
local Log = require "qvim.integrations.log"

--- Create the base table for an integration
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
        whichkey_group = config.whichkey_group or {},
        whichkey = config.whichkey or {},
        keymaps = config.keymaps or {},
        options = config.options or {},
    }
    return base_table
end

-- Create a new integration table with defaults and whatever
-- an integration might implement.
---@param config_file string
---@return table? obj
---@return table? instance instance to the integration
function M:new(config_file)
    local status_ok, instance = pcall(require, "qvim.integrations." .. config_file)
    if not status_ok then
        Log:debug(string.format("No configuration file for plugin '%s'", config_file))
        return
    end

    local config = instance:init()
    local obj = setmetatable({}, meta.base_meta_table)
    local base_table = create_base_table(config)
    obj = setmetatable(obj, { __index = base_table })

    for key, value in pairs(config) do
        obj[key] = value
    end

    return obj, instance
end

return M
