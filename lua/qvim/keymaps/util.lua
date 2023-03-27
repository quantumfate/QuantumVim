---Util for keymap declaration
---@class keymap.util
local util = {}
---Verifies that a given `tbl` is from an accepted structure.
---@param tbl table
---@return boolean
function util.has_simple_group_structure(tbl)
    if type(tbl) ~= 'table' then
        return false
    end

    local keys = { 'name', 'key_group', 'prefix', 'bindings', 'options' }

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

---Verifies that all nested table on the second level are from an accepted structure.
---@param tbl table
---@return boolean
function util.has_nested_group_structure(tbl)
    if type(tbl) ~= 'table' then
        return false
    end

    for _, sub_table in ipairs(tbl) do
        if not util.has_simple_group_structure(sub_table) then
            return false
        end
    end

    return true
end

return util
