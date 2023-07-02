---Requiring this module returns a full spec table of configured plugins
---https://github.com/folke/lazy.nvim#-plugin-spec
local M = {}
local status_ok, lazy_spec_config = pcall(require, "qvim.integrations._loader.spec.config")

if status_ok then
	for plugin_alias, plugin_name in pairs(lazy_spec_config.qvim_integrations) do
		local spec = lazy_spec_config:new(plugin_alias, plugin_name)
		if spec then
			M[#M + 1] = spec
		end
	end
end
return M
