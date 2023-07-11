---@generic T
---@class nvim-dap : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-dap, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-dap)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: nvim-dap, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_dap = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    options = {},
    keymaps = {},
    main = nil,
    on_setup_start = nil,
    setup = nil,
    on_setup_done = nil,
    url = nil,
}

nvim_dap.__index = nvim_dap

return nvim_dap
