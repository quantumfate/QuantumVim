---@class group
local group = {}

local Log = require("qvim.integrations.log")
local default = require("qvim.keymaps.default")

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

group.mt = {
    __newindex = function(t, idx, group_member)
        if type(idx) == "number" then
            if type(idx) == "string" and group_member == "key_group" == group_member.key_group == nil then
                Log:error("A group member must have a key group key")
                return
            end
            local _group_member = util.get_new_group_member_proxy_mt()
            _group_member["name"] = group_member.name or default.keymap_group.name
            _group_member["key_group"] = group_member.key_group
            _group_member["prefix"] = group_member.prefix or default.keymap_group.prefix
            _group_member["bindings"] = group_member.bindings or default.keymap_group.bindings
            _group_member["options"] = group_member.options or default.keymap_group.options
            fn_t.rawset_debug(t, idx, _group_member)
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
            if k == "bindings" or k == "options" or rawget(t, k) ~= nil then
                return t[k]
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
            if k == "bindings" and type(other) == "table" then
                local keymaps = util.process_keymap_mt(k, other)
                fn_t.rawset_debug(t, k, keymaps)
            elseif k == "options" and type(other) == "table" then
                local options = setmetatable(other or {}, { __index = default.keymap_group_opts })
                fn_t.rawset_debug(t, k, options)
            else
                if type(other) == "string" then
                    fn_t.rawset_debug(t, k, other)
                else
                    Log:debug(string.format(
                        "The value of '%s' must be a string but was '%s'. Defaults were applied.", k, type(other)))
                    fn_t.rawset_debug(t, k, default.keymap_group[k])
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
            "key_group=" .. rawget(t, "key_group")
        )
        return base
    end

}

return group
