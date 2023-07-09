---@class core_base
local core_base = {}
core_base.__index = core_base

local core_base_mt = { __index = core_base }

local fmt = string.format
local log = require "qvim.log"

local plugin_path_prefix = "qvim.core.plugins."

---Error handler plugin configuration.
---@param err string
---@param plugin_name string
---@param plugin_path string
local function error_handler(err, plugin_name, plugin_path)
	if err:match(".*'" .. plugin_path .. "'.*") then
		log:debug(fmt("No configuration file found for '%s'.", plugin_name))
	elseif err:match ".*module '.*' not found.*" then
		log:warn(
			fmt(
				"A module in the configuration of '%s' caused an error. Is this first time setup? If it's not some plugin in '%s' is missing or malfunctioning require path was used.",
				plugin_name,
				plugin_path
			)
		)
		print(debug.traceback())
	else
		log:warn(
			fmt(
				"Unknown error occured during configuration of '%s' in '%s'.",
				plugin_name,
				plugin_path
			)
		)
	end
end

---Loads a plugin configuration of a plugin by a given `plugin_name` as a table and
---adds it to the global `qvim` table where the configuration is referenced by the
---`plugin_name`. Such as: `qvim.[plugin] = spec` where `spec` is a table.
---
---Additionally `spec` extends the `core_base_mt` that provides a general purpose setup function and is
---directly returned as a table.
---@param plugin_name string
---@param url string
---@param hr_name string
---@return plugin? plugin_spec the `spec` of a plugin that extends the `core_base_mt`.
function core_base.new(plugin_name, url, hr_name)
	local plugin_path = plugin_path_prefix .. hr_name

	local function error_handler_closure(err)
		error_handler(err, plugin_name, plugin_path)
	end

	local status_ok, plugin =
		xpcall(require, error_handler_closure, plugin_path)
	if not status_ok then
		log:debug(
			"Skipping configuration of '%s'. No configuration available.",
			plugin_name
		)
		return
	else
		vim.validate {
			enabled = { plugin.enabled, { "b", "f" }, true },
			options = { plugin.options, "t", true },
			keymaps = { plugin.keymaps, "t", true },
			main = { plugin.main, "s", false },
			setup = { plugin.setup, "f", true },
			url = { plugin.url, "s", false },
		}
		plugin["name"] = plugin_name

		if not plugin.url then
			plugin.url = url
		end

		---@class plugin : core_base
		---@field active boolean
		---@field options table|nil
		---@field keymaps table|nil
		---@field require_name string|nil
		---@field name string
		---@field url string
		local plugin_spec = setmetatable(plugin, core_base_mt)
		return plugin_spec
	end
end

---Generic setup function for plugins that don't implement anything special.
---@param self plugin
function core_base:setup()
	local require_name = self.require_name or self.name
	local status_ok, plugin = pcall(require, require_name)
	if not status_ok then
		log:warn(
			fmt(
				"The plugin '%s' with the plugin name '%s' could not be loaded.",
				require_name,
				self.name
			)
		)
	end

	local function setup_error_handler(err)
		log:debug(
			fmt(
				"Required Plugin: '%s'. The setup call of '%s' failed. Consult '%s' to see validate the configuration."
				.. "\n"
				.. "%s"
				.. "\n"
				.. "%s",
				require_name,
				self.name,
				self.url,
				err,
				debug.traceback()
			)
		)
	end

	local setup_ok, _ = xpcall(plugin.setup, setup_error_handler, self.options)
	if setup_ok then
		log:debug(
			fmt(
				"SUCCESS: Called setup function from '%s' configured by '%s'.",
				require_name,
				self.name
			)
		)
	else
		log:trace(
			fmt(
				"Setup from '%s' configured by '%s' not called. More information in logs.",
				require_name,
				self.name
			)
		)
	end
end

return core_base
