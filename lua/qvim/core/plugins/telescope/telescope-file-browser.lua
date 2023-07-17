---@class telescope-file-browser : telescope
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope-file-browser, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: telescope-file-browser)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: telescope-file-browser, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope_file_browser = {
    enabled = true,
    name = nil,
    options = {
        theme = "ivy",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
        mappings = {
            ["i"] = {
                -- your custom insert mode mappings
            },
            ["n"] = {
                -- your custom normal mode mappings
            },
        },
    },
    keymaps = {},
    main = "file_browser",
    on_setup_start = nil,
    ---@param self telescope-file-browser<AbstractExtension>
    setup_ext = function(self)
        require("qvim.core.plugins.telescope.util").hook_extension(self)
    end,
    on_setup_done = nil,
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim",
}

telescope_file_browser.__index = telescope_file_browser

return telescope_file_browser
