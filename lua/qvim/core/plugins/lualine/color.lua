local color_templates = {}
local colors = require("qvim.core.plugins.lualine.util").get_colors()

color_templates.catppuccin = {
    normal = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    insert = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    visual = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    replace = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    command = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    terminal = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
    inactive = {
        a = { bg = colors.mauve, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.base, fg = colors.pink, gui = "bold" },
        z = { bg = colors.base, fg = colors.teal, gui = "bold" },
    },
}

return color_templates
