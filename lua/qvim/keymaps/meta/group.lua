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
