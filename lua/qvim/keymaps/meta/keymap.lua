--- yet (another) innovative keymap enabling setter
---@class keymap
local keymap = {}
local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local fn = require("qvim.utils.fn")
local util = require("qvim.keymaps.meta.util")

---Ensures that a collection of table has the default optoins as well as parsed options.
---@param _other table
---@return table table table with the metatable `keymap.opts_collection_mt`.
local function retrieve_opts_collection_mt(_other)
    local opts_collection = setmetatable({}, { __index = keymap.opts_collection_mt })
    for _, binding in pairs(_other) do
        table.insert(opts_collection, retrieve_opts_mt(binding))
    end
    return opts_collection
end
---Returns a table with a specific metatable.
---@param _other table|any
---@return table|nil metatable table with the metatable `keymap.opts_mt` or `keymap.opts_collection_mt` or `nil`.
local function define_other_table(_other)
    if type(_other) == "table" and type(next(_other)) == "table" then
        return retrieve_opts_collection_mt(_other)
    elseif type(_other) == "table" then
        return retrieve_opts_mt(_other)
    end
    Log:warn(
        "The result of defining a table type is nil because it does not match any of the accepted criteria. Your added keymap will be nil.")
    return nil
end

---Returns the first unique mapping of a table of `opts_collection_mt`
---@param _collection table
---@return table|nil first the first unique mapping or nil
local function truly_unique_mapping_from_collection(_collection)
    local first = nil
    for _, value in ipairs(_collection) do
        if value.unique then
            first = value
        end
        if first and value.unique then
            Log:warn(string.format(
                "Only one unique keymap is allowed but another was found. The keybind with the right hand side '%s' will be discarded.",
                value.rhs))
        end
    end
    return first
end


---Merges two metatables of `keymap.opts_collection_mt`. If a given `_other` has a unique keybind it will be returned and the
---metatable will be updated to `keymap.opts_mt` essentially erasing everything that was defined in `_this`.
---@param _this table `keymap.opts_collection_mt` set as a metatable.
---@param _other table `keymap.opts_collection_mt` set as a metatable.
---@param idx integer|nil
---@return table|nil result either a keymap table with `keymap.opts_mt` set as a metatable or
---a collection of keymap table with `keymap.opts_collection_mt` set as a metatable.
local function merge_opts_collection_mt(_this, _other, idx)
    idx = idx or (#_this + 1)
    local result = nil
    if getmetatable(_this) == keymap.opts_collection_mt and getmetatable(_other) == keymap.opts_collection_mt then
        result = truly_unique_mapping_from_collection(_other)
        if not result then
            result = setmetatable(fn.shallow_table_copy(_this), { keymap.opts_collection_mt })
            for _, value in ipairs(_other) do
                if not opts_mt_is_duplicate(_this, value) then
                    fn_t.rawset_debug(result, idx, value, "options collection")
                end
            end
        end
    end
    return result
end

---Merges a table of `keymap.opts_collection_mt` with a table of `keymap.opts_mt`.
---@param _this table table of `keymap.opts_collection_mt`.
---@param _other table table of `keymap.opts_mt`.
---@param idx integer|nil
---@return table result empty when given tables are not type of the correct metatable otherwise
---merged result or the origin `_this` table. If `_other` is unique this table will be returned.
local function merge_opts_collection_mt_with_opts_mt(_this, _other, idx)
    idx = idx or (#_this + 1)
    local result = _this
    local is_opts_collection = getmetatable(_this) == keymap.opts_collection_mt
    if is_opts_collection and getmetatable(_other) == keymap.opts_mt then
        if _other.unique then
            return _other
        end
        if not opts_mt_is_duplicate(_this, _other) then
            fn_t.rawset_debug(result, idx, _other, "opts collection")
        end
    end
    return is_opts_collection and _this or result
end



--- The metatable for keymaps. A left hand side will be bound to a `keymap.opts_mt` table.
keymap.mt = setmetatable({}, {
    ---Returns the value corresponding to the left hand side of `keymap.mt`
    ---@param t any
    ---@param lhs string
    ---@return table
    __index = function(t, lhs)
        return get_value_or_defaults(t, lhs)
    end,
    ---Creates a new index in `t` and the value can in any case be either `keymap.opts_mt` or `keymap.opts_collection_mt`.
    ---When `getmetatable` of `t[lhs]` and `other` are identical an addition operation will be called on the tables.
    ---In case of different return values of `getmetatable` the appropriate action will be called to merge the existing `t[lhs]`
    ---with `other`.0
    ---@param t any
    ---@param lhs any
    ---@param other any
    __newindex = function(t, lhs, other)
        if type(other) == "table" then
            local post_t = define_other_table(other)
            if t[lhs] and post_t then
                local current_mt = getmetatable(t[lhs])
                local current_t = t[lhs]
                setmetatable(t[lhs], nil) -- clear the metatable to eventually convert
                t[lhs] = nil

                if current_mt == post_t then
                    t[lhs] = add_meta_wrapper(current_t, post_t, lhs) -- calculate merge
                    return
                end
                fn_t.rawset_debug(t, lhs, post_t, "keymap")
            end
        end
    end
})


return keymap
