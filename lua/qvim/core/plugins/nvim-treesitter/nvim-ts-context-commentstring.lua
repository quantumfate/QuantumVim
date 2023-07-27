---@class nvim-ts-context-commentstring : nvim-treesitter
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-ts-context-commentstring, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-ts-context-commentstring)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-ts-context-commentstring, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_ts_context_commentstring = {
    enabled = true,
    name = nil,
    options = {
        enable = true,
        enable_autocmd = false,
        config = {
            -- Languages that have a single comment style
            typescript = "// %s",
            css = "/* %s */",
            scss = "/* %s */",
            html = "<!-- %s -->",
            svelte = "<!-- %s -->",
            vue = "<!-- %s -->",
            json = "",
        },
    },
    keymaps = {},
    main = nil,
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
}

nvim_ts_context_commentstring.__index = nvim_ts_context_commentstring

return nvim_ts_context_commentstring
