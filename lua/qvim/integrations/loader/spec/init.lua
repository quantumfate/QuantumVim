---Requiring this module returns a full spec table of configured plugins
---https://github.com/folke/lazy.nvim#-plugin-spec
local M = {}
local status_ok, declared_plugins = pcall(require, "qvim.integrations.loader.spec.config")

if status_ok then
    for _, value in ipairs(declared_plugins.qvim_integrations) do
        local plugin_spec = {} -- order matters!
        plugin_spec[#plugin_spec + 1] = value
        local plugin_options = declared_plugins:load_options_for_plugin(value)
        print(type(plugin_options))
        local lazy_spec = declared_plugins:new(plugin_options)
        print(type(lazy_spec))
        print(value)
        plugin_spec[#plugin_spec + 1] = lazy_spec
        M[#M + 1] = plugin_spec
    end
end
return M
