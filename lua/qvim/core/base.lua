---@class core_base
local core_base = {}
core_base.__index = core_base

local core_base_mt = { __index = core_base }
local core_base_bundle_mt = { __index = core_base }
function core_base_bundle_mt:setup()
	-- TODO: generic setup for extensions
end

local core_base_bundle_extension_mt = {
	__index = core_base_bundle_mt,
}

---@param self extension
function core_base_bundle_extension_mt:setup_ext()
	-- TODO: generic setup for extensions
end

local fmt = string.format
local log = require "qvim.log"
local core_util = require("qvim.core.util")
local qvim_util = require("qvim.utils")
local core_error_util = require("qvim.core.error")

local plugin_path_prefix = "qvim.core.plugins."

---Loads a plugin configuration of a plugin by a given `plugin_name` as a table and
---adds it to the global `qvim` table where the configuration is referenced by the
---`plugin_name`. Such as: `qvim.[plugin] = spec` where `spec` is a table.
---
---Additionally `spec` extends the `core_base_mt` that provides a general purpose setup function and is
---directly returned as a table.
---@param plugin_name string
---@param url string
---@param hr_name string
---@return plugin|plugin_parent? plugin_spec the `spec` of a plugin that extends the `core_base_mt`.
function core_base.new(plugin_name, url, hr_name)
	local plugin_path = plugin_path_prefix .. hr_name

	local function error_handler_closure(err)
		core_error_util.error_handler(err, hr_name, plugin_path)
	end

	local plugin_spec

	local status_ok, plugin =
		xpcall(require, error_handler_closure, plugin_path)
	if not status_ok then
		log:debug(fmt(
			"Skipping configuration of '%s'. No configuration available.",
			plugin_name
		))
		return
	else
		local uv = vim.loop
		local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
		if qvim_util.is_directory(join_paths(get_qvim_dir(), "lua", plugin_path:gsub("\\.", path_sep))) then
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				extensions = { plugin.extensions, "t", true },
				conf_extensions = { plugin.conf_extensions, "t", true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				setup = { plugin.setup, "f", true },
				url = { plugin.url, "s", false },
			}, hr_name)
			for _, extension_url in pairs(plugin.extensions) do
				local ext_name, ext_spec = core_base.new_ext(plugin_name, hr_name, extension_url)
				if ext_name and ext_spec then
					plugin.conf_extensions[ext_name] = ext_spec
				end
			end
			---@class plugin_parent : core_base
			---@field active boolean
			---@field extensions table<string>
			---@field conf_extensions table<string, plugin>
			---@field options table|nil
			---@field keymaps table|nil
			---@field main string|nil
			---@field name string
			---@field url string
			plugin_spec = setmetatable(plugin, core_base_mt)
		else
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				setup = { plugin.setup, "f", true },
				url = { plugin.url, "s", false },
			}, hr_name)
			---@class plugin : core_base
			---@field active boolean
			---@field options table|nil
			---@field keymaps table|nil
			---@field main string|nil
			---@field name string
			---@field url string
			plugin_spec = setmetatable(plugin, core_base_mt)
		end

		plugin["name"] = plugin_name

		if not plugin.url then
			plugin.url = url
		end
		return plugin_spec
	end
end

---Loads a plugin configuration of a plugin extension by a given `plugin_name` as a table and
---adds it to the global `qvim` table where the configuration is referenced by the
---`plugin_name`. Such as: `qvim.[parent][extensions][plugin_ext] = spec` where `spec` is a table.
---
---Additionally `spec` extends the `core_base_bundle_extension_mt` that provides a general purpose setup function and is
---directly returned as a table.
---@param plugin_name string
---@param hr_name_parent string
---@param extension_url string
---@return string? plugin_name_ext
---@return extension? plugin_spec the `spec` of a plugin that extends the `core_base_mt`.
function core_base.new_ext(plugin_name, hr_name_parent, extension_url)
	local is_valid, plugin_name_ext, hr_name_ext = core_util.is_valid_plugin_name(extension_url)
	if not (is_valid and plugin_name_ext and hr_name_ext) then
		return
	else
		local plugin_path = plugin_path_prefix .. hr_name_parent .. "." .. hr_name_ext

		local function error_handler_closure(err)
			core_error_util.error_handler_ext(err, hr_name_parent, hr_name_ext, plugin_path)
		end

		local plugin_spec

		local status_ok, plugin =
			xpcall(require, error_handler_closure, plugin_path)
		if not status_ok then
			log:debug(fmt(
				"Skipping configuration of '%s'. No configuration available.",
				plugin_name
			))
			return
		else
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				setup = { plugin.setup, "f", true },
				url = { plugin.url, "s", true },
			}, hr_name_ext)
			---@class extension : plugin_parent
			---@field active boolean
			---@field options table|nil
			---@field keymaps table|nil
			---@field main string|nil
			---@field name string
			---@field url string
			plugin_spec = setmetatable(plugin, core_base_bundle_extension_mt)
		end

		plugin["name"] = plugin_name_ext

		if not plugin.url then
			plugin.url = extension_url
		end
		return plugin_name_ext, plugin_spec
	end
end

---Generic setup function for plugins that don't implement anything special.
---@param self plugin
function core_base:setup()
	local status_ok, plugin = pcall(require, self.main)
	if not status_ok then
		log:warn(
			fmt(
				"The plugin '%s' with the plugin name '%s' could not be loaded.",
				self.main,
				self.name
			)
		)
	end

	local function error_handler_closure(err)
		core_error_util.setup_error_handler(self, err)
	end

	local setup_ok, _ = xpcall(plugin.setup, error_handler_closure, self.options)
	if setup_ok then
		log:debug(
			fmt(
				"SUCCESS: Called setup function from '%s' configured by '%s'.",
				self.main,
				self.name
			)
		)
	else
		log:trace(
			fmt(
				"Setup from '%s' configured by '%s' not called. More information in logs.",
				self.main,
				self.name
			)
		)
	end
end

return core_base
