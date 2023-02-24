---@class default
local default = {}
local Log = require "qvim.integrations.log"

default.keymap_opts_mt = setmetatable({}, {
    __index = function(t, k)
        local opts = {
            mode = true,
            noremap = true,
            nowait = true,
            silent = true,
            script = true,
            expr = true,
            unique = true,
            buffer = true,
            callback = true,
            desc = true,
        }
        if opts[k] then
            local defaults = {
                mode = "n",
                noremap = true,
                nowait = false,
                silent = true,
                script = false,
                expr = false,
                unique = false,
                buffer = nil,
                callback = nil,
                desc = "",
            }
            return defaults[k]
        else
            Log:error(string.format("Invalid option '%s' for keymap.", k))
        end
    end
})

return default
