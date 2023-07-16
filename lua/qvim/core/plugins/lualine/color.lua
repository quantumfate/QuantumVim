local color_templates = {}
local colors = require("qvim.core.plugins.lualine.util").get_colors()

color_templates.catppuccin = {
    normal = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    insert = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    visual = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    replace = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    command = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    terminal = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
    inactive = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.pink, fg = colors.mantle },
        c = { bg = colors.surface0, fg = colors.pink },
        x = { bg = colors.surface0, fg = colors.text, gui = "bold" },
        y = { bg = colors.pink, fg = colors.crust, gui = "bold" },
        z = { bg = colors.mauve, fg = colors.crust, gui = "bold" },
    },
}

return color_templates
