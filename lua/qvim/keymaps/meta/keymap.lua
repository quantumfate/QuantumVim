--- yet (another) innovative keymap enabling setter
---@class keymap
local keymap = {}
local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
local fn = require("qvim.utils.fn")

---Ensures that a given table has the default options for keymaps as well as valid parsed options.
---@param _other table
---@return table table table with the metatable `keymap.opts_mt`.
local function retrieve_opts_mt(_other)
    local opts = setmetatable({}, default.keymap_opts)
    for opt, value in pairs(_other) do
        if default.valid_keymap_opts[opt] then
            opts[opt] = value
        end
    end
    return setmetatable(opts, { __index = keymap.opts_mt })
end

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

---Checks if a given table `_other` is present in `_this`.
---@param _this table `keymap.opts_collection_mt` set as a metatable.
---@param _other table `keymap.opts_mt` set as a metatable.
---@return boolean
local function opts_mt_is_duplicate(_this, _other)
    local is_duplicate = false
    if getmetatable(_this) == keymap.opts_collection_mt and getmetatable(_other) == keymap.opts_mt then
        for _, pre_value in ipairs(_this) do
            if pre_value == _other then
                is_duplicate = true
            end
        end
    end
    return is_duplicate
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

---Processes two mappings considering neovims unique option.
---@param _old any
---@param _new any
---@return table|nil
local function truly_unique_mapping(_old, _new)
    if getmetatable(_old) == keymap.opts_mt and getmetatable(_new) == keymap.opts_mt then
        if _old == _new then
            return _old
        else
            if _old.unique and not _new.unique then
                return _old
            elseif not _old.unique and _new.unique then
                return _new
            elseif _old.unique and _new.unique then
                return _new
            else
                return setmetatable({ _old, _new }, keymap.opts_collection_mt)
            end
        end
    else
        Log:error("An invalid table was parsed to the nvim specific options handler")
        return nil
    end
end

---A wrapper function to process the addition on metatables of the same kind.
---@param t1 table
---@param t2 table
---@param lhs string
---@return meta|nil metatable the calculated meta table with proper metatable field
local function add_meta_wrapper(t1, t2, lhs)
    if type(t1) == "table" and type(t2) == "table" and getmetatable(t1) == getmetatable(t2) then
        local result = t1 + t2
        assert(type(result) == "table",
            string.format(
                "The expected addition result on a metatable of the same kind must be a table. Binding affected: %s", lhs))
        return setmetatable(result, getmetatable(result))
    end
    return nil
end

--- The meta table that maps an index function to retrieve
--- the default keymap options. It implements an `__eq` meta method
--- to allow comparing of right hand side bindings.
keymap.opts_mt = {
    ---Merges default options with user defined options stored in the table
    ---@param t table the indexed table
    ---@param opt string
    ---@return boolean|string|integer|function|nil
    __index = function(t, opt)
        if default.valid_keymap_opts[opt] then
            local pre_t = t
            setmetatable(pre_t, nil)
            local opts = setmetatable(pre_t, { __index = default.keymap_opts })
            return opts[opt]
        else
            Log:error(string.format("Invalid option '%s' for keymap.", opt))
            return nil
        end
    end,
    ---Set an value for a supported option and fill with defaults
    ---@param t table
    ---@param opt string
    ---@param setting function|boolean|string|integer|nil
    __newindex = function(t, opt, setting)
        if default.valid_keymap_opts[opt] and type(setting) == type(default.keymap_opts[opt]) or nil then
            local opts = setmetatable(t, default.keymap_opts)
            opts[opt] = setting
            t = opts
        else
            Log:error(string.format("Invalid option '%s' for keymap.", opt))
        end
    end,
    ---Checks for equality in keymappings. Two keymaps with a different buffer value are not considered equal.
    ---@param t1 table
    ---@param t2 table
    ---@return boolean
    __eq = function(t1, t2)
        if t1.buffer and t2.buffer and t1.buffer ~= t2.buffer then
            return false
        end
        local function is_function(v) return type(v) == "function" end
        for k, v in pairs(t1) do
            if not is_function(v) and t2[k] ~= v then
                return false
            end
        end
        for k, v in pairs(t2) do
            if not is_function(v) and t1[k] ~= v then
                return false
            end
        end
        return true
    end,
    ---An add operation on two mappings of opts_mt returns the unique mapping or both mappings when neither of them are unique.
    ---This may convert the meta table into opts_collection_mt when none of the parsed mappings are unique.
    ---@param t1 any
    ---@param t2 any
    ---@return table|nil
    __add = function(t1, t2)
        return truly_unique_mapping(t1, t2)
    end
}

---Returns and existing value or a meta table with an `__index` that points to `keymap.opts_mt`
---@param t table
---@param idx string|number
---@return table
local function get_value_or_defaults(t, idx)
    local val = nil
    if t[idx] then
        val = t[idx]
    else
        val = setmetatable({}, { __index = keymap.opts_mt })
    end
    Log:debug(string.format("A keymap with the index '%s' was idexed from the keymap group '%s'", idx, t))
    return val
end
keymap.opts_collection_mt = setmetatable({}, {
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
    end
})
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
        if type(lhs) == "string" and type(other) == "table" then
            local post_t = define_other_table(other)
            local post_mt = getmetatable(post_t)
            if t[lhs] and post_t then
                -- add bindings
                local current_mt = getmetatable(t[lhs])
                local current_t = t[lhs]
                setmetatable(t[lhs], nil) -- clear the metatable to eventually convert
                t[lhs] = nil
                if (current_mt == keymap.opts_mt and post_mt == keymap.opts_mt) or
                    (current_mt == keymap.opts_collection_mt and post_mt == keymap.opts_collection_mt) then
                    t[lhs] = add_meta_wrapper(current_t, post_t, lhs)                 -- calculate merge
                elseif current_mt == keymap.opts_mt and post_mt == keymap.opts_collection_mt then
                    t[lhs] = merge_opts_collection_mt_with_opts_mt(post_t, current_t) -- append to the end
                elseif current_mt == keymap.opts_collection_mt and post_mt == keymap.opts_mt then
                    t[lhs] = merge_opts_collection_mt_with_opts_mt(current_t, post_t) -- append to the end
                end
                return
            end
            -- set a new binding
            fn_t.rawset_debug(t, lhs, post_t, "keymap")
        end
    end
})


return keymap
