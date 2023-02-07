---A base and utility to work with lazy plugin specs
local M = {}
local Log = require "qvim.utils.log"

---Set the lazy configuration spec for a plugin.
---
---Refer to: https://github.com/folke/lazy.nvim#-plugin-spec
---
---@param name string the plugin name
---@return table obj a plugin spec to be used by lazy
function M:new(name)
    local fields = M:load_options_for_plugin(name)

    local obj = {
        name or "",
        lazy = fields.lazy or false,
        enabled = fields.enabled or true,
        cond = fields.cond or true,
        dependencies = fields.dependencies or {},
        init = fields.init or nil,
        opts = fields.opts or {},
        config = fields.config or true,
        build = fields.build or nil,
        branch = fields.branch or nil,
        tag = fields.tag or nil,
        version = fields.version or nil,
        pin = fields.pin or false,
        event = fields.event or nil,
        cmd = fields.cmd or nil,
        ft = fields.ft or nil,
        priority = fields.priority or 50,
    }
    return obj
end

---Validates the plugin name and returns its basename.
---@param plugin string The full plugin path
---@return boolean valid whether the provided plugin name is valid or not
---@return string|nil plugin_name the plugins basename
local function is_valid_plugin_name(plugin)
    local nvim_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.nvim$"
    local lua_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.lua$"
    local normal_pattern = "^[%a%d%-_]+/([%a%d%-_]+)$"

    local plugin_name = plugin:match(nvim_pattern) or plugin:match(lua_pattern) or plugin:match(normal_pattern)
    Log:debug("Recognized the plugin: %s", plugin_name)
    if plugin_name ~= nil then
        return true, plugin_name
    else
        Log:warn("The plugin '%s' is not a valid plugin name.", plugin)
        return false
    end
end

---Requires a module from the plugin directory and if the file exists it will return
---the table that this module would return as if it was directly required. If the
---module doesn't exist this function will just return an empty table so that
---this function can be used without any extra run time checks.
---@param plugin string the string of the plugin. Valid plugin names are "Developer/plugin.nvim", "Developer/plugin.lua" or "Developer/plugin"
---@return table options the options that should override the individual default plugin spec
function M:load_options_for_plugin(plugin)
    local options = {}
    local isvalid, plugin_name = is_valid_plugin_name(plugin)
    if isvalid then
        local options_file = "qvim.integrations.loader.plugins." .. plugin_name .. ".lua"
        local success, result = pcall(require, options_file)
        if success then
            options = result
        end
        return options
    else
        return {}
    end
end

---The plugins that should be configured
M.qvim_integrations = {
    "folke/lazy.nvim",
    "Tastyep/structlog.nvim",
    "nvim-telescope/telescope.nvim",
    "windwp/nvim-autopairs",
    "kyazdani42/nvim-tree.lua",
}
return M
