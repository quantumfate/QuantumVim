---@class util
local util = {}

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

return util
