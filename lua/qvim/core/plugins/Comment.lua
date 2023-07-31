---@class Comment : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: Comment, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: Comment)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: Comment, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local comment = {
	enabled = true,
	name = nil,
	options = {
		pre_hook = require(
			"ts_context_commentstring.integrations.comment_nvim"
		).create_pre_hook(),
		-- comment option configuration
		---Add a space b/w comment and the line
		padding = true,
		---Whether the cursor should stay at its position
		sticky = true,
		---Lines to be ignored while (un)comment
		ignore = nil,
		---LHS of toggle mappings in NORMAL mode
		toggler = {
			---Line-comment toggle keymap
			line = "gcc",
			---Block-comment toggle keymap
			block = "gbc",
		},
		---LHS of operator-pending mappings in NORMAL and VISUAL mode
		opleader = {
			---Line-comment keymap
			line = "gc",
			---Block-comment keymap
			block = "gb",
		},
		---LHS of extra mappings
		extra = {
			---Add comment on the line above
			above = "gcO",
			---Add comment on the line below
			below = "gco",
			---Add comment at the end of line
			eol = "gcA",
		},
		---Enable keybindings
		---NOTE: If given `false` then the plugin won't create any mappings
		mappings = {
			---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
			basic = true,
			---Extra mapping; `gco`, `gcO`, `gcA`
			extra = true,
		},
	},
	keymaps = {},
	main = "Comment",
	on_setup_start = nil,
	setup = nil,
	on_setup_done = nil,
	url = "https://github.com/numToStr/Comment.nvim",
}

comment.__index = comment

return comment
