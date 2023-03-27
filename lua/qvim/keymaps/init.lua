local M = {}
local Log = require "qvim.integrations.log"
local meta = require("qvim.keymaps.meta")
local default = require("qvim.keymaps.default")
if in_headless_mode() then
    Log:info("Headless Mode: Not setting any keymaps.")
    return
end


function M:init()
    if in_headless_mode() then
        Log:info("Headless mode detected. Not loading any keymappings.")
        return
    end
    local whichkey_loaded, whichkey = pcall(reload, "whichkey")

    --- A global variable to enable or disable whichkey specific features
    _G.qvim_which_key_is_available = whichkey_loaded

    if whichkey_loaded then
        Log:debug(string.format("Using '%s' to set keymaps.", whichkey))
    else
        Log:debug(string.format("The plugin '%s' is not available. Using standard method to set keymaps.", whichkey))
    end

    local grouped_keymaps = {}

    for _, value in ipairs(qvim_integrations()) do
        qvim.integrations[value].keymaps
    end

    -- try to require whichkey
    -- iterate qvim.integrations for all keymaps
    -- aggregate them in one table
    -- fetch keymaps for whichkey or normal layout when whichkey is not available
    -- translate the groups into whichkey format or in workaround when whichkey is not available
    -- register the keymaps or parse them in whichkey

    qvim.keymaps = setmetatable({}, {
    })

    Log:info("Keymaps were loaded.")
end

return M
