---A base and utility to work with lazy plugin specs
local M = {}
local Log = require "qvim.integrations.log"

---Set the lazy configuration spec for a plugin.
---
---Refer to: https://github.com/folke/lazy.nvim#-plugin-spec
---
---@param name string the plugin name
---@return table obj a plugin spec to be used by lazy
function M:new(name)
    local fields = M:load_lazy_config_spec_for_plugin(name)

    local obj = {
        name or "",
        lazy = fields.lazy or false,
        enabled = fields.enabled or M:activate_plugin(name),
        cond = fields.cond or true,
        dependencies = fields.dependencies or {},
        init = fields.init or nil,
        opts = fields.opts or {},
        config = fields.config or M:hook_integration_config(name),
        build = fields.build or nil,
        branch = fields.branch or nil,
        tag = fields.tag or nil,
        version = fields.version or nil,
        pin = fields.pin or false,
        event = fields.event or nil,
        cmd = fields.cmd or nil,
        key = fields.key or nil,
        ft = fields.ft or nil,
        priority = fields.priority or 50,
    }
    return obj
end

---Validates if a plugin is configured meaning that its global
---configuration table is defined.
---@param plugin_name string|nil the actual plugin name
local function is_plugin_configured(plugin_name)
    if type(plugin_name) == "string" and qvim.integrations[plugin_name] then
        return true
    else
        Log:warn("Plugin is defined but not configured: '%s'", plugin_name)
        return false
    end
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

---Check if a plugin is activated.
---@param plugin_name string|nil The plugin name of that is used in the global config table
---@return boolean
local function is_plugin_activated(plugin_name)
    if qvim.integrations[plugin_name] then
        return qvim.integrations[plugin_name].active
    else
        Log:debug("The global configuration table for '%s' is not initialized.", plugin_name)
        return true
    end
end

---Enables a plugin and updates the global configuration variable.
---By default a plugin will be activated unless its deactivated explicitly.
---@param plugin string The qualified plugin name
function M:activate_plugin(plugin)
    local isvalid, plugin_name = is_valid_plugin_name(plugin)
    if isvalid then
        return is_plugin_activated(plugin_name)
    else
        Log:debug("Tried to activate an invalid Plugin '%s'", plugin_name)
        return false
    end
end

---Hook the setup function of a plugin and return it as a callback.
---If the global configuration table of a plugin is not defined this
---function will return nil even if a setup function is declared for the plugin.
---If this function returns nil the setup call of the integration will
---be delegated to the lazy plugin manager.
---@param plugin string the qualified plugin name
---@return function|nil callback the function callback or nil on fail
function M:hook_integration_config(plugin)
    local callback = nil
    local isvalid, plugin_name = is_valid_plugin_name(plugin)
    if isvalid then
        local plugin_file = "qvim.integrations." .. plugin_name
        local success, result = pcall(require, plugin_file)
        if success and is_plugin_configured(plugin_name) then
            callback = result.setup
        end
        return callback
    else
        return callback
    end
end

---Requires a lazy spec from the config directory and if the file exists it will return
---the table that it would return as if it was directly required. If the
---module doesn't exist this function will just return an empty table so that
---this function can be used without any extra run time checks.
---@param plugin string the string of the plugin. Valid plugin names are "Developer/plugin.nvim", "Developer/plugin.lua" or "Developer/plugin"
---@return table options the options that should override the individual default plugin spec
function M:load_lazy_config_spec_for_plugin(plugin)
    local plugin_spec = {}
    local isvalid, plugin_name = is_valid_plugin_name(plugin)
    if isvalid then
        local spec_file = "qvim.integrations.loader.spec.config." .. plugin_name
        local success, spec = pcall(require, spec_file)
        if success then
            plugin_spec = spec
        end
        return plugin_spec
    else
        return plugin_spec
    end
end

---The plugins that should be configured
M.qvim_integrations = {
    "folke/lazy.nvim",
    "Tastyep/structlog.nvim",
    "nvim-telescope/telescope.nvim",
    "windwp/nvim-autopairs",
    "kyazdani42/nvim-tree.lua",
    "phaazon/hop.nvim",
    "nvim-lualine/lualine.nvim",
    "RRethy/vim-illuminate"
}
return M
