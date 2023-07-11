---@class telescope-lazy : core_meta_ext, telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope-lazy, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: telescope-lazy)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: telescope-lazy, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope_lazy = {
    enabled = true,
    name = nil,
    options = {
        -- Optional theme (the extension doesn't set a default theme)
        theme = "ivy",
        -- Whether or not to show the icon in the first column
        show_icon = true,
        -- Mappings for the actions
        mappings = {
            open_in_browser = "<C-o>",
            open_in_file_browser = "<M-b>",
            open_in_find_files = "<C-f>",
            open_in_live_grep = "<C-g>",
            open_plugins_picker = "<C-b>", -- Works only after having called first another action
            open_lazy_root_find_files = "<C-r>f",
            open_lazy_root_live_grep = "<C-r>g",
        },
    },
    keymaps = {},
    main = "lazy",
    on_setup_start = nil,
    ---@param self telescope-lazy<AbstractExtension>
    setup_ext = function(self)
        require("qvim.core.plugins.telescope.util").hook_extension(self)
    end,
    on_setup_done = nil,
    url = "https://github.com/tsakirist/telescope-lazy.nvim",
}

telescope_lazy.__index = telescope_lazy

return telescope_lazy
