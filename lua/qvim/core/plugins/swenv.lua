---@class swenv : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: swenv, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: swenv)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: swenv, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local swenv = {
	enabled = true,
	name = nil,
	options = {
		-- swenv option configuration
		get_venvs = function(venvs_path)
			return require("swenv.api").get_venvs(venvs_path)
		end,
		-- Path passed to `get_venvs`.
		venvs_path = vim.fn.expand("~/venvs"),
		-- Something to do after setting an environment, for example call vim.cmd.LspRestart
		post_set_venv = function()
			return vim.cmd.LspRestart
		end,
	},
	keymaps = {},
	main = "swenv",
	on_setup_start = nil,
	setup = nil,
	on_setup_done = nil,
	url = "https://github.com/AckslD/swenv.nvim",
}

swenv.__index = swenv

return swenv
