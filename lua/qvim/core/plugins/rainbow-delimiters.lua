local rd = require("qvim.utils.modules").require_on_index("rainbow-delimiters")

---@class rainbow-delimiters : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: rainbow-delimiters, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: rainbow-delimiters)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: rainbow-delimiters, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local rainbow_delimiters = {
	enabled = true,
	name = nil,
	options = {
		strategy = {
			[""] = rd.strategy["global"],
			commonlisp = rd.strategy["local"],
		},
		query = {
			[""] = "rainbow-delimiters",
			latex = "rainbow-blocks",
		},
		highlight = {
			"RainbowDelimiterRed",
			"RainbowDelimiterYellow",
			"RainbowDelimiterBlue",
			"RainbowDelimiterOrange",
			"RainbowDelimiterGreen",
			"RainbowDelimiterViolet",
			"RainbowDelimiterCyan",
		},
		blacklist = {},
	},
	keymaps = {
		mappings = {},
	},
	main = "rainbow-delimiters",
	on_setup_start = nil,
	---@param self rainbow-delimiters
	setup = function(self)
		vim.g.rainbow_delimiters = self.options
	end,
	on_setup_done = nil,
	url = "https://github.com/hiphish/rainbow-delimiters.nvim",
}

rainbow_delimiters.__index = rainbow_delimiters

return rainbow_delimiters
