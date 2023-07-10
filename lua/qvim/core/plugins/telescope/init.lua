local log = require("qvim.log")

---@generic T
---@class telescope : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, T> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup fun(self: telescope)|nil overwrite the setup function in core_meta_parent
---@field url string neovim plugin url
local telescope = {
    enabled = true,
    name = nil,
    extensions = {},
    conf_extensions = {},
    options = {},
    keymaps = {},
    main = nil,
    setup = nil, -- getmetatable(self).__index.setup(self) to call generic setup with additional logic
    url = nil,
}

telescope.__index = telescope

return telescope
