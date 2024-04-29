---@class util
local util = {}

local log = require("qvim.log").qvim
local fmt = string.format

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
---@return string|nil plugin_name The valid plugin name used for table keys
---@return string|nil hr_name the human readable name of a plugin for file and directory names as well as representation
function util.is_valid_plugin_name(plugin)
	local nvim_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.nvim$"
	local lua_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.lua$"
	local normal_pattern = "^[%a%d%-_]+/([%a%d%-_]+)$"
	local plugin_name = plugin:match(nvim_pattern)
		or plugin:match(lua_pattern)
		or plugin:match(normal_pattern)
		or nil

	if normal_pattern and plugin_name == "nvim" then
		local special_pattern = "^([%a%d%-_]+)/nvim$"
		plugin_name = plugin:match(special_pattern)
		if plugin_name then
			plugin_name = string.gsub(plugin_name, "nvim", "")
		end
	end

	if plugin_name then
		plugin_name = string.gsub(plugin_name, "-+", "-")
		local hr_name = plugin_name
		plugin_name = string.gsub(plugin_name, "-", "_")
		return true, string.lower(plugin_name), hr_name
	else
		return false, nil, nil
	end
end

---Invokes a callable on a all plugins with plugin_name and url as an argument.
---The return value of the callable will be added to the global `qvim.plugins` table
---where the corresponding key is the plugin_name.
---@param call fun(hr_name: string):AbstractPlugin|AbstractParent?
function util.qvim_process_plugins(call)
	for _, url in pairs(require("qvim.core").plugins) do
		local name_ok, plugin_name, hr_name = util.is_valid_plugin_name(url)
		if name_ok and plugin_name and hr_name then
			qvim.plugins[plugin_name] = call(hr_name)
		else
			log.debug(
				fmt(
					"The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
					url
				)
			)
		end
	end
end

---Invokes a callable on a all plugins.
---The result of the callable will be added to the returned lazy_specs where each
---lazy_spec is referenced by a numerical index.
---@param call fun(plugin_name: string, url: string, first_time_setup: boolean, hr_name: string)
---@param first_time_setup boolean
---@return table lazy_specs
function util.lazy_process_plugins(call, first_time_setup)
	local lazy_specs = {}
	for _, url in pairs(require("qvim.core").plugins) do
		local name_ok, plugin_name, hr_name = util.is_valid_plugin_name(url)
		if name_ok and plugin_name and hr_name then
			lazy_specs[#lazy_specs + 1] =
				call(plugin_name, url, first_time_setup, hr_name)
		else
			log.debug(
				fmt(
					"The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
					url
				)
			)
		end
	end
	return lazy_specs
end

---Counts the amaunt of plugins in `qvim.plugins`
---@return number count
function util.plugins_tbl_size()
	local count = 0
	for _, _ in pairs(qvim.plugins) do
		count = count + 1
	end
	return count
end

---Returns the plugin from a lua path
---@param plugin_path string
---@return string
function util.get_plugin_basename(plugin_path)
	local basename = plugin_path:match("[^%.]+$")
	return basename
end

---@param self AbstractPlugin|AbstractParent|AbstractExtension|core_meta_parent|core_meta_plugin|table
function util.register_keymaps(self)
	local wk = require("which-key")
	for lhs, spec in pairs(self.keymaps.mappings) do
		if not spec.name then
			wk.register({ [lhs] = spec })
		else
			wk.register({ [lhs] = spec }, self.keymaps.options)
		end
	end
end

---Calls the setup function of the meta table that `self` extends.
---It is possible to invoke any setup function by providing the necessary
---fields in a `setmetatable` that the setup function expects. If a custom
---table is parsed instead of the usual `self` the meta table needs to point
---the `__index` method to the module that implements the setup function.
---
---Example argument:
---```lua
---setmetatable({
--- url = self.url,
--- main = self.main,
--- name = self.name,
--- options = theme.config
---}, {
--- __index = core_meta_plugin
---})
---```
---
---@param self core_meta_parent|core_meta_plugin|table
function util.call_super_setup(self)
	getmetatable(self).__index.setup(self)
end

return util
