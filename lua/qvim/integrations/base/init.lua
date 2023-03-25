local M = {}

local meta = require("qvim.integrations.meta")
local keymap_meta = require("qvim.keymaps.meta.keymap")
local Log = require "qvim.integrations.log"

--- Create the base table for an integration with the `keymap_meta.mt` and populates
--- the table with additionally defined options from a given `config`.
---@param config table
---@return table base_table
local function create_base_table(config)
    local enabled = true
    if type(config.active) == "boolean" then
        enabled = config.active
    end

    local opts = setmetatable(
        {
            active = enabled,
            on_config_done = config.on_config_done,
            keymaps = setmetatable(config.keymaps, keymap_meta.mt),
            options = config.options
        },
        meta.integration_opts_mt)

    for option, value in pairs(config) do
        opts[option] = value
    end
    return opts
end

-- Create a new integration table with defaults and whatever
-- an integration might implement.
---@param config_file string
---@return table? base_table the table to be bound to the configuration table
---@return table? instance instance to the integration
function M:new(config_file)
    local status_ok, instance = pcall(require, "qvim.integrations." .. config_file)
    if not status_ok then
        Log:debug(string.format("No configuration file for plugin '%s'", config_file))
        return
    end

    local config = instance:init()

    return create_base_table(config), instance
end

return M
