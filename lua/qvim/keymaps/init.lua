local M = {}
local Log = require "qvim.integrations.log"
local meta = require("qvim.keymaps.meta")
if in_headless_mode() then
    Log:info("Headless Mode: Not setting any keymaps.")
    return
end



function M:init()
    if in_headless_mode() then
        Log:info("Headless mode detected. Not loading any keymappings.")
        return
    end

    qvim.keymaps = setmetatable({}, {
        __index = meta.keymap_mode_meta
    })

    Log:info("Keymaps were loaded.")
end

return M
