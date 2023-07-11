---@class nvim-dap-repl-highlights : core_meta_ext, nvim-dap
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-dap-repl-highlights, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-dap-repl-highlights)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-dap-repl-highlights, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_dap_repl_highlights = {
    enabled = true,
    name = nil,
    options = nil,
    keymaps = {},
    main = "nvim-dap-repl-highlights",
    on_setup_start = nil,
    setup_ext = nil,
    on_setup_done = nil,
    url = "https://github.com/LiadOz/nvim-dap-repl-highlights",
}

nvim_dap_repl_highlights.__index = nvim_dap_repl_highlights

return nvim_dap_repl_highlights
