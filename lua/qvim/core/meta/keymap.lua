---@class keymaps
---@field mappings table|nil
---@field options table|nil
local keymap_mt = {
    options = {
        prefix = "<leader>"
    }
}

return keymap_mt
