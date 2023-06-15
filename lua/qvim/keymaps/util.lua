---Util for keymap declaration
---@class keymap.util
local util = {}
local constants = require("qvim.keymaps.constants")
local Log = require("qvim.integrations.log")

---Calls the pairs method on a proxy table.
---@generic T: table, K, V
---@param t T
---@return fun(table: table<K, V>, index?: K):K, V
---@return T
function util.pairs_on_proxy(t)
    local mt = getmetatable(t)
    if mt then
        if mt.__pairs then
            return mt.__pairs(t)
        end
        if mt.__index then
            return pairs(mt.__index)
        end
        error(
            "Proxy table doesn't implement a 'pairs' metamethod or doesn't have an underlying table specified in the 'index' metamethod that can be called by a 'pairs' function.")
    end
    error("The given table is not a Proxy table.")
end

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
    if tbl['options'] then
        -- this is optional
        if type(tbl['options']) ~= 'table' then
            return false
        end
    end

    return true
end

---Enables logic based on single bindings or group bindings.
---@param descriptor string The descriptor used to identify the type of binding.
---@param binding_call function A callable for binding specific actions.
---@param binding_group_call function A callable for group specific actions.
function util.action_based_on_descriptor(descriptor, binding_call, binding_group_call)
    if string.match(descriptor, constants.binding_prefix_pt) then
        binding_call()
    elseif string.match(descriptor, constants.binding_group_prefix_pt) then
        binding_group_call()
    else
        Log:error(string.format("Unsupported  descriptor '%s'.", descriptor))
    end
end

function util.warn(msg)
    vim.notify(msg, vim.log.levels.WARN, { title = "Yikes" })
end

function util.error(msg)
    vim.notify(msg, vim.log.levels.ERROR, { title = "Yikes" })
end

return util
