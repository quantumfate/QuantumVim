local color_templates = {}
local colors = require("qvim.core.plugins.lualine.util").get_colors()

color_templates.catppuccin = {
    normal = {
        a = { bg = colors.teal, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.lavender, fg = colors.mantle },
        y = { bg = colors.mauve, fg = colors.mantle },
        z = { bg = colors.rosewater, fg = colors.mantle },
    },
    insert = {
        a = { bg = colors.text, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.pink, fg = colors.mantle },
        y = { bg = colors.flamingo, fg = colors.mantle },
        z = { bg = colors.red, fg = colors.mantle },
    },
    visual = {
        a = { bg = colors.red, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.blue, fg = colors.mantle },
        y = { bg = colors.sapphire, fg = colors.mantle },
        z = { bg = colors.sky, fg = colors.mantle },
    },
    replace = {
        a = { bg = colors.peach, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.green, fg = colors.mantle },
        y = { bg = colors.yellow, fg = colors.mantle },
        z = { bg = colors.peach, fg = colors.mantle },
    },
    command = {
        a = { bg = colors.green, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.maroon, fg = colors.mantle },
        y = { bg = colors.red, fg = colors.mantle },
        z = { bg = colors.mauve, fg = colors.mantle },
    },
    terminal = {
        a = { bg = colors.pink, fg = colors.mantle, gui = 'bold' },
        b = { bg = colors.surface2, fg = colors.text },
        c = { bg = colors.surface0, fg = colors.text },
        x = { bg = colors.text, fg = colors.mantle },
        y = { bg = colors.subtext1, fg = colors.mantle },
        z = { bg = colors.subtext0, fg = colors.mantle },
    },
    inactive = {
        a = { bg = colors.surface0, fg = colors.overlay1, gui = 'bold' },
        b = { bg = colors.surface0, fg = colors.overlay1 },
        c = { bg = colors.surface0, fg = colors.overlay1 },
        x = { bg = colors.overlay0, fg = colors.overlay1 },
        y = { bg = colors.overlay1, fg = colors.overlay2 },
        z = { bg = colors.overlay2, fg = colors.overlay0 },
    },
}

return color_templates
