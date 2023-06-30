local M = {}
local components = require("qvim.integrations.lualine.components")

local themes = {
	qvim = nil,
	default = nil,
	none = nil,
}

themes.none = {
	theme = "none",
	options = {
		theme = "auto",
		globalstatus = true,
		icons_enabled = qvim.use_icons,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {},
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
}

themes.default = {
	theme = "default",
	options = {
		theme = "auto",
		globalstatus = true,
		icons_enabled = qvim.use_icons,
		component_separators = {
			left = qvim.icons.ui.DividerRight,
			right = qvim.icons.ui.DividerLeft,
		},
		section_separators = {
			left = qvim.icons.ui.BoldDividerRight,
			right = qvim.icons.ui.BoldDividerLeft,
		},
		disabled_filetypes = {},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {},
}

themes.qvim = {
	theme = "qvim",
	options = {
		theme = "auto",
		globalstatus = true,
		icons_enabled = qvim.use_icons,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "alpha" },
	},
	sections = {
		lualine_a = {
			components.mode,
		},
		lualine_b = {
			components.branch,
		},
		lualine_c = {
			components.diff,
			components.python_env,
		},
		lualine_x = {
			components.diagnostics,
			components.lsp,
			components.spaces,
			components.filetype,
		},
		lualine_y = { components.location },
		lualine_z = {
			components.progress,
		},
	},
	inactive_sections = {
		lualine_a = {
			components.mode,
		},
		lualine_b = {
			components.branch,
		},
		lualine_c = {
			components.diff,
			components.python_env,
		},
		lualine_x = {
			components.diagnostics,
			components.lsp,
			components.spaces,
			components.filetype,
		},
		lualine_y = { components.location },
		lualine_z = {
			components.progress,
		},
	},
	tabline = {},
	extensions = {},
}

function M.get_theme(theme)
	local theme_keys = vim.tbl_keys(themes)
	if not vim.tbl_contains(theme_keys, theme) then
		local Log = require("qvim.log")
		Log:error(
			"Invalid lualine theme"
			.. string.format('"%s"', theme)
			.. "options are: "
			.. string.format('"%s"', table.concat(theme_keys, '", "'))
		)
		Log:debug('"qvim" theme is applied.')
		theme = "qvim"
	end
	return vim.deepcopy(themes[theme])
end

function M.update()
	local theme = M.get_theme(qvim.integrations.lualine.theme)
	local Log = require("qvim.log")

	qvim.integrations.lualine = vim.tbl_deep_extend("keep", qvim.integrations.lualine, theme)

	local color_template = vim.g.colors_name or qvim.colorscheme
	local theme_supported, template = pcall(function()
		require("lualine.utils.loader").load_theme(color_template)
	end)
	if theme_supported and template then
		qvim.integrations.lualine.options.theme = color_template
	end
end

return M
