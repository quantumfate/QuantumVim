---The context-commentstring configuration file of the treesitter plugin
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for treesitter
function M:config()
	qvim.integrations.treesitter.context_commentstring = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- context_commentstring option configuration
			enable = true,
			enable_autocmd = false,
			config = {
				-- Languages that have a single comment style
				typescript = "// %s",
				css = "/* %s */",
				scss = "/* %s */",
				html = "<!-- %s -->",
				svelte = "<!-- %s -->",
				vue = "<!-- %s -->",
				json = "",
			},
		},
		url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	}
end

return M
