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

local descripted_keymaps = meta.get_new_descriptor_mt()



---Initializes the `qvim.keymaps` variable with from every configured integration.
---Additionally a global variable `qvim_which_key_is_available` will be registered that
---that will determine the behavior of how keymaps are going to be registered.
function M:init()
    if in_headless_mode() then
        Log:info("Headless mode detected. Not loading any keymappings.")
        return
    end

    qvim.keymaps = {}
    qvim.keymaps["keymaps"] = {}
    qvim.keymaps["keymap_groups"] = {}

    for vim_mode, bindings in pairs(keymap_defaults.get_defaults()) do
        local translated_mode = keymap_mode_adapters[vim_mode]
        for lhs, opts in pairs(bindings) do
            opts["mode"] = translated_mode
            local keymaps = meta.get_new_keymap_mt()
            keymaps[lhs] = opts
            -- TODO: add keymap properly
            descripted_keymaps[tostring(keymaps[lhs])] = keymaps
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
                        local keymaps = meta.get_new_keymap_mt()
                        keymaps[lhs] = declaration
                        descripted_keymaps[tostring(keymaps[lhs])] = keymaps
                        Log:debug(string.format("Keybind '%s' '%s' added.", lhs, tostring(keymaps[lhs])))
                    elseif type(lhs) == "number" and util.has_simple_group_structure(declaration) then
                        -- group
                        local keymap_groups = meta.get_new_group_mt()
                        local current_index = #keymap_groups + 1
                        print("declaration", vim.inspect(dec))
                        keymap_groups[current_index] = declaration
                        print("current group: ", vim.inspect(keymap_groups[current_index]))
                        descripted_keymaps[tostring(keymap_groups[current_index])] = keymap_groups[current_index]
                        Log:debug(string.format("Group '%s' added.", tostring(keymap_groups[current_index])))
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


    print("keymaps: ", vim.inspect(descripted_keymaps))

    Log:info("Keymaps were fetched.")
end

return M
