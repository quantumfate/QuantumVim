---The hover configuration file
local M = {}


local Log = require("qvim.log")

---Registers the global configuration scope for hover
function M:init()
	if in_headless_mode() then
		return
	end
	local hover = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {
			-- hover option configuration
			init = function()
				-- Require providers
				require("hover.providers.lsp")
				require("hover.providers.gh")
				-- require('hover.providers.gh_user')
				-- require('hover.providers.jira')
				-- require('hover.providers.man')
				-- require('hover.providers.dictionary')
			end,
			preview_opts = {
				border = "single",
			},
			-- Whether the contents of a currently open hover window should be moved
			-- to a :h preview-window when pressing the hover keymap.
			preview_window = false,
			title = true,
		},
	}
	return hover
end

---The hover setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	if in_headless_mode() then
		return
	end
	local status_ok, hover = pcall(reload, "hover")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", hover))
		return
	end

	local _hover = qvim.integrations.hover
	hover.setup(_hover.options)

	if _hover.on_config_done then
		_hover.on_config_done()
	end
end

return M
