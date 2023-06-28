---The extensions configuration file of the telescope plugin
local M = {}

local Log = require("qvim.integrations.log")

---Registers the global configuration scope for telescope
function M:config()
	qvim.integrations.telescope.extensions = {
		options = {
			extensions_to_load = {
				"fzf",
				"lazy",
				"dap",
				"project",
				"file_browser",
			},
			-- extensions option configuration
			extensions = {
				lazy = {
					-- Whether or not to show the icon in the first column
					show_icon = true,
					-- Mappings for the actions
					mappings = {
						open_in_browser = "<C-o>",
						open_in_file_browser = "<M-b>",
						open_in_find_files = "<C-f>",
						open_in_live_grep = "<C-g>",
						open_plugins_picker = "<C-b>", -- Works only after having called first another action
						open_lazy_root_find_files = "<C-r>f",
						open_lazy_root_live_grep = "<C-r>g",
					},
				},
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				},
				file_browser = {
					theme = qvim.config.colorscheme,
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
				},
			},
		},
	}
end

return M
