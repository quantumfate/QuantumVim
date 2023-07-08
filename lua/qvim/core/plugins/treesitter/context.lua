---The context configuration file of the treesitter plugin
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for treesitter
function M:config()
	qvim.integrations.treesitter.context = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- context option configuration
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = true,
			multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
		},
		url = "https://github.com/nvim-treesitter/nvim-treesitter-context",
	}
end

---The context setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, context = pcall(reload, "treesitter-context")
	if not status_ok then
		Log:warn(string.format("The extension '%s' could not be loaded.", context))
		return
	end

	local _treesitter_context = qvim.integrations.treesitter.context
	context.setup(_treesitter_context.options)

	if _treesitter_context.on_config_done then
		_treesitter_context.on_config_done()
	end
end

return M
