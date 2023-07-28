---@class hop : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: hop, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: hop)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: hop, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local hop = {
	enabled = true,
	name = nil,
	options = {
		keys = "etovxqpdygfblzhckisuran",
	},
	keymaps = {
		mappings = {
			t = {
				"",
				"Jump before any char on the current line.",
				noremap = false,
				callback = function()
					local hop = require("hop")
					hop.hint_char1({
						current_line_only = true,
					})
				end,
				mode = { "v", "o", "n", "x" },
			},
			T = {
				"",
				"Jump after any char on the current line.",
				noremap = false,
				callback = function()
					local hop = require("hop")
					hop.hint_char1({
						current_line_only = true,
						hint_offset = 1,
					})
				end,
				mode = { "v", "o", "n", "x" },
			},
			h = {
				name = "+Hop",
				h = {
					desc = "Jump before any char.",
					callback = function()
						local hop = require("hop")
						hop.hint_char1({
							current_line_only = false,
						})
					end,
				},
				H = {
					desc = "Jump after any char.",
					callback = function()
						local hop = require("hop")
						hop.hint_char1({
							current_line_only = false,
							hint_offset = 1,
						})
					end,
				},
				["/"] = {
					desc = "Jump to search pattern.",
					callback = function()
						local hop = require("hop")
						hop.hint_patterns({
							current_line_only = false,
						})
					end,
				},
			},
		},
	},
	main = "hop",
	on_setup_start = nil,
	setup = nil,
	---@param self hop
	on_setup_done = function(self)
		require("qvim.core.util").register_keymaps(self)
	end,
	url = "https://github.com/smoka7/hop.nvim",
}

hop.__index = hop

return hop
