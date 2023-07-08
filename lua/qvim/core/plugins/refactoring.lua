---The refactoring configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for refactoring
function M:init()
	local refactoring = {
		active = true,
		on_config_done = nil,
		keymaps = {
			{
				binding_group = "r",
				name = "+Refactoring",
				bindings = {
					e = {
						mode = { "n", "v" },
						rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Function')<CR>",
						desc = "Extract Function",
					},
					f = {
						mode = "v",
						rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Function To File')<CR>",
						desc = "Extract Function To File",
					},
					v = {
						mode = "v",
						rhs = "<ESC><cmd>lua require('refactoring').refactor('Extract Variable')<CR>",
						desc = "Extract Variable",
					},
					i = {
						mode = "v",
						rhs = "<ESC><cmd>lua require('refactoring').refactor('Inline Variable')<CR>",
						desc = "Inline Variable",
					},
					b = {
						rhs = "<cmd>lua require('refactoring').refactor('Extract Block')<CR>",
						desc = "Extract Block",
					},
					["bf"] = {
						rhs = "<cmd>lua require('refactoring').refactor('Extract Block To File')<CR>",
						desc = "Extract Block To File",
					},
				},
				options = {
					prefix = "<leader>",
					noremap = true,
					silent = true,
					expr = false,
				},
			},
		},
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
	if in_headless_mode() then
		return
	end
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
