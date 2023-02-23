local M = {}
local functions = require "qvim.utils.functions"
local Log = require "qvim.integrations.log"
if functions.in_headless_mode() then
    Log:info("Headless Mode: Not setting any keymaps.")
    return
end



function M:init()
    if functions.in_headless_mode() then
        Log:info("Headless mode detected. Not loading any keymappings.")
        return
    end

    qvim.keymaps = qvim.keymaps or {}
    for mode_adapters, _ in pairs(keymap_mode_adapters) do
        if not qvim.keymaps[mode_adapters] then
            -- init empty table for mode_adapters that are not set by default
            qvim.keymaps[mode_adapters] = {}
        end
    end


    --    local defaults = self:get_defaults()
end

return M
