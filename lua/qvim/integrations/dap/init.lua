---The dap configuration file
local M = {}

local Log = require("qvim.integrations.log")

---Registers the global configuration scope for dap
function M:init()
	local dap = {
		active = true,
		on_config_done = function()
			require("qvim.integrations.dap.virtual-text"):setup()
		end,
		extensions = {
			"mason-dap",
			"repl-highlights",
			"ui",
			"virtual-text",
			"cmp-dap",
		},
		keymaps = {
			["gt"] = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle breakpoint" },
			["gT"] = { "<cmd>lua require('dap').set_breakpoint()<cr>", "Set breakpoint" },
			["gC"] = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
			["gso"] = { "<cmd>lua require'dap'.step_over()<cr>", "Step over" },
			["gsi"] = { "<cmd>lua require'dap'.step_into()<cr>", "Step into" },
			["gse"] = { "<cmd>require('dap').step_out()<cr>", "Step out" },
			["gro"] = { "<cmd>lua require'dap'.repl.open()<cr>", "Toggle breakpoint" },
			["grl"] = { "<cmd>lua require('dap').run_last()<cr>", "Run last" },
			["gr"] = { "<cmd>lua require('dap').restart()<cr>", "Restart" },
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
	-- dap config function to call additional configs
	require("qvim.integrations.dap.adapters.python").adapt()
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

	--dap.setup(_dap.options)

	dap.adapters.python = {
		type = "executable",
		command = os.getenv("HOME") .. "/.virtualenvs/debugpy/bin/python",
		args = { "-m", "debugpy.adapter" },
	}

	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			pythonPath = function()
				return "/usr/bin/python"
			end,
		},
	}

	dap.set_log_level(qvim.integrations.dap.options.log.level)
	if _dap.on_config_done then
		_dap.on_config_done()
	end
end

return M
