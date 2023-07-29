---@class nvim-notify : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-notify, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-notify)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: nvim-notify, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_notify = {
	enabled = true,
	name = nil,
	options = {
		background_colour = "#000000",
		-- notify option configuration
		icons = {
			DEBUG = "",
			ERROR = "",
			INFO = "",
			TRACE = "",
			WARN = "",
			OFF = "",
		},
	},
	keymaps = {},
	main = "notify",
	on_setup_start = nil,
	setup = nil,
	---@param notify table
	on_setup_done = function(_, notify)
		vim.notify = notify
	end,
	url = "https://github.com/rcarriga/nvim-notify",
}

nvim_notify.__index = nvim_notify

return nvim_notify
