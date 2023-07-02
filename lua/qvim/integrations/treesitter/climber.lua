---The climber configuration file of the treesitter plugin
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for treesitter
function M:config()
	qvim.integrations.treesitter.climber = {
		active = true,
		on_config_done = nil,
		keymaps = {
			["H"] = { callback = require("tree-climber").goto_parent, desc = "Climb to parent node." },
			["L"] = { callback = require("tree-climber").goto_child, desc = "Climb to child node." },
			["J"] = { callback = require("tree-climber").goto_next, desc = "Climb to next node." },
			["K"] = { callback = require("tree-climber").goto_prev, desc = "Climb to previous node." },
			["<c-k>"] = {
				callback = require("tree-climber").swap_prev,
				desc = "Swap current with previous node.",
			},
			["<c-j>"] = {
				callback = require("tree-climber").swap_next,
				desc = "Swap current with next node.",
			},
			["<c-h>"] = {
				callback = require("tree-climber").highlight_node,
				desc = "Highlight current node",
			},
		},
		options = {
			-- climber option configuration
		},
		url = "https://github.com/drybalka/tree-climber.nvim",
	}
end

return M
