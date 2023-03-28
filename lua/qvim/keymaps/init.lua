local M = {}
local Log = require "qvim.integrations.log"
local meta = require("qvim.keymaps.meta")
local keymap_defaults = require("qvim.keymaps.keymap")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local util = require("qvim.keymaps.util")
if in_headless_mode() then
    Log:info("Headless Mode: Not setting any keymaps.")
    return
end

local whichkey_loaded, whichkey = pcall(reload, "whichkey")

--- A global variable to enable or disable whichkey specific features
_G.qvim_which_key_is_available = whichkey_loaded

if whichkey_loaded then
    Log:warn(string.format("Using whichkey to set keymaps."))
else
    Log:warn(string.format("The plugin whichkey is not available. Using standard method to set keymaps."))
end

local keymaps = meta.get_new_keymap_mt()
local keymap_groups = meta.get_new_keymap_mt()

local keymap_modes = meta.get_new_mode_mt()

local grouped_keymaps = {}
local function fetch_whichkey_keymaps()

end

local function fetch_standard_keymaps()

end
---Initializes the `qvim.keymaps` variable with from every configured integration.
---Additionally a global variable `qvim_which_key_is_available` will be registered that
---that will determine the behavior of how keymaps are going to be registered.
function M:init()
    if in_headless_mode() then
        Log:info("Headless mode detected. Not loading any keymappings.")
        return
    end

    -- get the defaults
    for _mode, _keymaps in pairs(keymap_defaults.get_defaults()) do
        for _lhs, _bind in pairs(_keymaps) do
            local current_mode = keymap_mode_adapters[_mode]
            local bind_mt = meta.set_binding_mt(_lhs, _bind, { mode = current_mode })
            local descriptor_key = tostring(bind_mt)
            if not keymap_modes[_mode] then
                keymap_modes[_mode] = meta.get_new_descriptor_mt()
            end
            if not keymap_modes[_mode][descriptor_key] then
                keymap_modes[_mode][descriptor_key] = {}
            end
            keymap_modes[_mode][descriptor_key][_lhs] = bind_mt
        end
    end
    -- process keymaps declared by integrations
    for _, integration in ipairs(qvim_integrations()) do
        local integration_keymaps = qvim.integrations[integration].keymaps

        if integration_keymaps then
            if fn_t.length(integration_keymaps) > 0 then
                for lhs, declaration in pairs(integration_keymaps) do
                    if type(lhs) == "string" then
                        -- binding
                        Log:debug(string.format("Adding keymaps for '%s' to '%s'.", integration, getmetatable(keymaps)))
                        keymaps[lhs] = declaration
                        Log:warn(string.format("LHS = '%s' Binding:: '%s'", lhs, tostring(keymaps[lhs])))
                    elseif type(lhs) == "number" and util.has_simple_group_structure(declaration) then
                        -- group
                        Log:debug(string.format("Adding keymap group indicated by '%s' for '%s' to '%s'.",
                            declaration.key_group, integration,
                            getmetatable(keymap_groups)))
                        keymap_groups[#keymaps + 1] = declaration
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

    -- fetch keymaps for whichkey or normal layout when whichkey is not available
    -- translate the groups into whichkey format or in workaround when whichkey is not available
    -- register the keymaps or parse them in whichkey

    print("keymap_modes:", vim.inspect(keymap_modes))
    Log:info("Keymaps were fetched.")
end

return M
