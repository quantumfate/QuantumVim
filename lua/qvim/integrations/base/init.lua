local M = {}

local meta = require("qvim.integrations.meta")
local Log = require("qvim.integrations.log")

--- Create the base table for an integration with the `keymap_meta.mt` and populates
--- the table with additionally defined options from a given `config`.
---@param config table
---@param name string
---@return table base_table
local function create_base_table(name, config)
	local opts = setmetatable({}, meta.integration_opts_mt)
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
	Log:debug(string.format("Called init function for '%s'. Config is '%s'.", config_file, config))
	local _, base_t = pcall(create_base_table, config_file, config)
	return base_t, instance
end

return M
