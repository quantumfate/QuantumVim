local M = {}
local Log = require "qvim.integrations.log"
local meta = require("qvim.keymaps.meta")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local util = require("qvim.keymaps.util")
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

    local keymaps = meta.get_new_keymap_mt()

    for _, integration in ipairs(qvim_integrations()) do
        local integration_keymaps = qvim.integrations[integration].keymaps

        if integration_keymaps then
            if fn_t.length(integration_keymaps) > 0 then
                Log:debug(string.format("Processing keymaps for '%s'.", integration))
                for lhs, declaration in pairs(integration_keymaps) do
                    if type(lhs) == "string" then
                        -- binding
                        keymaps[lhs] = declaration
                    elseif type(lhs) == "number" and util.has_simple_group_structure(declaration) then
                        -- group
                        keymaps[#keymaps + 1] = declaration
                    else
                        Log:error(string.format("Unsupported key '%s' from type '%s' in keymaps init function.",
                            tostring(lhs), type(lhs)))
                    end
                end
            else
                Log:debug(string.format("No keymaps defined for '%s'.", integration))
            end
        else
            Log:debug("For integration '%s' were not keymaps found.", integration)
        end
    end

    -- try to require whichkey
    -- iterate qvim.integrations for all keymaps
    -- aggregate them in one table
    -- fetch keymaps for whichkey or normal layout when whichkey is not available
    -- translate the groups into whichkey format or in workaround when whichkey is not available
    -- register the keymaps or parse them in whichkey

    qvim.keymaps = keymaps

    Log:info("Keymaps were loaded.")
end

return M
