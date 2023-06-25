---The hop configuration file
local M = {}

local utils = require("qvim.utils")
local Log = require("qvim.integrations.log")
local directions = require("hop.hint").HintDirection
---Registers the global configuration scope for hop
function M:init()
	local hop = {
		active = true,
		on_config_done = nil,
		keymaps = {
			f = {
				"",
				"Jump anywhere after the selected cursor.",
				callback = function()
					local hop = require("hop")
					hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = false })
				end,
			},
			F = {
				"",
				"Jump anywhere before the selected cursor.",
				callback = function()
					local hop = require("hop")
					hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = false })
				end,
			},
			t = {
				"",
				"Jump after the selected cursor on the current line only.",
				callback = function()
					local hop = require("hop")
					hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
				end,
			},
			T = {
				"",
				"Jump before the selected cursor on the current line only.",
				callback = function()
					local hop = require("hop")
					hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
				end,
			},
		},
		-- hop option configuration
		options = {
			keys = "etovxqpdygfblzhckisuran",
			-- Options to parse to a keymap
			opts = {
				silent = true,
				noremap = true,
				callback = nil,
				desc = nil,
			},
		},
	}
	return hop
end

---The hop setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
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
