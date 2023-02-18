---A base and utility to work with lazy plugin specs
local M = {}
local Log = require "qvim.integrations.log"

---Set the lazy configuration spec for a plugin.
---
---- name: Setting the name manually will override every calculated name or alias
---- enabled: read from the global configuration table from a specific plugin
---- config: hook the setup function of an integration defined in the global qvim variable
---
---Refer to: https://github.com/folke/lazy.nvim#-plugin-spec
---
---@param alias integer|string the plugin alias
---@param name string the plugin name
---@return table|nil obj a plugin spec to be used by lazy
function M:new(alias, name)
    local is_valid, plugin_information = nil, nil
    if type(alias) == "string" then
        is_valid, plugin_information = M:get_valid_plugin_info(alias)
    else
        is_valid, plugin_information = M:get_valid_plugin_info(name)
    end
    if is_valid and plugin_information then
        local plugin_name = plugin_information.plugin_name
        local plugin_alias = plugin_information.plugin_alias or plugin_name
        local fields = M:load_lazy_config_spec_for_plugin(plugin_alias)

        if not fields then
            return nil
        end
        if fields.name then
            plugin_alias = fields.name
        end

        local enabled = true
        if qvim.integrations[plugin_alias] then
            enabled = qvim.integrations[plugin_alias].active
        end
        if fields.enabled then
            enabled = fields.enabled
        end
        local obj = {
            name,
            name = fields.name or plugin_alias,
            lazy = fields.lazy or false,
            enabled = enabled,
            cond = fields.cond or nil,
            dependencies = fields.dependencies or {},
            init = fields.init or nil,
            opts = fields.opts or {},
            config = fields.config or M:hook_integration_config(plugin_alias),
            build = fields.build or nil,
            branch = fields.branch or nil,
            tag = fields.tag or nil,
            version = fields.version or nil,
            pin = fields.pin or false,
            event = fields.event or nil, -- https://neovim.io/doc/user/autocmd.html#autocmd-events
            cmd = fields.cmd or nil,
            key = fields.key or nil,
            ft = fields.ft or nil,
            priority = fields.priority or 50,
        }
        return obj
    else
        Log:debug("The plugin '%s' could is not a valid plugin.", name)
        return nil
    end
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

---Validates the plugin name.
---@param plugin any
---@return boolean valid Whether the plugin is a valid plugin or nor
---@return string|nil plugin_name The valid plugin name or nil
local function is_valid_plugin_name(plugin)
    local nvim_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.nvim$"
    local lua_pattern = "^[%a%d%-_]+/([%a%d%-_]+)%.lua$"
    local normal_pattern = "^[%a%d%-_]+/([%a%d%-_]+)$"
    local plugin_name = plugin:match(nvim_pattern) or plugin:match(lua_pattern) or plugin:match(normal_pattern) or nil

    if plugin_name then
        return true, plugin_name
    else
        return false
    end
end

---Validates the plugin name or an alias that is mapped to a plugin name.
---@param plugin string The full plugin path or an alias that is mapped to a plugin path
---@param plugin_information table|nil plugin_information about the plugin
---@return boolean valid whether the provided plugin name is valid or not
---@return table|nil plugin_information holding a plugin_name and/or an alias_name
function M:get_valid_plugin_info(plugin, plugin_information)
    local is_valid, plugin_name = is_valid_plugin_name(plugin)
    if not plugin_information then
        plugin_information = {
            plugin_name = plugin_name,
            plugin_alias = nil,
        }
    else
        plugin_information.plugin_name = plugin_name
    end

    if not is_valid and M.qvim_integrations[plugin] then
        plugin_information.plugin_alias = plugin
        return M:get_valid_plugin_info(M.qvim_integrations[plugin], plugin_information)
    end

    return is_valid, plugin_information
end

---Hook the setup function of a plugin and return it as a callback.
---If the global configuration table of a plugin is not defined this
---function will return nil even if a setup function is declared for the plugin.
---If this function returns nil the setup call of the integration will
---be delegated to the lazy plugin manager.
---@param plugin_name string the verified plugin name
---@return function|nil callback the function callback or nil on fail
function M:hook_integration_config(plugin_name)
    local callback = nil
    local plugin_file = "qvim.integrations." .. plugin_name
    local success, result = pcall(require, plugin_file)
    if success and is_plugin_configured(plugin_name) then
        if not result.setup then
            Log:warn(string.format(
                "The plugin '%s' does not implement a standard setup function.", plugin_name))

            return callback
        end
        callback = result.setup
    else
        Log:warn(string.format(
            "The plugin '%s' could not be associated with a configuration file in the integrations section.", plugin_name))
    end
    return callback
end

---Requires a lazy spec from the config directory and if the file exists it will return
---the table that it would return as if it was directly required. If the
---module doesn't exist this function will just return an empty table so that
---this function can be used without any extra run time checks.
---@param plugin_name string the verified plugin name
---@return table|nil options the options that should override the individual default plugin spec
function M:load_lazy_config_spec_for_plugin(plugin_name)
    local plugin_spec = {}
    local spec_file = "qvim.integrations.loader.spec.config." .. plugin_name
    if spec_file then
        local success, spec = pcall(require, spec_file)
        if success then
            plugin_spec = spec
        end
        return plugin_spec
    else
        return nil
    end
end

---Plugins that should be installed. The key
---values represent the accepted plugin name
---across the qvim project.
M.qvim_integrations = {
    "nvim-lua/plenary.nvim",
    "Tastyep/structlog.nvim",
    "nvim-telescope/telescope.nvim",
    autopairs = "windwp/nvim-autopairs",
    "kyazdani42/nvim-tree.lua",
    "phaazon/hop.nvim",
    "nvim-lualine/lualine.nvim",
    illuminate = "RRethy/vim-illuminate",
    "EdenEast/nightfox.nvim",
    "akinsho/bufferline.nvim",
    dashboard = "glepnir/dashboard-nvim",
    "glepnir/dbsession.nvim",
    treesitter = "nvim-treesitter/nvim-treesitter",
    indentline = "lukas-reineke/indent-blankline.nvim",
    notify = "rcarriga/nvim-notify",
    "akinsho/toggleterm.nvim",
}

return M
