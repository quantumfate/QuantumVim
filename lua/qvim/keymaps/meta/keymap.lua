---@class keymap
local keymap = {}
local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local fn_t = require("qvim.utils.fn_t")
--local fn = require("qvim.utils.fn")

---Ensures that a given table has the default options for keymaps as well as valid parsed options
---@param _other table
---@return table metatable the keymap.opts_mt metatable
local function retrieve_opts_mt(_other)
    local opts = setmetatable({}, default.keymap_opts)
    for opt, value in pairs(_other) do
        if default.valid_keymap_opts[opt] then
            opts[opt] = value
        end
    end
    return setmetatable(opts, { __index = keymap.opts_mt })
end

---Ensures that a collection of table has the default optoins as well as parsed options
---@param _other table
---@return table metatable the keymap.opts_collection_mt metatable
local function retrieve_opts_collection_mt(_other)
    local opts_collection = setmetatable({}, { __index = keymap.opts_collection_mt })
    for _, binding in pairs(_other) do
        table.insert(opts_collection, retrieve_opts_mt(binding))
    end
    return opts_collection
end
---Returns a specific metatable
---@param _other table|any
---@return table|nil metatable keymap.opts_mt or keymap.opts_collection_mt or nil
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

---Checks if a given table _other is present in _this
---@param _this table metatable for keymap.opts_collection_mt
---@param _other table metatable for keymap.other_mt
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

---Merges two metatables of keymap.opts_collection_mt
---@param _this table keymap.opts_collection_mt
---@param _other table keymap.opts_collection_mt
---@return table result empty when given tables are not type of the correct metatable  otherwise a unique merge
local function merge_opts_collection_mt(_this, _other)
    local result = setmetatable({}, keymap.opts_collection_mt)
    if getmetatable(_this) == keymap.opts_collection_mt and getmetatable(_other) == keymap.opts_collection_mt then
        for _, value in ipairs(_other) do
            if not opts_mt_is_duplicate(_this, value) then
                fn_t.rawset_debug(result, #result, value, "options collection")
            end
        end
    end
    return result
end

---Merges a keymap.opts_collection_mt with a keymap.opts_mt
---@param _this table keymap.opts_collection_mt
---@param _other table keymap.opts_mt
---@return table result empty when given tables are not type of the correct metatable otherwise merged result or the origin _this table
local function merge_opts_collection_mt_with_opts_mt(_this, _other)
    local result = setmetatable({}, keymap.opts_collection_mt)
    local is_opts_collection = getmetatable(_this) == keymap.opts_collection_mt
    if is_opts_collection and getmetatable(_other) == keymap.opts_mt then
        if not opts_mt_is_duplicate(_this, _other) then
            fn_t.rawset_debug(result, #result, _other, "opts collection")
        end
    end
    return is_opts_collection and _this or result
end

--- The meta table that maps an index function to retrieve
--- the default keymap options. It implements an __eq meta method
--- to allow comparing of right hand side bindings.
keymap.opts_mt = {
    ---Merges default options with user defined options stored in the table
    ---@param t table the indexed table
    ---@param opt string
    ---@return table|nil
    __index = function(t, opt)
        if default.valid_keymap_opts[opt] then
            local opts = setmetatable(t, default.keymap_opts)
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
    __eq = function(t1, t2)
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
    __add = function(t1, t2)
        -- TODO: figure out how this should be merged
    end
}

keymap.opts_collection_mt = setmetatable({}, {
    __index = function(t, idx)
        -- TODO: this is just wrong
        local opts_mt_bindings = setmetatable({}, keymap.opts_collection_mt)
        for _, value in ipairs(t) do
            if getmetatable(value) == keymap.opts_mt then
                table.insert(opts_mt_bindings, value)
            end
        end
        return opts_mt_bindings
    end,
    __newindex = function(t, idx, other)
        local other_mt = define_other_table(other)
        if t[idx] then
            if other_mt then
                local pre_mt = getmetatable(t[idx])
                if not opts_mt_is_duplicate(pre_mt, other_mt) then
                    t = merge_opts_collection_mt_with_opts_mt(pre_mt, other_mt)
                    return
                end
                t = merge_opts_collection_mt(pre_mt, other_mt)
            end
        else
            fn_t.rawset_debug(t, idx, other_mt, "options collection")
        end
    end,
    __add = function(t1, t2)
        return merge_opts_collection_mt(t1, t2)
    end
})
keymap.mt = setmetatable({}, {
    __index = function(t, lhs)
        if getmetatable(t) == keymap.opts_mt then
            return t[lhs]
        elseif getmetatable[t] == keymap.opts_collection_mt then
            return t.__index(t)
        end
    end,
    __newindex = function(t, lhs, other)
        if type(lhs) == "string" and type(other) == "table" then
            local post_t = define_other_table(other)
            local post_mt = getmetatable(post_t)
            if t[lhs] then
                local current_mt = getmetatable(t[lhs])
                if (current_mt == keymap.opts_mt and post_mt == keymap.opts_mt) or
                    (current_mt == keymap.opts_collection_mt and post_mt == keymap.opts_collection_mt) then
                    t[lhs] = t[lhs] + post_t
                elseif current_mt == keymap.opts_mt and post_mt == keymap.opts_collection_mt then
                    t[lhs] = merge_opts_collection_mt_with_opts_mt(post_mt, current_mt)
                elseif current_mt == keymap.opts_collection_mt and post_mt == keymap.opts_mt then
                    t[lhs] = merge_opts_collection_mt_with_opts_mt(current_mt, post_mt)
                else
                    -- TODO: something went wrong | post_mt == nil
                end
            else
                fn_t.rawset_debug(t, lhs, post_t, "keymap")
            end
        end
    end
})


return keymap
