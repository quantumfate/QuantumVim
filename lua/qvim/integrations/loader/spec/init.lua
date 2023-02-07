---Requiring this module returns a full spec table of configured plugins
---https://github.com/folke/lazy.nvim#-plugin-spec
local M = {}
local status_ok, lazy_spec_config = pcall(require, "qvim.integrations.loader.spec.config")

if status_ok then
    for _, plugin_name in ipairs(lazy_spec_config.qvim_integrations) do
        M[#M + 1] = lazy_spec_config:new(plugin_name)
    end
end
return M
