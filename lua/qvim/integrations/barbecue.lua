---The barbecue configuration file
local M = {}

local Log = require("qvim.integrations.log")

---Registers the global configuration scope for barbecue
function M:init()
	vim.opt.updatetime = 200
	local barbecue = {
		active = true,
		on_config_done = nil,
		keymaps = {},
		options = {

			-- barbecue option configuration
			theme = "catppuccin-mocha",
			attach_navic = false, -- done automatically on attach in lsp
			show_modified = true,
			create_autocmd = false, -- autocammand is defined
			kinds = {
				File = qvim.icons.kind.File,
				Module = qvim.icons.kind.Module,
				Namespace = qvim.icons.kind.Namespace,
				Package = qvim.icons.kind.Package,
				Class = qvim.icons.kind.Class,
				Method = qvim.icons.kind.Method,
				Property = qvim.icons.kind.Property,
				Field = qvim.icons.kind.Field,
				Constructor = qvim.icons.kind.Constructor,
				Enum = qvim.icons.kind.Enum,
				Interface = qvim.icons.kind.Interface,
				Function = qvim.icons.kind.Function,
				Variable = qvim.icons.kind.Variable,
				Constant = qvim.icons.kind.Constant,
				String = qvim.icons.kind.String,
				Number = qvim.icons.kind.Number,
				Boolean = qvim.icons.kind.Boolean,
				Array = qvim.icons.kind.Array,
				Object = qvim.icons.kind.Object,
				Key = qvim.icons.kind.Key,
				Null = qvim.icons.kind.Null,
				EnumMember = qvim.icons.kind.EnumMember,
				Struct = qvim.icons.kind.Struct,
				Event = qvim.icons.kind.Event,
				Operator = qvim.icons.kind.Operator,
				TypeParameter = qvim.icons.kind.TypeParameter,
			},
		},
	}
	return barbecue
end

---The barbecue setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	local status_ok, barbecue = pcall(reload, "barbecue")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", barbecue))
		return
	end

	local _barbecue = qvim.integrations.barbecue
	barbecue.setup(_barbecue.options)

	if _barbecue.on_config_done then
		_barbecue.on_config_done()
	end
end

return M
