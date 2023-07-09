---@class yikes.group
---@field mt table
---@field member_mt table
local group = {}

---@class default
local default = require "qvim.keymaps.default"
local constants = require "qvim.keymaps.constants"
local fn = require "qvim.utils.fn"
local fn_t = require "qvim.utils.fn_t"
local shared_util = require "qvim.keymaps.util"
---@class util
local util = nil

---initializes the group module with the util factory
---@param _util util
---@return group
function group.init(_util)
    util = _util
    return group
end

local const = constants.binding_group_constants

group.mt = {
    __newindex = function(t, idx, group_member)
        if type(idx) == "number" then
            if
                group_member[const.key_binding_group] == nil
                or group_member[const.key_binding_group] == ""
            then
                error "A group member must have a key group key"
            end
            local _group_member = util.get_new_group_member_proxy_mt()
            _group_member[const.key_name] = group_member[const.key_name]
                or default.keymap_group_members[const.key_name]
            _group_member[const.key_binding_group] =
                group_member[const.key_binding_group]
            _group_member[const.key_prefix] = group_member[const.key_prefix]
                or default.keymap_group_members[const.key_prefix]
            -- the following order matters because we want to apply the options to bindings
            -- where the options for a binding were not explicitly set
            _group_member[const.key_options] = group_member[const.key_options]
                or default.keymap_group_opts
            _group_member[const.key_bindings] = group_member[const.key_bindings]
                or default.keymap_group_members[const.key_bindings]
            rawset(t, idx, _group_member)
        else
            error(
                string.format(
                    "The index of a group member in the group metatable must be a number but was '%s'",
                    type(idx)
                )
            )
        end
    end,
}

group.member_mt = {
    __index = function(t, k)
        if type(k) == "string" then
            if
                k == const.key_bindings
                or k == const.key_options
                or rawget(t, k) ~= nil
            then
                return t[k]
            else
                fn_t.rawget_debug(t, k)
            end
        else
            error(
                string.format(
                    "The key to a value in '%s' must be a string but was '%s'.",
                    t,
                    type(k)
                )
            )
        end
    end,
    ---Ensures that values in a group have the correct metatable information or at least the defaults
    ---@param t table
    ---@param k string
    ---@param other table
    __newindex = function(t, k, other)
        if type(k) == "string" then
            if k == const.key_bindings and type(other) == "table" then
                local keymaps = util.process_keymap_mt(
                    k,
                    other,
                    fn.shallow_table_copy(rawget(t, const.key_options))
                )
                rawset(t, k, keymaps)
            elseif const.key_options and type(other) == "table" then
                local options = setmetatable(
                    other or {},
                    { __index = default.keymap_group_opts }
                )
                rawset(t, k, options)
            else
                if type(other) == "string" then
                    rawset(t, k, other)
                else
                    shared_util.warn(
                        string.format(
                            "The value of '%s' must be a string but was '%s'. Defaults were applied.",
                            k,
                            type(other)
                        )
                    )
                    rawset(t, k, default.keymap_group_members[k])
                end
            end
        else
            error(
                string.format(
                    "The key to a group member in '%s' must be a string but was '%s'.",
                    t,
                    type(k)
                )
            )
        end
    end,
    ---Returns a human readable representation of a group
    ---@param t table
    __tostring = function(t)
        local base = string.format(
            "%s",
            const.key_binding_group .. "=" .. rawget(t, const.key_binding_group)
        )
        return base
    end,
}

return group
