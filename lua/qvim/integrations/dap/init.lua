---The dap configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for dap
function M:init()
	if in_headless_mode() then
		return
	end
	local dap = {
		active = true,
		on_config_done = function()
			require("qvim.integrations.dap.virtual-text"):setup()
		end,
		extensions = {
			"mason-dap",
			"ui",
			"virtual-text",
			"cmp-dap",
		},
		keymaps = {
			{
				binding_group = "d",
				name = "+Dap",
				bindings = {
					["tc"] = { "<cmd>lua require'telescope'.extensions.dap.commands{}<cr>", "Show commands" },
					["ts"] = { "<cmd>lua require'telescope'.extensions.dap.configurations{}<cr>", "Show setups" },
					["tv"] = { "<cmd>lua require'telescope'.extensions.dap.variables{}<cr>", "Show variables" },
					["tf"] = { "<cmd>lua require'telescope'.extensions.dap.frames{}<cr>", "Show frames" },
					["tb"] = { "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<cr>", "Show breakpoints" },
					["b"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle breakpoint" },
					["B"] = { "<cmd>lua require('dap').set_breakpoint()<cr>", "Set breakpoint" },
					["R"] = { "<cmd>lua require'dap'.continue()<cr>", "Continue|Run" },
					["so"] = { "<cmd>lua require'dap'.step_over()<cr>", "Step over" },
					["si"] = { "<cmd>lua require'dap'.step_into()<cr>", "Step into" },
					["sr"] = { "<cmd>require('dap').step_out()<cr>", "Step out" },
					["ro"] = { "<cmd>lua require'dap'.repl.open()<cr>", "Repl open" },
					["rl"] = { "<cmd>lua require('dap').run_last()<cr>", "Run last" },
					["<backspace>"] = { "<cmd>lua require('dap').restart()<cr>", "Restart" },
				},
				options = {
					prefix = "<leader>",
				},
			},
		},
		options = {
			-- dap option configuration
			breakpoint = {
				text = qvim.icons.ui.Bug,
				texthl = "DiagnosticSignError",
				linehl = "",
				numhl = "",
			},
			breakpoint_rejected = {
				text = qvim.icons.ui.Bug,
				texthl = "DiagnosticSignError",
				linehl = "",
				numhl = "",
			},
			stopped = {
				text = qvim.icons.ui.BoldArrowRight,
				texthl = "DiagnosticSignWarn",
				linehl = "Visual",
				numhl = "DiagnosticSignWarn",
			},
			log = {
				level = "info",
			},
		},
	}
	return dap
end

function M:config()
	if _G.in_headless_mode() then
		return
	end
	for _, ext in pairs(qvim.integrations.dap.extensions) do
		require("qvim.integrations.dap." .. ext):config()
	end

	require("qvim.integrations.dap.mason-dap"):setup()
end

---The dap setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local dap = require("dap")

	if qvim.use_icons then
		vim.fn.sign_define("DapBreakpoint", qvim.integrations.dap.options.breakpoint)
		vim.fn.sign_define("DapBreakpointRejected", qvim.integrations.dap.options.breakpoint_rejected)
		vim.fn.sign_define("DapStopped", qvim.integrations.dap.options.stopped)
	end

	local _dap = qvim.integrations.dap

	dap.set_log_level(qvim.integrations.dap.options.log.level)
	if _dap.on_config_done then
		_dap.on_config_done()
	end
end

return M
