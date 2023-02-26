---@class default_mt
local default_mt = {}
local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")

default_mt.keymap_opts_mt = setmetatable({}, {
    __index = function(t, k)
        if default.valid_keymap_opts[k] then
            return default.keymap_opts[k]
        else
            Log:error(string.format("Invalid option '%s' for keymap.", k))
        end
    end
})


return default_mt
