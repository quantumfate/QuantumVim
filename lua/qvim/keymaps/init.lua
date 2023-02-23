local M = {}
local functions = require "qvim.utils.functions"
local Log = require "qvim.integrations.log"
if functions.in_headless_mode() then
    Log:info("Headless Mode: Not setting any keymaps.")
    return
end

---Translates a mode adapter
---@param mode string the short written or long written mode
---@return boolean success success on translation
---@return string? mode the translated mode
function _G.translate_mode_adapter(mode)
    if keymap_mode_adapters[mode] then
        return true, inverted_keymap_mode_adapters[keymap_mode_adapters[mode]]
    elseif inverted_keymap_mode_adapters[mode] then
        return true, keymap_mode_adapters[inverted_keymap_mode_adapters[mode]]
    else
        Log:debug("Failed to translate mode! Unsupported mode: '" .. mode)
        return false
    end
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
