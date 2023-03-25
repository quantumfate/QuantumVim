---@class util
---@field retrieve_opts_mt function
---@field get_value_or_defaults function Returns a value by an index
local util = {}
local Log = require("qvim.integrations.log")

local initialized = false
local binding, group, keymap, default = nil, nil, nil, nil

---Init function to parse modules to avoid circular dependencies.
---@param _binding table the required binding module
---@param _group table the required group module
---@param _keymap table the required keymap module
function util.init(_binding, _group, _keymap)
    binding = _binding
    group = _group
    keymap = _keymap
    default = require("qvim.keymaps.default")
    initialized = true
end

---Checks if the module has been initialized
local function check_initialized()
    if not initialized then
        error("The util module must be initialized with util.init(dependencies) before use.")
    end
end
---Ensures that a given table has the default options for keymaps as well as valid parsed options.
---@param _other table
---@return table table table with the metatable `keymap.opts_mt`.
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

---Checks if a given table `_other` is present in `_this`.
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

---Processes two mappings considering neovims unique option. If no mapping is unique
---the `_new` mapping will replace the `_old`.
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

return util
