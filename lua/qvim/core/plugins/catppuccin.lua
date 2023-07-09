---The catpuccin configuration file
local M = {}

local Log = require "qvim.log"

---Registers the global configuration scope for catpuccin
function M:init()
    if in_headless_mode() then
        return
    end
    local catppuccin = {
        active = true,
        on_config_done = nil,
        keymaps = {},
        options = {
            -- catpuccin option configuration
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            transparent_background = false, -- disables setting the background color.
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
            dim_inactive = {
                enabled = false, -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            no_italic = false, -- Force no italic
            no_bold = false, -- Force no bold
            no_underline = false, -- Force no underline
            styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            color_overrides = {},
            integrations = {
                nvimtree = true,
                telescope = true,
                notify = true,
                alpha = true,
                gitsigns = true,
                hop = true,
                mini = false,
                indent_blankline = {
                    enabled = true,
                    colored_indent_levels = false,
                },
                leap = true,
                markdown = true,
                mason = true,
                neotest = true,
                cmp = true,
                dap = {
                    enabled = true,
                    enable_ui = true,
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                navic = {
                    enabled = true,
                    custom_bg = "NONE",
                },
                ts_rainbow2 = true,
                treesitter_context = true,
                treesitter = true,
                which_key = true,
                illuminate = true,
                barbecue = {
                    dim_dirname = true, -- directory name is dimmed by default
                    bold_basename = true,
                    dim_context = false,
                    alt_background = false,
                },
                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            },
        },
        url = "https://github.com/catppuccin/nvim",
    }
    return catppuccin
end

---@return colors
function M.get_colors()
    ---@class colors
    ---@field	rosewater string
    ---@field	flamingo string
    ---@field	pink string
    ---@field	mauve string
    ---@field	red string
    ---@field	maroon string
    ---@field	peach string
    ---@field	yellow string
    ---@field	green string
    ---@field	teal string
    ---@field	sky string
    ---@field	sapphire string
    ---@field	blue string
    ---@field	lavender string
    ---@field	text string
    ---@field	subtext1 string
    ---@field	subtext0 string
    ---@field	overlay2 string
    ---@field	overlay1 string
    ---@field	overlay0 string
    ---@field	surface2 string
    ---@field	surface1 string
    ---@field	surface0 string
    ---@field	base string
    ---@field	mantle string
    ---@field	crust string
    return require("catppuccin.palettes").get_palette "mocha"
end

---The catpuccin setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
    if in_headless_mode() then
        return
    end
    local status_ok, catppuccin = pcall(reload, "catppuccin")
    if not status_ok then
        Log:warn(
            string.format("The plugin '%s' could not be loaded.", catppuccin)
        )
        return
    end

    local _catppuccin = qvim.integrations.catppuccin
    catppuccin.setup(_catppuccin.options)

    if _catppuccin.on_config_done then
        _catppuccin.on_config_done()
    end
end

return M
