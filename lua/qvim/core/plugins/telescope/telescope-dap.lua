---@class telescope-dap : telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope-dap, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: telescope-dap)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: telescope-dap, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope_dap = {
    enabled = true,
    name = nil,
    options = {},
    keymaps = {},
    main = "dap",
    on_setup_start = nil,
    ---@param self telescope-dap<AbstractExtension>
    setup_ext = function(self)
        require("qvim.core.plugins.telescope.util").hook_extension(self)
    end,
    on_setup_done = nil,
    url = "https://github.com/nvim-telescope/telescope-dap.nvim",
}

telescope_dap.__index = telescope_dap

return telescope_dap
