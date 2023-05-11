---Util for keymap declaration
---@class keymap.util
local util = {}
local constants = require("qvim.keymaps.constants")
local Log = require("qvim.integrations.log")

---Verifies that a given `tbl` is from an accepted structure.
---@param tbl table
---@return boolean
function util.has_simple_group_structure(tbl)
    if type(tbl) ~= 'table' then
        return false
    end

    local keys = {
        constants.binding_group_constants.key_name,
        constants.binding_group_constants.key_binding_group,
        constants.binding_group_constants.key_prefix,
        constants.binding_group_constants.key_bindings,
        constants.binding_group_constants.key_options }

    for tbl_k, _ in pairs(tbl) do
        local has_key = false
        for _, key in ipairs(keys) do
            if tbl_k == key then
                has_key = true
            end
        end
        if not has_key then
            return false
        end
    end

    if type(tbl['bindings']) ~= 'table' then
        return false
    end
    if table['options'] then
        -- this is optional
        if type(tbl['options']) ~= 'table' then
            return false
        end
    end

    return true
end

---comment
---@param descriptor string
---@param binding_call function
---@param binding_group_call function
function util.action_based_on_descriptor(descriptor, binding_call, binding_group_call)
    if string.match(descriptor, constants.binding_prefix_pt) then
        binding_call()
    elseif string.match(descriptor, constants.binding_group_prefix_pt) then
        binding_group_call()
    else
        Log:error(string.format("Unsupported  descriptor '%s'.", descriptor))
    end
end

return util
