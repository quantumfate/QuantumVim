---The ui configuration file of the dap plugin
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for dap
function M:config()
	qvim.integrations.dap.ui = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- ui option configuration
			auto_open = true,
			notify = {
				threshold = vim.log.levels.INFO,
			},
			config = {
				icons = { expanded = "", collapsed = "", circular = "" },
				mappings = {
					-- Use a table to apply multiple mappings
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				-- Use this to override mappings for specific elements
				element_mappings = {},
				expand_lines = true,
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.33 },
							{ id = "breakpoints", size = 0.17 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 0.33,
						position = "right",
					},
					{
						elements = {
							{ id = "repl", size = 0.45 },
							{ id = "console", size = 0.55 },
						},
						size = 0.27,
						position = "bottom",
					},
				},
				controls = {
					enabled = true,
					-- Display controls in this element
					element = "repl",
					icons = {
						pause = "",
						play = "",
						step_into = "",
						step_over = "",
						step_out = "",
						step_back = "",
						run_last = "",
						terminate = "",
					},
				},
				floating = {
					max_height = 0.9,
					max_width = 0.5, -- Floats will be treated as percentage of your screen.
					border = "rounded",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				windows = { indent = 1 },
				render = {
					max_type_length = nil, -- Can be integer or nil.
					max_value_lines = 100, -- Can be integer or nil.
				},
			},
		},
	}
end

---The ui setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, ui = pcall(reload, "dapui")
	if not status_ok then
		Log:warn(string.format("The extension '%s' could not be loaded.", ui))
		return
	end

	local status_ok_dap, dap = pcall(require, "dap")
	if not status_ok_dap then
		return
	end

	local _dap_ui = qvim.integrations.dap.ui
	ui.setup(_dap_ui.options)

	dap.listeners.after.event_initialized["dapui_config"] = function()
		ui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		ui.close()
	end
	dap.listeners.before.event_exited["dapui_config"] = function()
		ui.close()
	end

	-- until rcarriga/nvim-dap-ui#164 is fixed
	local function notify_handler(msg, level, opts)
		if level >= qvim.builtin.dap.ui.notify.threshold then
			return vim.notify(msg, level, opts)
		end

		opts = vim.tbl_extend("keep", opts or {}, {
			title = "dap-ui",
			icon = "",
			on_open = function(win)
				vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
			end,
		})

		-- vim_log_level can be omitted
		if level == nil then
			level = Log.levels["INFO"]
		elseif type(level) == "string" then
			level = Log.levels[(level):upper()] or Log.levels["INFO"]
		else
			-- https://github.com/neovim/neovim/blob/685cf398130c61c158401b992a1893c2405cd7d2/runtime/lua/vim/lsp/log.lua#L5
			level = level + 1
		end

		msg = string.format("%s: %s", opts.title, msg)
		Log:add_entry(level, msg)
	end

	local dapui_ok, _ = xpcall(function()
		require("dapui.util").notify = notify_handler
	end, debug.traceback)
	if not dapui_ok then
		Log:debug("Unable to override dap-ui logging level")
	end

	if _dap_ui.on_config_done then
		_dap_ui.on_config_done()
	end
end

return M
