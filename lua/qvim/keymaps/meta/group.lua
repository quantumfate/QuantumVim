---@class group
local group = {}

local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")
local constants = require("qvim.keymaps.constants")
local fn = require("qvim.utils.fn")
local fn_t = require("qvim.utils.fn_t")

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
            if group_member.name == const.key_binding_group == group_member.binding_group == nil then
                Log:error("A group member must have a key group key")
                return
            end
            local _group_member = util.get_new_group_member_proxy_mt()
            _group_member[const.key_name] = group_member.name or default.keymap_group.name
            _group_member[const.key_binding_group] = group_member.binding_group
            _group_member[const.key_prefix] = group_member.prefix or default.keymap_group.prefix
            -- the following order matters because we want to apply the options to bindings
            -- where the options for a binding were not explicitly set
            _group_member[const.key_options] = group_member.options or default.keymap_group_opts
            _group_member[const.key_bindings] = group_member.bindings or default.keymap_group.bindings
            rawset(t, idx, _group_member)
        else
            Log:error(string.format(
                "The index of a group member in the group metatable must be a number but was '%s'",
                type(idx)))
        end
    end
}

group.member_mt = {
    __index = function(t, k)
        if type(k) == "string" then
            if k == const.key_bindings or k == const.key_options or rawget(t, k) ~= nil then
                return t[k]
            else
                fn_t.rawget_debug(t, k)
            end
        else
            Log:error(string.format("The key to a value in '%s' must be a string but was '%s'.", getmetatable(t), type(k)))
        end
    end,
    ---Ensures that values in a group have the correct metatable information or at least the defaults
    ---@param t table
    ---@param k string
    ---@param other table
    __newindex = function(t, k, other)
        if type(k) == "string" then
            if k == const.key_bindings and type(other) == "table" then
                fn.shallow_table_copy(rawget(t, "options"))
                local keymaps = util.process_keymap_mt(k, other, fn.shallow_table_copy(rawget(t, "options")))
                rawset(t, k, keymaps)
            elseif const.key_options and type(other) == "table" then
                local options = setmetatable(other or {}, { __index = default.keymap_group_opts })
                rawset(t, k, options)
            else
                if type(other) == "string" then
                    rawset(t, k, other)
                else
                    Log:debug(string.format(
                        "The value of '%s' must be a string but was '%s'. Defaults were applied.", k, type(other)))
                    rawset(t, k, default.keymap_group[k])
                end
            end
        else
            Log:error(string.format("The key to a value in '%s' must be a string but was '%s'.", getmetatable(t), type(k)))
        end
    end,
    ---Returns a human readable representation of a group
    ---@param t table
    __tostring = function(t)
        local base = string.format(
            "%s",
            const.key_binding_group .. "=" .. rawget(t, "binding_group")
        )
        return base
    end

}

return group
