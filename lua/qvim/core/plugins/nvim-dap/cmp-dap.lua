---@class cmp-dap : core_meta_ext, nvim-dap
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: cmp-dap, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: cmp-dap)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: cmp-dap, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local cmp_dap = {
    -- is configured in nvim-dap
    enabled = true,
    name = nil,
    options = {},
    keymaps = {},
    main = nil,
    on_setup_start = nil,
    setup_ext = function()
        -- skip setup
    end,
    on_setup_done = nil,
    url = "https://github.com/rcarriga/cmp-dap",
}

cmp_dap.__index = cmp_dap

return cmp_dap
