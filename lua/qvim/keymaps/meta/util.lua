---Utility functions for keymap meta
---@class util
local util = {}

local Log = require("qvim.integrations.log")
local fn_t = require("qvim.utils.fn_t")

local initialized = false

--[[
   Modules
]]
local
---@class binding
binding,
---@class group
group,
---@class keymap
keymap,
---@class default
default,
---@class mode
mode,
---@class descriptor
descriptor = nil, nil, nil, nil, nil, nil

--[[
    Require paths
]]
local
---@class string
path_binding,
---@class string
path_group,
---@class string
path_keymap,
---@class string
path_default,
---@class string
path_mode,
---@class string
path_descriptor = "", "", "", "", "", ""

local util_require = require

---Init function to parse modules to avoid circular dependencies.
---@param _binding string the binding module path
---@param _group string the group module path
---@param _keymap string the keymap module path
---@param _mode string the mode module path
---@param _descriptor string the descriptor module path
---@return util, binding, group, keymap, mode, descriptor
function util.init(_binding, _group, _keymap, _mode, _descriptor)
    -- initialize the strings
    path_binding = _binding
    path_group = _group
    path_keymap = _keymap
    path_mode = _mode
    path_descriptor = _descriptor

    -- require modules once
    binding = util_require(path_binding)
    group = util_require(path_group)
    keymap = util_require(path_keymap)
    mode = util_require(path_mode)
    descriptor = util_require(path_descriptor)

    default = require("qvim.keymaps.default")
    initialized = true
    return util, binding, group, keymap, mode, descriptor
end

---Checks if the module has been initialized
local function check_initialized()
    if not initialized then
        error("The util module must be initialized with util.init(...) before use.")
    end
end

local util_get_metatable = function(init, metatable)
    return getmetatable(setmetatable(init, metatable))
end


---Returns a table with the metatable `binding.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_binding_mt = function(init)
    return util_get_metatable(init or {}, binding.mt)
end

---Returns a table with the metatable `group.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_group_mt = function(init)
    return util_get_metatable(init or {}, group.mt)
end

---Returns a table with the metatable `group.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_group_member_mt = function(init)
    return util_get_metatable(init or {}, group.member_mt)
end


---Returns a table with the metatable `keymap.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_keymap_mt = function(init)
    return util_get_metatable(init or {}, keymap.mt)
end

---Returns a table with the metatable `keymap.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_mode_mt = function(init)
    return util_get_metatable(init or {}, mode.mt)
end

---Returns a table with the metatable `descriptor.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_descriptor_mt = function(init)
    return util_get_metatable(init or {}, descriptor.mt)
end

---Ensures that a given table has the default options for keymaps as well as valid parsed options.
---@param _other table
---@return table table table with the metatable `binding.mt`.
util.retrieve_opts_mt = function(_other)
    local opts = default.keymap_group_opts
    for opt, value in pairs(_other) do
        if default.valid_keymap_opts[opt] then
            opts[opt] = value
        end
    end
    return setmetatable(opts, binding.mt)
end

---Returns and existing value or nil
---@param t table
---@param idx string|number
---@return table|nil
util.get_value_or_defaults = function(t, idx)
    local val = nil
    if t[idx] then
        val = t[idx]
    end
    Log:debug(string.format("A keymap with the index '%s' was idexed from the keymap group '%s'", idx, t))
    return val
end

---Checks if a given table `_other` is present in `_this`. The util module
---must be initialized with `util.init(...)` before this function can be used.
---@param _this table `keymap.opts_collection_mt` set as a metatable.
---@param _other table `keymap.opts_mt` set as a metatable.
---@return boolean
util.opts_mt_is_duplicate = function(_this, _other)
    check_initialized()
    local is_duplicate = false
    if getmetatable(_this) == group.mt and getmetatable(_other) == binding.mt then
        for _, pre_value in ipairs(_this) do
            if pre_value == _other then
                is_duplicate = true
            end
        end
    end
    return is_duplicate
end

---Ensures that the given table `_binding` is a table of `binding.mt` with accepted options.
---The key, value pair assigment for the returned table will be delegated to the `__newindex`
---method of `binding.mt`. Skips the process when a given `_binding` already has the necessary
---meta information.
---@param _lhs string the left hand side `_binding` will be associated with
---@param _binding table the binding
---@param _options table|nil manually set options - options in `_binding` have precedence
---@return table table the binding with accepted options with the metatable `binding.mt`
util.set_binding_mt = function(_lhs, _binding, _options)
    if getmetatable(_binding) == binding.mt then
        return _binding
    end
    local table = {}
    _options = setmetatable(_options or {}, { __index = default.keymap_opts })
    table = util.get_new_binding_mt(table)
    if fn_t.length(_binding) > 0 then
        for key, _ in pairs(default.keymap_opts) do
            if _binding[key] == nil then
                table[key] = _options[key]
            else
                table[key] = _binding[key]
            end
        end
    end
    if fn_t.length(table) == 0 then
        Log:warn(string.format(
            "The table with the associated left hand side '%s' is empty because no accepted options were parsed as keys.",
            _lhs))
    end
    return table
end


---Processes two mappings considering neovims unique option. If no mapping is unique
---the `_new` mapping will replace the `_old`. The util module
---must be initialized with `util.init(...)` before this function can be used.
---@param _old any
---@param _new any
---@return table|nil
util.truly_unique_mapping = function(_old, _new)
    check_initialized()
    if getmetatable(_old) == binding.mt and getmetatable(_new) == binding.mt then
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
                return _new
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
---@param idx string
---@return table|nil result the calculated table with proper `__metatable` field
util.add_meta_wrapper = function(t1, t2, idx)
    if type(t1) == "table" and type(t2) == "table" and getmetatable(t1) == getmetatable(t2) then
        local result = t1 + t2
        assert(type(result) == "table",
            string.format(
                "The expected addition result on a metatable of the same kind must be a table. Binding affected: %s", idx))
        return result
    end
    return nil
end


---Takes a table where the key and value pairs are `binding.mt` tables.
---Processes them into a `keymap.mt` calling the necessary `__newindex` methods.
---The process is skipped when `other` already has the necessary meta information.
---@param k string
---@param other table
---@param predicate function|nil parse a predicate that compares `k` with `_binding`
---@return table
util.process_keymap_mt = function(k, other, predicate)
    -- TODO: the keymap
    if getmetatable(other) == keymap.mt then
        return other
    end
    local keymaps = util.get_new_keymap_mt()

    if type(other) == "table" then
        if fn_t.length(other) > 0 then
            local use_predicate = type(predicate) == "function"
            if other.filter and other.condition and not use_predicate then
                -- determine who should handle the predicate condition
                Log:warn("Keymap uses internal predicate")
                rawset(keymaps, "filter", other.filter)
                rawset(keymaps, "condition", other.condition)
            end

            for lhs, _binding in pairs(other) do
                if not lhs == "filter" and not lhs == "condition" then
                    if use_predicate then
                        if predicate and predicate(k, _binding) then
                            Log:warn(string.format("Applying predicate on '%s'", lhs))
                            keymaps[lhs] = util.set_binding_mt(lhs, _binding)
                        end
                    else
                        Log:warn(string.format("Adding '%s'", lhs))
                        keymaps[lhs] = util.set_binding_mt(lhs, _binding)
                    end
                end
            end
        else
            return keymaps
        end
    else
        Log:debug(string.format(
            "The value corresponding to '%s' must be a table but was '%s'. Value is now an empty table with meta information.",
            k, type(other)))
    end
    return keymaps
end

---Adds a group of keymaps with the following attributes unless `other` already has the necessary meta information:
---- `name` the name representing the group
---- `key_group` the `key` to be pressed to activate the `bindings`
---- `prefix` the `key` to be pressed before a `key_group` can be chosen
---- `bindings` the table of individual keymaps, individual options have precedence over individual options in `options`
---- `options` options that should reflect on `bindings`
---
---When the plugin whichkey is available:
---- `options` global options for whichkey bindings
---@param t table
---@param idx integer
---@param other table either a keymap.opts_collection_mt or a keymap.opts_mt
util.process_group_mt = function(t, idx, other)
    if getmetatable(other) == group.mt then
        return other
    end
    if type(idx) == "number" then
        if type(other) == "table" then
            if other.key_group and type(other.key_group) == "string" then
                local _group = util.get_new_group_mt()
                for key, value in pairs(other) do
                    _group[key] = value
                end
                return _group
            else
                Log:error(string.format(
                    "A group '%s' must have keygroup indicator. The key to be pressed to activate a group. But was '%s'.",
                    getmetatable(t), type(other.key_group)))
            end
        else
            Log:debug(string.format("A group '%s' needs to be a table but was '%s'", getmetatable(t), type(other)))
        end
    else
        Log:error(string.format("A group's '%s' index must be a number but was '%s'", getmetatable(t), type(idx)))
    end
end

---Create a descriptor metatable. If a given `_descriptor` is a string the `_descriptor` will
---be initialized as a first table entry with `nil` as a value. More flexibily can be enabled when
---`_descriptor` is parsed as a table
---@param _key any
---@param _descriptor string|table
---@return table
util.process_descriptor_mt = function(_key, _descriptor)
    if type(_descriptor) == "table" and getmetatable(_descriptor) == descriptor.mt then
        Log:warn(string.format("Returning bullshit '%s'", _descriptor))
        return _descriptor
    end
    local table = nil
    Log:debug(string.format("Processing descriptor metatable for '%s'", _key))
    if type(_descriptor) == "string" then
        table = util.get_new_descriptor_mt({ [_descriptor] = nil })
    elseif type(_descriptor) == "table" then
        table = util.get_new_descriptor_mt(_descriptor)
    else
        Log:error(string.format(
            "Only strings and tables are accepted when processing descriptor metatables. But '%s' was found.",
            type(_descriptor)))
    end
    return table
end
return util
