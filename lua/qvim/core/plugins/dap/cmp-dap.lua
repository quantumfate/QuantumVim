---The cmp-dap configuration file of the dap plugin
local M = {}

---Registers the global configuration scope for dap
function M:config()
	qvim.integrations.dap.cmp_dap = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- cmp_dap option configuration
			"dap-repl",
			"dapui_watches",
			"dapui_hover",
		},
	}
end

return M
