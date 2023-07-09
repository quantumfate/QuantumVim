---@class util
local util = {}

local log = require "qvim.log"

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
---@param call fun(plugin_name: string, url: string, hr_name: string)
function util.qvim_process_plugins(call)
    for _, url in pairs(require("qvim.core").plugins) do
        local name_ok, plugin_name, hr_name = util.is_valid_plugin_name(url)
        if name_ok and plugin_name and hr_name then
            qvim.plugins[plugin_name] = call(plugin_name, url, hr_name)
        else
            log:debug(
                "The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
                url
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
            log:debug(
                "The plugin url '%s' did not pass the plugin name validation. No configuration or setup will be called.",
                url
            )
        end
    end
    return lazy_specs
end

return util
