---@class component : table
---@field [1] string
---@field icons_enabled boolean
---@field icon string|nil
---@field separator string|nil
---@field cond fun():boolean|nil
---@field draw_empty boolean
---@field color table<string,string>|string|fun(section: string):table<string,string>|nil
---@field type string|function|nil
---@field padding number
---@field fmt fun(displayed: string, ctx: table)|nil
---@field on_click fun(count: number, m_button:string, modifiers:table)|nil

---@type lualine_components
local lualine_components = require("qvim.core.plugins.lualine.components")
local color_template = require("qvim.core.plugins.lualine.color").catppuccin
---@type lualine_highlights
local lualine_highlights = require("qvim.core.plugins.lualine.highlights")

---@class lualine : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options lualine_options|nil options used in the setup call of lualine
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: lualine, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: lualine)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: lualine, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local lualine = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    ---@class lualine_options : table
    ---@field options options
    ---@field sections sections
    ---@field inactive_sections inactive_sections
    options = {
        ---@class options : table
        ---@field icons_enabled boolean
        ---@field component_separators table<string, string>
        ---@field section_separators table<string, string>
        ---@field theme string|table
        ---@field disabled_filetypes table<string,table<string>|string>
        ---@field globalstatus boolean
        options = {
            -- lualine option configuration
            icons_enabled = qvim.config.use_icons,
            component_separators = {
                left = lualine_highlights.ComponentDividerDarkBg(qvim.icons.ui.DividerRight),
                right = lualine_highlights.ComponentDividerDarkBg(qvim.icons.ui.DividerLeft)
            },
            section_separators = { left = qvim.icons.ui.BoldDividerRight, right = qvim.icons.ui.BoldDividerLeft },
            theme = color_template,
            disabled_filetypes = { statusline = { "alpha" }, "dashboard", "NvimTree", "Outline" },
            globalstatus = true,
        },
        ---@class sections : table
        ---@field lualine_a table<component>|nil
        ---@field lualine_b table<component>|nil
        ---@field lualine_c table<component>|nil
        ---@field lualine_x table<component>|nil
        ---@field lualine_y table<component>|nil
        ---@field lualine_z table<component>|nil
        sections = {
            lualine_a = {
                lualine_components.mode,
            },
            lualine_b = {
                lualine_components.branch,
            },
            lualine_c = {
                lualine_components.diff,
                lualine_components.python_env,
                lualine_components.lsp_progress,
            },
            lualine_x = {
                lualine_components.diagnostics,
                lualine_components.lsp,
                lualine_components.copilot,
                lualine_components.filetype,
            },
            lualine_y = {

                lualine_components.location
            },
            lualine_z = {
                lualine_components.progress,
            },
        },
        ---@class inactive_sections : table
        ---@field lualine_a table<component>|nil
        ---@field lualine_b table<component>|nil
        ---@field lualine_c table<component>|nil
        ---@field lualine_x table<component>|nil
        ---@field lualine_y table<component>|nil
        ---@field lualine_z table<component>|nil
        inactive_sections = {
            lualine_a = {
                lualine_components.mode,
            },
            lualine_b = {
                lualine_components.branch,
            },
            lualine_c = {
                lualine_components.diff,
                lualine_components.python_env,
                lualine_components.lsp_progress,
            },
            lualine_x = {
                lualine_components.diagnostics,
                lualine_components.lsp,
                lualine_components.filetype,
            },
            lualine_y = {

                lualine_components.location
            },
            lualine_z = {
                lualine_components.progress,
            },
            tabline = nil,
            extensions = nil,
        },
    },
    keymaps = {},
    main = "lualine",
    on_setup_start = nil,
    setup = nil,
    on_setup_done = nil,
    url = "https://github.com/nvim-lualine/lualine.nvim",
}
lualine.__index = lualine

return lualine
