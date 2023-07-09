---@class util
local util = {}

local log = require("qvim.log")

---Validates the plugin name. By comparing it against the accepted patterns:
---- user/`plugin`.nvim
---- user/`plugin`.lua
---- user/`plugin`
---- `plugin`/nvim
---
---The string `plugin` will be extracted and returned in lower case
---and `-` will be replaced by `_` as well as any occurence of the string `nvim`
---will be romoved.
---@param plugin string
---@return boolean valid Whether the plugin is a valid plugin or nor
---@return string|nil plugin_name The valid plugin name or nil
function util.is_valid_plugin_name(plugin)
	local nvim_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.nvim$"
	local lua_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.lua$"
	local normal_pattern = "^[%a%d%-_]+/([%a%d%-_]+)$"
	local plugin_name = plugin:match(nvim_pattern) or plugin:match(lua_pattern) or plugin:match(normal_pattern) or nil

	if plugin_name == "nvim" then
		plugin_name = nil
		local special_pattern = "^([%a%d%-_]+)/nvim$"
		plugin_name = plugin:match(special_pattern)
	end

	if plugin_name then
		plugin_name = string.gsub(plugin_name, "-", "_")
		plugin_name = string.gsub(plugin_name, "nvim", "")
		return true, string.lower(plugin_name)
	else
		return false
	end
end

---Invokes a callable on a all plugins with plugin_name and url as an argument.
---The return value of the callable will be added to the global `qvim.plugins` table
---where the corresponding key is the plugin_name.
---@param call function
function util.qvim_process_plugins(call)
	for _, url in pairs(require("qvim.core").plugins) do
		local name_ok, plugin_name = util.is_valid_plugin_name(url)
		if name_ok and plugin_name then
			qvim.plugins[plugin_name] = call(plugin_name, url)
		else
			log:debug(
				"The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
				url
			)
		end
	end
end

---Invokes a callable on a all plugins with plugin_name and url as an argument.
---The result of the callable will be added to the returned lazy_specs where each
---lazy_spec is referenced by a numerical index.
---@param call function
---@param first_time_setup boolean
---@return table lazy_specs
function util.lazy_process_plugins(call, first_time_setup)
	local lazy_specs = {}
	for _, url in pairs(require("qvim.core").plugins) do
		local name_ok, plugin_name = util.is_valid_plugin_name(url)
		if name_ok and plugin_name then
			lazy_specs[#lazy_specs + 1] = call(plugin_name, url, first_time_setup)
		else
			log:debug(
				"The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
				url
			)
		end
	end
	return lazy_specs
end

return util
