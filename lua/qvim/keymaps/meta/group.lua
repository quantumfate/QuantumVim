---@class group
local group = {}

group.mt = setmetatable({}, {
    -- TODO: implement group options and set bindings to proper metatable
    ---Returns the value corresponding to a numerical index of `keymap.opts_collection_mt`
    ---@param t table
    ---@param idx string|number
    ---@return table
    __index = function(t, idx)
        return get_value_or_defaults(t, idx)
    end,
    ---Adds a new index based on the meta table of other. Meta tables of the same type
    ---of t will automatically merged into the referenced table.
    ---@param t table
    ---@param idx integer
    ---@param other table either a keymap.opts_collection_mt or a keymap.opts_mt
    __newindex = function(t, idx, other)
        local other_t = define_other_table(other)
        if #t == 0 then
            fn_t.rawset_debug(t, #t + 1, other_t, "options collection")
            return
        end
        if other_t then
            local _idx = nil
            if t[idx] then
                -- if the value exists overwrite it otherwise append to the end
                _idx = idx
            end
            local current_t = t
            if getmetatable(other_t) == keymap.opts_mt then
                t = merge_opts_collection_mt_with_opts_mt(current_t, other_t, _idx)
                return
            end
            t = merge_opts_collection_mt(current_t, other_t, _idx) or current_t
        end
    end,
    ---Combines `t1` and `t2`
    ---@param t1 table
    ---@param t2 table
    ---@return table|nil
    __add = function(t1, t2)
        return merge_opts_collection_mt(t1, t2)
    end,
    __tostring = function(t)
        return
    end
})

return group
