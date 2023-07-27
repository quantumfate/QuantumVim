---@class mason-nvim-dap : nvim-dap
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: mason-nvim-dap, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: mason-nvim-dap)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: mason-nvim-dap, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local mason_nvim_dap = {
    enabled = true,
    name = nil,
    options = {
        -- mason setup is handled by lang section
        automatic_installation = false,
        ensure_installed = { "python", "mix_task", "cppdbg", "codelldb", "chrome", "bash", "node2" },
        handlers = {
        },
    },
    keymaps = {},
    main = "mason-nvim-dap",
    on_setup_start = nil,
    setup_ext = function()
        -- mason dap setup is explicitly called by dap
    end,
    on_setup_done = nil,
    url = "https://github.com/jay-babu/mason-nvim-dap.nvim",
}

mason_nvim_dap.__index = mason_nvim_dap

return mason_nvim_dap
