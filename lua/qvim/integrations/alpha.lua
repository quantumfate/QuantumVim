---The alpha configuration file
local M = {}

local Log = require("qvim.integrations.log")
local header = {
	[[                                                              ]],
	[[   ____                    __                _    ___         ]],
	[[  / __ \__  ______ _____  / /___  ______ ___| |  / (_)___ ___ ]],
	[[ / / / / / / / __ `/ __ \/ __/ / / / __ `__ \ | / / / __ `__ \]],
	[[/ /_/ / /_/ / /_/ / / / / /_/ /_/ / / / / / / |/ / / / / / / /]],
	[[\___\_\__,_/\__,_/_/ /_/\__/\__,_/_/ /_/ /_/|___/_/_/ /_/ /_/ ]],
	[[                                                              ]],
}
---Registers the global configuration scope for alpha
function M:init()
	local alpha = {
		activ = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			header = header,
			noautocmd = true,
			header_hl = "Include",
			-- alpha option configuration
			buttons = {
				{ key = "f", desc = "  Find file", cmd = ":Telescope find_files <CR>" },
				{ key = "e", desc = "  New file", cmd = ":ene <BAR> startinsert <CR>" },
				{ key = "p", desc = "  Find project", cmd = ":Telescope projects <CR>" },
				{
					key = "r",
					desc = "  Recently used files",
					cmd = ":lua require'telescope'.extensions.project.project{}<CR>",
				},
				{ key = "t", desc = "  Find text", cmd = ":Telescope live_grep <CR>" },
				{ key = "c", desc = "  Configuration", cmd = ":e ~/.config/qvim/ <CR>" },
				{ key = "q", desc = "  Quit Neovim", cmd = ":qa<CR>" },
			},
			button_area = {
				type = "group",
				val = {
					{ type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
					{ type = "padding", val = 1 },
				},
				position = "center",
			},
		},
	}
	return alpha
end

---Create the dashboard buttons.
---@param buttons table the buttons configuration
---@param button_area table the button block in the dashboard
---@return table button_area the modified block
local function create_buttons(buttons, button_area)
	local dashboard = require("alpha.themes.dashboard")

	for _, button in ipairs(buttons) do
		button_area.val[#button_area.val + 1] = dashboard.button(button.key, button.desc, button.cmd)
	end
	return button_area
end

---The alpha setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, alpha = pcall(reload, "alpha")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", "alpha"))
		return
	end
	local theme = require("alpha.themes.theta")
	local _alpha = qvim.integrations.alpha
	local _options = _alpha.options
	local buttons = create_buttons(_options.buttons, _options.button_area)

	theme.buttons = buttons
	theme.header.val = _options.header
	theme.header.opts.hl = _options.header_hl

	local cdir = vim.fn.getcwd()

	local section_mru = {
		type = "group",
		val = {
			{
				type = "text",
				val = "Recent files",
				opts = {
					hl = "SpecialComment",
					shrink_margin = false,
					position = "center",
				},
			},
			{ type = "padding", val = 1 },
			{
				type = "group",
				val = function()
					return { theme.mru(0, cdir) }
				end,
				opts = { shrink_margin = false },
			},
		},
	}
	local layout = {
		{ type = "padding", val = 2 },
		theme.header,
		{ type = "padding", val = 2 },
		section_mru,
		{ type = "padding", val = 2 },
		buttons,
	}

	theme.config.layout = layout

	alpha.setup(theme.config)

	if _alpha.on_config_done then
		_alpha.on_config_done()
	end
end

return M
