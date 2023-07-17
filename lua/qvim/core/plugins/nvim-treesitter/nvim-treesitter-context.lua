---@class nvim-treesitter-context : nvim-treesitter
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-treesitter-context, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-treesitter-context)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-treesitter-context, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_treesitter_context = {
    enabled = true,
    name = nil,
    options = {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
        trim_scope = "outer",     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor",          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20,     -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
    keymaps = {},
    main = "treesitter-context",
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = "https://github.com/nvim-treesitter/nvim-treesitter-context",
}

nvim_treesitter_context.__index = nvim_treesitter_context

return nvim_treesitter_context
