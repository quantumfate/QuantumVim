---@class nvim-dap-virtual-text : nvim-dap
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-dap-virtual-text, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-dap-virtual-text)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-dap-virtual-text, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_dap_virtual_text = {
    enabled = true,
    name = nil,
    options = {
        only_first_definition = true,
    },
    keymaps = {},
    main = "nvim-dap-virtual-text",
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = "https://github.com/theHamsta/nvim-dap-virtual-text",
}

nvim_dap_virtual_text.__index = nvim_dap_virtual_text

return nvim_dap_virtual_text
