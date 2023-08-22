---@class ts_util
local ts_util = require("qvim.core.plugins.nvim-treesitter.util")
---@class nvim-treesitter-refactor : nvim-treesitter
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-treesitter-refactor, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-treesitter-refactor)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-treesitter-refactor, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_treesitter_refactor = {
	enabled = true,
	name = nil,
	options = {
		highlight_definitions = {
			enable = true,
			-- Set to false if you have an `updatetime` of ~100.
			clear_on_cursor_move = true,
		},
		smart_rename = {
			enable = true,
			-- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
			keymaps = {
				smart_rename = "grr",
			},
		},
		navigation = {
			enable = true,
			-- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
			keymaps = {
				--TODO
				-- goto_definition = "gnd",
				-- list_definitions = "gnD",
				-- list_definitions_toc = "gO",
				-- goto_next_usage = "<a-*>",
				-- goto_previous_usage = "<a-#>",
			},
		},
	},
	keymaps = {
		mappings = {},
	},
	main = "refactor", -- used to hook into treesitter config
	on_setup_start = nil,
	---@param self nvim-treesitter-refactor<AbstractExtension>
	setup_ext = function(self)
		ts_util.hook_extension_options(self)
	end,
	on_setup_done = nil,
	url = "https://github.com/nvim-treesitter/nvim-treesitter-refactor",
}

nvim_treesitter_refactor.__index = nvim_treesitter_refactor

return nvim_treesitter_refactor
