---The refactoring configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for refactoring
function M:init()
	local refactoring = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- refactoring option configuration
			-- prompt for return type
			prompt_func_return_type = {
				go = true,
				cpp = true,
				c = true,
				java = true,
			},
			-- prompt for function parameters
			prompt_func_param_type = {
				go = true,
				cpp = true,
				c = true,
				java = true,
			},
		},
	}
	return refactoring
end

---The refactoring setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, refactoring = pcall(reload, "refactoring")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", refactoring))
		return
	end

	local _refactoring = qvim.integrations.refactoring
	refactoring.setup(_refactoring.options)

	if _refactoring.on_config_done then
		_refactoring.on_config_done()
	end
end

return M
