local color_templates = {}
local colors = require("qvim.core.plugins.lualine.util").get_colors()

color_templates.catppuccin = {
	normal = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	insert = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	visual = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	replace = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	command = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	terminal = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
	inactive = {
		a = { bg = colors.surface0, fg = colors.mauve, gui = "bold" },
		b = { bg = colors.surface1, fg = colors.teal },
		c = { bg = colors.surface0, fg = colors.pink },
		x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
		y = { bg = colors.base, fg = colors.pink, gui = "bold" },
		z = { bg = colors.base, fg = colors.teal, gui = "bold" },
	},
}

return color_templates
