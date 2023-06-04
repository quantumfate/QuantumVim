---Utility functions for keymap meta
---@class util
local util = {}

local Log = require("qvim.integrations.log")
local fn_t = require("qvim.utils.fn_t")
local binding_group_constants = require("qvim.keymaps.constants").binding_group_constants
local constants = require("qvim.keymaps.constants")
local shared_util = require("qvim.keymaps.util")
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
path_descriptor = "", "", "", "", ""

local util_require = require

---Init function to parse modules to avoid circular dependencies.
---@param _binding string the binding module path
---@param _group string the group module path
---@param _keymap string the keymap module path
---@param _descriptor string the descriptor module path
---@return util, binding, group, keymap, descriptor
function util.init(_binding, _group, _keymap, _descriptor)
    -- initialize the strings
    path_binding = _binding
    path_group = _group
    path_keymap = _keymap
    path_descriptor = _descriptor

    -- require modules once
    binding = util_require(path_binding)
    group = util_require(path_group)
    keymap = util_require(path_keymap)
    descriptor = util_require(path_descriptor)

    default = require("qvim.keymaps.default")
    initialized = true
    return util, binding, group, keymap, descriptor
end

---Checks if the module has been initialized
local function check_initialized()
    if not initialized then
        error("The util module must be initialized with util.init(...) before use.")
    end
end

local util_get_proxy_metatable = function(init, metatable)
    return setmetatable(init, metatable)
end

---Returns a proxy table with the metatable `binding.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_binding_proxy_mt = function(init)
    return util_get_proxy_metatable(init or {}, binding.mt)
end

---Returns a proxy table with the metatable `group.member_mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_group_member_proxy_mt = function(init)
    return util_get_proxy_metatable(init or {}, group.member_mt)
end


---Returns a proxy table with the metatable `keymap.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_keymap_proxy_mt = function(init)
    return util_get_proxy_metatable(init or {}, keymap.mt)
end

---Returns a proxy table with the metatable `descriptor.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_descriptor_proxy_mt = function(init)
    return util_get_proxy_metatable(init or {}, descriptor.mt)
end

---Returns a proxy table with the metatable `group.mt`
---@param init any|nil the table that should inherit from the metatable
---@return table
util.get_new_group_proxy_mt = function(init)
    return util_get_proxy_metatable(init or {}, group.mt)
end

---Helper function to determine the `metatable` of a given `table`.
---@param table any
---@param metatable any
---@return boolean is_metatable true if a given `table` has a meta field `metatable`, false otherwise.
local function already_meta_table(table, metatable)
    return getmetatable(table) == metatable
end

---Takes a binding an mormalizes it.
---@param bind table
---@return table|nil
function util.normalize_keymap(lhs, bind)
    if getmetatable(bind) ~= nil then
        shared_util.warn(string.format(
            "Processing positional arguments for a binding \n'%s'\n corresponding to '%s' may have unexpected results because it's a metatable.",
            vim.inspect(bind), lhs))
    end
    -- If the keymap is already in the normalized format, return it as is
    if bind[constants.neovim_options_constants.rhs] and bind[constants.neovim_options_constants.desc] then
        return bind
    end

    -- If the keymap is in the positional format, convert it to the normalized format
    if type(bind) == "table" and #bind <= 2 then
        -- Check if it's a mixed format
        if bind[constants.neovim_options_constants.rhs] then
            bind[constants.neovim_options_constants.desc] = bind[1]
            bind[1] = nil
        elseif bind[constants.neovim_options_constants.desc] then
            bind[constants.neovim_options_constants.rhs] = bind[1]
            bind[1]                                      = nil
        else
            -- It's the purely positional format
            bind[constants.neovim_options_constants.rhs]  = bind[constants.rhs_index]
            bind[constants.neovim_options_constants.desc] = bind[constants.desc_index]
            bind[constants.rhs_index]                     = nil
            bind[constants.desc_index]                    = nil
        end
        return bind
    end

    error(string.format("The bindnig for '%s' is in an invalid format.", lhs))
end

---Adds a group of keymaps with the following attributes unless `other` already has the necessary meta information:
---- `name` the name representing the group
---- `binding_group` the `key` to be pressed to activate the `bindings`
---- `prefix` the `key` to be pressed before a `binding_group` can be chosen
---- `bindings` the table of individual keymaps, individual options have precedence over individual options in `options`
---- `options` options that should reflect on `bindings`
---
---When the plugin whichkey is available:
---- `options` global options for whichkey bindings
---@param t table
---@param idx integer|string
---@param other table|nil either a keymap.opts_collection_mt or a keymap.opts_mt
---@return table|nil _group the processed group or nil
util.process_group_memeber_mt = function(t, idx, other)
    if already_meta_table(other, group.member_mt) then
        return other
    end

    if type(idx) == "number" or type(idx) == "string" then
        if type(other) == "table" then
            if other[binding_group_constants.key_binding_group]
                and type(other[binding_group_constants.key_binding_group]) == "string"
                and other[binding_group_constants.key_binding_group] ~= "" then
                local _group = util.get_new_group_member_proxy_mt()
                for key, value in pairs(other) do
                    _group[key] = value
                end
                return _group
            else
                Log:error(string.format(
                    "A group '%s' must have keygroup indicator. The key to be pressed to activate a group. But was '%s'.",
                    getmetatable(t), type(other[binding_group_constants.key_binding_group])))
            end
        else
            Log:debug(string.format("A group '%s' needs to be a table but was '%s'", t, type(other)))
        end
    else
        Log:error(string.format("A group's '%s' index must be a number or a string but was '%s'", t, type(idx)))
    end
end

---Takes a table where the key and value pairs are `binding.mt` tables.
---Processes them into a `keymap.mt` calling the necessary `__newindex` methods.
---The process is skipped when `other` already has the necessary meta information.
---Options explicitly set in a binding have precedence over options parsed by a
---given `options`.
---@param k string
---@param other table
---@param options table|nil a table of options that should be applied to bindings
---@return table
util.process_keymap_mt = function(k, other, options)
    if already_meta_table(other, keymap.mt) then
        return other
    end

    local keymaps = util.get_new_keymap_proxy_mt()

    if type(other) == "table" then
        if fn_t.length(other) > 0 then
            for lhs, _binding in pairs(other) do
                local new_binding = util.set_binding_mt(lhs, _binding, options)
                keymaps[lhs] = new_binding
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

---Ensures that the given table `_binding` is a table of `binding.mt` with accepted options.
---The key, value pair assigment for the returned table will be delegated to the `__newindex`
---method of `binding.mt`. Skips the process when a given `_binding` already has the necessary
---meta information.
---@param _lhs string the left hand side `_binding` will be associated with
---@param _binding table the binding
---@param _options table|nil manually set options - options in `_binding` have precedence
---@return table table the binding with accepted options with the metatable `binding.mt`
util.set_binding_mt = function(_lhs, _binding, _options)
    if already_meta_table(_binding, binding.mt) then
        return _binding
    end

    util.normalize_keymap(_lhs, _binding)
    local new_options = setmetatable(_options or {}, { __index = default.binding_opts })
    local new_binding = util.get_new_binding_proxy_mt(_binding)

    for opt, _ in shared_util.pairs_on_proxy(default.valid_binding_opts) do
        if rawget(new_binding, opt) == nil then
            if rawget(new_options, opt) then
                new_binding[opt] = new_options[opt]
            else
                new_binding[opt] = default.binding_opts[opt]
            end
        end
    end
    if fn_t.length(new_binding) == 0 then
        Log:warn(string.format(
            "The table with the associated left hand side '%s' is empty because no accepted options were parsed as keys.",
            _lhs))
    end
    return new_binding
end

return util
