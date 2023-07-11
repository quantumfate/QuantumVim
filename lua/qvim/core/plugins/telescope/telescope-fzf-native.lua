---@class telescope-fzf-native : core_meta_ext, telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope-fzf-native, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: telescope-fzf-native)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: telescope-fzf-native, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope_fzf_native = {
    enabled = true,
    name = nil,
    options = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    },
    keymaps = {},
    main = "fzf",
    on_setup_start = nil,
    ---@param self telescope-fzf-native<AbstractExtension>
    setup_ext = function(self)
        require("qvim.core.plugins.telescope.util").hook_extension(self)
    end,
    on_setup_done = nil,
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
}

telescope_fzf_native.__index = telescope_fzf_native

return telescope_fzf_native
