---The hop configuration file
local M = {}

local utils = require("qvim.utils")
local Log = require("qvim.log")
local hint_position = require("hop.hint").HintPosition
---Registers the global configuration scope for hop
function M:init()
	if in_headless_mode() then
		return
	end
	local hop = {
		active = true,
		on_config_done = nil,
		keymaps = {
			t = {
				desc = "Jump before any char on the current line.",
				noremap = false,
				callback = function()
					local hop = require("hop")
					hop.hint_char1({
						current_line_only = true,
					})
				end,
			},
			T = {
				desc = "Jump after any char on the current line.",
				noremap = false,
				callback = function()
					local hop = require("hop")
					hop.hint_char1({
						current_line_only = true,
						hint_offset = 1,
					})
				end,
			},
			{
				binding_group = "h",
				name = "+Hop",
				bindings = {
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
				options = {
					prefix = "<leader>",
				},
			},
		},
		-- hop option configuration
		options = {
			keys = "etovxqpdygfblzhckisuran",
		},
	}
	return hop
end

---The hop setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	if in_headless_mode() then
		return
	end
	local status_ok, hop = pcall(reload, "hop")
	if not status_ok then
		Log:warn("The plugin '%s' could not be loaded.", hop)
		return
	end
	local _hop = qvim.integrations.hop
	local hop_keys = _hop.options.keys

	hop.setup({ keys = hop_keys })

	if _hop.on_config_done then
		_hop.on_config_done()
	end
end

return M
