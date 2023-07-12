---@class core_base
local core_base = {}
core_base.__index = core_base

local core_meta_plugin = require("qvim.core.meta.plugin")
local core_meta_parent = require("qvim.core.meta.parent")
local core_meta_ext = require("qvim.core.meta.ext")

local core_base_mt = { __index = core_meta_plugin }
local core_base_parent_mt = { __index = core_meta_parent }

local fmt = string.format
local log = require("qvim.log")
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
---@param hr_name string
---@return AbstractParent|AbstractPlugin? plugin_spec the `spec` of a plugin that extends the `core_base_mt`.
function core_base.new(hr_name)
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
			hr_name
		))
		return
	else
		if not plugin["name"] then
			plugin["name"] = hr_name
		end

		local uv = vim.loop
		local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"

		if qvim_util.is_directory(join_paths(get_qvim_dir(), "lua", (plugin_path:gsub("%.", path_sep)))) then
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				name = { plugin.name, "s", true },
				extensions = { plugin.extensions, "t", true },
				conf_extensions = { plugin.conf_extensions, "t", true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				on_setup_start = { plugin.on_setup_start, "f", true },
				setup = { plugin.setup, "f", true },
				on_setup_done = { plugin.on_setup_done, "f", true },
				url = { plugin.url, "s", false },
			}, hr_name)
			if plugin.extensions then
				for _, extension_url in pairs(plugin.extensions) do
					local ext_name, ext_spec = core_base.new_ext(hr_name, extension_url, plugin)
					if ext_name and ext_spec then
						plugin.conf_extensions[ext_name] = ext_spec
					end
				end
			end
			---@generic AbstractParent
			---@class AbstractParent : core_meta_parent
			---@field enabled boolean|fun():boolean|nil
			---@field name string|nil the human readable name
			---@field extensions table<string> a list of extension url's
			---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
			---@field options table|nil options used in the setup call of a neovim plugin
			---@field keymaps table|nil keymaps parsed to yikes.nvim
			---@field main string|nil the string to use when the neovim plugin is required
			---@field on_setup_start fun(self: AbstractParent, instance: table)|nil hook setup logic at the beginning of the setup call
			---@field setup fun(self: AbstractParent)|nil overwrite the setup function in core_base
			---@field on_setup_done fun(self: AbstractParent, instance: table)|nil hook setup logic at the end of the setup call
			---@field url string neovim plugin url
			plugin_spec = setmetatable(plugin, core_base_parent_mt)
		else
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				on_setup_start = { plugin.on_setup_start, "f", true },
				setup = { plugin.setup, "f", true },
				on_setup_done = { plugin.on_setup_done, "f", true },
				url = { plugin.url, "s", false },
			}, hr_name)
			---@generic AbstractPlugin
			---@class AbstractPlugin : core_meta_plugin
			---@field enabled boolean|fun():boolean|nil
			---@field name string|nil the human readable name
			---@field options table|nil options used in the setup call of a neovim plugin
			---@field keymaps table|nil keymaps parsed to yikes.nvim
			---@field main string the string to use when the neovim plugin is required
			---@field on_setup_start fun(self: AbstractPlugin, instance: table)|nil hook setup logic at the beginning of the setup call
			---@field setup fun(self: AbstractPlugin)|nil overwrite the setup function in core_base
			---@field on_setup_done fun(self: AbstractPlugin, instance: table)|nil hook setup logic at the end of the setup call
			---@field url string neovim plugin url
			plugin_spec = setmetatable(plugin, core_base_mt)
		end

		return plugin_spec
	end
end

---Loads a plugin configuration of a plugin extension by a given `plugin_name` as a table and
---adds it to the global `qvim` table where the configuration is referenced by the
---`plugin_name`. Such as: `qvim.[parent][extensions][plugin_ext] = spec` where `spec` is a table.
---
---Additionally `spec` extends the `core_base_parent_extension_mt` that provides a general purpose setup function and is
---directly returned as a table.
---@param hr_name_parent string
---@param extension_url string
---@param parent AbstractParent a reference to the table of the parent
---@return string? plugin_name_ext
---@return AbstractExtension? plugin_spec the `spec` of a plugin that extends the `core_base_mt`.
function core_base.new_ext(hr_name_parent, extension_url, parent)
	local is_valid, plugin_name_ext, hr_name_ext = core_util.is_valid_plugin_name(extension_url)
	if not (is_valid and plugin_name_ext and hr_name_ext) then
		log:debug(fmt("The extension url '%s' of the plugin '%s' did not pass the name check valitation.", extension_url,
			hr_name_parent))
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
				"Plugin: '%s'. Skipping configuration of the '%s' extension. No configuration available.",
				hr_name_parent,
				extension_url
			))
			return
		else
			core_util.vim_validate_wrapper({
				enabled = { plugin.enabled, { "b", "f" }, true },
				options = { plugin.options, "t", true },
				keymaps = { plugin.keymaps, "t", true },
				main = { plugin.main, "s", false },
				on_setup_start = { plugin.on_setup_start, "f", true },
				setup_ext = { plugin.setup_ext, "f", true },
				on_setup_done = { plugin.on_setup_done, "f", true },
				url = { plugin.url, "s", false },
			}, hr_name_ext)
			if not plugin["name"] then
				plugin["name"] = hr_name_ext
			end
			---@generic E
			---@class AbstractExtension : core_meta_ext, AbstractParent
			---@field enabled boolean
			---@field name string|nil the human readable name
			---@field options table|nil options used in the setup call of a neovim plugin
			---@field keymaps table|nil keymaps parsed to yikes.nvim
			---@field main string the string to use when the neovim plugin is required
			---@field on_setup_start fun(self: AbstractExtension, instance: table|nil)|nil hook setup logic at the beginning of the setup call
			---@field setup_ext fun(self: AbstractExtension)|nil overwrite the setup function in core_base
			---@field on_setup_done fun(self: AbstractExtension, instance: table|nil)|nil hook setup logic at the end of the setup call
			---@field url string neovim plugin url
			plugin_spec = setmetatable(plugin, parent)
		end
		return plugin_name_ext, plugin_spec
	end
end

return core_base
