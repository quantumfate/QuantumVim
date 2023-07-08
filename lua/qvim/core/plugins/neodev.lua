---The neodev configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for neodev
function M:init()
	local neodev = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- neodev option configuration
			library = { plugins = { "nvim-dap-ui" }, types = true },
		},
	}
	return neodev
end

---The neodev setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	if in_headless_mode() then
		return
	end
	local status_ok, neodev = pcall(reload, "neodev")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", neodev))
		return
	end

	local _neodev = qvim.integrations.neodev
	neodev.setup(_neodev.options)

	if _neodev.on_config_done then
		_neodev.on_config_done()
	end
end

return M
