---Requiring this module returns a full spec table of configured plugins
---https://github.com/folke/lazy.nvim#-plugin-spec
local M = {}
local declared_plugins = pcall(require, "qvim.integrations.loader.spec.config")

for _, value in ipairs(declared_plugins.qvim_integrations) do
    local plugin_spec = { value } -- order matters!
    plugin_spec.add(declared_plugins:new(declared_plugins:load_options_for_plugin(value)))
    M[#M + 1] = plugin_spec
end

return M
