---The playground configuration file of the treesitter plugin
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for treesitter
function M:config()
	qvim.integrations.treesitter.playground = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- playground option configuration
			enable = false,
			disable = {},
			updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
			persist_queries = false, -- Whether the query persists across vim sessions
			keybindings = {
				toggle_query_editor = "o",
				toggle_hl_groups = "i",
				toggle_injected_languages = "t",
				toggle_anonymous_nodes = "a",
				toggle_language_display = "I",
				focus_language = "f",
				unfocus_language = "F",
				update = "R",
				goto_node = "<cr>",
				show_help = "?",
			},
		},
	}
end

return M
